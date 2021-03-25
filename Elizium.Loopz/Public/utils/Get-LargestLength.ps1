
function Get-LargestLength {
  <#
  .NAME
    Get-LargestLength

  .SYNOPSIS
    Get the size of the largest string item in the collection.

  .DESCRIPTION
    
  
  .PARAMETER Data
    Hashtable containing the table data.
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
