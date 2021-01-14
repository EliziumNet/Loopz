---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# New-RegularExpression

## SYNOPSIS

regex factory function.

## SYNTAX

```powershell
New-RegularExpression [-Expression] <String> [-Escape] [-WholeWord] [-Label <String>] [<CommonParameters>]
```

## DESCRIPTION

Creates a regex object from the $Expression specified. Supports inline regex
flags ('mixsn') which must be specified at the end of the $Expression after a
'/'.

## PARAMETERS

### -Escape

switch parameter to indicate that the expression should be escaped. (This is an
alternative to the '~' prefix).

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

### -Expression

The pattern for the regular expression. If it starts with a tilde ('~'), then
the whole expression is escaped so any special regex characters are interpreted
literally.

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

### -Label

string that gives a name to the regular expression being created and is used for
logging/error reporting purposes only, so it's not mandatory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WholeWord

switch parameter to indicate the expression should be wrapped with word boundary
markers \b, so an $Expression defined as 'foo' would be adjusted to '\bfoo\b'.

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

### System.Text.RegularExpressions.Regex

## NOTES

## RELATED LINKS
