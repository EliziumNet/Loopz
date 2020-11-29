
function Get-Signals {
  [OutputType([System.Collections.Hashtable])]
  param(
    [Parameter()]
    [System.Collections.Hashtable]$SourceSignals = $global:Loopz.Signals,

    [Parameter()]
    [System.Collections.Hashtable]$Custom = $global:Loopz.CustomSignals
  )

  [System.Collections.Hashtable]$result = $SourceSignals.Clone();

  if ($Custom -and ($Custom.Count -gt 0)) {
    $Custom.GetEnumerator() | ForEach-Object {
      try {
        $result[$_.Key] = $_.Value;
      } catch {
        Write-Error "Skipping custom signal: '$($_.Key)'";
      }
    }
  }

  return $result;
}
