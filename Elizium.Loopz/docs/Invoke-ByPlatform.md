---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# Invoke-ByPlatform

## SYNOPSIS

Given a hashtable, invokes the function/script-block whose corresponding key matches
the operating system name as returned by Get-PlatformName.

## SYNTAX

```powershell
Invoke-ByPlatform [[-Hash] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION

Provides a way to provide OS specific functionality. Returns $null if the $Hash does
not contain an entry corresponding to the current platform.
(Doesn't support invoking a function with named parameters; PowerShell doesn't currently
support this, not even via splatting, if this changes, this will be implemented.)

## EXAMPLES

### EXAMPLE 1

```powershell
  function invoke-winFn {
    param(
      [string]$name,
      [string]$colour
    )

    "win: Name:$name, Colour:$colour";
  }

  [hashtable]$platformsPositional = @{
    'windows' = [PSCustomObject]@{
      FnInfo     = Get-Command -Name invoke-winFn -CommandType Function;
      Positional = @('cherry', 'red');
    };
    'linux'   = [PSCustomObject]@{
      FnInfo     = Get-Command -Name invoke-linuxFn -CommandType Function;
      Positional = @('grass', 'green');
    };
    'mac'     = [PSCustomObject]@{
      FnInfo     = Get-Command -Name invoke-macFn -CommandType Function;
      Positional = @('lagoon', 'blue');
    };
  }
  Invoke-ByPlatform -Hash $platformsPositional;
```

(invoke-linuxFn, invoke-macFn, omitted above but defined with the same signature as invoke-winFn)

On windows, Returns

'win: Name:cherry, Colour:red'

## PARAMETERS

### -Hash

  A hashtable object whose keys are values that can be returned by Get-PlatformName. The
values are of type PSCustomObject and can contain the following properties:

+ FnInfo: A FunctionInfo instance. This can be obtained from an existing function by
invoking Get-Command -Name \<function-name\>
+ Positional: an array of positional parameter values

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
