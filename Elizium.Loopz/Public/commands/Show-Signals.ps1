
function Show-Signals {
  <#
  .NAME
    Show-Signals

  .SYNOPSIS
    Shows all defined signals, including user defined signals

  .DESCRIPTION
    User can override signal definitions in their profile, typically using the provided
  function Update-CustomSignals.
  #>
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
  param(
    [Parameter()]
    [hashtable]$SourceSignals = $(Get-Signals),

    [Parameter()]
    [hashtable]$Custom = $global:Loopz.CustomSignals
  )
  $result = $SourceSignals;

  [hashtable]$collection = @{}
  $result.GetEnumerator() | ForEach-Object {

    $collection[$_.Key] = [PSCustomObject]@{
      Label  = $_.Value.Key;
      Icon   = $_.Value.Value;
      Length = $_.Value.Value.Length
    }
  }

  # result is array, because of the sort
  #
  $result = $collection.GetEnumerator() | Sort-Object -Property Name;

  return $result;
}
