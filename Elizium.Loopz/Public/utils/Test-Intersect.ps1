
function Test-Intersect {
  <#
  .NAME
    Test-Intersect

  .SYNOPSIS
    Determines if two sets of strings contains any common elements.

  .DESCRIPTION
    Essentially asks the question, 'Do the two sets intersect'.

  .PARAMETER First
    First collection of strings to compare.

  .PARAMETER Second
    Second collection of strings to compare.
  #>
  [OutputType([boolean])]
  param(
    [Parameter(Mandatory, Position = 0)]
    [string[]]$First,

    [Parameter(Mandatory, Position = 1)]
    [string[]]$Second
  )
  return $($First | Where-Object { ($Second -contains $_) })
}
