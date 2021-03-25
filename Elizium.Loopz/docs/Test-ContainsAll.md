---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Test-ContainsAll

## SYNOPSIS

Given two sequences of strings, determines if first contains all elements
of the other.

## SYNTAX

```powershell
Test-ContainsAll [-Super] <String[]> [-Sub] <String[]> [<CommonParameters>]
```

## DESCRIPTION

Is the first set a super set of the second.

## PARAMETERS

### -Sub

The sub set (Second)

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Super

The super set (First)

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

### System.Boolean

Returns $true if Super contains all the elements of Sub, $false otherwise.

## NOTES

## RELATED LINKS
