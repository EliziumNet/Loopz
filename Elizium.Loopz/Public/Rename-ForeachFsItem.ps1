
function Rename-ForeachFsItem {
  [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'RenameFiles')]
  [Alias('rnfsi', 'rnall')]
  param
  (
    [Parameter(ParameterSetName = 'RenameFiles', Mandatory, ValueFromPipeline = $true)]
    [Parameter(ParameterSetName = 'RenameDirectories', Mandatory, ValueFromPipeline = $true)]
    [System.IO.FileSystemInfo]$underscore,

    [Parameter(ParameterSetName = 'RenameFiles')]
    [Parameter(ParameterSetName = 'RenameDirectories')]
    [scriptblock]$Condition = ( { return $true; }),

    [Parameter(ParameterSetName = 'RenameFiles', Mandatory)]
    [switch]$File,

    [Parameter(ParameterSetName = 'RenameDirectories', Mandatory)]
    [switch]$Directory,

    [Parameter(ParameterSetName = 'RenameFiles', Mandatory)]
    [Parameter(ParameterSetName = 'RenameDirectories', Mandatory)]
    [string]$Pattern,

    [Parameter(ParameterSetName = 'RenameFiles', Mandatory)]
    [Parameter(ParameterSetName = 'RenameDirectories', Mandatory)]
    [string]$With,

    [Parameter(ParameterSetName = 'RenameFiles')]
    [Parameter(ParameterSetName = 'RenameDirectories')]
    [ValidateScript( { -not($PSBoundParameters.ContainsKey('Last')) -and
        -not($PSBoundParameters.ContainsKey('Literal')) })]
    [switch]$First,

    [Parameter(ParameterSetName = 'RenameFiles')]
    [Parameter(ParameterSetName = 'RenameDirectories')]
    [ValidateScript( { -not($PSBoundParameters.ContainsKey('Last')) -and
        ($PSBoundParameters.ContainsKey('First')) })]
    [int]$Quantity = 1,

    [Parameter(ParameterSetName = 'RenameFiles')]
    [Parameter(ParameterSetName = 'RenameDirectories')]
    [ValidateScript( { -not($PSBoundParameters.ContainsKey('First')) })]
    [switch]$Last,

    [Parameter(ParameterSetName = 'RenameFiles')]
    [Parameter(ParameterSetName = 'RenameDirectories')]
    [switch]$Literal
  )

  begin {
    Write-Debug '>>> Rename-ForeachFsItem >>>';

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
      [boolean]$literalPattern = $_passThru.ContainsKey('LOOPZ.RN-FOREACH.LITERAL') -and `
        $_passThru['LOOPZ.RN-FOREACH.LITERAL'];
      [string]$replaceWith = $_passThru['LOOPZ.RN-FOREACH.WITH'];
      [boolean]$processingFiles = $_passThru['LOOPZ.RN-FOREACH.FS-ITEM-TYPE'] -eq 'FILE';
      [string]$newItemName = [string]::Empty;
      [boolean]$errorOccurred = $false;
      [int]$quantityFirst = $_passThru.ContainsKey('LOOPZ.RN-FOREACH.QUANTITY-FIRST') `
        ? $_passThru['LOOPZ.RN-FOREACH.QUANTITY-FIRST'] : 0;
      [string[][]]$properties = @();

      if ($_passThru.ContainsKey('LOOPZ.RN-FOREACH.OCCURRENCE')) {
        [string]$occurrence = $_passThru['LOOPZ.RN-FOREACH.OCCURRENCE'];

        switch ($occurrence) {
          'FIRST' {
            # https://stackoverflow.com/questions/40089631/replacing-only-the-first-occurrence-of-a-word-in-a-string
            # "caat" -replace '(.*?)a(.*)', '$1@$2'
            # replace the first a with @

            # Another solution:
            # $test = "My name is Bob, her name is Sara."
            # [regex]$pattern = "name"
            # $pattern.replace($test, "baby", 1) 
            #

            [regex]$patternRegEx = New-Object -TypeName [regex] -ArgumentList $replacePattern;
            $newItemName = ($patternRegEx.Replace($_underscore.Name, $replaceWith, $quantityFirst)).Trim();
            break;
          }

          'LAST' {
            # https://stackoverflow.com/questions/46124821/find-last-match-of-a-string-only-using-powershell

            # ANother:

            # $text = "This is the dawning of the age of Aquarius. The age of Aquarius, Aquarius, Aquarius, Aquarius, Aquarius"
            # $text -replace "(.*)Aquarius(.*)", '$1Bumblebee Joe$2'
            # This is the dawning of the age of Aquarius. The age of Aquarius, Aquarius, Aquarius, Aquarius, Bumblebee Joe

            if ($literalPattern) {
              # The user says the pattern ($replacePattern) is not a regular expression, so take it as it is
              #
              [string]$expression = "(.*){0}(.*)" -f $replacePattern;
              [string]$replacement = '$1{0}$2' -f $replaceWith;
              $newItemName = ($_underscore.Name -replace $expression, $replacement).Trim();
            }
            else {
              # The pattern is a regular expression. However, it is quite dangerous to use Last in
              # this scenario, so to be on the safe side, we'll ignore and register an error.
              #
              $errorOccurred = $true;
            }
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

          # First check if we only differ by case
          #
          if ($newItemName.ToLower() -eq $_.Name.ToLower()) {
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
  }

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

    if ($With.Length -gt $WIDE_THRESHOLD) {
      $wideItems += , @('[-] With', $With);
    }
    else {
      $properties += , @('[-] With', $With);
    }

    [System.Collections.Hashtable]$passThru = @{
      'LOOPZ.WH-FOREACH-DECORATOR.BLOCK'         = $doRenameFsItems;
      'LOOPZ.WH-FOREACH-DECORATOR.MESSAGE'       = $message;
      'LOOPZ.WH-FOREACH-DECORATOR.PRODUCT-LABEL' = $File.ToBool() ? 'File' : 'Directory';

      'LOOPZ.HEADER-BLOCK.CRUMB'                 = '[🛡️] '
      'LOOPZ.HEADER-BLOCK.LINE'                  = $LoopzUI.DashLine;
      'LOOPZ.HEADER-BLOCK.MESSAGE'               = 'Rename';

      'LOOPZ.SUMMARY-BLOCK.LINE'                 = $LoopzUI.EqualsLine;
      'LOOPZ.SUMMARY-BLOCK.MESSAGE'              = '[💫] Rename Summary';

      'LOOPZ.RN-FOREACH.PATTERN'                 = $Pattern;
      'LOOPZ.RN-FOREACH.WITH'                    = $With;
      'LOOPZ.RN-FOREACH.FS-ITEM-TYPE'            = $File.ToBool() ? 'FILE' : 'DIRECTORY';
    }

    if ($First.ToBool()) {
      $properties += @('[+] First', '[/]');
      $passThru['LOOPZ.RN-FOREACH.OCCURRENCE'] = 'FIRST';
      $passThru['LOOPZ.RN-FOREACH.QUANTITY-FIRST'] = $Quantity;
    }

    if ($Last.ToBool()) {
      $properties += @('[+] Last', '[/]');
      $passThru['LOOPZ.RN-FOREACH.OCCURRENCE'] = 'LAST';
    }

    if ($wideItems.Length -gt 0) {
      $passThru['LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS'] = $wideItems;
    }

    if ($properties.Length -gt 0) {
      $passThru['LOOPZ.SUMMARY-BLOCK.PROPERTIES'] = $properties;
    }

    if ($Literal.ToBool()) {
      $passThru['LOOPZ.RN-FOREACH.LITERAL'] = $true;
    }

    [System.Collections.Hashtable]$parameters = @{
      'Condition' = $Condition;
      'PassThru'  = $passThru;
      'Header'    = $LoopzHelpers.DefaultHeaderBlock;
      'Summary'   = $LoopzHelpers.SimpleSummaryBlock;
      'Block'     = $LoopzHelpers.WhItemDecoratorBlock;
    }

    if ($PSCmdlet.ParameterSetName -eq 'RenameFiles') {
      $parameters['File'] = $true;
    }
    else {
      $parameters['Directory'] = $true;
    }

    $collection | Invoke-ForeachFsItem @parameters;
  }
}
