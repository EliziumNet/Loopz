---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# Get-SyntaxScheme

## SYNOPSIS

Get the scheme instance required by Command Syntax functionality in the
parameter set tools.

## SYNTAX

```powershell
Get-SyntaxScheme [[-Theme] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION

The scheme is related to the Krayola theme. Some of the entries in the scheme
are derived from the Krayola theme. The colours are subject to the presence of
the environment variable 'KRAYOLA_LIGHT_TERMINAL', this is to prevent light
foreground colours being selected when the background is also using light colours.

## PARAMETERS

### -Theme

The Krayola theme that the scheme will be associated with.

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

A command Syntax related scheme

## NOTES

## RELATED LINKS

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
