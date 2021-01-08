
function Initialize-ShellOperant {
  [OutputType([Operant])]
  param(
    [Parameter()]
    [string]$HomePath = $(Resolve-Path "~"),

    [Parameter()]
    # ShortCode = 'remy', OperantName = 'UndoRename', Shell = 'PoShShell', BaseFilename = 'undo-rename'
    # DisabledKey = 'LOOPZ_UNDO_RENAME'
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

  [UndoRename]$operant = if (-not($isDisabled)) {
    [string]$loopzPath = $(Get-EnvironmentVariable 'LOOPZ_PATH');
    [string]$subPath = ".loopz" + [System.IO.Path]::DirectorySeparatorChar + $($Options.ShortCode)
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
      -Directory $loopzPath -Operant 'UndoRename' -Shell 'PoShShell';
  } else {
    $null;
  }

  return $operant;
}
