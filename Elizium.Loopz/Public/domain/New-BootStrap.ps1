
function New-BootStrap {
  [OutputType([BootStrap])]
  param(
    [Parameter()]
    [hashtable]$Exchange,

    [Parameter()]
    [PSCustomObject]$Containers,

    [Parameter()]
    [PSCustomObject]$Options
  )

  return [BootStrap]::new($Exchange, $Containers, $Options);
}
