---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# New-Syntax

## SYNOPSIS

Get a new 'Syntax' object for a command.

## SYNTAX

```powershell
New-Syntax [-CommandName] <String> [[-Signals] <Hashtable>] [[-Scribbler] <Scribbler>] [[-Scheme] <Hashtable>]
 [<CommonParameters>]
```

## DESCRIPTION

The Syntax instance is a supporting class for the parameter set tools. It contains
various formatters, string definitions and utility functionality. The primary feature
it contains is that relating to the colouring in of the standard syntax statement
that is derived from a commands parameter set.

## PARAMETERS

### -CommandName

The name of the command to get syntax instance for

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

### -Scheme

The hashtable syntax specific scheme instance

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

### -Scribbler

The Krayola scribbler instance used to manage rendering to console

```yaml
Type: Scribbler
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Signals

The signals hashtable collection

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

A new syntax instance

## NOTES

## RELATED LINKS

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
