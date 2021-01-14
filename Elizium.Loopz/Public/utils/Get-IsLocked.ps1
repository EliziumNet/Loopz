
function Get-IsLocked {
  <#
  .NAME
    Get-IsLocked

  .SYNOPSIS
    Utility function to determine whether the environment variable specified
  denotes that it is set to $true to indicate the associated function is in a locked
  state.

  .DESCRIPTION
    Returns a boolean indicating the 'locked' status of the associated functionality.
  Eg, for the Rename-Many command, a user can only use it for real when it has been
  unlocked by setting it's associated environment variable 'LOOPZ_REMY_LOCKED' to $false.

  .PARAMETER Variable
    The environment variable to check.

  #>
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
