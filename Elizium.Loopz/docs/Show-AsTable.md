---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Show-AsTable

## SYNOPSIS

Shows the provided data in a coloured table form.

## SYNTAX

```powershell
Show-AsTable [[-MetaData] <Hashtable>] [[-Headers] <Hashtable>] [[-Table] <Hashtable>] [[-Title] <String>]
 [[-TitleFormat] <String>] [[-Scribbler] <Scribbler>] [[-Render] <ScriptBlock>] [[-Options] <PSObject>]
 [<CommonParameters>]
```

## DESCRIPTION

Requires table meta data, headers and values and renders the content according
to the options provided. The clint can override the default cell rendering behaviour
by providing a render function.

## PARAMETERS

### -Headers

Hashtable instance that represents the headers displayed for the table. Maps the
raw column title to the actual text used to display it. In practice, this is a
space padded version of the raw title determined from the meta data.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MetaData

Hashtable instance which maps column titles to a PSCustomObject instance that
contains display information pertaining to that column. The object must contain

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

The table display options (See command [Get-TableDisplayOptions](#Get-TableDisplayOptions.md))

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Render

A script-block allowing client defined cell rendering logic. The Render script-block
contains the following parameters:

- Column: spaced padded column title, indicating which column this cell is in.
- Value: the current value of the cell being rendered.
- row: a PSCustomObject containing all the field values for the current row. The whole
row is presented to the cell render function so that cross field functionality can be
defined.
- Options: The table display options
- Scribbler: The Krayola scribbler instance
- counter: the row number

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scribbler

The Krayola scribbler instance used to manage rendering to console.

```yaml
Type: Scribbler
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Table

Hashtable containing the table data. Currently, the data row is indexed by the
'Name' property and as such, the Name in in row must be unique (actually acts
like its the primary key for the table; this will be changed in future so that
an alternative ID field is used instead of Name.)

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Title

If provided, this will be shown as the title for this table.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TitleFormat

A table title format string which must contain a {0} place holder for the Title
to be inserted into.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
