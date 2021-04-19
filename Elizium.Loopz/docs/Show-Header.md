---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# Show-Header

## SYNOPSIS

Function to display header as part of an iteration batch.

## SYNTAX

```powershell
Show-Header [[-Exchange] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION

Behaviour can be customised by the following entries in the Exchange:

* 'LOOPZ.KRAYON' (mandatory): the Krayola Krayon writer object.
* 'LOOPZ.HEADER-BLOCK.MESSAGE': The custom message to be displayed as
part of the header.
* 'LOOPZ.HEADER.PROPERTIES': A Krayon [line] instance contain a collection
of Krayola [couplet]s. When present, the header displayed will be a static
line, the collection of these properties then another static line.
* 'LOOPZ.HEADER-BLOCK.LINE': The static line text. The length of this line controls
how everything else is aligned (ie the flex part and the message if present).

## PARAMETERS

### -Exchange

The exchange hashtable object.

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

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
