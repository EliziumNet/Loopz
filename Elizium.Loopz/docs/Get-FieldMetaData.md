---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Get-FieldMetaData

## SYNOPSIS

Derives the meta data from the table data provided.

## SYNTAX

```powershell
Get-FieldMetaData [[-Data] <PSObject[]>] [<CommonParameters>]
```

## DESCRIPTION

The source table data is just an array of PSCustomObjects where each object
represents a row in the table. The meta data is required to format the table
cells correctly so that each cell is properly aligned.

## PARAMETERS

### -Data

Hashtable containing the table data.

```yaml
Type: PSObject[]
Parameter Sets: (All)
Aliases:

Required: False
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

A hashtable of the metadata required to display a table.

## NOTES

## RELATED LINKS
