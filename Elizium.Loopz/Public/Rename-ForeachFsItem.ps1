
function Rename-ForeachFsItem {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '',
    Justification = 'WhatIf is accessed and passed into PassThru')]
  [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'ReplaceWith')]
  [Alias('rnfsi', 'rnall')]
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

    [Parameter(ParameterSetName = 'ReplaceFirst', Mandatory)]
    [switch]$First,

    [Parameter(ParameterSetName = 'ReplaceFirst')]
    [int]$Quantity = 1,

    [Parameter(ParameterSetName = 'ReplaceWith')]
    [Parameter(ParameterSetName = 'MoveToEnd')]
    [Parameter(ParameterSetName = 'MoveToStart')]
    [Parameter(ParameterSetName = 'MoveRelative')]
    [switch]$Last,

    [Parameter()]
    [switch]$Whole,

    [Parameter(Mandatory, Position = 0)]
    [string]$Pattern,

    [Parameter(ParameterSetName = 'MoveToStart')]
    [Parameter(ParameterSetName = 'MoveToEnd')]
    [Parameter(ParameterSetName = 'MoveRelative')]
    [Parameter(ParameterSetName = 'ReplaceFirst')]
    [Parameter(ParameterSetName = 'ReplaceWith', Mandatory)]
    [AllowEmptyString()]
    [string]$With,

    [Parameter()]
    [string]$Except = [string]::Empty,

    [Parameter()]
    [scriptblock]$Condition = ( { return $true; }),

    [Parameter(ParameterSetName = 'MoveRelative')]
    [string]$Target,

    [Parameter(ParameterSetName = 'MoveRelative')]
    [string]$Relation = 'after',

    [Parameter(ParameterSetName = 'MoveToStart', Mandatory)]
    [switch]$Start,

    [Parameter(ParameterSetName = 'MoveToEnd', Mandatory)]
    [switch]$End
  )

  begin {
    Write-Debug ">>> Rename-ForeachFsItem [ParamaterSet: '$($PSCmdlet.ParameterSetName)]' >>>";

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
      [string]$replaceWith = $_passThru['LOOPZ.RN-FOREACH.WITH'];
      [boolean]$itemIsDirectory = ($_underscore.Attributes -band
        [System.IO.FileAttributes]::Directory) -eq [System.IO.FileAttributes]::Directory;

      $endAdapter = New-EndAdapter($_underscore);
      [string]$adjustedName = $endAdapter.GetAdjustedName();

      [boolean]$wholeWord = $_passThru.ContainsKey('LOOPZ.RN-FOREACH.WHOLE-WORD') `
        ? $_passThru['LOOPZ.RN-FOREACH.WHOLE-WORD'] : $false;
      
      [string]$action = $_passThru['LOOPZ.RN-FOREACH.ACTION'];

      [System.Collections.Hashtable]$actionParameters = @{
        'Value'   = $adjustedName;
        'Pattern' = $replacePattern;
        'With'    = $replaceWith;
      }

      if ($wholeWord) {
        $actionParameters['Whole'] = $true;
      }

      switch ($action) {
        'REPLACE-WITH' {
          [string]$actionFn = 'invoke-ReplaceTextAction';
          $actionParameters['Quantity'] = $_passThru.ContainsKey('LOOPZ.RN-FOREACH.QUANTITY-FIRST') `
            ? $_passThru['LOOPZ.RN-FOREACH.QUANTITY-FIRST'] : 1;

          if ($_passThru.ContainsKey('LOOPZ.RN-FOREACH.OCCURRENCE')) {
            $actionParameters['Occurrence'] = $_passThru['LOOPZ.RN-FOREACH.OCCURRENCE'];
          }
          break;
        }

        'MOVE-TOKEN' {
          [string]$actionFn = 'invoke-MoveTextAction';
          if ($_passThru.ContainsKey('LOOPZ.RN-FOREACH.TARGET')) {
            $actionParameters['Target'] = $_passThru['LOOPZ.RN-FOREACH.TARGET'];
          }
          $actionParameters['TargetType'] = $_passThru['LOOPZ.RN-FOREACH.TARGET-TYPE'];
          $actionParameters['Relation'] = $Relation;
          break;
        }

        default {
          throw "doRenameFsItems: encountered Invalid 'LOOPZ.RN-FOREACH.ACTION': '$action'";
        }
      } # $action

      [string]$newItemName = & $actionFn @actionParameters;
      $newItemName = $endAdapter.GetNameWithExtension($newItemName);

      [boolean]$trigger = $false;
      [boolean]$affirm = $false;
      [boolean]$whatIf = $_passThru.ContainsKey('WHAT-IF') -and ($_passThru['WHAT-IF']);
      [string[][]]$properties = @();

      [string]$parent = $itemIsDirectory ? $_underscore.Parent.FullName : $_underscore.Directory.FullName;
      [boolean]$nameHasChanged = -not($_underscore.Name -ceq $newItemName);
      [string]$newItemFullPath = Join-Path -Path $parent -ChildPath $newItemName;
      [boolean]$clash = (Test-Path -Path $newItemFullPath) -and $nameHasChanged;

      [string]$itemEmoji = $itemIsDirectory ? '📁' : '🏷️';
      [string]$message = '   [{0}] Rename Item{1}' -f $itemEmoji, ($whatIf ? ' (WhatIf)' : '');
      $_passThru['LOOPZ.WH-FOREACH-DECORATOR.MESSAGE'] = $message;

      if ($nameHasChanged -and -not($clash)) {
        $trigger = $true;
        $product = rename-FsItem -From $_underscore -To $newItemName -WhatIf:$whatIf;
      }
      else {
        $product = $_underscore;
      }

      [boolean]$differsByCaseOnly = $newItemName.ToLower() -eq $_underscore.Name.ToLower();
      [boolean]$affirm = $trigger -and ($product) -and -not($differsByCaseOnly);

      if ($trigger) {
        $properties += , @('To', $newItemName, $affirm);
      }
      else {
        if ($clash) {
          Write-Debug "!!! doRenameFsItems; path: '$newItemFullPath' already exists, rename skipped"
          $properties += , @('Clash', '⛔');
        }
        else {
          $properties += , @('Not renamed', '⛔');
        }
      }

      [PSCustomObject]$result = [PSCustomObject]@{
        Product = $product;
      }

      $result | Add-Member -MemberType NoteProperty -Name 'Pairs' -Value (, $properties);

      if ($trigger) {
        $result | Add-Member -MemberType NoteProperty -Name 'Trigger' -Value $true;
      }

      return $result;
    } # doRenameFsItems

    [System.IO.FileSystemInfo[]]$collection = @();
  } # begin

  process {
    Write-Debug "=== Rename-ForeachFsItem [$($underscore.Name)] ===";

    $collection += $underscore;
  }

  end {
    Write-Debug '<<< Rename-ForeachFsItem <<<';
    [int]$WIDE_THRESHOLD = 6;

    [boolean]$whatIf = $PSBoundParameters.ContainsKey('WhatIf');
    [string[][]]$wideItems = @();
    [string[][]]$properties = @();

    if ($Pattern.Length -gt $WIDE_THRESHOLD) {
      $wideItems += , @('[🔍] Pattern', $Pattern);
    }
    else {
      $properties += , @('[🔍] Pattern', $Pattern);
    }

    if ($PSBoundParameters.ContainsKey('With')) {
      if (-not([string]::IsNullOrEmpty($With))) {
        if ($Pattern.Length -gt $WIDE_THRESHOLD) {
          $wideItems += , @('[📌] With', $With);
        }
        else {
          $properties += , @('[📌] With', $With);
        }
      }
      else {
        $properties += , @('[✂️] Cut', $Pattern);
      }
    }

    if ($PSBoundParameters.ContainsKey('Target')) {
      [string]$targetLabel = '[🎯] Target ({0})' -f $Relation;
      if ($Target.Length -gt $WIDE_THRESHOLD) {
        $wideItems += , @($targetLabel, $Target);
      }
      else {
        $properties += , @($targetLabel, $Target);
      }
    }

    [scriptblock]$getResult = {
      param($result)

      $result.GetType() -in @([System.IO.FileInfo], [System.IO.DirectoryInfo]) ? $result.Name : $result;
    }

    [boolean]$doMoveToken = ($PSBoundParameters.ContainsKey('Target') -or
      $PSBoundParameters.ContainsKey('Start') -or $PSBoundParameters.ContainsKey('End'));

    [System.Collections.Hashtable]$passThru = @{
      'LOOPZ.WH-FOREACH-DECORATOR.BLOCK'         = $doRenameFsItems;
      'LOOPZ.WH-FOREACH-DECORATOR.PRODUCT-LABEL' = $File.ToBool() ? 'File' : 'Directory';
      'LOOPZ.WH-FOREACH-DECORATOR.GET-RESULT'    = $getResult;

      'LOOPZ.HEADER-BLOCK.CRUMB'                 = '[🛡️] '
      'LOOPZ.HEADER-BLOCK.LINE'                  = $LoopzUI.DashLine;
      'LOOPZ.HEADER-BLOCK.MESSAGE'               = $whatIf ? 'Rename (WhatIf)' : 'Rename';

      'LOOPZ.SUMMARY-BLOCK.LINE'                 = $LoopzUI.EqualsLine;
      'LOOPZ.SUMMARY-BLOCK.MESSAGE'              = '[💎] Rename Summary';

      'LOOPZ.RN-FOREACH.PATTERN'                 = $Pattern;
      'LOOPZ.RN-FOREACH.FS-ITEM-TYPE'            = $File.ToBool() ? 'FILE' : 'DIRECTORY';
    }

    $passThru['LOOPZ.RN-FOREACH.WITH'] = if ($doMoveToken) {
      -not([string]::IsNullOrEmpty($With)) ? $With : $Pattern;
    }
    else {
      $With;
    }

    if ($First.ToBool()) {
      $properties += , @('First', '[✔️]');
      $passThru['LOOPZ.RN-FOREACH.OCCURRENCE'] = 'FIRST';
      $passThru['LOOPZ.RN-FOREACH.QUANTITY-FIRST'] = $Quantity;
    }

    if ($Last.ToBool()) {
      $properties += , @('Last', '[✔️]');
      $passThru['LOOPZ.RN-FOREACH.OCCURRENCE'] = 'LAST';
    }

    if ($Whole.ToBool()) {
      $passThru['LOOPZ.RN-FOREACH.WHOLE-WORD'] = $true;
    }

    $passThru['LOOPZ.RN-FOREACH.ACTION'] = $doMoveToken ? 'MOVE-TOKEN' : 'REPLACE-WITH';
    $passThru['LOOPZ.RN-FOREACH.RELATION'] = $Relation;

    if (-not([string]::IsNullOrEmpty($Target))) {
      $passThru['LOOPZ.RN-FOREACH.TARGET-TYPE'] = 'MATCHED-ITEM';
      $passThru['LOOPZ.RN-FOREACH.TARGET'] = $Target;
    }
    elseif ($PSBoundParameters.ContainsKey('Start')) {
      $properties += , @('Start', '[✔️]');
      $passThru['LOOPZ.RN-FOREACH.TARGET-TYPE'] = 'START';
    }
    elseif ($PSBoundParameters.ContainsKey('End')) {
      $properties += , @('End', '[✔️]');
      $passThru['LOOPZ.RN-FOREACH.TARGET-TYPE'] = 'END';
    }

    if ($wideItems.Length -gt 0) {
      $passThru['LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS'] = $wideItems;
    }

    if ($properties.Length -gt 0) {
      $passThru['LOOPZ.SUMMARY-BLOCK.PROPERTIES'] = $properties;
    }

    [scriptblock]$clientCondition = $Condition;

    [scriptblock]$matchesPattern = {
      param(
        [System.IO.FileSystemInfo]$pipelineItem
      )
      # Inside the scope of this script block, $Condition is assigned to Invoke-ForeachFsItem's
      # version of the Condition parameter which is this scriptblock and thus results in a stack
      # overflow due to infinite recursion. We need to use a temporary variable so that
      # the client's Condition (Rename-ForeachFsItem) is not accidentally hidden.
      #
      return ($pipelineItem.Name -match $Pattern) -and `
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
    else {
      $parameters['Directory'] = $true;
    }

    if ($whatIf) {
      $passThru['WHAT-IF'] = $true;
    }

    $null = $collection | Invoke-ForeachFsItem @parameters;
  } # end
} # Rename-ForeachFsItem
