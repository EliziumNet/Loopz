
function Rename-ForeachFsItem {
  [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'ReplaceWith')]
  [Alias('rnfsi', 'rnall')]
  param
  (
    # Defining parameter sets for File and Directory, just to ensure both of these switches
    # are mutually exclusive makes the whole parameter set definition exponentially more
    # complex. It's easier just to enforce this with a ValidateScript.
    #
    [Parameter()]
    [ValidateScript({ -not($PSBoundParameters.ContainsKey('Directory')); })]
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
    [Parameter(ParameterSetName = 'MoveToEnd', Mandatory)]
    [Parameter(ParameterSetName = 'MoveToStart')]
    [Parameter(ParameterSetName = 'MoveRelative')]
    [switch]$Last,

    [Parameter()]
    [switch]$Whole,

    [Parameter(Mandatory, Position = 0)]
    [string]$Pattern,

    [Parameter(ParameterSetName = 'ReplaceFirst')]
    [Parameter(ParameterSetName = 'ReplaceWith')]
    [string]$With,

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
      [boolean]$processingFiles = $_passThru['LOOPZ.RN-FOREACH.FS-ITEM-TYPE'] -eq 'FILE';
      [boolean]$wholeWord = $_passThru.ContainsKey('LOOPZ.RN-FOREACH.WHOLE-WORD') `
        ? $_passThru['LOOPZ.RN-FOREACH.WHOLE-WORD'] : $false;
      [string]$newItemName = [string]::Empty;
      [boolean]$errorOccurred = $false;
      [string[][]]$properties = @();

      if ($_passThru.ContainsKey('LOOPZ.RN-FOREACH.OCCURRENCE')) {
        [string]$occurrence = $_passThru['LOOPZ.RN-FOREACH.OCCURRENCE'];

        switch ($occurrence) {
          'FIRST' {
            [int]$quantityFirst = $_passThru.ContainsKey('LOOPZ.RN-FOREACH.QUANTITY-FIRST') `
              ? $_passThru['LOOPZ.RN-FOREACH.QUANTITY-FIRST'] : 1;

            $newItemName = (edit-ReplaceFirstMatch -Source $_underscore.Name `
                -Pattern $replacePattern -With $replaceWith -Quantity $quantityFirst `
                -Whole:$wholeWord).Trim();
            break;
          }

          'LAST' {
            $newItemName = (edit-ReplaceLastMatch -Source $_underscore.Name `
                -Pattern $replacePattern -With $replaceWith -Whole:$wholeWord).Trim();
            break;
          }
          default {
            $errorOccurred = $true;
            break;
          }
        }
      }
      else {
        # Just replace all occurrences
        #
        $newItemName = ($_underscore.Name -replace $replacePattern, $replaceWith).Trim();
      }

      [boolean]$trigger = $false;
      [boolean]$affirm = $false;

      if (-not($errorOccurred)) {
        if (-not($_underscore.Name -ceq $newItemName)) {
          $trigger = $true;

          $destinationPath = ($processingFiles) `
            ? (Join-Path $_underscore.Directory.FullName $newItemName) `
            : (Join-Path $_underscore.Parent.FullName $newItemName);

          # TODO: do not do the rename directly here. Abstract this out into another command.
          # This will enable us to generate an undo-script, in case the user made a mistake
          # Display the location of the undo script in the summary.
          #

          # First check if we only differ by case (TODO: check if this also applies to unix)
          #
          if ($newItemName.ToLower() -eq $_underscore.Name.ToLower()) {
            if ($PSCmdlet.ShouldProcess($_underscore.Name, 'Rename Item')) {
              # Just doing a double move to get around the problem of not being able to rename
              # an item unless the case is different
              #
              $tempName = $newItemName + "_";

              $tempDestinationPath = ($processingFiles) `
                ? (Join-Path $_underscore.Directory.FullName $tempName) `
                : (Join-Path $_underscore.Parent.FullName $tempName);
  
              Move-Item -LiteralPath $_underscore.FullName -Destination $tempDestinationPath -PassThru | `
                Move-Item -Destination $destinationPath;
            }
          }
          else {
            $affirm = $true;
            if ($PSCmdlet.ShouldProcess($_underscore.Name, 'Rename Item')) {
              Move-Item -LiteralPath $_underscore.FullName -Destination $destinationPath;
            }
          }
        }

        if ($trigger) {
          $properties += , @('Original', $_underscore.Name);
        }
      }

      [PSCustomObject]$result = [PSCustomObject]@{
        Product = $newItemName;
      }

      $result | Add-Member -MemberType NoteProperty -Name 'Pairs' -Value (, $properties);

      if ($affirm) {
        $result | Add-Member -MemberType NoteProperty -Name 'Affirm' -Value $true;
      }

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

    [string]$itemEmoji = $File.ToBool() ? '🏷️' : '📁';
    [string]$message = '   [{0}] Rename Item' -f $itemEmoji;
    [string[][]]$wideItems = @();
    [string[][]]$properties = @();

    if ($Pattern.Length -gt $WIDE_THRESHOLD) {
      $wideItems += , @('[*] Pattern', $Pattern);
    }
    else {
      $properties += , @('[*] Pattern', $Pattern);
    }

    if ($With -and $With.Length -gt 0) {
      if ($With.Length -gt $WIDE_THRESHOLD) {
        $wideItems += , @('[-] With', $With);
      }
      else {
        $properties += , @('[-] With', $With);
      }
    }

    [scriptblock]$getResult = {
      param($result)

      $result.GetType() -in @([System.IO.FileInfo], [System.IO.DirectoryInfo]) ? $result.Name : $result;
    }

    [System.Collections.Hashtable]$passThru = @{
      'LOOPZ.WH-FOREACH-DECORATOR.BLOCK'         = $doRenameFsItems;
      'LOOPZ.WH-FOREACH-DECORATOR.MESSAGE'       = $message;
      'LOOPZ.WH-FOREACH-DECORATOR.PRODUCT-LABEL' = $File.ToBool() ? 'File' : 'Directory';
      'LOOPZ.WH-FOREACH-DECORATOR.GET-RESULT'    = $getResult;

      'LOOPZ.HEADER-BLOCK.CRUMB'                 = '[🛡️] '
      'LOOPZ.HEADER-BLOCK.LINE'                  = $LoopzUI.DashLine;
      'LOOPZ.HEADER-BLOCK.MESSAGE'               = 'Rename';

      'LOOPZ.SUMMARY-BLOCK.LINE'                 = $LoopzUI.EqualsLine;
      'LOOPZ.SUMMARY-BLOCK.MESSAGE'              = '[💫] Rename Summary';

      'LOOPZ.RN-FOREACH.PATTERN'                 = $Pattern;
      'LOOPZ.RN-FOREACH.FS-ITEM-TYPE'            = $File.ToBool() ? 'FILE' : 'DIRECTORY';
      'LOOPZ.RN-FOREACH.WITH'                    = ($PSBoundParameters.ContainsKey('Target') -or
        $PSBoundParameters.ContainsKey('Start') -or $PSBoundParameters.ContainsKey('End')) `
        ? $Pattern : $With;
    }

    if ($First.ToBool()) {
      $properties += , @('[+] First', '[=]');
      $passThru['LOOPZ.RN-FOREACH.OCCURRENCE'] = 'FIRST';
      $passThru['LOOPZ.RN-FOREACH.QUANTITY-FIRST'] = $Quantity;
    }

    if ($Last.ToBool()) {
      $properties += , @('[+] Last', '[=]');
      $passThru['LOOPZ.RN-FOREACH.OCCURRENCE'] = 'LAST';
    }

    if ($wideItems.Length -gt 0) {
      $passThru['LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS'] = $wideItems;
    }

    if ($properties.Length -gt 0) {
      $passThru['LOOPZ.SUMMARY-BLOCK.PROPERTIES'] = $properties;
    }

    if ($Whole.ToBool()) {
      $passThru['LOOPZ.RN-FOREACH.WHOLE-WORD'] = $true;
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
      return ($pipelineItem.Name -match $Pattern) -and $clientCondition.Invoke($pipelineItem);
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

    $collection | Invoke-ForeachFsItem @parameters;
  }
}
