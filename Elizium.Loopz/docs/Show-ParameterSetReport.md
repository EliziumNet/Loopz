---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# Show-ParameterSetReport

## SYNOPSIS

Shows a reporting indicating problems with a command's parameter sets.

## SYNTAX

### ByName

```powershell
Show-ParameterSetReport [-Name] <String> [-Scribbler <Scribbler>] [-Test] [<CommonParameters>]
```

### ByPipeline

```powershell
Show-ParameterSetReport -InputObject <Array[]> [-Scribbler <Scribbler>] [-Test] [<CommonParameters>]
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

## EXAMPLES

### EXAMPLE 1 (CommandInfo via pipeline)

```powershell
Get Command Rename-Many | Show-ParameterSetReport
```

### EXAMPLE 2 (command name via pipeline)

```powershell
'Rename-Many' | Show-ParameterSetReport
```

### EXAMPLE 3 (By Name)

```powershell
Show-ParameterSetReport -Name 'Rename-Many'
```

## PARAMETERS

### -InputObject

Item(s) from the pipeline. Can be command/alias name of the command, or command/alias
info obtained via Get-Command.

```yaml
Type: Array[]
Parameter Sets: ByPipeline
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Name

The name of the command to show parameter set report for. Can be alias or full command name.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: True
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

### System.String[] or CommandInfo[]

Parameter `$Name`, can be CommandInfo derived from get-Command or simply the name of the command as a string. Multiple items can be specified using array notation.

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
