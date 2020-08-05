function Write-HostFeItemDecorator {
  <#
  .NAME
    Write-HostFeItemDecorator

  .SYNOPSIS
    Wraps a function or scriptblock as a decorator writing appropriate user interface
    info to the host for each entry in the pipeline.

  .DESCRIPTION
    The function being decorated may or may not Support ShouldProcess. If it does, then the
    client should add 'WHAT-IF' to the pass through, set to the current value of WhatIf;
    or more accurately the existence of 'WhatIf' in PSBoundParameters. Or another way of putting
    it is, the presence of WHAT-IF indicates SupportsShouldProcess, and the value of WHAT-IF
    dictates the value of WhatIf. This way, we only need a single value in the PassThru, rather
    than having to represent SupportShouldProcess explicitly with another value.
      The PastThru must contain either a 'FUNCTION-NAME' entry meaning a named function is
    being decorated or 'BLOCK' mean a script block is being decorated, but not both.
      PassThru must also contain either 'ITEM-LABEL' or 'PROPERTIES'. If there is only a single
    item that must be written out, then the user can specify a single value for 'ITEM-LABEL'
    and an accompanying 'ITEM-VALUE'. If there are multiple values, then 'PROPERTIES' must
    be specified and set to an array of key/value string pairs (so its an array of 2 item arrays).
      By default, to render the value displayed, ToString() is called. However, the result item
    may not have a ToString() method, in this case, the user should provide a custom script-block
    to determines how the value is constructed. This can be done by assigning a custom script-block
    to the 'GET-RESULT' entry in PassThru. 
      This function is designed to be used with Invoke-ForeachFsItem and as such, it's signature
    needs to match that required by Invoke-ForeachFsItem. Any additional parameters can be
    passed in via the PassThru.
      The rationale behind Write-HostFeItemDecorator is to maintain separation of concerns
    that allows development of functions that could be used with Invoke-ForeachFsItem which do
    not contain any UI related code. This strategy also helps for the development of different
    commands  that product output to the terminal in a consistent manner.

  .PARAMETER $Underscore
    The current pipeline object.

  .PARAMETER $Index
    the 0 based index representing current item in the pipeline.

  .PARAMETER $PassThru
    A hash table containing miscellaneous information gathered internally
    throughout the iteration batch. This can be of use to the user, because it is the way
    the user can perform bi-directional communication between the invoked custom script block
    and client side logic.

  .PARAMETER $Trigger
      A boolean value, useful for state changing idempotent operations. At the end
    of the batch, the state of the trigger indicates whether any of the items were actioned.
    When the script block is invoked, the trigger should indicate if the trigger was pulled for
    any of the items so far processed in the batch. This is the responsibility of the
    client's block implementation.

  .RETURNS
    The result of invoking the decorated script-block.

  .EXAMPLE

  function Test-FN {
    param(
      [System.IO.DirectoryInfo]$Underscore,
      [int]$Index,
      [System.Collections.Hashtable]$PassThru,
      [boolean]$Trigger,
    )

    $format = $PassThru['CLIENT.FORMAT'];
    @{ Product = $format -f $Underscore.Name, $Underscore.Exists }
    ...
  }

  [Systems.Collection.Hashtable]$passThru = @{
    'LOOPZ.FOREACH-DECORATOR.FUNCTION-NAME' = 'Test-FN';
    'LOOPZ.FOREACH-DECORATOR.ITEM-LABEL' = 'Widget'
    'LOOPZ.FOREACH-DECORATOR.ITEM-VALUE' = $widget,
    'CLIENT.FORMAT' = '=== [{0}] -- [{1}] ==='
  }

  Get-ChildItem ... | Invoke-ForeachFsItem -Path '<blah>' -PassThru $passThru
    -Functee 'Write-HostFeItemDecorator'

    So, Test-FN is not concerned about writing any output to the console, it simply does
  what it does silently and Write-HostFeItemDecorator handles generation of output. It
  invokes the function defined in 'LOOPZ.FOREACH-DECORATOR.FUNCTION-NAME' and generates
  corresponding output. It happens to use the console colouring facility provided by a 
  a dependency Elizium.Krayola to creating colourful in a predefined format via the
  Krayola Theme.

  Note, Write-HostFeItemDecorator does not forward additional parameters to the decorated
  function (Test-FN), but this can be circumvented via the PassThru as illustrated by
  the 'CLIENT.FORMAT' parameter in this example.

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
      Write-Warning "null custom properties defined in PassThru"
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
} # Write-HostFeItemDecorator
