---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version: https://eliziumnet.github.io/Loopz/
schema: 2.0.0
---

# Initialize-ShellOperant

## SYNOPSIS

Operant factory function.

## SYNTAX

```powershell
Initialize-ShellOperant [[-HomePath] <String>] [[-Options] <PSObject>] [-DryRun] [<CommonParameters>]
```

## DESCRIPTION

  By default all operant related files are stored somewhere inside the home path.
Actually, a predefined subpath under home is used. This can be customised by the user
by them defining an alternative path (in the environment as 'LOOPZ_PATH'). This
alternative path can be relative or absolute. Relative paths are relative to the
home directory.
  The options specify how the operant is created and must be a PSCustomObject with
the following fields (examples provided inside brackets relate to Rename-Many command):

+ ShortCode ('remy'): a short string denoting the related command
+ OperantName ('UndoRename'): name of the operant class required
+ Shell ('PoShShell'): The type of shell that the command should be generated for. So
for PowerShell the user would specify 'PoShShell' (which for the time being is the
only shell supported).
+ BaseFilename ('undo-rename'): the core part of the file name which should reflect
the nature of the operant (the operation, which ideally should be a verb noun pair
but is not enforced)
+ DisabledEnVar ('LOOPZ_REMY_UNDO_DISABLED'): The environment variable used to disable
this operant.

## EXAMPLES

### Example 1

```powershell
  [PSCustomObject]$operantOptions = [PSCustomObject]@{
    ShortCode    = 'remy';
    OperantName  = 'UndoRename';
    Shell        = 'PoShShell';
    BaseFilename = 'undo-rename';
    DisabledEnVar  = 'LOOPZ_REMY_UNDO_DISABLED';
  }
```

Operant options for Rename-Many(remy) command

## PARAMETERS

### -DryRun

Similar to WhatIf, but by passing ShouldProcess process for custom handling of
dry run scenario. DryRun should be set if WhatIf is enabled.

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

### -HomePath

User's home directory. (This parameter does not need to be set by client, just
used for testing purposes.)

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

### -Options

(See command description for $Options field descriptions).

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### Operant

## NOTES

## RELATED LINKS

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
