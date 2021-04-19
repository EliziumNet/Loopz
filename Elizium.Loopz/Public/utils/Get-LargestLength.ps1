
function Get-LargestLength {
  <#
  .NAME
    Get-LargestLength

  .SYNOPSIS
    Get the size of the largest string item in the collection.

  .DESCRIPTION
    Get the size of the largest string item in the collection.

  .LINK
    https://eliziumnet.github.io/Loopz/

  .PARAMETER Data
    Hashtable containing the table data.

  .PARAMETER items
    The source collection to get largest length of.
  #>
  param(
    [string[]]$items
  )
  [int]$largest = 0;
  if ($items -and $items.Count -gt 0) {
    foreach ($i in $items) {
      if (-not([string]::IsNullOrEmpty($i)) -and $($i.Length -gt $largest)) {
        $largest = $i.Length;
      }
    }
  }

  return $largest;
}
