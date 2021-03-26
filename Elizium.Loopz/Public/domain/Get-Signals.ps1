
function Get-Signals {
  <#
  .NAME
    Get-Signals

  .SYNOPSIS
    Returns a copy of the Signals hashtable.

  .DESCRIPTION
    The signals returned include the user defined signal overrides.

  NOTE: 3rd party commands need to register their signal usage with the signal
  registry. This can be done using command Register-CommandSignals and would
  be best performed at module initialisation stage invoked at import time.

  .PARAMETER Custom
    The hashtable instance containing custom overrides. Does not need to be
  specified by the client as it is defaulted.

  .PARAMETER SourceSignals
    The hashtable instance containing the main signals. Does not need to be
  specified by the client as it is defaulted.

  #>
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
