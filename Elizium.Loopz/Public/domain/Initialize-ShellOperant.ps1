
function Initialize-ShellOperant {
  <#
  .NAME
    Initialize-ShellOperant

  .SYNOPSIS
    Operant factory function.

  .DESCRIPTION
    By default all operant related files are stored somewhere inside the home path.
  Actually, a predefined subpath under home is used. This can be customised by the user
  by them defining an alternative path (in the environment as 'LOOPZ_PATH'). This
  alternative path can be relative or absolute. Relative paths are relative to the
  home directory.
    The options specify how the operant is created and must be a PSCustomObject with
  the following fields (examples provided inside brackets relate to Rename-Many command):
  - ShortCode ('remy'): a short string denoting the related command
  - OperantName ('UndoRename'): name of the operant class required
  - Shell ('PoShShell'): The type of shell that the command should be generated for. So
  for PowerShell the user would specify 'PoShShell' (which for the time being is the
  only shell supported).
  - BaseFilename ('undo-rename'): the core part of the file name which should reflect
  the nature of the operant (the operation, which ideally should be a verb noun pair
  but is not enforced)
  - DisabledKey ('LOOPZ_REMY_UNDO_DISABLED'): The environment variable used to disable
  this operant.

  .PARAMETER DryRun
    Similar to WhatIf, but by passing ShouldProcess process for custom handling of
  dry run scenario. DryRun should be set if WhatIf is enabled.

  .PARAMETER HomePath
      User's home directory. (This parameter does not need to be set by client, just
    used for testing purposes.)

  .PARAMETER Options
    (See command description for $Options field descriptions).

  .EXAMPLE 1
  Operant options for Rename-Many(remy) command

  [PSCustomObject]$operantOptions = [PSCustomObject]@{
    ShortCode    = 'remy';
    OperantName  = 'UndoRename';
    Shell        = 'PoShShell';
    BaseFilename = 'undo-rename';
    DisabledKey  = 'LOOPZ_REMY_UNDO_DISABLED';
  }
    
  #>
  [OutputType([Operant])]
  param(
    [Parameter()]
    [string]$HomePath = $(Resolve-Path "~"),

    [Parameter()]
    [PSCustomObject]$Options,

    [Parameter()]
    [switch]$DryRun
  )
  [string]$envUndoRenameDisabled = $(Get-EnvironmentVariable -Variable $Options.DisabledKey);

  try {
    [boolean]$isDisabled = if (-not([string]::IsNullOrEmpty($envUndoRenameDisabled))) {
      [System.Convert]::ToBoolean($envUndoRenameDisabled);
    }
    else {
      $false;
    }
  }
  catch {
    [boolean]$isDisabled = $false;
  }

  [Operant]$operant = if (-not($isDisabled)) {
    [string]$loopzPath = $(Get-EnvironmentVariable 'LOOPZ_PATH');
    [string]$subPath = ".loopz" + [System.IO.Path]::DirectorySeparatorChar + $($Options.ShortCode);
    if ([string]::IsNullOrEmpty($loopzPath)) {
      $loopzPath = Join-Path -Path $HomePath -ChildPath $subPath;
    }
    else {
      $loopzPath = Path.IsPathRooted(loopzPath) `
        ? Join-Path -Path $loopzPath -ChildPath $subPath `
        : Join-Path -Path $HomePath -ChildPath $loopzPath -AdditionalChildPath $subPath;
    }

    if (-not(Test-Path -Path $loopzPath -PathType Container)) {
      if (-not($DryRun)) {
        $null = New-Item -Type Directory -Path $loopzPath;
      }
    }

    New-ShellOperant -BaseFilename $Options.BaseFilename `
      -Directory $loopzPath -Operant $($Options.OperantName) -Shell $Options.Shell;
  }
  else {
    $null;
  }

  return $operant;
}
