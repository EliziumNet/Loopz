---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# Edit-RemoveSingleSubString

## SYNOPSIS

Removes a sub-string from the target string provided.

## SYNTAX

### Single (Default)

```powershell
Edit-RemoveSingleSubString [-Target <String>] [-Subtract <String>] [-Insensitive] [-Last] [<CommonParameters>]
```

### LastOnly

```powershell
Edit-RemoveSingleSubString [-Last] [<CommonParameters>]
```

## DESCRIPTION

Either the first or the last occurrence of a single substring can be removed
depending on whether the Last flag has been set.

## EXAMPLES

### EXAMPLE 1

```powershell
$result = edit-RemoveSingleSubString -Target "Twilight and Willow's excellent adventure" -Subtract "excellent ";
```

Returns "Twilight and Willow's adventure"

## PARAMETERS

### -Insensitive

Flag to indicate if the search is case sensitive or not. By default, search is case
sensitive.

```yaml
Type: SwitchParameter
Parameter Sets: Single
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Last

Flag to indicate whether the last occurrence of a sub string is to be removed from the
Target.

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

### -Subtract

The sub string to subtract from the Target.

```yaml
Type: String
Parameter Sets: Single
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Target

The string from which the subtraction is to occur.

```yaml
Type: String
Parameter Sets: Single
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

### System.String

## NOTES

## RELATED LINKS

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
