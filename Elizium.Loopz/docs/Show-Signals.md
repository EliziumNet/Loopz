---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# Show-Signals

## SYNOPSIS

Shows all defined signals, including user defined signals.

## SYNTAX

```powershell
Show-Signals [[-SourceSignals] <Hashtable>] [-Registry <Hashtable>] [-Include <String[]>] [-Test]
 [<CommonParameters>]
```

## DESCRIPTION

User can override signal definitions in their profile, typically using the provided function Update-CustomSignals.

## EXAMPLES

### EXAMPLE 1

```powershell
Show-Signals
```

Show signal definitions and references for all registered commands

### EXAMPLE 2

```powershell
Show-Signals -Include remy, ships
```

Show the signal definitions and references for commands 'remy' and 'ships' only

## PARAMETERS

### -SourceSignals

Hashtable containing signals to be displayed.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Include

Provides a filter. When specified, only the applications included in the list will be shown.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Registry

Hashtable containing information concerning commands usage of signals.

```yaml
Type: Hashtable
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

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
