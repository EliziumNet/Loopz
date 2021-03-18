
function initialize-Signals {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
  [OutputType([hashtable])]
  param(
    [Parameter()]
    [hashtable]$Signals = $global:Loopz.DefaultSignals,

    [Parameter()]
    [hashtable]$Overrides = $global:Loopz.OverrideSignals
  )

  [hashtable]$source = $Signals.Clone();
  [hashtable]$withOverrides = Resolve-ByPlatform -Hash $Overrides;

  [boolean]$useEmoji = $(Test-HostSupportsEmojis);

  [hashtable]$resolved = @{}
  [int]$index = $useEmoji ? 1 : 2;

  $source.GetEnumerator() | ForEach-Object {
    $resolved[$_.Key] = New-Pair(@($_.Value[0], $_.Value[$index]));
  }

  $withOverrides.GetEnumerator() | ForEach-Object {
    try {
      $resolved[$_.Key] = New-Pair(@($_.Value[0], $_.Value[$index])); ;
    }
    catch {
      Write-Error "Skipping override signal: '$($_.Key)'";
    }
  }

  return $resolved;
}
