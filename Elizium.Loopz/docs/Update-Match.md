---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Update-Match

## SYNOPSIS

The core update match action function principally used by Rename-Many. Updates
$Pattern match in it's current location.

## SYNTAX

```powershell
Update-Match [-Value] <String> [-Pattern] <Regex> [[-PatternOccurrence] <String>] [[-Copy] <Regex>]
 [[-CopyOccurrence] <String>] [[-With] <String>] [[-Paste] <String>] [-Diagnose] [<CommonParameters>]
```

## DESCRIPTION

Returns a new string that reflects updating the specified $Pattern match.
First Update-Match, removes the Pattern match from $Value.
This makes the With and Copy match against the remainder ($patternRemoved) of $Value.
This way, there is no overlap between the Pattern match and $With and it also makes the functionality more understandable for the user.
NB: Pattern only tells you what to remove, but it's the With, Copy and Paste that defines what to insert.
The user should not be using named capture groups in Copy rather, they should be defined inside $Paste and referenced inside Paste.

## PARAMETERS

### -Copy

Regular expression string applied to $Value (after the $Pattern match has been removed), indicating a portion which should be copied and re-inserted (via the $Paste parameter; see $Paste or $With).
Since this is a regular expression to be used in $Paste/$With, there is no value in the user specifying a static pattern, because that static string can just be defined in $Paste/$With.
The value in the $Copy parameter comes when a generic pattern is defined eg \d{3} (is non static), specifies any 3 digits as opposed to say '123', which could be used directly in the $Paste/$With parameter without the need for $Copy.
The match defined by $Copy is stored in special variable ${_p} and can be referenced as such from $Paste and $With.

```yaml
Type: Regex
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CopyOccurrence

Can be a number or the letters f, l

* f: first occurrence
* l: last occurrence
* \<number\>: the nth occurrence

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

### -Diagnose

switch parameter that indicates the command should be run in WhatIf mode.
When enabled it presents additional information that assists the user in correcting the un-expected results caused by an incorrect/un-intended regular expression.
The current diagnosis will show the contents of named capture groups that they may have specified.
When an item is not renamed (usually because of an incorrect regular expression), the user can use the diagnostics along side the 'Not Renamed' reason to track down errors.
When $Diagnose has been specified, $WhatIf does not need to be specified.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Paste

This is a NON regular expression string.
It would be more accurately described as a formatter, similar to the $With parameter.
The other special variables that can be used inside a $Paste string is documented under the $With parameter.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Pattern

Regular expression string that indicates which part of the $Value that either needs to be moved or replaced as part of overall rename operation.
Those characters in $Value which match $Pattern, are removed.

```yaml
Type: Regex
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PatternOccurrence

Can be a number or the letters f, l

* f: first occurrence
* l: last occurrence
* \<number\>: the nth occurrence

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

### -Value

The source value against which regular expressions are applied.

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

### -With

This is a NON regular expression string.
It would be more accurately described as a formatter, similar to the $Paste parameter.
Defines what text is used as the replacement for the $Pattern match.
Works in concert with $Relation (whereas $Paste does not).
$With can reference special variables:

* $0: the pattern match
* ${_c}: the copy match

When $Pattern contains named capture groups, these variables can also be referenced.
Eg if the $Pattern is defined as '(?\<day\>\d{1,2})-(?\<mon\>\d{1,2})-(?\<year\>\d{4})', then the variables ${day}, ${mon} and ${year} also become available for use in $With or $Paste.
Typically, $With is static text which is used to replace the $Pattern match.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.String

Returns the string which reflects match update operation.

## NOTES

## RELATED LINKS
