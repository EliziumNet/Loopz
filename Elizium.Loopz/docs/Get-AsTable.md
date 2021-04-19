---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# Get-AsTable

## SYNOPSIS

Selects the table header and data from source and meta data.

## SYNTAX

```powershell
Get-AsTable [[-MetaData] <Hashtable>] [[-TableData] <PSObject[]>] [[-Options] <PSObject>]
 [[-Evaluate] <ScriptBlock>] [<CommonParameters>]
```

## DESCRIPTION

The client can override the behaviour to perform custom evaluation of
table cell values. The default will space pad the cell value and align
according the table options (./HeaderAlign and ./ValueAlign).

## PARAMETERS

### -Evaluate

A script-block allowing client defined cell rendering logic. The Render script-block
contains the following parameters:

- Value: the current value of the cell being rendered.
- columnData: column meta data
- isHeader: flag to indicate if the current cell being evaluated is a header, if false
then it is a data cell.
- Options: The table display options

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MetaData

Hashtable instance which maps column titles to a PSCustomObject instance that
contains display information pertaining to that column. The object must contain
the following members:

- FieldName: the name of the column
- Max: the size of the largest value found in the table data for that column
- Type: the type of data represented by that column

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Options

The table display options (See Get-TableDisplayOptions)

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TableData

Hashtable containing the table data.

```yaml
Type: PSObject[]
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

### System.Collections.Hashtable

Returns 2 hashtable instances inside an array, the first represents the headers and the second the table data.

## NOTES

## RELATED LINKS

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
