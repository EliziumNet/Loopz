---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Show-Signals

## SYNOPSIS

Shows all defined signals, including user defined signals.

## SYNTAX

```powershell
Show-Signals [[-SourceSignals] <Hashtable>] [[-Custom] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION

User can override signal definitions in their profile, typically using the provided
function Update-CustomSignals.

## PARAMETERS

### -Custom

(User does not need to provide this parameter; required for testing purpose only)

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

### -SourceSignals

(User does not need to provide this parameter; required for testing purpose only)

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
