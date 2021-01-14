---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Format-Escape

## SYNOPSIS

Escapes the regular expression specified. This is just a wrapper around the
.net regex::escape method, but gives the user a much more user friendly to
invoke it from the command line

## SYNTAX

```powershell
Format-Escape [-pattern] <Object> [<CommonParameters>]
```

## DESCRIPTION

Various functions in Loopz have parameters that accept a regular expression. This
function gives the user an easy way to escape the regex, without them having to do
this manually themselves which could be tricky to get right depending on their
requirements.

## PARAMETERS

### -pattern

The source string to escape. (should really be called source)

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
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

### System.String

## NOTES

## RELATED LINKS
