
function Rename-Many {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '',
    Justification = 'WhatIf IS accessed and passed into PassThru')]
  [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'ReplaceWith')]
  [Alias('remy')]
  param
  (
    # Defining parameter sets for File and Directory, just to ensure both of these switches
    # are mutually exclusive makes the whole parameter set definition exponentially more
    # complex. It's easier just to enforce this with a ValidateScript.
    #
    [Parameter()]
    [ValidateScript( { -not($PSBoundParameters.ContainsKey('Directory')); })]
    [switch]$File,

    [Parameter()]
    [ValidateScript( { -not($PSBoundParameters.ContainsKey('File')); })]
    [switch]$Directory,

    [Parameter(Mandatory, ValueFromPipeline = $true)]
    [System.IO.FileSystemInfo]$underscore,

    [Parameter()]
    [ValidateSet('p', 'a', 'w', '*')]
    [string]$Whole,

    [Parameter(Mandatory, Position = 0)]
    [ValidateCount(1, 2)]
    [ValidateScript( { -not([string]::IsNullOrEmpty($_[0])) })]
    [object[]]$Pattern,

    [Parameter(ParameterSetName = 'MoveToAnchor', Mandatory)]
    [ValidateCount(1, 2)]
    [ValidateScript( { -not([string]::IsNullOrEmpty($_[0])) })]
    [object[]]$Anchor,

    [Parameter(ParameterSetName = 'MoveToAnchor')]
    [ValidateSet('before', 'after')]
    [string]$Relation = 'after',

    [Parameter(ParameterSetName = 'MoveToAnchor')]
    [Parameter(ParameterSetName = 'ReplaceWith')]
    [ValidateCount(1, 2)]
    [ValidateScript( { -not([string]::IsNullOrEmpty($_[0])) })]
    [object[]]$With,

    [Parameter(ParameterSetName = 'ReplaceLiteralWith', Mandatory)]
    [string]$LiteralWith,

    [Parameter()]
    [Alias('x')]
    [string]$Except = [string]::Empty,

    [Parameter()]
    [scriptblock]$Condition = ( { return $true; }),

    # Both Start & End are members of ReplaceWith, but they shouldn't be supplied at
    # the same time. So how to prevent this? Use ValidateScript instead.
    #
    [Parameter(ParameterSetName = 'ReplaceWith')]
    [Parameter(ParameterSetName = 'MoveToStart', Mandatory)]
    [ValidateScript( { -not($PSBoundParameters.ContainsKey('End')); })]
    [switch]$Start,

    [Parameter(ParameterSetName = 'ReplaceWith')]
    [Parameter(ParameterSetName = 'MoveToEnd', Mandatory)]
    [ValidateScript( { -not($PSBoundParameters.ContainsKey('Start')); })]
    [switch]$End,

    [Parameter()]
    [string]$Paste,

    [Parameter()]
    [PSCustomObject]$Context = [PSCustomObject]@{
      Title          = 'Rename'
      ItemMessage    = 'Rename Item'
      SummaryMessage = 'Rename Summary'
    }
  )

  begin {
    Write-Debug ">>> Rename-Many [ParamaterSet: '$($PSCmdlet.ParameterSetName)]' >>>";

    [scriptblock]$doRenameFsItems = {
      param(
        [Parameter(Mandatory)]
        [System.IO.FileSystemInfo]$_underscore,

        [Parameter(Mandatory)]
        [int]$_index,

        [Parameter(Mandatory)]
        [System.Collections.Hashtable]$_passThru,

        [Parameter(Mandatory)]
        [boolean]$_trigger
      )

      [string]$replacePattern = $_passThru['LOOPZ.RN-FOREACH.PATTERN'];
      [boolean]$itemIsDirectory = ($_underscore.Attributes -band
        [System.IO.FileAttributes]::Directory) -eq [System.IO.FileAttributes]::Directory;

      $endAdapter = New-EndAdapter($_underscore);
      [string]$adjustedName = $endAdapter.GetAdjustedName();

      [string]$action = $_passThru['LOOPZ.RN-FOREACH.ACTION'];

      [System.Collections.Hashtable]$actionParameters = @{
        'Value'   = $adjustedName;
        'Pattern' = $replacePattern;
      }

      $actionParameters['PatternOccurrence'] = $_passThru.ContainsKey('LOOPZ.RN-FOREACH.PATTERN-OCC') `
        ? $_passThru['LOOPZ.RN-FOREACH.PATTERN-OCC'] : 'f';

      if ($_passThru.ContainsKey('LOOPZ.RN-FOREACH.WITH')) {
        $actionParameters['With'] = $_passThru['LOOPZ.RN-FOREACH.WITH'];

        if ($_passThru.ContainsKey('LOOPZ.RN-FOREACH.WITH-OCC')) {
          $actionParameters['WithOccurrence'] = $_passThru['LOOPZ.RN-FOREACH.WITH-OCC'];
        }
      }
      elseif ($_passThru.ContainsKey('LOOPZ.RN-FOREACH.LITERAL-WITH')) {
        $actionParameters['LiteralWith'] = $_passThru['LOOPZ.RN-FOREACH.LITERAL-WITH'];
      }

      if ($_passThru.ContainsKey('LOOPZ.RN-FOREACH.PASTE')) {
        $actionParameters['Paste'] = $_passThru['LOOPZ.RN-FOREACH.PASTE']
      }

      if ($action -eq 'Move-Match') {
        if ($_passThru.ContainsKey('LOOPZ.RN-FOREACH.ANCHOR')) {
          $actionParameters['Anchor'] = $_passThru['LOOPZ.RN-FOREACH.ANCHOR'];
        }

        switch ($_passThru['LOOPZ.RN-FOREACH.ANCHOR-TYPE']) {
          'MATCHED-ITEM' {
            if ($_passThru.ContainsKey('LOOPZ.RN-FOREACH.RELATION')) {
              $actionParameters['Relation'] = $_passThru['LOOPZ.RN-FOREACH.RELATION'];
            }
            break;
          }
          'START' {
            $actionParameters['Start'] = $true;
            break;
          }
          'END' {
            $actionParameters['End'] = $true;
            break;
          }
          default {
            throw "doRenameFsItems: encountered Invalid 'LOOPZ.RN-FOREACH.ANCHOR-TYPE': '$AnchorType'";
          }
        }
      } # $action

      [string]$newItemName = & $action @actionParameters;
      $newItemName = $endAdapter.GetNameWithExtension($newItemName);

      [boolean]$trigger = $false;
      [boolean]$affirm = $false;
      [boolean]$whatIf = $_passThru.ContainsKey('WHAT-IF') -and ($_passThru['WHAT-IF']);
      [string[][]]$properties = @();
      [string[][]]$lines = @();

      [string]$parent = $itemIsDirectory ? $_underscore.Parent.FullName : $_underscore.Directory.FullName;
      [boolean]$nameHasChanged = -not($_underscore.Name -ceq $newItemName);
      [string]$newItemFullPath = Join-Path -Path $parent -ChildPath $newItemName;
      [boolean]$clash = (Test-Path -LiteralPath $newItemFullPath) -and $nameHasChanged;
      [string]$fileSystemItemType = $itemIsDirectory ? 'Directory' : 'File';
      
      $_passThru['LOOPZ.WH-FOREACH-DECORATOR.INDENT'] = 39;

      [PSCustomObject]$context = $_passThru['LOOPZ.RN-FOREACH.CONTEXT'];
      [int]$maxItemMessageSize = $_passThru['LOOPZ.RN-FOREACH.MAX-ITEM-MESSAGE-SIZE'];
      [System.Collections.Hashtable]$signals = $_passThru['LOOPZ.SIGNALS'];

      [string]$messageLabel = if ($context.psobject.properties.match('ItemMessage') -and `
          -not([string]::IsNullOrEmpty($Context.ItemMessage))) {

        get-PaddedLabel -Label $($Context.ItemMessage.replace(
            $Loopz.FsItemTypePlaceholder, $fileSystemItemType)) -Width $maxItemMessageSize;
      }
      else {
        'Rename Item';
      }
      [string]$message = Get-FormattedSignal -Name $($itemIsDirectory ? 'DIRECTORY-A' : 'FILE-A') `
        -Signals $signals -CustomLabel $messageLabel -Format '   [{1}] {0}';

      $_passThru['LOOPZ.WH-FOREACH-DECORATOR.MESSAGE'] = $message;
      $_passThru['LOOPZ.WH-FOREACH-DECORATOR.PRODUCT-LABEL'] = $(get-PaddedLabel -Label $(
          $fileSystemItemType) -Width 9);

      if ($nameHasChanged -and -not($clash)) {
        $trigger = $true;
        $product = rename-FsItem -From $_underscore -To $newItemName -WhatIf:$whatIf;
      }
      else {
        $product = $_underscore;
      }

      if ($trigger) {       
        $lines += , @($_passThru['LOOPZ.RN-FOREACH.FROM-LABEL'], $_underscore.Name);
      }
      else {
        if ($clash) {
          Write-Debug "!!! doRenameFsItems; path: '$newItemFullPath' already exists, rename skipped";
          [string[]]$clashSignal = Get-FormattedSignal -Name 'CLASH' `
            -Signals $signals -EmojiAsValue -EmojiOnlyFormat '{0}';
          $properties += , $clashSignal;
        }
        else {
          [string[]]$notActionedSignal = Get-FormattedSignal -Name 'NOT-ACTIONED' `
            -Signals $signals -EmojiAsValue -CustomLabel 'Not Renamed' -EmojiOnlyFormat '{0}';
          $properties += , $notActionedSignal;
        }
      }

      if ($whatIf) {
        [string[]]$whatIfSignal = Get-FormattedSignal -Name 'WHAT-IF' `
          -Signals $signals -EmojiAsValue -EmojiOnlyFormat '{0}';
        $properties += , $whatIfSignal;
      }

      [PSCustomObject]$result = [PSCustomObject]@{
        Product = $product;
      }

      $result | Add-Member -MemberType NoteProperty -Name 'Pairs' -Value (, $properties);

      if ($lines.Length -gt 0) {
        $result | Add-Member -MemberType NoteProperty -Name 'Lines' -Value (, $lines);
      }

      if ($trigger) {
        $result | Add-Member -MemberType NoteProperty -Name 'Trigger' -Value $true;
      }

      [boolean]$differsByCaseOnly = $newItemName.ToLower() -eq $_underscore.Name.ToLower();
      [boolean]$affirm = $trigger -and ($product) -and -not($differsByCaseOnly);
      if ($affirm) {
        $result | Add-Member -MemberType NoteProperty -Name 'Affirm' -Value $true;
      }

      return $result;
    } # doRenameFsItems

    [System.IO.FileSystemInfo[]]$collection = @();
  } # begin

  process {
    Write-Debug "=== Rename-Many [$($underscore.Name)] ===";

    $collection += $underscore;
  }

  end {
    Write-Debug '<<< Rename-Many <<<';

    [boolean]$whatIf = $PSBoundParameters.ContainsKey('WhatIf');
    [PSCustomObject]$containers = @{
      Wide  = [string[][]]@();
      Props = [string[][]]@();
    }

    [string]$adjustedWhole = if ($PSBoundParameters.ContainsKey('Whole')) {
      $Whole.ToLower();
    }
    else {
      [string]::Empty;
    }

    [System.Collections.Hashtable]$signals = Get-Signals;

    # RegEx/Occurrence parameters
    #
    [string]$patternExpression, [string]$patternOccurrence = resolve-PatternOccurrence $Pattern

    Select-SignalContainer -Containers $containers -Name 'PATTERN' `
      -Value $patternExpression -Signals $signals;

    if ($PSBoundParameters.ContainsKey('Anchor')) {
      [string]$anchorExpression, [string]$anchorOccurrence = resolve-PatternOccurrence $Anchor

      Select-SignalContainer -Containers $containers -Name 'REMY.ANCHOR' `
        -Value $anchorExpression -Signals $signals -CustomLabel 'Anchor ({0})' -f $Relation;
    }

    if ($PSBoundParameters.ContainsKey('With')) {
      [string]$withExpression, [string]$withOccurrence = resolve-PatternOccurrence $With;

      Select-SignalContainer -Containers $containers -Name 'WITH' `
        -Value $withExpression -Signals $signals;
    }
    elseif ($PSBoundParameters.ContainsKey('LiteralWith')) {
      if (-not([string]::IsNullOrEmpty($LiteralWith))) {

        Select-SignalContainer -Containers $containers -Name 'LITERAL' `
          -Value $LiteralWith -Signals $signals;
      }
      elseif (-not($PSBoundParameters.ContainsKey('Paste'))) {

        $cutSignal = Get-FormattedSignal -Name 'CUT-A' -Value $patternExpression -Signals $Signals;
        $containers.Props += , $cutSignal;
      }
    }

    [boolean]$doMoveToken = ($PSBoundParameters.ContainsKey('Anchor') -or
      $PSBoundParameters.ContainsKey('Start') -or $PSBoundParameters.ContainsKey('End'));

    [boolean]$doCut = (
      -not($doMoveToken) -and
      -not($PSBoundParameters.ContainsKey('With')) -and
      -not($PSBoundParameters.ContainsKey('LiteralWith')) -and
      -not($PSBoundParameters.ContainsKey('Paste'))
    )

    if ($doCut) {
      $cutSignal = Get-FormattedSignal -Name 'CUT-A' -Value $patternExpression -Signals $Signals;
      $containers.Props += , $cutSignal;
    }

    if ($PSBoundParameters.ContainsKey('Paste')) {
      if (-not([string]::IsNullOrEmpty($Paste))) {
        Select-SignalContainer -Containers $containers -Name 'PASTE-A' `
          -Value $Paste -Signals $signals;
      }
    }

    [scriptblock]$getResult = {
      param($result)

      $result.GetType() -in @([System.IO.FileInfo], [System.IO.DirectoryInfo]) ? $result.Name : $result;
    }

    [System.Text.RegularExpressions.RegEx]$patternRegEx = new-RegularExpression -Expression $patternExpression `
      -WholeWord:$(-not([string]::IsNullOrEmpty($adjustedWhole)) -and ($adjustedWhole -in @('*', 'p')));

    [string]$title = $Context.psobject.properties.match('Title') -and `
      -not([string]::IsNullOrEmpty($Context.Title)) `
      ? $Context.Title : 'Rename';

    [int]$maxItemMessageSize = ($Context.psobject.properties.match('ItemMessage') -and `
        -not([string]::IsNullOrEmpty($Context.ItemMessage))) `
      ? $Context.ItemMessage.replace($Loopz.FsItemTypePlaceholder, 'Directory').Length `
      : $Context.ItemMessage.Length;

    [string]$summaryMessage = $Context.psobject.properties.match('SummaryMessage') -and `
      -not([string]::IsNullOrEmpty($Context.SummaryMessage)) `
      ? $Context.SummaryMessage : 'Rename Summary';

    $summaryMessage = Get-FormattedSignal -Name 'SUMMARY-A' -Signals $signals -CustomLabel $summaryMessage;
    [string]$crumb = Get-FormattedSignal -Name 'CRUMB-A' -Signals $signals -EmojiOnly;

    [System.Collections.Hashtable]$passThru = @{
      'LOOPZ.WH-FOREACH-DECORATOR.BLOCK'       = $doRenameFsItems;
      'LOOPZ.WH-FOREACH-DECORATOR.GET-RESULT'  = $getResult;

      'LOOPZ.HEADER-BLOCK.CRUMB'               = $crumb;
      'LOOPZ.HEADER-BLOCK.LINE'                = $LoopzUI.DashLine;

      'LOOPZ.SUMMARY-BLOCK.LINE'               = $LoopzUI.EqualsLine;
      'LOOPZ.SUMMARY-BLOCK.MESSAGE'            = $summaryMessage;
      'LOOPZ.HEADER-BLOCK.MESSAGE'             = $title;

      'LOOPZ.RN-FOREACH.PATTERN'               = $patternRegEx;
      'LOOPZ.RN-FOREACH.PATTERN-OCC'           = $patternOccurrence;
      'LOOPZ.RN-FOREACH.CONTEXT'               = $Context;
      'LOOPZ.RN-FOREACH.MAX-ITEM-MESSAGE-SIZE' = $maxItemMessageSize;

      'LOOPZ.RN-FOREACH.FROM-LABEL'            = get-PaddedLabel -Label 'From' -Width 9;
      'LOOPZ.SIGNALS'                          = $signals;
    }
    $passThru['LOOPZ.RN-FOREACH.ACTION'] = $doMoveToken ? 'Move-Match' : 'Update-Match';

    if ($PSBoundParameters.ContainsKey('With')) {
      [System.Text.RegularExpressions.RegEx]$withRegEx = new-RegularExpression -Expression $withExpression `
        -WholeWord:$(-not([string]::IsNullOrEmpty($adjustedWhole)) -and ($adjustedWhole -in @('*', 'w')));

      $passThru['LOOPZ.RN-FOREACH.WITH-OCC'] = $withOccurrence;
      $passThru['LOOPZ.RN-FOREACH.WITH'] = $withRegEx;
    }
    elseif ($PSBoundParameters.ContainsKey('LiteralWith')) {
      $passThru['LOOPZ.RN-FOREACH.LITERAL-WITH'] = $LiteralWith;
    }

    if ($PSBoundParameters.ContainsKey('Relation')) {
      $passThru['LOOPZ.RN-FOREACH.RELATION'] = $Relation;
    }

    if ($PSBoundParameters.ContainsKey('Anchor')) {

      [System.Text.RegularExpressions.RegEx]$anchorRegEx = new-RegularExpression -Expression $anchorExpression `
        -WholeWord:$(-not([string]::IsNullOrEmpty($adjustedWhole)) -and ($adjustedWhole -in @('*', 'a')));

      $passThru['LOOPZ.RN-FOREACH.ANCHOR-OCC'] = $anchorOccurrence;
      $passThru['LOOPZ.RN-FOREACH.ANCHOR-TYPE'] = 'MATCHED-ITEM';
      $passThru['LOOPZ.RN-FOREACH.ANCHOR'] = $anchorRegEx;
    }
    elseif ($PSBoundParameters.ContainsKey('Start')) {

      $containers.Props += , @(Get-FormattedSignal -Name 'SWITCH-ON' `
          -Value $patternExpression -Signals $Signals -CustomLabel 'Start');
      $passThru['LOOPZ.RN-FOREACH.ANCHOR-TYPE'] = 'START';
    }
    elseif ($PSBoundParameters.ContainsKey('End')) {

      $containers.Props += , @(Get-FormattedSignal -Name 'SWITCH-ON' `
          -Value $patternExpression -Signals $Signals -CustomLabel 'End');
      $passThru['LOOPZ.RN-FOREACH.ANCHOR-TYPE'] = 'END';
    }

    if ($PSBoundParameters.ContainsKey('Paste')) {
      $passThru['LOOPZ.RN-FOREACH.PASTE'] = $Paste;
    }

    if ($containers.Wide.Length -gt 0) {
      $passThru['LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS'] = $containers.Wide;
    }

    if ($containers.Props.Length -gt 0) {
      $passThru['LOOPZ.SUMMARY-BLOCK.PROPERTIES'] = $containers.Props;
    }

    [scriptblock]$clientCondition = $Condition;

    [scriptblock]$matchesPattern = {
      param(
        [System.IO.FileSystemInfo]$pipelineItem
      )
      # Inside the scope of this script block, $Condition is assigned to Invoke-ForeachFsItem's
      # version of the Condition parameter which is this scriptblock and thus results in a stack
      # overflow due to infinite recursion. We need to use a temporary variable so that
      # the client's Condition (Rename-Many) is not accidentally hidden.
      #
      return ($patternRegEx.IsMatch($pipelineItem.Name)) -and `
      (($Except -eq [string]::Empty) -or -not($pipelineItem.Name -match $Except)) -and `
        $clientCondition.Invoke($pipelineItem);
    }

    [System.Collections.Hashtable]$parameters = @{
      'Condition' = $matchesPattern;
      'PassThru'  = $passThru;
      'Header'    = $LoopzHelpers.DefaultHeaderBlock;
      'Summary'   = $LoopzHelpers.SimpleSummaryBlock;
      'Block'     = $LoopzHelpers.WhItemDecoratorBlock;
    }

    if ($PSBoundParameters.ContainsKey('File')) {
      $parameters['File'] = $true;
    }
    elseif ($PSBoundParameters.ContainsKey('Directory')) {
      $parameters['Directory'] = $true;
    }

    if ($whatIf) {
      $passThru['WHAT-IF'] = $true;
    }

    $null = $collection | Invoke-ForeachFsItem @parameters;
  } # end
} # Rename-Many
