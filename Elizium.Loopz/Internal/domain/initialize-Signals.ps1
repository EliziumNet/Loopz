
function initialize-Signals {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
  [OutputType([hashtable])]
  param(
    [Parameter()]
    [hashtable]$Signals = $global:Loopz.DefaultSignals,

    [Parameter()]
    [hashtable]$Overrides = $global:Loopz.OverrideSignals
  )

  [hashtable]$result = $Signals.Clone();
  [hashtable]$withOverrides = Resolve-ByPlatform -Hash $Overrides;

  $withOverrides.GetEnumerator() | ForEach-Object {
    try {
      $result[$_.Key] = $_.Value;
    }
    catch {
      Write-Error "Skipping override signal: '$($_.Key)'";
    }
  }

  return $result;
}

