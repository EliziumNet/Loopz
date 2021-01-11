
function Get-Signals {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
  [OutputType([hashtable])]
  param(
    [Parameter()]
    [hashtable]$SourceSignals = $global:Loopz.Signals,

    [Parameter()]
    [hashtable]$Custom = $global:Loopz.CustomSignals
  )

  [hashtable]$result = $SourceSignals.Clone();

  if ($Custom -and ($Custom.Count -gt 0)) {
    $Custom.GetEnumerator() | ForEach-Object {
      try {
        $result[$_.Key] = $_.Value;
      }
      catch {
        Write-Error "Skipping custom signal: '$($_.Key)'";
      }
    }
  }

  return $result;
}
