---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# Select-Patterns

## SYNOPSIS

This is a simplified yet enhanced version of standard Select-String command (or
the grep command on Linux/Unix/mac) that allows the user to run multiple searches
which are chained together to produce its final result.

## SYNTAX

```powershell
greps [-patterns] <String[]> [[-filter] <String>] [<CommonParameters>]
```

## DESCRIPTION

The main rationale for using this command ("greps" as in multiple grep invokes) instead
of Select-String, is for the provision of multiple patterns. Now, Select-String does
allow the user to provide multiple Patterns, but the result is a logical OR rather
than an AND. greps uses AND by piping the result of each individual Pattern search to
the next Pattern search so the result is those lines found that match all the patterns
provided rather than all lines that match 1 or more of the patterns. The user can achieve
OR functionality by using a | inside the same string; for example to find all lines
that contain any of the patterns 'red', 'green' or 'blue', they could just use
'red|green|blue'.

At the end of the run, greps displays the full command (containing multiple pipeline
legs, one for each pattern provided). If so required, the user can re-run the command
by running the full command which is displayed and providing different parameters not
directly supported by greps.

'greps', does not currently support input from the pipeline. Perhaps this will be
implemented in a future release.

At some point in the future, it is intended to further enhance greps using a coloured
output, whereby a colour is assigned to each pattern and that colour is used to render the
result. So where the user has provided multiple patterns, currently, only the first pattern
is highlighted in the result. With the coloured enhancement, the user will be able to see
all pattern matches in the result with each match displayed in the corresponding allocated
colour.

## EXAMPLES

### Example 1

```powershell
greps red, blue *.txt
```

Show lines in all .txt files in the current directory files that contain the patterns
'red' and 'blue'

### Example 2

```powershell
greps 'green lorry', 'yellow lorry' ~/*.txt
```

Show lines in all .txt files in home directory that contain the patterns 'green lorry' and
'yellow lorry'

### Example 3

```powershell
greps foo, !bar
```

Show lines in all files defined in environment as 'LOOPZ_GREPS_FILTER' that contains
'foo' but not 'bar'

## PARAMETERS

### -filter

Defines which files are considered in the search. It can be a path with a wildcard or
simply a wildcard. If its just a wildcard (eg *.txt), then files considered will be from
the current directory only.

The user can define a default filter in the environment as variable 'LOOPZ_GREPS_FILTER'
which should be a glob such as '*.txt' to represent all text files. If no filter parameter
is supplied to the greps invoke, then the filter is defined by the value of
'LOOPZ_GREPS_FILTER'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Patterns

An array of patterns. The result shows all lines that match all the patterns specified.
An individual pattern can be prefixed with a not op: '!', which means exclude those lines
which match the subsequent pattern; it is a more succinct way of specifying the -NotMatch
operator on Select-String. The '!' is not part of the pattern.

```yaml
Type: String[]
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

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
