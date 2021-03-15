
function New-Syntax {
  param(
    [Parameter(Mandatory)]
    [string]$CommandName,

    [Parameter()]
    [hashtable]$Signals = $(Get-Signals),

    [Parameter()]
    [Scribbler]$Scribbler,

    [Parameter()]
    [Hashtable]$Scheme
  )
  if (-not($PSBoundParameters.ContainsKey('Scheme'))) {
    $Scheme = Get-SyntaxScheme -Theme $($Scribbler.Krayon.Theme);
  }
  return [syntax]::new($CommandName, $Signals, $Scribbler, $Scheme);
}
