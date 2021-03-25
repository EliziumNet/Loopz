---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Get-PartitionedPcoHash

## SYNOPSIS

Partitions a hash of PSCustomObject (Pco)s by a specified field name.

## SYNTAX

```powershell
Get-PartitionedPcoHash [-Hash] <Hashtable> [-Field] <String> [<CommonParameters>]
```

## DESCRIPTION

Given a hashtable whose values are PSCustomObjects, will return a hashtable of
hashtables, keyed by the field specified. This effectively re-groups the hashtable
entries based on a custom field. The first level hash in the result is keyed,
by the field specified. The second level has is the original hash key. So
given the original hash [ORIGINAL-KEY]=>[PSCustomObject], after partitioning,
the same PSCustomObject can be accessed, via 2 steps $outputHash[$Field][ORIGINAL-KEY].

## PARAMETERS

### -Field

The name of the field to partition by

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Hash

The input hashtable to partition

```yaml
Type: Hashtable
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

### System.Object

A hashtable of hashtable keyed by the field specified.

## NOTES

## RELATED LINKS
