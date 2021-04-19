---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# Test-IsFileSystemSafe

## SYNOPSIS

Checks the $Value to see if it contains any file-system un-safe characters.

## SYNTAX

```powershell
Test-IsFileSystemSafe [[-Value] <String>] [[-InvalidSet] <Char[]>] [<CommonParameters>]
```

## DESCRIPTION

Warning, this function is not comprehensive nor platform specific, but it does not intend to be.
There are some characters eg /, that are are allowable under mac/linux as part of the filename but are not under windows; in this case they are considered unsafe for all platforms.
This approach is taken because of the likely possibility that a file may be copied over from differing file system types.

## PARAMETERS

### -InvalidSet

(Client does not need to specify this parameter; used for testing purposes only).

```yaml
Type: Char[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value

The string value to check.

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

### System.Boolean

Returns $true if the value contains ony file-system safe characters only, $false otherwise

## NOTES

## RELATED LINKS

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
