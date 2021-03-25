
function Update-CustomSignals {
  <#
  .NAME
    Update-CustomSignals

  .SYNOPSIS
    Allows user to override the emoji's for commands

  .DESCRIPTION
    A user may want to customise the appear of commands that use signals in their
  display. The user can specify overrides for any of the declared signals (See
  Show-Signals). Typically, the user should invoke this in their profile script.

  .PARAMETER Signals
    A hashtable containing signal overrides.

  .EXAMPLE 1
  Override signals 'PATTERN' and 'LOCKED' with custom emojis.

  [hashtable]$myOverrides = @{
    'PATTERN' = $(kp(@('Capture', '👾')));
    'LOCKED' = $(kp(@('No soup for you', '🥣')));
  }
  Update-CustomSignals -Signals $myOverrides
  #>
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
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
