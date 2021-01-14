
function Select-SignalContainer {
  <#
  .NAME
    Select-SignalContainer

  .SYNOPSIS
    Selects a signal into the container specified (either 'Wide' or 'Props').
  Wide items will appear on their own line, Props are for items which are
  short in length and can be combined into the same line.

  .DESCRIPTION
    This is a wrapper around Get-FormattedSignal in addition to selecting the
  signal into a container.

  .PARAMETER Containers
    PSCustomObject that contains Wide and Props properties which must be of Krayola's
  type [line].

  .PARAMETER CustomLabel
    A custom label applied to the formatted signal.

  .PARAMETER Force
    An override (bypassing $Threshold) to push a signal into a specific collection.

  .PARAMETER Format
    The format applied to the formatted signal.

  .PARAMETER Name
    The signal name.

  .PARAMETER Signals
    The signal hashtable collection from which to select the required signal denoted by
  $Name.

  .PARAMETER Threshold
    A threshold that defines whether the signal is added to Wide or Props.

  .PARAMETER Value
    The value associated wih the signal.

  #>
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

  [couplet]$formattedSignal = Get-FormattedSignal -Name $Name -Format $Format -Value $Value `
    -Signals $Signals -CustomLabel $CustomLabel;

  if ($PSBoundParameters.ContainsKey('Force')) {
    if ($Force -eq 'Wide') {
      $null = $Containers.Wide.append($formattedSignal);
    }
    else {
      $null = $Containers.Props.append($formattedSignal);
    }
  }
  else {
    if ($Value.Length -gt $Threshold) {
      $null = $Containers.Wide.append($formattedSignal);
    }
    else {
      $null = $Containers.Props.append($formattedSignal);
    }
  }
}
