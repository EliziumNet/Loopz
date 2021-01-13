
function Get-FormattedSignal {
  <#
  .NAME
    Get-FormattedSignal

  .SYNOPSIS
    Controls and standardises the way that signals are displayed.

  .DESCRIPTION
    This function enables the display of key/value pairs where the key includes
  an emoji. The value may also include the emoji depending on how the function
  is used.
    Generally, this function returns either a Pair object or a single string.
  The user can define a format string (or simply use the default) which controls
  how the signal is displayed. If the function is invoked without a Value, then
  a formatted string is returned other a pair object is returned.

  .PARAMETER Name
    The name of the signal

  .PARAMETER Format
    A string defining the format defining how the signal is displayed. Should
  contain either {0} representing the signal's emoji or {1} the label. They
  can appear as many time as is required, but there should be at least either
  of these.

  .PARAMETER Value
    A string defining the Value displayed when the signal is a Key/Value pair.

  .PARAMETER Signals
    The signals hashtable collection from which to select the signal from.

  .PARAMETER CustomLabel
    An alternative label to display overriding the signal's defined label.

  .PARAMETER EmojiOnlyFormat
    When the switch EmojiOnly is enabled, defines the format used to create
  the result. Should contain at least 1 occurrence of {1} representing the
  emoji.

  .PARAMETER EmojiOnly
    Changes what is returned to be a single only whose formatted as EmojiOnlyFormat.

  .PARAMETER EmojiAsValue
    switch which changes the result so that the emoji appears as part of the
  value as opposed to the key.

  #>
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
