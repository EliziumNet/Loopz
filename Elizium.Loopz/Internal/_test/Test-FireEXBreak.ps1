
function Test-FireEXBreak {
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
  $break = ('EX' -eq $Underscore.Name);
  Write-Host "  [-] Test-FireEXBreak(index: $Index): directory: $($Underscore.Name)";
  @{ Product = $Underscore; Break = $break }
}

