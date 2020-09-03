
function Test-FireBreakOnFirstItem {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
  param(
    [Parameter(Mandatory)]
    [System.IO.DirectoryInfo]$Underscore,

    [Parameter(Mandatory)]
    [int]$Index,

    [Parameter(Mandatory)]
    [System.Collections.Hashtable]$PassThru,

    [Parameter(Mandatory)]
    [boolean]$Trigger
  )
  Write-Host "  [-] Test-FireBreakOnFirstItem(index: $Index): directory: $($Underscore.Name)";
  @{ Product = $Underscore; Break = $true }
}

