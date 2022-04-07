
function New-Kerberus {
  [CmdletBinding()]
  [OutputType([Kerberus])]
  param(
    [Parameter()]
    [FilterDriver]$Driver
  )

  [FilterStrategy]$strategy = [LeafGenerationStrategy]::new()
  [Kerberus]$controller = [Kerberus]::new($strategy);

  return $controller;
}
