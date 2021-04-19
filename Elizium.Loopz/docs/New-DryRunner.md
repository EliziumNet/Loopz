---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# New-DryRunner

## SYNOPSIS

Dry-Runner factory function

## SYNTAX

```powershell
New-DryRunner [[-CommandName] <String>] [[-Signals] <Hashtable>] [[-Scribbler] <Scribbler>]
 [<CommonParameters>]
```

## DESCRIPTION

The Dry-Runner is used by the Show-InvokeReport command. The DryRunner can
be used in unit-tests to ensure that expected parameters can be used to
invoke the function without causing errors. In the unit tests, the client just needs
to instantiate the DryRunner (using this function) then pass in an expected list
of parameters to the Resolve method. The test case can review the result parameter
set(s) and assert as appropriate. (Actually, a developer can also use the
RuleController class in unit tests to check that commands do not violate the
parameter set rules.)

## PARAMETERS

### -CommandName

The name of the command to get DryRunner instance for

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scribbler

The Krayola scribbler instance used to manage rendering to console

```yaml
Type: Scribbler
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Signals

The signals hashtable collection

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

A new DryRunner instance

## NOTES

## RELATED LINKS

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
