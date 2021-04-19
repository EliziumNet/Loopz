---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# Resolve-PatternOccurrence

## SYNOPSIS

Helper function to assist in processing regular expression parameters that can
be adorned with an occurrence value.

## SYNTAX

```powershell
Resolve-PatternOccurrence [[-Value] <Array>] [<CommonParameters>]
```

## DESCRIPTION

Since the occurrence part is optional and defaults to mean first occurrence only,
this function will fill in the default 'f' when occurrence is not specified.

## PARAMETERS

### -Value

The value of a regex parameter, which is an array whose first element is the
pattern and the second if present is the match occurrence.

```yaml
Type: Array
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
