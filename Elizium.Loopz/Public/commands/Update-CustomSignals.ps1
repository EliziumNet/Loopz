
function Update-CustomSignals {
  param(
    [Parameter(Mandatory)]
    [hashtable]$Signals
  )

  if ($Signals -and ($Signals.Count -gt 0)) {
    if ($Loopz) {
      if (-not($Loopz.CustomSignals)) {
        $Loopz.CustomSignals = @{}
      }

      $Signals.GetEnumerator() | ForEach-Object {
        if ($_.Value -and ($_.Value -is [couplet])) {
          $Loopz.CustomSignals[$_.Key] = $_.Value;
        }
        else {
          Write-Warning "Loopz: Skipping custom signal('$($_.Key)'); not a valid couplet/pair: -->$($_.Value)<--";
        }
      }
    }
  }
}
