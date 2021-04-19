---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
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

## EXAMPLES

### EXAMPLE 1

```powershell
New-RegularExpression -Expression '(?\<y\>\d{4})-(?\<m\>\d{2})-(?\<d\>\d{2})'
```

Create a regular expression

### EXAMPLE 2 (with WholeWord)

```powershell
New-RegularExpression -Expression '(?\<y\>\d{4})-(?\<m\>\d{2})-(?\<d\>\d{2})' -WholeWord
```

Apply whole word semantics, by surrounding the pattern with word boundary token: '\b'

### EXAMPLE 3 (Escaped)

```powershell
New-RegularExpression -Expression '(123)' -Escape
```

Escape the whole pattern.

### EXAMPLE 4 (Escaped with leading ~)

```powershell
New-RegularExpression -Expression '~(123)'
```

Escape the whole pattern with leading ~.

### EXAMPLE 5 (Create a case insensitive expression)

```powershell
New-RegularExpression -Expression 'DATE/i'
```

Create a case insensitive expression via inline options

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

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
