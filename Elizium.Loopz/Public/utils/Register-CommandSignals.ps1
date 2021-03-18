
function Register-CommandSignals {
  [Alias('rgcos')]
  param(
    [Parameter(Mandatory)]
    [string]$Alias,

    [Parameter(Mandatory)]
    [string[]]$UsedSet,

    [Parameter()]
    [hashtable]$Signals = $(get-Signals)
  )
  if ($Loopz.SignalRegistry.ContainsKey($Alias)) {
    throw [System.Management.Automation.MethodInvocationException]::new(
      "Register failed; alias: '$Alias' already exists."
    );
  }

  [string[]]$signalKeys = $Signals.PSBase.Keys;

  if (Test-ContainsAll -Super $signalKeys -Sub $UsedSet) {
    $Loopz.SignalRegistry[$Alias] = $UsedSet;
  }
  else {
    throw [System.Management.Automation.MethodInvocationException]::new(
      "Register failed; 1 or more of the defined signals are invalid"
    );
  }
}
