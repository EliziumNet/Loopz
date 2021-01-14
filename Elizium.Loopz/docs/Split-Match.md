---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Split-Match

## SYNOPSIS

Function to display summary as part of an iteration batch.

## SYNTAX

```powershell
Split-Match [-Source] <String> [[-PatternRegEx] <Regex>] [[-Occurrence] <String>] [-CapturedOnly]
 [[-Marker] <Char>] [<CommonParameters>]
```

## DESCRIPTION

Helper function to get the pattern match and the remaining text. This helper
helps us to avoid unnecessary duplicated reg ex matches. It returns
up to 3 items inside an array, the first is the matched text, the second is
the source with the matched text removed and the third is the match object
that represents the matched text.

## PARAMETERS

### -CapturedOnly

switch parameter to indicate what should be returned. When the client does not need
the match object or the remainder, they can use this switch to ensure only the matched
text is returned.

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

### -Marker

A character used to mark the place where the $PatternRegEx's match was removed from.
It should be a special character that is not easily typed on the keyboard by the user
so as to not interfere wth $Anchor/$Copy matches which occur after $Pattern match is
removed.

```yaml
Type: Char
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Occurrence

Denotes which match should be used.

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

### -PatternRegEx

The regex object to apply to the $Source.

```yaml
Type: Regex
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Source

The source value against which regular expression is applied.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
