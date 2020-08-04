
function Test-HoistResult {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
  param(
    [Parameter(Mandatory)]
    [System.IO.DirectoryInfo]$Underscore,

    [Parameter(Mandatory)]
    [int]$Index,

    [Parameter(Mandatory)]
    [System.Collections.Hashtable]$PassThru,

    [Parameter(Mandatory)]
    [boolean]$Trigger,

    [Parameter(Mandatory = $false)]
    [string]$Format = "These aren't the droids you're looking for, ..., move along, move along!:___{0}___"
  )

  [string]$result = $Format -f ($Underscore.Name);
  Write-Debug "Custom function; Test-HoistResult: '$result'";
  @{ Product = $Underscore }
}
