
function New-ShellOperant {
  [OutputType([Operant])]
  param(
    [Parameter()]
    [string]$BaseFilename,

    [Parameter()]
    [string]$Directory,

    [Parameter()]
    [string]$DateTimeFormat = 'yyyy-MM-dd_HH-mm-ss',

    [Parameter()]
    [ValidateSet('UndoRename')]
    [string]$Operant = 'UndoRename',

    [Parameter()]
    [ValidateSet('PoShShell')]
    [string]$Shell = 'PoShShell'
  )
  [string]$filename = "{0}_{1}.ps1" -f $BaseFilename, $(get-CurrentTime -Format $DateTimeFormat);
  [string]$fullPath = Join-Path -Path $Directory -ChildPath $filename;

  [Shell]$shell = if ($Shell -eq 'PoShShell') {
    [PoShShell]::new($fullPath);
  }
  else {
    $null;
  }

  [Operant]$operant = if ($shell) {
    if ($Operant -eq 'UndoRename') {
      [UndoRename]::new($shell);
    }
    else {
      $null;
    }
  }
  else {
    $null;
  }

  return $operant;
}
