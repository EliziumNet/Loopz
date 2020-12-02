
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
    [switch]$EmojiOnly,

    [Parameter()]
    [switch]$EmojiAsValue
  )

  $signal = $Signals.ContainsKey($Name) `
    ? $Signals[$Name] `
    : @($("??? ({0})" -f $Name), $(resolve-ByPlatform -Hash $Loopz.MissingSignal)[1]);

  [string]$label = ($PSBoundParameters.ContainsKey('CustomLabel') -and
    (-not([string]::IsNullOrEmpty($CustomLabel)))) ? $CustomLabel : $signal[0];

  [string]$formatted = $EmojiOnly.ToBool() `
    ? $EmojiOnlyFormat -f $signal[1] : $Format -f $label, $signal[1];

  $result = if ($PSBoundParameters.ContainsKey('Value')) {
    @($formatted, $Value);
  }
  elseif ($EmojiAsValue.ToBool()) {
    @($label, $($EmojiOnlyFormat -f $signal[1]));
  }
  else {
    $formatted;
  }

  return $result;
}
