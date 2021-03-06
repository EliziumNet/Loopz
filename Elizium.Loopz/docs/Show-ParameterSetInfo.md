---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# Show-ParameterSetInfo

## SYNOPSIS

Displays information for a commands parameter sets. This includes the standard
syntax statement associated with each parameter set, but is also coloured in, to help
readability.

## SYNTAX

```powershell
Show-ParameterSetInfo [-Name] <String[]> [[-Sets] <String[]>] [-Scribbler <Scribbler>] [-Title <String>]
 [-Common] [-Test] [<CommonParameters>]
```

## DESCRIPTION

If the command does not define parameter sets, then no information is displayed
apart from a message indicating no parameter sets were found.

One of the issues that a developer can encounter when designing parameter sets for
a command is making sure that each parameter set includes at least 1 unique parameter
as per recommendations. This function will greatly help in this regard. For each
parameter set shown, the table it contains includes a 'Unique' column which shows
whether a the parameter is unique to that parameter set. This relieves the developer
from having to figure this out themselves.

## EXAMPLES

### EXAMPLE 1 (Show all parameter sets, CommandInfo via pipeline)

```powershell
Get-Command 'Rename-Many' | Show-ParameterSetInfo
```

### EXAMPLE 2 (Show all parameter sets with Common parameters, command name via pipeline)

```powershell
'Rename-Many' | Show-ParameterSetInfo -Common
```

### EXAMPLE 3 (Show specified parameter sets, command name via pipeline)

```powershell
'Rename-Many' | Show-ParameterSetInfo -Sets MoveToAnchor, UpdateInPlace
```

### EXAMPLE 4 (By Name)

```powershell
Show-ParameterSetInfo -Name 'Rename-Many' -Sets MoveToAnchor, UpdateInPlace
```

## PARAMETERS

### -Common

switch to indicate if the standard PowerShell Common parameters should be included

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

The name of the command to show parameter set info report for. Can be alias or full command name.

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

### -Sets

A list of parameter sets the output should be restricted to. When not specified, all
parameter sets are displayed.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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

### -Title

The text displayed as a title. End user does not have to specify this value. It is useful
to other client command that invoke this one, so some context can be added to the display.

```yaml
Type: String
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
