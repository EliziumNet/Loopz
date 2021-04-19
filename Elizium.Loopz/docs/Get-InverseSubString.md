---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# Get-InverseSubString

## SYNOPSIS

Performs the opposite of [string]::Substring.

## SYNTAX

```powershell
Get-InverseSubString [-Source] <String> [-StartIndex <Int32>] [-Length <Int32>] [-Split] [-Marker <Char>]
 [<CommonParameters>]
```

## DESCRIPTION

Returns the remainder of that part of the substring denoted by the $StartIndex
$Length.

## PARAMETERS

### -Length

The number of characters in the sub-string.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Marker

A character used to mark the position of the sub-string. If the client specifies
a marker, then this marker is inserted between the head and the tail.

```yaml
Type: Char
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Source

The source string

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

### -Split

When getting the inverse sub-string there are two elements that are returned,
the head (prior to sub-string) and the tail, what comes after the sub-string.
This switch indicates whether the function returns the head and tail as separate
entities in an array, or should simply return the tail appended to the head.

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

### -StartIndex

The index of sub-string.

```yaml
Type: Int32
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

### System.Object

## NOTES

## RELATED LINKS

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
