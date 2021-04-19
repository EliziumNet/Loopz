---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# Get-IsLocked

## SYNOPSIS

Utility function to determine whether the environment variable specified
denotes that it is set to $true to indicate the associated function is in a locked
state.

## SYNTAX

```powershell
Get-IsLocked [-Variable] <String> [<CommonParameters>]
```

## DESCRIPTION

Returns a boolean indicating the 'locked' status of the associated functionality.
Eg, for the Rename-Many command, a user can only use it for real when it has been
unlocked by setting it's associated environment variable 'LOOPZ_REMY_LOCKED' to $false.

## PARAMETERS

### -Variable

The environment variable to check.

```yaml
Type: String
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

## NOTES

## RELATED LINKS

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
