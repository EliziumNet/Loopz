---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Get-FormattedSignal

## SYNOPSIS

Controls and standardises the way that signals are displayed.

## SYNTAX

```powershell
Get-FormattedSignal [-Name] <String> [[-Format] <String>] [[-Value] <String>] [[-Signals] <Hashtable>]
 [[-CustomLabel] <String>] [[-EmojiOnlyFormat] <String>] [-EmojiOnly] [-EmojiAsValue] [<CommonParameters>]
```

## DESCRIPTION

  This function enables the display of key/value pairs where the key includes
an emoji. The value may also include the emoji depending on how the function
is used.
  Generally, this function returns either a Pair object or a single string.
The user can define a format string (or simply use the default) which controls
how the signal is displayed. If the function is invoked without a Value, then
a formatted string is returned other a pair object is returned.

## PARAMETERS

### -CustomLabel

An alternative label to display overriding the signal's defined label.

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

### -EmojiAsValue

switch which changes the result so that the emoji appears as part of the
value as opposed to the key.

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

### -EmojiOnly

Changes what is returned to be a single only whose formatted as EmojiOnlyFormat.

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

### -EmojiOnlyFormat

When the switch EmojiOnly is enabled, defines the format used to create
the result. Should contain at least 1 occurrence of {1} representing the
emoji.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Format

A string defining the format defining how the signal is displayed. Should
contain either {0} representing the signal's emoji or {1} the label. They
can appear as many time as is required, but there should be at least either
of these.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

The name of the signal

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Signals

The signals hashtable collection from which to select the signal from.

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

### -Value

A string defining the Value displayed when the signal is a Key/Value pair.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
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
