function Write-HostItemDecorator {
  <#
  .NAME
    Write-HostItemDecorator

  .SYNOPSIS
    Wraps a function or scriptbloack as a decorator writing appropriate user interface
    info to the host for each entry in the pipeline.

  .DESCRIPTION
    The function being decorated may or may not Support ShouldProcess. If it does, then the
    client should add 'WHAT-IF' to the pass through, set to the current value of WhatIf;
    or more accurately the existence of 'WhatIf' in PSBoundParameters. Or another way of putting
    it is, the presence of WHAT-IF indicates SupportsShouldProcess, and the value of WHAT-IF
    dictates the value of WhatIf. This way, we only need a single value in the PassThru, rather
    than having to represent SupportShouldProcess explicitly with another value.

  .PARAMETER $Underscore
    The iterated target item provided by the parent iterator function

  .PARAMETER $Index
    0 based numeric index specifing the ordinal of the iterated target.

  .PARAMETER $PassThru
    The dictionary object used to pass parameters to the decorated scriptblock
    (enclosed within the PassThru Hashtable)

  .PARAMETER $Trigger
    Indicates whether any of the previous items already processed in the pipeline batch
    have triggered.

  .RETURNS
    The result of invoking the BODY script block.
  #>

  [OutputType([PSCustomObject])]
  [CmdletBinding()]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
  param (
    [Parameter(
      Mandatory = $true
    )]
    $Underscore,

    [Parameter(
      Mandatory = $true
    )]
    [int]$Index,

    [Parameter(
      Mandatory = $true
    )]
    [ValidateScript( {
        return ($_.ContainsKey('FUNCTION-NAME') -xor $_.ContainsKey('BLOCK')) -and
          ($_.ContainsKey('ITEM-LABEL') -xor $_.ContainsKey('PROPERTIES'))
      })]
    [System.Collections.Hashtable]
    $PassThru,

    [Parameter()]
    [boolean]$Trigger
  )

  [scriptblock]$defaultGetResult = {
    param($result)
    try {
      $result.ToString();
    } catch {
      Write-Error "Default get-result function failed, consider defining custom function as 'GET-RESULT' in PassThru"
    }
  }

  [scriptblock]$decorator = {
    param ($_underscore, $_index, $_passthru, $_trigger)

    if ($_passthru.Contains('FUNCTION-NAME')) {
      [string]$functee = $_passthru['FUNCTION-NAME'];

      [System.Collections.Hashtable]$parameters = @{
        'Underscore' = $_underscore;
        'Index'      = $_index;
        'PassThru'   = $_passthru;
        'Trigger'    = $_trigger;
      }
      if ($_passthru.Contains('WHAT-IF')) {
        $parameters['WhatIf'] = $_passthru['WHAT-IF'];
      }

      return & $functee @parameters;
    }
    elseif ($_passthru.Contains('BLOCK')) {
      [scriptblock]$block = $_passthru['BLOCK'];

      return $block.Invoke($_underscore, $_index, $_passthru, $_trigger);
    }
  }

  $invokeResult = $decorator.Invoke($Underscore, $Index, $PassThru, $Trigger);

  [string]$message = $PassThru['MESSAGE'];
  [string]$itemLabel = $PassThru['ITEM-LABEL'];
  [string]$itemValue = $PassThru['ITEM-VALUE'];
  [string]$productValue = [string]::Empty;

  $getResult = $PassThru.Contains('GET-RESULT') ? $PassThru['GET-RESULT'] : $defaultGetResult;

  [string[][]]$themedPairs = @(, @('No', $("{0,3}" -f ($Index + 1))));

  # Get Product if it exists
  #
  [string]$productLabel = '';
  if ($invokeResult -and $invokeResult.Product) {
    $productValue = $getResult.Invoke($invokeResult.Product);
    $productLabel = $PassThru.ContainsKey('PRODUCT-LABEL') ? $PassThru['PRODUCT-LABEL'] : 'Product';

    if (-not([string]::IsNullOrWhiteSpace($productLabel))) {
      $themedPairs += , @($productLabel, $productValue);
    }
  }

  # PROPERTIES or ITEM-LABEL/ITEM-VALUE
  #
  if ($PassThru.Contains('PROPERTIES')) {
    $properties = $PassThru['PROPERTIES'];

    if ($properties) {
      if ($properties -is [Array]) {
        Write-Debug "No of custom propeties in PassThru: $($properties.Length)"
        $themedPairs += $properties;
      }
      else {
        Write-Warning "Custom 'PROPERTIES' in PassThru is not an array, skipping (type: $($properties.GetType()))"
        $themedPairs += , @('PROPERTIES', 'Malformed');
      }
    } else {
      Write-Warning "null custom propeties defined in PassThru"
      $themedPairs += , @('PROPERTIES', 'Malformed (null)');
    }

  } else {
    $themedPairs += , @($itemLabel, $itemValue);
  }

  # Write with a Krayola Theme
  #
  [System.Collections.Hashtable]$krayolaTheme = $PassThru.ContainsKey('KRAYOLA-THEME') ?
    $PassThru['KRAYOLA-THEME'] : (Get-KrayolaTheme);
  
  [System.Collections.Hashtable]$parameters = @{}
  $parameters['Pairs'] = $themedPairs;
  $parameters['Theme'] = $krayolaTheme;

  [string]$writerFn = 'Write-ThemedPairsInColour';

  if (-not([string]::IsNullOrWhiteSpace($message))) {
    $parameters['Message'] = $message;
  }

  if (-not([string]::IsNullOrWhiteSpace($writerFn))) {
    & $writerFn @parameters;
  }

  return $invokeResult;
}
