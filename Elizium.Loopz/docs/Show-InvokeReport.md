---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Show-InvokeReport

## SYNOPSIS

Given a list of parameters, shows which parameter set they resolve to. If they
don't resolve to a parameter set then this is reported. If the parameters
resolve to more than one parameter set, then all possible candidates are reported.
This is a helper function which end users and developers alike can use to determine
which parameter sets are in play for a given list of parameters. It was built to
counter the un helpful message one sees when a command is invoked either with
insufficient or an incorrect combination:

"Parameter set cannot be resolved using the specified named parameters. One or
more parameters issued cannot be used together or an insufficient number of
parameters were provided.".

Of course not all error scenarios can be detected, but some are which is better
than none. This command is a substitute for actually invoking the target command.
The target command may not be safe to invoke on an ad-hoc basis, so it's safer
to invoke this command specifying the parameters without their values.

## SYNTAX

```powershell
Show-InvokeReport [-Name] <String[]> -Params <String[]> [-Scribbler <Scribbler>] [-Common] [-Test]
 [<CommonParameters>]
```

## DESCRIPTION

If no errors were found with any the parameter sets for this command, then
  the result is simply a message indicating no problems found. If the user wants
  to just get the parameter set info for a command, then they can use command
  Show-ParameterSetInfo instead.

Parameter set violations are defined as rules. The following rules are defined:

- 'Non Unique Parameter Set': Each parameter set must have at least one unique
parameter. If possible, make this parameter a mandatory parameter.
- 'Non Unique Positions': A parameter set that contains multiple positional
parameters must define unique positions for each parameter. No two positional
parameters can specify the same position.
- 'Multiple Claims to Pipeline item': Only one parameter in a set can declare the
ValueFromPipeline keyword with a value of true.
- 'In All Parameter Sets By Accident': Defining a parameter with multiple
'Parameter Blocks', some with and some without a parameter set, is invalid.

## PARAMETERS

### -Common

switch to indicate if the standard PowerShell Common parameters show be included

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

The name of the command to show invoke report for

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Params

The set of parameter names the command is invoked for. This is like invoking the
command without specifying the values of the parameters.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
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
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Test

Required by unit tests only.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
