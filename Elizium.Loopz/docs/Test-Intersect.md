---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Test-Intersect

## SYNOPSIS

Determines if two sets of strings contains any common elements.

## SYNTAX

```powershell
Test-Intersect [-First] <String[]> [-Second] <String[]> [<CommonParameters>]
```

## DESCRIPTION

Essentially asks the question, 'Do the two sets intersect'.

## PARAMETERS

### -First

First collection of strings to compare.

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

Second collection of strings to compare.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Boolean

Returns $true if the 2 sets share common element, $false otherwise.

## NOTES

## RELATED LINKS
