
function New-Syntax {
  param(
    [Parameter(Mandatory)]
    [string]$CommandName,

    [Parameter()]
    [hashtable]$Signals = $(Get-Signals),

    [Parameter()]
    [Krayon]$Krayon = $(Get-Krayon),

    [Parameter()]
    [Hashtable]$Scheme
  )
  if (-not($PSBoundParameters.ContainsKey('Scheme'))) {
    $Scheme = Get-SyntaxScheme -Theme $($Krayon.Theme);
  }
  return [syntax]::new($CommandName, $Signals, $Krayon, $Scheme);
}
