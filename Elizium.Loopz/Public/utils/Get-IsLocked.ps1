
function Get-IsLocked {
  [OutputType([boolean])]
  param(
   [Parameter(Mandatory)]
   [string]$Variable
  )

  [string]$lockedEnv = Get-EnvironmentVariable $Variable;
  [boolean]$locked = ([string]::IsNullOrEmpty($lockedEnv) -or
    (-not([string]::IsNullOrEmpty($lockedEnv)) -and
      ($lockedEnv -eq [boolean]::TrueString)));

  return $locked;
}
