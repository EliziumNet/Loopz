---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# Get-Signals

## SYNOPSIS

Returns a copy of the Signals hashtable.

## SYNTAX

```powershell
Get-Signals [[-SourceSignals] <Hashtable>] [[-Custom] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION

The signals returned include the user defined signal overrides.

NOTE: 3rd party commands need to register their signal usage with the signal
registry. This can be done using command Register-CommandSignals and would
be best performed at module initialisation stage invoked at import time.

## PARAMETERS

### -Custom

The hashtable instance containing custom overrides. Does not need to be
specified by the client as it is defaulted.

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

The hashtable instance containing the source signal definitions. The actual signals
returned are derived from the source. Does not need to be specified by the client as
it is defaulted.

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

### System.Collections.Hashtable

The resolved Signal definitions.

## NOTES

## RELATED LINKS

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
