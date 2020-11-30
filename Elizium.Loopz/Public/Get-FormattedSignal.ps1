
function Get-FormattedSignal {
  param(
    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter()]
    [string]$Format = '[{1}] {0}', # 0=Label, 1=Emoji

    [Parameter()]
    [string]$Value,

    [Parameter()]
    [System.Collections.Hashtable]$Signals = $(Get-Signals),

    [Parameter()]
    [string]$CustomLabel,

    [Parameter()]
    [string]$EmojiOnlyFormat = '[{0}] ',

    [Parameter()]
    [switch]$EmojiOnly
  )

  $signal = $Signals.ContainsKey($Name) `
    ? $Signals[$Name] : $(resolve-ByPlatform -Hash $Loopz.MissingSignal);

  if ($EmojiOnly.ToBool()) {
    [string]$formatted = $EmojiOnlyFormat -f $signal[1]
  } else {
    [string]$label = ($PSBoundParameters.ContainsKey('CustomLabel') -and
      (-not([string]::IsNullOrEmpty($CustomLabel)))) ? $CustomLabel : $signal[0];

    [string]$formatted = $Format -f $label, $signal[1]
  }

  $result = $PSBoundParameters.ContainsKey('Value') `
    ? @($formatted, $Value) : $formatted;

  return $result;
}
