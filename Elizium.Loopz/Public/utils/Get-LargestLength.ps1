
function Get-LargestLength {
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
