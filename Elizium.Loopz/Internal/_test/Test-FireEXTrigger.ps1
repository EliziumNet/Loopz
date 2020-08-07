function Test-FireEXTrigger {
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
  $trigger = ('EX' -eq $Underscore.Name);
  Write-Host "  [-] Test-FireEXTrigger(index: $Index, trigger: $trigger): directory: $($Underscore.Name)";
  @{ Product = $Underscore; Trigger = $trigger }
}
