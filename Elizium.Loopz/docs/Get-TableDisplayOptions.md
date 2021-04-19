---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# Get-TableDisplayOptions

## SYNOPSIS

Gets the default table display options.

## SYNTAX

```powershell
Get-TableDisplayOptions [[-Signals] <Hashtable>] [[-Scribbler] <Object>] [[-Select] <String[]>]
 [[-Custom] <PSObject>] [<CommonParameters>]
```

## DESCRIPTION

The client can further customise by overwriting the members on the
PSCustomObject returned.

## PARAMETERS

### -Custom

A client defined PSCustomObject that will be populated under the ./Custom in the
PSCustomObject returned.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scribbler

The Krayola scribbler instance used to manage rendering to console.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Select

An array of strings defining which columns are selected to be shown in the table.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Signals

The signals hashtable collection from which to select the signals.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Management.Automation.PSObject

The table display options including client defined custom section.

## NOTES

## RELATED LINKS

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
