---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Format-BooleanCellValue

## SYNOPSIS

Table Render callback that can be passed into Show-AsTable

## SYNTAX

```powershell
Format-BooleanCellValue [[-Value] <String>] [[-TableOptions] <PSObject>] [<CommonParameters>]
```

## DESCRIPTION

For table cells containing boolean fields, this callback function will
render the cell with alternative values other than 'true' or 'false'. Typically,
the client would set the alternative representation of these boolean values
(the default values are emoji values 'SWITCH-ON'/'SWITCH-OFF') in the table
options.

## PARAMETERS

### -TableOptions

The PSCustomObject that contains the alternative boolean values (./Values/True
and ./Values/False)

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value

The original boolean value in string form.

```yaml
Type: String
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

### System.String

## NOTES

## RELATED LINKS
