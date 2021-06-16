
function Register-CommandSignals {
  <#
  .NAME
    Register-CommandSignals

  .SYNOPSIS
    A client can use this function to register which signals it uses
  with the signal registry. When the user uses the Show-Signals command,
  they can see which signals a command uses and therefore see the impact
  of defining a custom signal.

  .DESCRIPTION
    Stores the list of signals used for a command in the signal registry.
  It is recommended that the client defines an alias for their command then
  registers signals against this more concise alias, rather the the full
  command name. This will reduce the chance of an overflow in the console,
  if too many commands are registered. It is advised that clients invoke
  this for all commands that use signals in the module initialisation code.
  This will mean that when a module is imported, the command's signals are
  registered and will show up in the table displayed by 'Show-Signals'.

  .LINK
    https://eliziumnet.github.io/Loopz/

  .PARAMETER Alias
    The name of the command's alias, to register the signals under.

  .PARAMETER Signals
    The signals hashtable collection, to validate the UsedSet against;
  should be left to the default.

  .PARAMETER UsedSet
    The set of signals that the specified command uses.

  .EXAMPLE 1
  Register-CommandSignals -Alias 'xcopy', 'WHAT-IF', 'SOURCE', 'DESTINATION'

  #>
  [Alias('rgcos')]
  param(
    [Parameter(Mandatory)]
    [string]$Alias,

    [Parameter(Mandatory)]
    [string[]]$UsedSet,

    [Parameter()]
    [hashtable]$Signals = $(Get-Signals),

    [Parameter()]
    [switch]$Silent
  )
  if ($Loopz.SignalRegistry.ContainsKey($Alias) -and -not($Silent.IsPresent)) {
    Write-Warning $("Register ignored; alias: '$Alias' already exists.");
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
