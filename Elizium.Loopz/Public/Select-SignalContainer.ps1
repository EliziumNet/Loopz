
function Select-SignalContainer {
  param(
    [Parameter(Mandatory)]
    [PSCustomObject]$Containers,

    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter(Mandatory)]
    [string]$Value,

    [Parameter()]
    [hashtable]$Signals = $(Get-Signals),

    [Parameter()]
    [string]$Format = '[{1}] {0}', # 0=Label, 1=Emoji,

    [Parameter()]
    [int]$Threshold = 6,

    [Parameter()]
    [string]$CustomLabel,

    [Parameter()]
    [ValidateSet('Wide', 'Props')]
    [string]$Force
  )

  $formattedSignal = Get-FormattedSignal -Name $Name -Format $Format -Value $Value `
    -Signals $Signals -CustomLabel $CustomLabel;

  if ($PSBoundParameters.ContainsKey('Force')) {
    if ($Force -eq 'Wide') {
      $Containers.Wide += , $formattedSignal;
    }
    else {
      $Containers.Props += , $formattedSignal;
    }
  }
  else {
    if ($Value.Length -gt $Threshold) {
      $Containers.Wide += , $formattedSignal;
    }
    else {
      $Containers.Props += , $formattedSignal;
    }
  }
}
