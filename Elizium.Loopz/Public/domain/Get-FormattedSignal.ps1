
function Get-FormattedSignal {
  param(
    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter()]
    [string]$Format = '[{1}] {0}', # 0=Label, 1=Emoji

    [Parameter()]
    [string]$Value,

    [Parameter()]
    [hashtable]$Signals = $(Get-Signals),

    [Parameter()]
    [string]$CustomLabel,

    [Parameter()]
    [string]$EmojiOnlyFormat = '[{0}] ',

    [Parameter()]
    [switch]$EmojiOnly,

    [Parameter()]
    [switch]$EmojiAsValue
  )

  [couplet]$signal = $Signals.ContainsKey($Name) `
    ? $Signals[$Name] `
    : $(New-Pair(@($("??? ({0})" -f $Name), $(Resolve-ByPlatform -Hash $Loopz.MissingSignal).Value)));

  [string]$label = ($PSBoundParameters.ContainsKey('CustomLabel') -and
    (-not([string]::IsNullOrEmpty($CustomLabel)))) ? $CustomLabel : $signal.Key;

  [string]$formatted = $EmojiOnly.ToBool() `
    ? $EmojiOnlyFormat -f $signal.Value : $Format -f $label, $signal.Value;

  $result = if ($PSBoundParameters.ContainsKey('Value')) {
    New-Pair($formatted, $Value);
  }
  elseif ($EmojiAsValue.ToBool()) {
    New-Pair($label, $($EmojiOnlyFormat -f $signal.Value));
  }
  else {
    $formatted;
  }

  return $result;
}
