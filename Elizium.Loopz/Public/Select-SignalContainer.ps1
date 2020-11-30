
function Select-SignalContainer {
  param(
    [Parameter(Mandatory)]
    [PSCustomObject]$Containers,

    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter(Mandatory)]
    [string]$Value,

    [Parameter()]
    [System.Collections.Hashtable]$Signals = $(Get-Signals),

    [Parameter()]
    [string]$Format = '[{1}] {0}', # 0=Label, 1=Emoji,

    [Parameter()]
    [int]$Threshold = 6,

    [Parameter()]
    [string]$CustomLabel
  )

  $formattedSignal = Get-FormattedSignal -Name $Name -Format $Format -Value $Value `
    -Signals $Signals -CustomLabel $CustomLabel;

  if ($Value.Length -gt $Threshold) {
    $Containers.Wide += , $formattedSignal;
  }
  else {
    $Containers.Props += , $formattedSignal;
  }
}
