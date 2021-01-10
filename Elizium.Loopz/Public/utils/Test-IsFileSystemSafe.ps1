
function Test-IsFileSystemSafe {
  [OutputType([boolean])]
  param(
    [Parameter()]
    [string]$Value,

    [Parameter()]
    [char[]]$InvalidSet = $Loopz.InvalidCharacterSet
  )
  return ($Value.IndexOfAny($InvalidSet) -eq -1);
}
