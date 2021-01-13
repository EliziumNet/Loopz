
function Test-IsFileSystemSafe {
  <#
  .NAME
    Test-IsFileSystemSafe

  .SYNOPSIS
    Checks the $Value to see if it contains any file-system un-safe characters.

  .DESCRIPTION
    Warning, this function is not comprehensive nor platform specific, but it does not
  intend to be. There are some characters eg /, that are are allowable under mac/linux
  as part of the filename but are not under windows; in this case they are considered
  unsafe for all platforms. This approach is taken because of the likely possibility
  that a file may be copied over from differing file system types.

  .PARAMETER Value
    The string value to check.

  .PARAMETER Value
    

  #>
  [OutputType([boolean])]
  param(
    [Parameter()]
    [string]$Value,

    [Parameter()]
    [char[]]$InvalidSet = $Loopz.InvalidCharacterSet
  )
  return ($Value.IndexOfAny($InvalidSet) -eq -1);
}
