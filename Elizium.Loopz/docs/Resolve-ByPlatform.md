---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# Resolve-ByPlatform

## SYNOPSIS

Given a hashtable, resolves to the value whose corresponding key matches
the operating system name as returned by Get-PlatformName.

## SYNTAX

```powershell
Resolve-ByPlatform [[-Hash] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION

Provides a way to select data depending on the current OS as determined by
Get-PlatformName.

## EXAMPLES

### EXAMPLE 1

```powershell
[hashtable]$platforms = @{
  'windows' = 'windows-info';
  'linux'   = 'linux-info';
  'mac'     = 'mac-info';
}
Resolve-ByPlatform -Hash $platforms
```

### EXAMPLE 2 (With default)

```powershell
[hashtable]$platforms = @{
  'windows' = 'windows-info';
  'default' = 'default-info';
}
Resolve-ByPlatform -Hash $platforms
```

## PARAMETERS

### -Hash

A hashtable object whose keys are values that can be returned by Get-PlatformName. The
values can be anything.

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

### System.Object

## NOTES

## RELATED LINKS

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
