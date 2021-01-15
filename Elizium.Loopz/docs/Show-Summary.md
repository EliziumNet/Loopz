---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Show-Summary

## SYNOPSIS

Function to display summary as part of an iteration batch.

## SYNTAX

```powershell
Show-Summary [[-Count] <Int32>] [[-Skipped] <Int32>] [[-Triggered] <Boolean>] [[-Exchange] <Hashtable>]
 [<CommonParameters>]
```

## DESCRIPTION

  Behaviour can be customised by the following entries in the Exchange:

* 'LOOP.KRAYON' (mandatory): the Krayola Krayon writer object.
* 'LOOPZ.SUMMARY-BLOCK.MESSAGE': The custom message to be displayed as
part of the summary.
* 'LOOPZ.SUMMARY.PROPERTIES': A Krayon [line] instance contain a collection
of Krayola [couplet]s. The first line of summary properties shows the values of
$Count, $Skipped and $Triggered. The properties, if present are appended to this line.
* 'LOOPZ.SUMMARY-BLOCK.LINE': The static line text. The length of this line controls
how everything else is aligned (ie the flex part and the message if present).
* 'LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS': The collection (an array of Krayola [lines]s)
containing 'wide' items and therefore should be on their own separate line.
* 'LOOPZ.SUMMARY-BLOCK.GROUP-WIDE-ITEMS': Perhaps the wide items are not so wide after
all, so if this entry is set (a boolean value), the all wide items appear on their
own line.

## PARAMETERS

### -Count

The number items processed, this is the number of items in the pipeline which match
the $Pattern specified and therefore are allocated an index.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Exchange

The exchange hashtable object.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Skipped

The number of pipeline items skipped. An item is skipped for the following reasons:

* Item name does not match the $Include expression
* Item name satisfies the $Exclude expression. ($Exclude overrides $Include)
* Iteration is terminated early by the invoked function/script-block returning a
PSCustomObject with a Break property set to $true.
* FileSystem item is not of the request type. Eg, if File is specified, then all
directory items will be skipped.
* An item fails to satisfy the $Condition predicate.
* Number of items processed breaches Top.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Triggered

Indicates whether any of the processed pipeline items were actioned in a modifying
batch; ie if no items were mutated, then Triggered would be $false.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
