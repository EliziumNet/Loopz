---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Select-SignalContainer

## SYNOPSIS

Selects a signal into the container specified (either 'Wide' or 'Props').
Wide items will appear on their own line, Props are for items which are
short in length and can be combined into the same line.

## SYNTAX

```powershell
Select-SignalContainer [-Containers] <PSObject> [-Name] <String> [-Value] <String> [[-Signals] <Hashtable>]
 [[-Format] <String>] [[-Threshold] <Int32>] [[-CustomLabel] <String>] [[-Force] <String>] [<CommonParameters>]
```

## DESCRIPTION

This is a wrapper around Get-FormattedSignal in addition to selecting the
signal into a container.

## PARAMETERS

### -Containers

PSCustomObject that contains Wide and Props properties which must be of Krayola's
type [line]

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CustomLabel

A custom label applied to the formatted signal.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force

An override (bypassing $Threshold) to push a signal into a specific collection.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Wide, Props

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Format

The format applied to the formatted signal.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

The signal name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Signals

The signal hashtable collection from which to select the required signal denoted by
$Name.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Threshold

A threshold that defines whether the signal is added to Wide or Props.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value

The value associated wih the signal.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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
