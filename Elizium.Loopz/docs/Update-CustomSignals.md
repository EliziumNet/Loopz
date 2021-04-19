---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# Update-CustomSignals

## SYNOPSIS

Allows user to override the emoji's for commands

## SYNTAX

```powershell
Update-CustomSignals [-Signals] <Hashtable> [<CommonParameters>]
```

## DESCRIPTION

A user may want to customise the appear of commands that use signals in their
display. The user can specify overrides for any of the declared signals (See
Show-Signals). Typically, the user should invoke this in their profile script.

## EXAMPLES

### Example 1

```powershell
  [hashtable]$myOverrides = @{
    'PATTERN' = $(kp(@('Capture', '👾')));
    'LOCKED' = $(kp(@('No soup for you', '🥣')));
  }
  Update-CustomSignals -Signals $myOverrides
```

Override signals 'PATTERN' and 'LOCKED' with custom emojis.

## PARAMETERS

### -Signals

A hashtable containing signal overrides.

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

## NOTES

## RELATED LINKS

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
