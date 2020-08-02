
function Test-HoistResult {
  param(
    [Parameter(Mandatory)]
    [System.IO.DirectoryInfo]$Underscore,

    [Parameter(Mandatory)]
    [int]$Index,

    [Parameter(Mandatory)]
    [System.Collections.Hashtable]$PassThru,

    [Parameter(Mandatory)]
    [boolean]$Trigger,

    [Parameter(Mandatory=$false)] # make non mandatory is temporary
    [string]$Format = "DEFAULT:___{0}___"
  )

  [string]$result = $Format -f ($Underscore.Name);
  Write-Host "Custom function; Test-HoistResult: '$result'";
  @{ Product = $Underscore }
}
