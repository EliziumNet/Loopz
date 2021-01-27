
function New-BootStrap {
  [OutputType([BootStrap])]
  param(
    [Parameter()]
    [hashtable]$Exchange,

    [Parameter()]
    [PSCustomObject]$Containers,

    [Parameter()]
    [hashtable]$Signals,

    [Parameter()]
    [hashtable]$Theme,

    [Parameter()]
    [PSCustomObject]$Options
  )

  return [BootStrap]::new($Exchange, $Containers, $Signals, $Theme, $Options);
}
