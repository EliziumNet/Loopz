
function Initialize-ShellOperant {
  <#
  .NAME
    Initialize-ShellOperant

  .SYNOPSIS
    Operant factory function.

  .DESCRIPTION
    By default all operant related files are stored somewhere inside the home path.
  Actually, a predefined subpath under home is used. This can be customised by the user
  by them defining an alternative path (in the environment as 'ELIZIUM_PATH'). This
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
  - DisabledEnVar ('LOOPZ_REMY_UNDO_DISABLED'): The environment variable used to disable
  this operant.

  .LINK
    https://eliziumnet.github.io/Loopz/

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
    DisabledEnVar  = 'LOOPZ_REMY_UNDO_DISABLED';
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
  [string]$envUndoRenameDisabled = $(Get-EnvironmentVariable -Variable $Options.DisabledEnVar);

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
    [string]$eliziumPath = $(Get-EnvironmentVariable -Variable 'ELIZIUM_PATH');
    [string]$subRoot = [string]::IsNullOrEmpty(${Options}?.SubRoot) ? '.elizium' : $Options.SubRoot;
    [string]$subPath = $(Join-Path -Path $subRoot -ChildPath $Options.ShortCode);

    if ([string]::IsNullOrEmpty($eliziumPath)) {
      $eliziumPath = Join-Path -Path $HomePath -ChildPath $subPath;
    }
    else {
      $eliziumPath = [System.IO.Path]::IsPathRooted($eliziumPath) `
        ? $(Join-Path -Path $eliziumPath -ChildPath $subPath) `
        : $(Join-Path -Path $HomePath -ChildPath $eliziumPath -AdditionalChildPath $subPath);
    }

    if (-not(Test-Path -Path $eliziumPath -PathType Container)) {
      if (-not($DryRun)) {
        $null = New-Item -Type Directory -Path $eliziumPath;
      }
    }

    New-ShellOperant -BaseFilename $Options.BaseFilename `
      -Directory $eliziumPath -Operant $($Options.OperantName) -Shell $Options.Shell;
  }
  else {
    $null;
  }

  return $operant;
}
