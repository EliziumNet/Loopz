
function New-Syntax {
  param(
    [Parameter(Mandatory)]
    [string]$CommandName,

    [Parameter()]
    [hashtable]$Signals = $(Get-Signals),

    [Parameter()]
    [Krayon]$Krayon = $(Get-Krayon)
  )
  return [syntax]::new($CommandName, $Signals, $Krayon);
}
