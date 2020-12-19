
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
    [ValidateSet('p', 'a', 'c', 'i', '*')]
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
    [object[]]$Copy,

    [Parameter(ParameterSetName = 'ReplaceLiteralWith', Mandatory)]
    [string]$With,

    [Parameter()]
    [Alias('x')]
    [string]$Except = [string]::Empty,

    [Parameter()]
    [Alias('i')]
    [string]$Include,

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
      Title          = $Loopz.Defaults.Remy.Title;
      ItemMessage    = $Loopz.Defaults.Remy.ItemMessage;
      SummaryMessage = $Loopz.Defaults.Remy.SummaryMessage;
    },

    [Parameter()]
    [switch]$Diagnose,

    [Parameter()]
    [string]$Drop
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

      [boolean]$itemIsDirectory = ($_underscore.Attributes -band
        [System.IO.FileAttributes]::Directory) -eq [System.IO.FileAttributes]::Directory;

      $endAdapter = New-EndAdapter($_underscore);
      [string]$adjustedName = $endAdapter.GetAdjustedName();

      [string]$action = $_passThru['LOOPZ.REMY.ACTION'];

      [System.Collections.Hashtable]$actionParameters = @{
        'Value'   = $adjustedName;
        'Pattern' = $_passThru['LOOPZ.REMY.PATTERN-REGEX'];
      }

      [boolean]$performDiagnosis = ($_passThru.ContainsKey('LOOPZ.DIAGNOSE') -and
        $_passThru['LOOPZ.DIAGNOSE']);

      $actionParameters['PatternOccurrence'] = $_passThru.ContainsKey('LOOPZ.REMY.PATTERN-OCC') `
        ? $_passThru['LOOPZ.REMY.PATTERN-OCC'] : 'f';

      if ($_passThru.ContainsKey('LOOPZ.REMY.COPY')) {
        $actionParameters['Copy'] = $_passThru['LOOPZ.REMY.COPY'];

        if ($_passThru.ContainsKey('LOOPZ.REMY.COPY-OCC')) {
          $actionParameters['CopyOccurrence'] = $_passThru['LOOPZ.REMY.COPY-OCC'];
        }
      }
      elseif ($_passThru.ContainsKey('LOOPZ.REMY.WITH')) {
        $actionParameters['With'] = $_passThru['LOOPZ.REMY.WITH'];
      }

      if ($_passThru.ContainsKey('LOOPZ.REMY.PASTE')) {
        $actionParameters['Paste'] = $_passThru['LOOPZ.REMY.PASTE']
      }

      if ($performDiagnosis) {
        $actionParameters['Diagnose'] = $_passThru['LOOPZ.DIAGNOSE']
      }

      if ($action -eq 'Move-Match') {
        if ($_passThru.ContainsKey('LOOPZ.REMY.ANCHOR')) {
          $actionParameters['Anchor'] = $_passThru['LOOPZ.REMY.ANCHOR'];
        }
        if ($_passThru.ContainsKey('LOOPZ.REMY.ANCHOR-OCC')) {
          $actionParameters['AnchorOccurrence'] = $_passThru['LOOPZ.REMY.ANCHOR-OCC'];
        }

        if ($_passThru.ContainsKey('LOOPZ.REMY.DROP')) {
          $actionParameters['Drop'] = $_passThru['LOOPZ.REMY.DROP'];
          $actionParameters['Marker'] = $_passThru['LOOPZ.REMY.MARKER'];
        }

        switch ($_passThru['LOOPZ.REMY.ANCHOR-TYPE']) {
          'MATCHED-ITEM' {
            if ($_passThru.ContainsKey('LOOPZ.REMY.RELATION')) {
              $actionParameters['Relation'] = $_passThru['LOOPZ.REMY.RELATION'];
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
            throw "doRenameFsItems: encountered Invalid 'LOOPZ.REMY.ANCHOR-TYPE': '$AnchorType'";
          }
        }
      } # $action

      [string[][]]$properties = @();
      [string[][]]$lines = @();
      [System.Collections.Hashtable]$signals = $_passThru['LOOPZ.SIGNALS'];

      # Perform Rename Action, then post process
      #
      [PSCustomObject]$actionResult = & $action @actionParameters;
      [string]$newItemName = $actionResult.Payload;
      $postResult = invoke-PostProcessing -InputSource $newItemName -Rules $Loopz.Rules.Remy `
        -Signals $signals;

      if ($postResult.Modified) {
        [string[]]$postSignal = Get-FormattedSignal -Name 'REMY.POST' `
          -Signals $signals -Value $postResult.Indication -CustomLabel $postResult.Label;
        $properties += , $postSignal;
        $newItemName = $postResult.TransformResult;
      }

      $newItemName = $endAdapter.GetNameWithExtension($newItemName);
      Write-Debug "Rename-Many; New Item Name: '$newItemName'";

      [boolean]$trigger = $false;
      [boolean]$affirm = $false;
      [boolean]$whatIf = $_passThru.ContainsKey('WHAT-IF') -and ($_passThru['WHAT-IF']);

      [string]$parent = $itemIsDirectory ? $_underscore.Parent.FullName : $_underscore.Directory.FullName;
      [boolean]$nameHasChanged = -not($_underscore.Name -ceq $newItemName);
      [string]$newItemFullPath = Join-Path -Path $parent -ChildPath $newItemName;
      [boolean]$clash = (Test-Path -LiteralPath $newItemFullPath) -and $nameHasChanged;
      [string]$fileSystemItemType = $itemIsDirectory ? 'Directory' : 'File';

      [PSCustomObject]$context = $_passThru['LOOPZ.REMY.CONTEXT'];
      [int]$maxItemMessageSize = $_passThru['LOOPZ.REMY.MAX-ITEM-MESSAGE-SIZE'];
      [string]$normalisedItemMessage = $Context.ItemMessage.replace(
        $Loopz.FsItemTypePlaceholder, $fileSystemItemType);

      [string]$messageLabel = if ($context.psobject.properties.match('ItemMessage') -and `
          -not([string]::IsNullOrEmpty($Context.ItemMessage))) {

        Get-PaddedLabel -Label $($Context.ItemMessage.replace(
            $Loopz.FsItemTypePlaceholder, $fileSystemItemType)) -Width $maxItemMessageSize;
      }
      else {
        $normalisedItemMessage;
      }

      [string]$signalName = $itemIsDirectory ? 'DIRECTORY-A' : 'FILE-A';
      [string]$message = Get-FormattedSignal -Name $signalName `
        -Signals $signals -CustomLabel $messageLabel -Format '   [{1}] {0}';

      [int]$signalLength = $signals[$signalName][1].Length;

      # TODO: Strictly speaking the 28 needs to be adjusted according to some of the
      # entries in the krayola scheme like MESSAGE-SUFFIX, FORMAT.
      #
      [int]$indent = 28 + $maxItemMessageSize + $($signalLength - 2);
      $_passThru['LOOPZ.WH-FOREACH-DECORATOR.INDENT'] = $indent;
      $_passThru['LOOPZ.WH-FOREACH-DECORATOR.MESSAGE'] = $message;
      $_passThru['LOOPZ.WH-FOREACH-DECORATOR.PRODUCT-LABEL'] = $(Get-PaddedLabel -Label $(
          $fileSystemItemType) -Width 9);

      if ($nameHasChanged -and -not($clash)) {
        $trigger = $true;
        $product = rename-FsItem -From $_underscore -To $newItemName -WhatIf:$whatIf;
      }
      else {
        $product = $_underscore;
      }

      if ($trigger) {
        $lines += , @($_passThru['LOOPZ.REMY.FROM-LABEL'], $_underscore.Name);
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

      if (-not($actionResult.Success)) {
        [string[]]$failedSignal = Get-FormattedSignal -Name 'FAILED-A' `
          -Signals $signals -Value $actionResult.FailedReason;
        $properties += , $failedSignal; 
      }

      # Do diagnostics
      #
      if ($performDiagnosis -and $actionResult.Diagnostics.Named -and
        ($actionResult.Diagnostics.Named.Count -gt 0)) {

        [string]$diagnosticEmoji = Get-FormattedSignal -Name 'DIAGNOSTICS' -Signals $signals `
          -EmojiOnly;

        [string]$captureEmoji = Get-FormattedSignal -Name 'CAPTURE' -Signals $signals `
          -EmojiOnly -EmojiOnlyFormat '[{0}]';

        foreach ($namedItem in $actionResult.Diagnostics.Named) {
          foreach ($namedKey in $namedItem.Keys) {
            [System.Collections.Hashtable]$groups = $actionResult.Diagnostics.Named[$namedKey];
            [string[]]$diagnosticLines = @();

            foreach ($groupName in $groups.Keys) {
              [string]$captured = $groups[$groupName];
              [string]$compoundValue = "({0} <{1}>)='{2}'" -f $captureEmoji, $groupName, $captured;
              [string]$namedLabel = Get-PaddedLabel -Label ($diagnosticEmoji + $namedKey);

              $diagnosticLines += $compoundValue;
            }
            $lines += , @($namedLabel, $($diagnosticLines -join ', '));
          }
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
    [string]$patternExpression, [string]$patternOccurrence = Resolve-PatternOccurrence $Pattern

    Select-SignalContainer -Containers $containers -Name 'PATTERN' `
      -Value $patternExpression -Signals $signals;

    if ($PSBoundParameters.ContainsKey('Anchor')) {
      [string]$anchorExpression, [string]$anchorOccurrence = Resolve-PatternOccurrence $Anchor

      Select-SignalContainer -Containers $containers -Name 'REMY.ANCHOR' `
        -Value $anchorExpression -Signals $signals -CustomLabel $('Anchor ({0})' -f $Relation);
    }

    if ($PSBoundParameters.ContainsKey('Copy')) {
      [string]$copyExpression, [string]$copyOccurrence = Resolve-PatternOccurrence $Copy;

      Select-SignalContainer -Containers $containers -Name 'COPY-A' `
        -Value $copyExpression -Signals $signals;
    }
    elseif ($PSBoundParameters.ContainsKey('With')) {
      if (-not([string]::IsNullOrEmpty($With))) {

        Select-SignalContainer -Containers $containers -Name 'WITH' `
          -Value $With -Signals $signals;
      }
      elseif (-not($PSBoundParameters.ContainsKey('Paste'))) {

        Select-SignalContainer -Containers $containers -Name 'CUT-A' `
          -Value $patternExpression -Signals $signals -Force 'Props';
      }
    }

    if ($PSBoundParameters.ContainsKey('Include')) {
      [string]$includeExpression, [string]$includeOccurrence = Resolve-PatternOccurrence $Include;

      Select-SignalContainer -Containers $containers -Name 'INCLUDE' `
        -Value $includeExpression -Signals $signals;
    }

    if ($PSBoundParameters.ContainsKey('Diagnose')) {
      [string]$switchOnEmoji = $signals['SWITCH-ON'][1];

      $diagnosticsSignal = Get-FormattedSignal -Name 'DIAGNOSTICS' `
        -Signals $signals -Value $('[{0}]' -f $switchOnEmoji);

      $containers.Props += , $diagnosticsSignal;
    }

    [boolean]$doMoveToken = ($PSBoundParameters.ContainsKey('Anchor') -or
      $PSBoundParameters.ContainsKey('Start') -or $PSBoundParameters.ContainsKey('End'));

    [boolean]$doCut = (
      -not($doMoveToken) -and
      -not($PSBoundParameters.ContainsKey('Copy')) -and
      -not($PSBoundParameters.ContainsKey('With')) -and
      -not($PSBoundParameters.ContainsKey('Paste'))
    )

    if ($doCut) {
      Select-SignalContainer -Containers $containers -Name 'CUT-A' `
        -Value $patternExpression -Signals $signals -Force 'Props';
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

    [System.Text.RegularExpressions.RegEx]$patternRegEx = New-RegularExpression -Expression $patternExpression `
      -WholeWord:$(-not([string]::IsNullOrEmpty($adjustedWhole)) -and ($adjustedWhole -in @('*', 'p')));

    [string]$title = $Context.psobject.properties.match('Title') -and `
      -not([string]::IsNullOrEmpty($Context.Title)) `
      ? $Context.Title : 'Rename';

    [int]$maxItemMessageSize = $Context.ItemMessage.replace(
      $Loopz.FsItemTypePlaceholder, 'Directory').Length;

    [string]$summaryMessage = $Context.psobject.properties.match('SummaryMessage') -and `
      -not([string]::IsNullOrEmpty($Context.SummaryMessage)) `
      ? $Context.SummaryMessage : 'Rename Summary';

    $summaryMessage = Get-FormattedSignal -Name 'SUMMARY-A' -Signals $signals -CustomLabel $summaryMessage;

    [System.Collections.Hashtable]$passThru = @{
      'LOOPZ.WH-FOREACH-DECORATOR.BLOCK'      = $doRenameFsItems;
      'LOOPZ.WH-FOREACH-DECORATOR.GET-RESULT' = $getResult;

      'LOOPZ.HEADER-BLOCK.CRUMB-SIGNAL'       = 'CRUMB-A';
      'LOOPZ.HEADER-BLOCK.LINE'               = $LoopzUI.DashLine;

      'LOOPZ.SUMMARY-BLOCK.LINE'              = $LoopzUI.EqualsLine;
      'LOOPZ.SUMMARY-BLOCK.MESSAGE'           = $summaryMessage;
      'LOOPZ.HEADER-BLOCK.MESSAGE'            = $title;

      'LOOPZ.REMY.PATTERN-REGEX'              = $patternRegEx;
      'LOOPZ.REMY.PATTERN-OCC'                = $patternOccurrence;
      'LOOPZ.REMY.CONTEXT'                    = $Context;
      'LOOPZ.REMY.MAX-ITEM-MESSAGE-SIZE'      = $maxItemMessageSize;

      'LOOPZ.REMY.FROM-LABEL'                 = Get-PaddedLabel -Label 'From' -Width 9;
      'LOOPZ.SIGNALS'                         = $signals;
    }
    $passThru['LOOPZ.REMY.ACTION'] = $doMoveToken ? 'Move-Match' : 'Update-Match';

    if ($PSBoundParameters.ContainsKey('Copy')) {
      [System.Text.RegularExpressions.RegEx]$copyRegEx = New-RegularExpression -Expression $copyExpression `
        -WholeWord:$(-not([string]::IsNullOrEmpty($adjustedWhole)) -and ($adjustedWhole -in @('*', 'c')));

      $passThru['LOOPZ.REMY.COPY-OCC'] = $copyOccurrence;
      $passThru['LOOPZ.REMY.COPY'] = $copyRegEx;
    }
    elseif ($PSBoundParameters.ContainsKey('With')) {
      $passThru['LOOPZ.REMY.WITH'] = $With;
    }

    if ($PSBoundParameters.ContainsKey('Relation')) {
      $passThru['LOOPZ.REMY.RELATION'] = $Relation;
    }

    # NB: anchoredRegEx refers to whether -Start or -End anchors have been specified,
    # NOT the -Anchor pattern (when ANCHOR-TYPE = 'MATCHED-ITEM') itself.
    #
    [System.Text.RegularExpressions.RegEx]$anchoredRegEx = $null;

    if ($PSBoundParameters.ContainsKey('Anchor')) {

      [System.Text.RegularExpressions.RegEx]$anchorRegEx = New-RegularExpression -Expression $anchorExpression `
        -WholeWord:$(-not([string]::IsNullOrEmpty($adjustedWhole)) -and ($adjustedWhole -in @('*', 'a')));

      $passThru['LOOPZ.REMY.ANCHOR-OCC'] = $anchorOccurrence;
      $passThru['LOOPZ.REMY.ANCHOR-TYPE'] = 'MATCHED-ITEM';
      $passThru['LOOPZ.REMY.ANCHOR'] = $anchorRegEx;
    }
    elseif ($PSBoundParameters.ContainsKey('Start')) {

      Select-SignalContainer -Containers $containers -Name 'SWITCH-ON' `
        -Value $patternExpression -Signals $signals -CustomLabel 'Start' -Force 'Props';

      $passThru['LOOPZ.REMY.ANCHOR-TYPE'] = 'START';

      [System.Text.RegularExpressions.RegEx]$anchoredRegEx = New-RegularExpression `
        -Expression $('^' + $patternExpression);
    }
    elseif ($PSBoundParameters.ContainsKey('End')) {

      Select-SignalContainer -Containers $containers -Name 'SWITCH-ON' `
        -Value $patternExpression -Signals $signals -CustomLabel 'End' -Force 'Props';

      $passThru['LOOPZ.REMY.ANCHOR-TYPE'] = 'END';

      [System.Text.RegularExpressions.RegEx]$anchoredRegEx = New-RegularExpression `
        -Expression $($patternExpression + '$');
    }

    if ($PSBoundParameters.ContainsKey('Drop') -and -not([string]::IsNullOrEmpty($Drop))) {
      Select-SignalContainer -Containers $containers -Name 'REMY.DROP' `
        -Value $Drop -Signals $signals -Force 'Wide';

      $passThru['LOOPZ.REMY.DROP'] = $Drop;
      $passThru['LOOPZ.REMY.MARKER'] = $Loopz.Defaults.Remy.Marker;
    }

    [boolean]$includeDefined = $PSBoundParameters.ContainsKey('Include');
    [System.Text.RegularExpressions.RegEx]$includeRegEx = $includeDefined `
      ? (New-RegularExpression -Expression $includeExpression `
        -WholeWord:$(-not([string]::IsNullOrEmpty($adjustedWhole)) -and ($adjustedWhole -in @('*', 'i')))) `
      : $null;

    if ($PSBoundParameters.ContainsKey('Paste')) {
      $passThru['LOOPZ.REMY.PASTE'] = $Paste;
    }

    if ($containers.Wide.Length -gt 0) {
      $passThru['LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS'] = $containers.Wide;
    }

    if ($containers.Props.Length -gt 0) {
      $passThru['LOOPZ.SUMMARY-BLOCK.PROPERTIES'] = $containers.Props;
    }
       
    [scriptblock]$clientCondition = $Condition;
    [scriptblock]$compoundCondition = {
      param(
        [System.IO.FileSystemInfo]$pipelineItem
      )
      [boolean]$clientResult = $true; # $clientCondition.Invoke($pipelineItem);
      [boolean]$isAlreadyAnchoredAt = $anchoredRegEx -and $anchoredRegEx.IsMatch($pipelineItem.Name);

      return $($clientResult -and -not($isAlreadyAnchoredAt));
    };

    [scriptblock]$matchesPattern = {
      param(
        [System.IO.FileSystemInfo]$pipelineItem
      )
      # Inside the scope of this script block, $Condition is assigned to Invoke-ForeachFsItem's
      # version of the Condition parameter which is this scriptblock and thus results in a stack
      # overflow due to infinite recursion. We need to use a temporary variable so that
      # the client's Condition (Rename-Many) is not accidentally hidden.
      #
      [boolean]$isIncluded = $includeDefined ? $includeRegEx.IsMatch($pipelineItem.Name) : $true;
      return ($patternRegEx.IsMatch($pipelineItem.Name)) -and $isIncluded -and `
      (($Except -eq [string]::Empty) -or -not($pipelineItem.Name -match $Except)) -and `
        $compoundCondition.Invoke($pipelineItem);
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

    if ($whatIf -or $Diagnose.ToBool()) {
      $passThru['WHAT-IF'] = $true;
    }

    if ($Diagnose.ToBool()) {
      $passThru['LOOPZ.DIAGNOSE'] = $true;
    }

    $null = $collection | Invoke-ForeachFsItem @parameters;
  } # end
} # Rename-Many
