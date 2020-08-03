

function Test-FileResult {
  param(
    [Parameter(Mandatory)]
    [System.IO.FileInfo]$Underscore,

    [Parameter(Mandatory)]
    [int]$Index,

    [Parameter(Mandatory)]
    [System.Collections.Hashtable]$PassThru,

    [Parameter(Mandatory)]
    [boolean]$Trigger,

    [Parameter(Mandatory)]
    [string]$Format
  )

  [string]$result = $Format -f ($Underscore.Name);
  Write-Host "Custom function; Test-FileResult: '$result'";
  @{ Product = $Underscore }
}
