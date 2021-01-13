
function Get-InverseSubString {
  <#
  .NAME
    Get-InverseSubString

  .SYNOPSIS
    Performs the opposite of [string]::Substring.

  .DESCRIPTION
    Returns the remainder of that part of the substring denoted by the $StartIndex
  $Length.

  .PARAMETER Source
    The source string

  .PARAMETER StartIndex
    The index of sub-string.

  .PARAMETER Length
    The number of characters in the sub-string.

  .PARAMETER Split
    When getting the inverse sub-string there are two elements that are returned,
  the head (prior to sub-string) and the tail, what comes after the sub-string.
    This switch indicates whether the function returns the head and tail as separate
  entities in an array, or should simply return the tail appended to the head.

  .PARAMETER Marker
    A character used to mark the position of the sub-string. If the client specifies
  a marker, then this marker is inserted between the head and the tail.

  #>
  param(
    [Parameter(Position = 0, Mandatory)]
    [string]$Source,

    [Parameter()]
    [ValidateScript( { $_ -lt $Source.Length })]
    [int]$StartIndex = 0,

    [Parameter()]
    [ValidateScript( { $_ -le ($Source.Length - $StartIndex ) })]
    [int]$Length = 0,

    [Parameter()]
    [switch]$Split,

    [Parameter()]
    [char]$Marker
  )

  $result = if ($StartIndex -eq 0) {
    $PSBoundParameters.ContainsKey('Marker') `
      ? $($Marker + $Source.SubString($Length)) : $Source.SubString($Length);
  }
  else {
    [string]$head = $Source.SubString(0, $StartIndex);

    if ($PSBoundParameters.ContainsKey('Marker')) {
      $head += $Marker;
    }

    [string]$tail = $Source.SubString($StartIndex + $Length);
    ($Split.ToBool()) ? ($head, $tail) : ($head + $tail);
  }
  $result;
}
