
function Test-ContainsAll {
  [OutputType([boolean])]
  param(
    [Parameter(Mandatory, Position = 0)]
    [string[]]$Super,

    [Parameter(Mandatory, Position = 1)]
    [string[]]$Sub
  )
  [string[]]$containedSet = $Sub | Where-Object { $Super -contains $_ };
  return $containedSet.Length -eq $Sub.Length;
}
