---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# Write-HostFeItemDecorator

## SYNOPSIS

Wraps a function or script-block as a decorator writing appropriate user interface
info to the host for each entry in the pipeline.

## SYNTAX

```powershell
Write-HostFeItemDecorator [-Underscore] <Object> [-Index] <Int32> [-Exchange] <Hashtable>
 [[-Trigger] <Boolean>] [<CommonParameters>]
```

## DESCRIPTION

The script-block/function (invokee) being decorated may or may not Support ShouldProcess. If it does,
then the client should add 'WHAT-IF' to the pass through, set to the current
value of WhatIf; or more accurately the existence of 'WhatIf' in PSBoundParameters. Or another
way of putting it is, the presence of WHAT-IF indicates SupportsShouldProcess, and the value of
'WHAT-IF' dictates the value of WhatIf. This way, we only need a single
value in the Exchange, rather than having to represent SupportShouldProcess explicitly with
another value.

The Exchange must contain either a 'LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME' entry meaning
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
'LOOPZ.WH-FOREACH-DECORATOR.GET-RESULT' entry in Exchange. eg:

[scriptblock]$customGetResult = {
  param($result)
  $result.SomeCustomPropertyOfRelevanceThatIsAString;
}
$Exchange['LOOPZ.WH-FOREACH-DECORATOR.GET-RESULT'] = $customGetResult;
...

Note also, the user can provide a custom 'GET-RESULT' in order to control what is displayed
by Write-HostFeItemDecorator.

This function is designed to be used with Invoke-ForeachFsItem and as such, it's signature
needs to match that required by Invoke-ForeachFsItem. Any additional parameters can be
passed in via the Exchange.

The rationale behind Write-HostFeItemDecorator is to maintain separation of concerns
that allows development of functions that could be used with Invoke-ForeachFsItem which do
not contain any UI related code. This strategy also helps for the development of different
commands that produce output to the terminal in a consistent manner.

## EXAMPLES

### Example 1

```powershell
  function Test-FN {
    param(
      [System.IO.DirectoryInfo]$Underscore,
      [int]$Index,
      [hashtable]$Exchange,
      [boolean]$Trigger,
    )

    $format = $Exchange['CLIENT.FORMAT'];
    @{ Product = $format -f $Underscore.Name, $Underscore.Exists }
    ...
  }

  [Systems.Collection.Hashtable]$exchange = @{
    'LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME' = 'Test-FN';
    'CLIENT.FORMAT' = '=== [{0}] -- [{1}] ==='
  }

  Get-ChildItem ... | Invoke-ForeachFsItem -Path <path> -Exchange $exchange
    -Functee 'Write-HostFeItemDecorator'
```

So, Test-FN is not concerned about writing any output to the console, it simply does
what it does silently and Write-HostFeItemDecorator handles generation of output. It
invokes the function defined in 'LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME' and generates
corresponding output. It happens to use the console colouring facility provided by a
a dependency Elizium.Krayola to create colourful output in a predefined format via the
Krayola Theme.

Note, Write-HostFeItemDecorator does not forward additional parameters to the decorated
function (Test-FN), but this can be circumvented via the Exchange as illustrated by
the 'CLIENT.FORMAT' parameter in this example.

## PARAMETERS

### -Exchange

A hash table containing miscellaneous information gathered internally
throughout the iteration batch. This can be of use to the user, because it is the way
the user can perform bi-directional communication between the invoked custom script block
and client side logic.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Index

The 0 based index representing current item in the pipeline.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Trigger

A boolean value, useful for state changing idempotent operations. At the end
of the batch, the state of the trigger indicates whether any of the items were actioned.
When the script block is invoked, the trigger should indicate if the trigger was pulled for
any of the items so far processed in the batch. This is the responsibility of the
client's block implementation.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Underscore

The current pipeline object.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES

## RELATED LINKS

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
