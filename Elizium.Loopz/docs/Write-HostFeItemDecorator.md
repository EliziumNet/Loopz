---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Write-HostFeItemDecorator

## SYNOPSIS

Wraps a function or scriptblock as a decorator writing appropriate user interface
info to the host for each entry in the pipeline.

## SYNTAX

```powershell
Write-HostFeItemDecorator [-Underscore] <Object> [-Index] <Int32> [-PassThru] <Hashtable>
 [[-Trigger] <Boolean>] [<CommonParameters>]
```

## DESCRIPTION

The function being decorated may or may not Support ShouldProcess. If it does, then the
client should add 'WHAT-IF' to the pass through, set to the current value of WhatIf;
or more accurately the existence of 'WhatIf' in PSBoundParameters. Or another way of putting
it is, the presence of WHAT-IF indicates SupportsShouldProcess, and the value of WHAT-IF
dictates the value of WhatIf. This way, we only need a single value in the PassThru, rather
than having to represent SupportShouldProcess explicitly with another value.

  The PastThru must contain either a 'FUNCTION-NAME' entry meaning a named function is
being decorated or 'BLOCK' meaning a script block is being decorated, but not both.

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

## EXAMPLES

### Example 1

```powershell
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

  Get-ChildItem ... | Invoke-ForeachFsItem -Path <path> -PassThru $passThru
    -Functee 'Write-HostFeItemDecorator'
```

  So, Test-FN is not concerned about writing any output to the console, it simply does
what it does silently and Write-HostFeItemDecorator handles generation of output. It
invokes the function defined in 'LOOPZ.FOREACH-DECORATOR.FUNCTION-NAME' and generates
corresponding output. It happens to use the console colouring facility provided by a
a dependency Elizium.Krayola to creating colourful in a predefined format via the
Krayola Theme.

Note, Write-HostFeItemDecorator does not forward additional parameters to the decorated
function (Test-FN), but this can be circumvented via the PassThru as illustrated by
the 'CLIENT.FORMAT' parameter in this example.

## PARAMETERS

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

### -PassThru

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
