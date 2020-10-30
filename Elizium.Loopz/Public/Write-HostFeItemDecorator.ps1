function Write-HostFeItemDecorator {
  <#
  .NAME
    Write-HostFeItemDecorator

  .SYNOPSIS
    Wraps a function or scriptblock as a decorator writing appropriate user interface
    info to the host for each entry in the pipeline.

  .DESCRIPTION
      The script-block/function (invokee) being decorated may or may not Support ShouldProcess. If it does,
    then the client should add 'WHAT-IF' to the pass through, set to the current
    value of WhatIf; or more accurately the existence of 'WhatIf' in PSBoundParameters. Or another
    way of putting it is, the presence of WHAT-IF indicates SupportsShouldProcess, and the value of
    'WHAT-IF' dictates the value of WhatIf. This way, we only need a single
    value in the PassThru, rather than having to represent SupportShouldProcess explicitly with
    another value.
      The PastThru must contain either a 'LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME' entry meaning
    a named function is being decorated or 'LOOPZ.WH-FOREACH-DECORATOR.BLOCK' meaning a script
    block is being decorated, but not both.
      By default, Write-HostFeItemDecorator will display an item no for each object in the pipeline
    and a property representing the Product. The Product is a property that the invokee can set on the
    PSCustomObject it returns. However, additional properties can be displayed. This can be achieved by
    the invokee populating another property Pairs, which is an array of string based key/value pairs. All
    properties found in Pairs will be written out by Write-HostFeItemDecorator.
      By default, to render the value displayed (ie the 'Product' property item on the PSCustomObject
    returned by the invokee), ToString() is called. However, the 'Product' property may not have a
    ToString() method, in this case (you will see an error indicating ToString method not being
    available), the user should provide a custom script-block to determine how the value is
    constructed. This can be done by assigning a custom script-block to the
    'LOOPZ.WH-FOREACH-DECORATOR.GET-RESULT' entry in PassThru. eg:

      [scriptblock]$customGetResult = {
        param($result)
        $result.SomeCustomPropertyOfRelevanceThatIsAString;
      }
      $PassThru['LOOPZ.WH-FOREACH-DECORATOR.GET-RESULT'] = $customGetResult;
      ...

      Note also, the user can provide a custom 'GET-RESULT' in order to control what is displayed
    by Write-HostFeItemDecorator.

      This function is designed to be used with Invoke-ForeachFsItem and as such, it's signature
    needs to match that required by Invoke-ForeachFsItem. Any additional parameters can be
    passed in via the PassThru.
      The rationale behind Write-HostFeItemDecorator is to maintain separation of concerns
    that allows development of functions that could be used with Invoke-ForeachFsItem which do
    not contain any UI related code. This strategy also helps for the development of different
    commands that produce output to the terminal in a consistent manner.

  .PARAMETER $Underscore
    The current pipeline object.

  .PARAMETER $Index
    The 0 based index representing current item in the pipeline.

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

  .EXAMPLE 1

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
    'LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME' = 'Test-FN';
    'CLIENT.FORMAT' = '=== [{0}] -- [{1}] ==='
  }

  Get-ChildItem ... | Invoke-ForeachFsItem -Path <path> -PassThru $passThru
    -Functee 'Write-HostFeItemDecorator'

    So, Test-FN is not concerned about writing any output to the console, it simply does
  what it does silently and Write-HostFeItemDecorator handles generation of output. It
  invokes the function defined in 'LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME' and generates
  corresponding output. It happens to use the console colouring facility provided by a
  a dependency Elizium.Krayola to create colourful output in a predefined format via the
  Krayola Theme.

  Note, Write-HostFeItemDecorator does not forward additional parameters to the decorated
  function (Test-FN), but this can be circumvented via the PassThru as illustrated by
  the 'CLIENT.FORMAT' parameter in this example.

  #>

  [OutputType([PSCustomObject])]
  [CmdletBinding()]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
  [Alias('wife', 'Decorate-Foreach')]
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
        return ($_.ContainsKey('LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME') -xor
          $_.ContainsKey('LOOPZ.WH-FOREACH-DECORATOR.BLOCK'))
      })]
    [System.Collections.Hashtable]
    $PassThru,

    [Parameter()]
    [boolean]$Trigger
  )

  [scriptblock]$defaultGetResult = {
    param($result)
    $result.ToString();
  }

  [scriptblock]$decorator = {
    param ($_underscore, $_index, $_passthru, $_trigger)

    if ($_passthru.Contains('LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME')) {
      [string]$functee = $_passthru['LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME'];

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
    elseif ($_passthru.Contains('LOOPZ.WH-FOREACH-DECORATOR.BLOCK')) {
      [scriptblock]$block = $_passthru['LOOPZ.WH-FOREACH-DECORATOR.BLOCK'];

      return $block.Invoke($_underscore, $_index, $_passthru, $_trigger);
    }
  }

  $invokeResult = $decorator.Invoke($Underscore, $Index, $PassThru, $Trigger);

  [string]$message = $PassThru['LOOPZ.WH-FOREACH-DECORATOR.MESSAGE'];
  [string]$productValue = [string]::Empty;
  [boolean]$ifTriggered = $PassThru.ContainsKey('LOOPZ.WH-FOREACH-DECORATOR.IF-TRIGGERED');
  [boolean]$resultIsTriggered = $invokeResult.psobject.properties.match('Trigger') -and $invokeResult.Trigger;

  # Suppress the write if client has set IF-TRIGGERED and the result is not triggered.
  # This makes re-runs of a state changing operation less verbose if that's  required.
  #
  if (-not($ifTriggered) -or ($resultIsTriggered)) {
    $getResult = $PassThru.Contains('LOOPZ.WH-FOREACH-DECORATOR.GET-RESULT') `
      ? $PassThru['LOOPZ.WH-FOREACH-DECORATOR.GET-RESULT'] : $defaultGetResult;

    [string[][]]$themedPairs = @(, @('No', $("{0,3}" -f ($Index + 1))));

    # Get Product if it exists
    #
    [string]$productLabel = [string]::Empty;
    if ($invokeResult -and $invokeResult.psobject.properties.match('Product') -and $invokeResult.Product) {
      [boolean]$affirm = $invokeResult.psobject.properties.match('Affirm') -and $invokeResult.Affirm;
      $productValue = $getResult.Invoke($invokeResult.Product);
      $productLabel = $PassThru.ContainsKey('LOOPZ.WH-FOREACH-DECORATOR.PRODUCT-LABEL') `
        ? $PassThru['LOOPZ.WH-FOREACH-DECORATOR.PRODUCT-LABEL'] : 'Product';

      if (-not([string]::IsNullOrWhiteSpace($productLabel))) {
        $themedPairs += , @($productLabel, $productValue, $affirm);
      }
    }

    # Get Key/Value Pairs
    #
    if ($invokeResult -and $invokeResult.psobject.properties.match('Pairs') -and
      $invokeResult.Pairs -and ($invokeResult.Pairs -is [Array]) -and ($invokeResult.Pairs.Count -gt 0)) {
      $themedPairs += $invokeResult.Pairs;
    }

    # Write with a Krayola Theme
    #
    [System.Collections.Hashtable]$krayolaTheme = `
      $PassThru.ContainsKey('LOOPZ.KRAYOLA-THEME') `
      ? $PassThru['LOOPZ.KRAYOLA-THEME'] : (Get-KrayolaTheme);

    [System.Collections.Hashtable]$parameters = @{}
    $parameters['Pairs'] = $themedPairs;
    $parameters['Theme'] = $krayolaTheme;

    if (-not([string]::IsNullOrWhiteSpace($message))) {
      $parameters['Message'] = $message;
    }

    # Write the primary line
    #
    Write-ThemedPairsInColour @parameters;

    # Write additional lines
    #
    if ($invokeResult -and $invokeResult.psobject.properties.match('Lines') -and $invokeResult.Lines) {
      [int]$indent = $PassThru.ContainsKey('LOOPZ.WH-FOREACH-DECORATOR.INDENT') `
        ? $PassThru['LOOPZ.WH-FOREACH-DECORATOR.INDENT'] : 3;
      $parameters['Message'] = [string]::new(' ', $indent);

      [System.Collections.Hashtable]$adjustedTheme = $krayolaTheme.Clone();
      $adjustedTheme['MESSAGE-SUFFIX'] = [string]::Empty;
      $adjustedTheme['OPEN'] = [string]::Empty;
      $adjustedTheme['CLOSE'] = [string]::Empty;
      $parameters['Theme'] = $adjustedTheme;

      foreach ($line in $invokeResult.Lines) {
        $parameters['Pairs'] = @(, $line);
        Write-ThemedPairsInColour @parameters;
      }
    }
  }

  return $invokeResult;
} # Write-HostFeItemDecorator
