
function Test-ContainsAll {
  <#
  .NAME
    Test-ContainsAll

  .SYNOPSIS
    Given two sequences of strings, determines if first contains all elements
  of the other.

  .DESCRIPTION
    Is the first set a super set of the second.

  .PARAMETER Super
    The super set (First)

  .PARAMETER Sub
    The sub set (Second)
  #>
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
