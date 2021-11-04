
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
  + SubRoot: This field is optional and specifies another sub-directory under which
  + ShortCode ('remy'): a short string denoting the related command
  + OperantName ('UndoRename'): name of the operant class required
  + Shell ('PoShShell'): The type of shell that the command should be generated for. So
  for PowerShell the user would specify 'PoShShell' (which for the time being is the
  only shell supported).
  + BaseFilename ('undo-rename'): the core part of the file name which should reflect
  the nature of the operant (the operation, which ideally should be a verb noun pair
  but is not enforced)
  + DisabledEnVar ('REXFS_REMY_UNDO_DISABLED'): The environment variable used to disable
  this operant.

  .LINK
    https://eliziumnet.github.io/Loopz/

  .PARAMETER DryRun
    Similar to WhatIf, but by passing ShouldProcess process for custom handling of
  dry run scenario. DryRun should be set if WhatIf is enabled.

  .PARAMETER Options
    (See command description for $Options field descriptions).

  .EXAMPLE 1
  Operant options for Rename-Many(remy) command

  [PSCustomObject]$operantOptions = [PSCustomObject]@{
    ShortCode    = 'remy';
    OperantName  = 'UndoRename';
    Shell        = 'PoShShell';
    BaseFilename = 'undo-rename';
    DisabledEnVar  = 'REXFS_REMY_UNDO_DISABLED';
  }

  The undo script is written to a directory denoted by the 'ShortCode'. The parent
  of the ShortCode is whatever has been defined in the environment variable
  'ELIZIUM_PATH'. If not defined, the operant script will be written to:
  $HOME/.elizium/ShortCode so in this case would be "~/.elizium/remy". If
  'ELIZIUM_PATH' has been defined, the path defined will be "'ELIZIUM_PATH'/remy".

  .EXAMPLE 2
  Operant options for Rename-Many(remy) command with SubRoot

  [PSCustomObject]$operantOptions = [PSCustomObject]@{
    SubRoot      = 'foo-bar';
    ShortCode    = 'remy';
    OperantName  = 'UndoRename';
    Shell        = 'PoShShell';
    BaseFilename = 'undo-rename';
    DisabledEnVar  = 'REXFS_REMY_UNDO_DISABLED';
  }

  The undo script is written to a directory denoted by the 'ShortCode' and 'SubRoot'
  If 'ELIZIUM_PATH' has not been defined as an environment variable, the operant script
  will be written to: "~/.elizium/foo-bar/remy". If 'ELIZIUM_PATH' has been defined,
  the path defined will be "'ELIZIUM_PATH'/foo-bar/remy".

  #>
  [OutputType([Operant])]
  param(
    [Parameter()]
    [PSCustomObject]$Options
  )
  [string]$eliziumPath = Use-EliziumPath;

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

  [object]$operant = if (-not($isDisabled)) {
    [string]$subRoot = [string]::IsNullOrEmpty(${Options}?.SubRoot) ? [string]::Empty : $Options.SubRoot;

    [string]$operantPath = $([string]::IsNullOrEmpty($subRoot)) ? $eliziumPath `
      : $(Join-Path -Path $eliziumPath -ChildPath $subRoot);

    [string]$shortCode = [string]::IsNullOrEmpty(${Options}?.ShortCode) ? [string]::Empty : $Options.ShortCode;
    if (-not([string]::IsNullOrEmpty($shortCode))) {
      $operantPath = $(Join-Path -Path $operantPath -ChildPath $shortCode);
    }

    if (-not(Test-Path -Path $operantPath -PathType Container)) {
      $null = New-Item -Type Directory -Path $operantPath;
    }

    New-ShellOperant -BaseFilename $Options.BaseFilename `
      -Directory $operantPath -Operant $($Options.OperantName) -Shell $Options.Shell;
  }
  else {
    $null;
  }

  return $operant;
}
