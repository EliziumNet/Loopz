---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Format-StructuredLine

## SYNOPSIS

Helper function to make it easy to generate a line to be displayed.

## SYNTAX

```
Format-StructuredLine [-Exchange] <Hashtable> [-LineKey] <String> [[-CrumbKey] <String>]
 [[-MessageKey] <String>] [-Truncate] [[-Krayon] <Krayon>] [[-Options] <PSObject>] [<CommonParameters>]
```

## DESCRIPTION

A structured line is some text that includes embedded colour instructions that
will be interpreted by the Krayola krayon writer. This function behaves like a
layout manager for a single line.

## PARAMETERS

### -CrumbKey

The key used to index into the $Exchange hashtable to denote which crumb is used.

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

### -Exchange

The exchange hashtable object.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Krayon

The writer object which contains the Krayola theme.

```yaml
Type: Krayon
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LineKey

The key used to index into the $Exchange hashtable to denote the core line.

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

### -MessageKey

The key used to index into the $Exchange hashtable to denote what message to display.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Options

+ this is the crumb
|
V                                                           <-- message ->|
[@@] --------------------------------------------------- [  Rename (WhatIf) ] ---
                                                                            |<-- This is a trailing wing
                                                                            whose length is WingLength
     |<--- flex part (which must be at least   -------->|
                    MinimumFlexSize in length, it shrinks to accommodate the message)

A PSCustomObject that allows further customisation of the structured line. Can contain the following
fields:

+ WingLength: The size of the lead and tail portions of the line ('---')
+ MinimumFlexSize: The smallest size that the flex part can shrink to, to accommodate
the message. If the message is so large that is pushes up against the minimal flex size
it will be truncated according to the presence of Truncate switch
+ Ellipses: When message truncation occurs, the ellipses string is used to indicate that
the message has been truncated.
+ WithLead: boolean flag to indicate whether a leading wing is displayed which would precede
the crumb. In the above example and by default, there is no leading wing.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Truncate

switch parameter to indicate whether the message is truncated to fit the line length.

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

### System.String

## NOTES

## RELATED LINKS
