
function Rename-Many {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '',
    Justification = 'WhatIf IS accessed and passed into Exchange')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock', '')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
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
    [ValidateSet('p', 'a', 'c', 'i', 'x', '*')]
    [string]$Whole,

    [Parameter(Mandatory, Position = 0)]
    [ValidateScript( { { $(test-ValidPatternArrayParam -Arg $_ -AllowWildCard ) } })]
    [array]$Pattern,

    [Parameter(ParameterSetName = 'MoveToAnchor', Mandatory)]
    [ValidateScript( { $(test-ValidPatternArrayParam -Arg $_) })]
    [array]$Anchor,

    [Parameter(ParameterSetName = 'MoveToAnchor')]
    [ValidateSet('before', 'after')]
    [string]$Relation = 'after',

    [Parameter(ParameterSetName = 'MoveToAnchor')]
    [Parameter(ParameterSetName = 'ReplaceWith')]
    [ValidateScript( { { $(test-ValidPatternArrayParam -Arg $_) } })]
    [array]$Copy,

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
      Locked         = 'LOOPZ_REMY_LOCKED';
    },

    [Parameter()]
    [switch]$Diagnose,

    [Parameter()]
    [string]$Drop,

    [Parameter()]
    [ValidateScript( { $_ -gt 0 } )]
    [int]$Top
  )

  begin {
    Write-Debug ">>> Rename-Many [ParameterSet: '$($PSCmdlet.ParameterSetName)]' >>>";

    function get-fixedIndent {
      [OutputType([int])]
      param(
        [Parameter()]
        [hashtable]$Theme,

        [Parameter()]
        [string]$Message = [string]::Empty
      )
      [int]$indent = $Message.Length;

      #          1         2         3         4
      # 1234567890123456789012345678901234567890
      #    [🏷️] Rename Item  // ["No" => "  1",
      #                      |<-- fixed bit -->|
      #
      $indent += $Theme['MESSAGE-SUFFIX'].Length;
      $indent += $Theme['OPEN'].Length;
      $indent += $Theme['FORMAT'].Replace($Theme['KEY-PLACE-HOLDER'], "No").Replace(
        $Theme['VALUE-PLACE-HOLDER'], '999').Length;
      $indent += $Theme['SEPARATOR'].Length;
      return $indent;
    }

    [scriptblock]$doRenameFsItems = {
      [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
      param(
        [Parameter(Mandatory)]
        [System.IO.FileSystemInfo]$_underscore,

        [Parameter(Mandatory)]
        [int]$_index,

        [Parameter(Mandatory)]
        [hashtable]$_exchange,

        [Parameter(Mandatory)]
        [boolean]$_trigger
      )

      [boolean]$itemIsDirectory = ($_underscore.Attributes -band
        [System.IO.FileAttributes]::Directory) -eq [System.IO.FileAttributes]::Directory;

      $endAdapter = New-EndAdapter($_underscore);
      [string]$adjustedName = $endAdapter.GetAdjustedName();

      [string]$action = $_exchange['LOOPZ.REMY.ACTION'];

      [hashtable]$actionParameters = @{
        'Value'   = $adjustedName;
        'Pattern' = $_exchange['LOOPZ.REMY.PATTERN-REGEX'];
      }

      [boolean]$performDiagnosis = ($_exchange.ContainsKey('LOOPZ.DIAGNOSE') -and
        $_exchange['LOOPZ.DIAGNOSE']);

      $actionParameters['PatternOccurrence'] = $_exchange.ContainsKey('LOOPZ.REMY.PATTERN-OCC') `
        ? $_exchange['LOOPZ.REMY.PATTERN-OCC'] : 'f';

      if ($_exchange.ContainsKey('LOOPZ.REMY.COPY')) {
        $actionParameters['Copy'] = $_exchange['LOOPZ.REMY.COPY'];

        if ($_exchange.ContainsKey('LOOPZ.REMY.COPY-OCC')) {
          $actionParameters['CopyOccurrence'] = $_exchange['LOOPZ.REMY.COPY-OCC'];
        }
      }
      elseif ($_exchange.ContainsKey('LOOPZ.REMY.WITH')) {
        $actionParameters['With'] = $_exchange['LOOPZ.REMY.WITH'];
      }

      if ($_exchange.ContainsKey('LOOPZ.REMY.PASTE')) {
        $actionParameters['Paste'] = $_exchange['LOOPZ.REMY.PASTE']
      }

      if ($performDiagnosis) {
        $actionParameters['Diagnose'] = $_exchange['LOOPZ.DIAGNOSE']
      }

      if ($action -eq 'Move-Match') {
        if ($_exchange.ContainsKey('LOOPZ.REMY.ANCHOR')) {
          $actionParameters['Anchor'] = $_exchange['LOOPZ.REMY.ANCHOR'];
        }
        if ($_exchange.ContainsKey('LOOPZ.REMY.ANCHOR-OCC')) {
          $actionParameters['AnchorOccurrence'] = $_exchange['LOOPZ.REMY.ANCHOR-OCC'];
        }

        if ($_exchange.ContainsKey('LOOPZ.REMY.DROP')) {
          $actionParameters['Drop'] = $_exchange['LOOPZ.REMY.DROP'];
          $actionParameters['Marker'] = $_exchange['LOOPZ.REMY.MARKER'];
        }

        switch ($_exchange['LOOPZ.REMY.ANCHOR-TYPE']) {
          'MATCHED-ITEM' {
            if ($_exchange.ContainsKey('LOOPZ.REMY.RELATION')) {
              $actionParameters['Relation'] = $_exchange['LOOPZ.REMY.RELATION'];
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

      [line]$properties = [line]::new();
      [line[]]$lines = @();
      [hashtable]$signals = $_exchange['LOOPZ.SIGNALS'];

      # Perform Rename Action, then post process
      #
      [PSCustomObject]$actionResult = & $action @actionParameters;
      [string]$newItemName = $actionResult.Payload;
      $postResult = invoke-PostProcessing -InputSource $newItemName -Rules $Loopz.Rules.Remy `
        -Signals $signals;

      if ($postResult.Modified) {
        [couplet]$postSignal = Get-FormattedSignal -Name 'REMY.POST' `
          -Signals $signals -Value $postResult.Indication -CustomLabel $postResult.Label;
        $properties.append($postSignal);
        $newItemName = $postResult.TransformResult;
      }

      $newItemName = $endAdapter.GetNameWithExtension($newItemName);
      Write-Debug "Rename-Many; New Item Name: '$newItemName'";

      [boolean]$trigger = $false;
      [boolean]$affirm = $false;
      [boolean]$whatIf = $_exchange.ContainsKey('WHAT-IF') -and ($_exchange['WHAT-IF']);

      [string]$parent = $itemIsDirectory ? $_underscore.Parent.FullName : $_underscore.Directory.FullName;
      [boolean]$nameHasChanged = -not($_underscore.Name -ceq $newItemName);
      [string]$newItemFullPath = Join-Path -Path $parent -ChildPath $newItemName;
      [boolean]$clash = (Test-Path -LiteralPath $newItemFullPath) -and $nameHasChanged;
      [string]$fileSystemItemType = $itemIsDirectory ? 'Directory' : 'File';

      [PSCustomObject]$context = $_exchange['LOOPZ.REMY.CONTEXT'];
      [int]$maxItemMessageSize = $_exchange['LOOPZ.REMY.MAX-ITEM-MESSAGE-SIZE'];
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

      [int]$indent = $_exchange['LOOPZ.REMY.FIXED-INDENT'] + $message.Length;
      $_exchange['LOOPZ.WH-FOREACH-DECORATOR.INDENT'] = $indent;
      $_exchange['LOOPZ.WH-FOREACH-DECORATOR.MESSAGE'] = $message;
      $_exchange['LOOPZ.WH-FOREACH-DECORATOR.PRODUCT-LABEL'] = $(Get-PaddedLabel -Label $(
          $fileSystemItemType) -Width 9);

      if ($nameHasChanged -and -not($clash)) {
        $trigger = $true;

        [UndoRename]$operant = $_exchange.ContainsKey('LOOPZ.REMY.UNDO') `
          ? $_exchange['LOOPZ.REMY.UNDO'] : $null;

        $product = rename-FsItem -From $_underscore -To $newItemName -WhatIf:$whatIf -UndoOperant $operant;
      }
      else {
        $product = $_underscore;
      }

      if ($trigger) {
        $null = $lines += (New-Line(
            New-Pair(@($_exchange['LOOPZ.REMY.FROM-LABEL'], $_underscore.Name))
          ));
      }
      else {
        if ($clash) {
          Write-Debug "!!! doRenameFsItems; path: '$newItemFullPath' already exists, rename skipped";
          [couplet]$clashSignal = Get-FormattedSignal -Name 'CLASH' `
            -Signals $signals -EmojiAsValue -EmojiOnlyFormat '{0}';
          $properties.append($clashSignal);
        }
        else {
          [couplet]$notActionedSignal = Get-FormattedSignal -Name 'NOT-ACTIONED' `
            -Signals $signals -EmojiAsValue -CustomLabel 'Not Renamed' -EmojiOnlyFormat '{0}';
          $properties.append($notActionedSignal);
        }
      }

      if (-not($actionResult.Success)) {
        [couplet]$failedSignal = Get-FormattedSignal -Name 'FAILED-A' `
          -Signals $signals -Value $actionResult.FailedReason;
        $properties.append($failedSignal);
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
            [hashtable]$groups = $actionResult.Diagnostics.Named[$namedKey];
            [string[]]$diagnosticLines = @();

            foreach ($groupName in $groups.Keys) {
              [string]$captured = $groups[$groupName];
              [string]$compoundValue = "({0} <{1}>)='{2}'" -f $captureEmoji, $groupName, $captured;
              [string]$namedLabel = Get-PaddedLabel -Label ($diagnosticEmoji + $namedKey);

              $diagnosticLines += $compoundValue;
            }
            $null = $lines += (New-Line(
                New-Pair(@($namedLabel, $($diagnosticLines -join ', ')))
              ));
          }
        }
      }

      if ($whatIf) {
        [couplet]$whatIfSignal = Get-FormattedSignal -Name 'WHAT-IF' `
          -Signals $signals -EmojiAsValue -EmojiOnlyFormat '{0}';
        $properties.append($whatIfSignal);
      }

      [PSCustomObject]$result = [PSCustomObject]@{
        Product = $product;
      }

      $result | Add-Member -MemberType NoteProperty -Name 'Pairs' -Value $properties;

      if ($lines.Length -gt 0) {
        $result | Add-Member -MemberType NoteProperty -Name 'Lines' -Value $lines;
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

    [boolean]$locked = Get-IsLocked -Variable $(
      [string]::IsNullOrEmpty($Context.Locked) ? 'LOOPZ_REMY_LOCKED' : $Context.Locked
    );
    [boolean]$whatIf = $PSBoundParameters.ContainsKey('WhatIf') -or $locked;
    [PSCustomObject]$containers = @{
      Wide  = [line]::new();
      Props = [line]::new();
    }

    [string]$adjustedWhole = if ($PSBoundParameters.ContainsKey('Whole')) {
      $Whole.ToLower();
    }
    else {
      [string]::Empty;
    }

    [hashtable]$signals = $(Get-Signals);

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
      [string]$switchOnEmoji = $signals['SWITCH-ON'].Value;

      [couplet]$diagnosticsSignal = Get-FormattedSignal -Name 'DIAGNOSTICS' `
        -Signals $signals -Value $('[{0}]' -f $switchOnEmoji);

      $containers.Props.Line += $diagnosticsSignal;
    }

    [boolean]$doMoveToken = ($PSBoundParameters.ContainsKey('Anchor') -or
      $PSBoundParameters.ContainsKey('Start') -or $PSBoundParameters.ContainsKey('End'));

    if ($doMoveToken -and ($patternOccurrence -eq '*')) {
      [string]$errorMessage = "'Pattern' wildcard prohibited for move operation (Anchor/Start/End).`r`n";
      $errorMessage += "Please use a digit, 'f' (first) or 'l' (last) for Pattern Occurrence";
      Write-Error $errorMessage -ErrorAction Stop;
    }

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
      if (-not(Test-IsFileSystemSafe -Value $Paste)) {
        throw [System.ArgumentException]::new("Paste parameter ('$Paste') contains unsafe characters")
      }
      if (-not([string]::IsNullOrEmpty($Paste))) {
        Select-SignalContainer -Containers $containers -Name 'PASTE-A' `
          -Value $Paste -Signals $signals;
      }
    }

    [scriptblock]$getResult = {
      param($result)

      $result.GetType() -in @([System.IO.FileInfo], [System.IO.DirectoryInfo]) ? $result.Name : $result;
    }

    [regex]$patternRegEx = New-RegularExpression -Expression $patternExpression `
      -WholeWord:$(-not([string]::IsNullOrEmpty($adjustedWhole)) -and ($adjustedWhole -in @('*', 'p')));

    [string]$title = $Context.psobject.properties.match('Title') -and `
      -not([string]::IsNullOrEmpty($Context.Title)) `
      ? $Context.Title : 'Rename';

    if ($locked) {
      $title = Get-FormattedSignal -Name 'LOCKED' -Signals $signals `
        -Format '{1} {0} {1}' -CustomLabel $('Locked: ' + $title);
    }

    [int]$maxItemMessageSize = $Context.ItemMessage.replace(
      $Loopz.FsItemTypePlaceholder, 'Directory').Length;

    [string]$summaryMessage = $Context.psobject.properties.match('SummaryMessage') -and `
      -not([string]::IsNullOrEmpty($Context.SummaryMessage)) `
      ? $Context.SummaryMessage : 'Rename Summary';

    $summaryMessage = Get-FormattedSignal -Name 'SUMMARY-A' -Signals $signals -CustomLabel $summaryMessage;

    [hashtable]$theme = $(Get-KrayolaTheme);
    [Krayon]$krayon = New-Krayon -Theme $theme;

    [hashtable]$exchange = @{
      'LOOPZ.WH-FOREACH-DECORATOR.BLOCK'      = $doRenameFsItems;
      'LOOPZ.WH-FOREACH-DECORATOR.GET-RESULT' = $getResult;

      'LOOPZ.HEADER-BLOCK.CRUMB-SIGNAL'       = 'CRUMB-A';
      'LOOPZ.HEADER-BLOCK.LINE'               = $LoopzUI.DashLine;
      'LOOPZ.HEADER-BLOCK.MESSAGE'            = $title;

      'LOOPZ.SUMMARY-BLOCK.LINE'              = $LoopzUI.EqualsLine;
      'LOOPZ.SUMMARY-BLOCK.MESSAGE'           = $summaryMessage;

      'LOOPZ.REMY.PATTERN-REGEX'              = $patternRegEx;
      'LOOPZ.REMY.PATTERN-OCC'                = $patternOccurrence;
      'LOOPZ.REMY.CONTEXT'                    = $Context;
      'LOOPZ.REMY.MAX-ITEM-MESSAGE-SIZE'      = $maxItemMessageSize;
      'LOOPZ.REMY.FIXED-INDENT'               = $(get-fixedIndent -Theme $theme);
      'LOOPZ.REMY.FROM-LABEL'                 = Get-PaddedLabel -Label 'From' -Width 9;

      'LOOPZ.SIGNALS'                         = $signals;
      'LOOP.KRAYON'                           = $krayon;
    }
    $exchange['LOOPZ.REMY.ACTION'] = $doMoveToken ? 'Move-Match' : 'Update-Match';

    if ($PSBoundParameters.ContainsKey('Copy')) {
      [regex]$copyRegEx = New-RegularExpression -Expression $copyExpression `
        -WholeWord:$(-not([string]::IsNullOrEmpty($adjustedWhole)) -and ($adjustedWhole -in @('*', 'c')));

      $exchange['LOOPZ.REMY.COPY-OCC'] = $copyOccurrence;
      $exchange['LOOPZ.REMY.COPY'] = $copyRegEx;
    }
    elseif ($PSBoundParameters.ContainsKey('With')) {
      if (-not(Test-IsFileSystemSafe -Value $With)) {
        throw [System.ArgumentException]::new("With parameter ('$With') contains unsafe characters")
      }
      $exchange['LOOPZ.REMY.WITH'] = $With;
    }

    if ($PSBoundParameters.ContainsKey('Relation')) {
      $exchange['LOOPZ.REMY.RELATION'] = $Relation;
    }

    # NB: anchoredRegEx refers to whether -Start or -End anchors have been specified,
    # NOT the -Anchor pattern (when ANCHOR-TYPE = 'MATCHED-ITEM') itself.
    #
    [regex]$anchoredRegEx = $null;

    if ($PSBoundParameters.ContainsKey('Anchor')) {

      [regex]$anchorRegEx = New-RegularExpression -Expression $anchorExpression `
        -WholeWord:$(-not([string]::IsNullOrEmpty($adjustedWhole)) -and ($adjustedWhole -in @('*', 'a')));

      $exchange['LOOPZ.REMY.ANCHOR-OCC'] = $anchorOccurrence;
      $exchange['LOOPZ.REMY.ANCHOR-TYPE'] = 'MATCHED-ITEM';
      $exchange['LOOPZ.REMY.ANCHOR'] = $anchorRegEx;
    }
    elseif ($PSBoundParameters.ContainsKey('Start')) {

      Select-SignalContainer -Containers $containers -Name 'REMY.ANCHOR' `
        -Value $signals['SWITCH-ON'].Value -Signals $signals -CustomLabel 'Start' -Force 'Props';

      $exchange['LOOPZ.REMY.ANCHOR-TYPE'] = 'START';

      [regex]$anchoredRegEx = New-RegularExpression `
        -Expression $('^' + $patternExpression);
    }
    elseif ($PSBoundParameters.ContainsKey('End')) {

      Select-SignalContainer -Containers $containers -Name 'REMY.ANCHOR' `
        -Value $signals['SWITCH-ON'].Value -Signals $signals -CustomLabel 'End' -Force 'Props';

      $exchange['LOOPZ.REMY.ANCHOR-TYPE'] = 'END';

      [regex]$anchoredRegEx = New-RegularExpression `
        -Expression $($patternExpression + '$');
    }

    if ($PSBoundParameters.ContainsKey('Drop') -and -not([string]::IsNullOrEmpty($Drop))) {
      Select-SignalContainer -Containers $containers -Name 'REMY.DROP' `
        -Value $Drop -Signals $signals -Force 'Wide';

      $exchange['LOOPZ.REMY.DROP'] = $Drop;
      $exchange['LOOPZ.REMY.MARKER'] = $Loopz.Defaults.Remy.Marker;
    }

    if ($locked) {
      Select-SignalContainer -Containers $containers -Name 'NOVICE' `
        -Value $signals['SWITCH-ON'].Value -Signals $signals -Force 'Wide';
    }

    [boolean]$includeDefined = $PSBoundParameters.ContainsKey('Include');
    [regex]$includeRegEx = $includeDefined `
      ? (New-RegularExpression -Expression $includeExpression `
        -WholeWord:$(-not([string]::IsNullOrEmpty($adjustedWhole)) -and ($adjustedWhole -in @('*', 'i')))) `
      : $null;

    if ($PSBoundParameters.ContainsKey('Paste')) {
      $exchange['LOOPZ.REMY.PASTE'] = $Paste;
    }

    [PSCustomObject]$operantOptions = [PSCustomObject]@{
      ShortCode    = 'remy';
      OperantName  = 'UndoRename';
      Shell        = 'PoShShell';
      BaseFilename = 'undo-rename';
      DisabledKey  = 'LOOPZ_REMY_UNDO_DISABLED';
    }
    [UndoRename]$operant = Initialize-ShellOperant -Options $operantOptions -DryRun:$whatIf;

    if ($operant) {
      $exchange['LOOPZ.REMY.UNDO'] = $operant;

      Select-SignalContainer -Containers $containers -Name 'REMY.UNDO' `
        -Value $operant.Shell.FullPath -Signals $signals -Force 'Wide';
    }
    else {
      Select-SignalContainer -Containers $containers -Name 'REMY.UNDO' `
        -Value $signals['SWITCH-OFF'].Value -Signals $signals -Force 'Wide';
    }

    if ($containers.Wide.Line.Length -gt 0) {
      $exchange['LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS'] = $containers.Wide;
    }

    if ($containers.Props.Line.Length -gt 0) {
      $exchange['LOOPZ.SUMMARY-BLOCK.PROPERTIES'] = $containers.Props;
    }

    [scriptblock]$clientCondition = $Condition;
    [scriptblock]$compoundCondition = {
      param(
        [System.IO.FileSystemInfo]$pipelineItem
      )

      [boolean]$clientResult = $clientCondition.InvokeReturnAsIs($pipelineItem);
      [boolean]$isAlreadyAnchoredAt = $anchoredRegEx -and $anchoredRegEx.IsMatch($pipelineItem.Name);

      return $($clientResult -and -not($isAlreadyAnchoredAt));
    };

    [regex]$excludedRegEx = [string]::IsNullOrEmpty($Except) `
      ? $null : $(New-RegularExpression -Expression $Except);

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
      ((-not($excludedRegEx)) -or -not($excludedRegEx.IsMatch($pipelineItem.Name))) -and `
        $compoundCondition.InvokeReturnAsIs($pipelineItem);
    }

    [hashtable]$parameters = @{
      'Condition' = $matchesPattern;
      'Exchange'  = $exchange;
      'Header'    = $LoopzHelpers.HeaderBlock;
      'Summary'   = $LoopzHelpers.SummaryBlock;
      'Block'     = $LoopzHelpers.WhItemDecoratorBlock;
    }

    if ($PSBoundParameters.ContainsKey('File')) {
      $parameters['File'] = $true;
    }
    elseif ($PSBoundParameters.ContainsKey('Directory')) {
      $parameters['Directory'] = $true;
    }

    if ($PSBoundParameters.ContainsKey('Top')) {
      $parameters['Top'] = $Top;
    }

    if ($whatIf -or $Diagnose.ToBool()) {
      $exchange['WHAT-IF'] = $true;
    }

    if ($Diagnose.ToBool()) {
      $exchange['LOOPZ.DIAGNOSE'] = $true;
    }

    try {
      $null = $collection | Invoke-ForeachFsItem @parameters;
    }
    catch {
      # ctrl-c doesn't invoke an exception, it just abandons processing,
      # ending up in the finally block.
      #
    }
    finally {
      # catch ctrl-c
      if ($operant -and -not($whatIf)) {
        $operant.finalise();
      }
    }
  } # end
} # Rename-Many
