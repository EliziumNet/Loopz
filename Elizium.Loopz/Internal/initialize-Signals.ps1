
function initialize-Signals {
  [OutputType([System.Collections.Hashtable])]
  param(
    [Parameter()]
    [System.Collections.Hashtable]$Signals = $global:Loopz.DefaultSignals,

    [Parameter()]
    [System.Collections.Hashtable]$Overrides = $global:Loopz.OverrideSignals
  )

  [System.Collections.Hashtable]$result = $Signals.Clone() | Sort-Object -Property Name;

  [System.Collections.Hashtable]$withOverrides = resolve-ByPlatform -Hash $Overrides;
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

