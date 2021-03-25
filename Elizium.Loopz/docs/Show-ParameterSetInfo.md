---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
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

### System.String[]

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
