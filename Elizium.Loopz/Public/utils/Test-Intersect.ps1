
function Test-Intersect {
  [OutputType([boolean])]
  param(
    [Parameter(Mandatory, Position = 0)]
    [string[]]$First,

    [Parameter(Mandatory, Position = 1)]
    [string[]]$Second
  )
  return $($First | Where-Object { ($Second -contains $_) })
}
