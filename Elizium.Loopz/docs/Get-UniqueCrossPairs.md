---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# Get-UniqueCrossPairs

## SYNOPSIS

Given 2 string arrays, returns an array of PSCustomObjects, containing
First and Second properties. The result is a list of all unique pair combinations
of the 2 input sequences.

## SYNTAX

```powershell
Get-UniqueCrossPairs [-First] <String[]> [[-Second] <String[]>] [<CommonParameters>]
```

## DESCRIPTION

Effectively, the result is a matrix with the first collection defining 1 axis
and the other defining the other axis. Pairs where both elements are the same are
omitted.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-UniqueCrossPairs -first a,b,c -second a,c,d

Returns

  First Second
  ----- ------
  a     c
  a     d
  b     a
  b     c
  b     d
  c     d
```

### EXAMPLE 2

```powershell
Get-UniqueCrossPairs -first a,b,c -second d

Returns

  First Second
  ----- ------
  d     a
  d     b
  d     c
```

## PARAMETERS

### -First

First string array to compare

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

### -Second

The other string array to compare

```yaml
Type: String[]
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

### System.Management.Automation.PSObject[]

## NOTES

## RELATED LINKS

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
