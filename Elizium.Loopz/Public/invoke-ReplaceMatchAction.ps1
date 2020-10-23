
function invoke-ReplaceMatchAction {
  # This will eventually be renamed to be a public function Update-Match
  [OutputType([string])]
  param(
    [Parameter()]
    [string]$Value,

    [Parameter()]
    [System.Text.RegularExpressions.RegEx]$Pattern,

    [Parameter()]
    [string]$PatternOccurrence = 'f',

    [Parameter()]
    [System.Text.RegularExpressions.RegEx]$With,

    [Parameter()]
    [string]$WithOccurrence = 'f',

    [Parameter()]
    [string]$LiteralWith,

    [Parameter()]
    [string]$Paste
  )

  [string]$capturedPattern, $null, [System.Text.RegularExpressions.Match]$patternMatch = `
    Get-DeconstructedMatch -Source $Value -PatternRegEx $Pattern `
    -Occurrence ($PSBoundParameters.ContainsKey('PatternOccurrence') ? $PatternOccurrence : 'f');

  if (-not([string]::IsNullOrEmpty($capturedPattern))) {
    if ($PSBoundParameters.ContainsKey('With')) {
      [string]$replaceWith, $null, [System.Text.RegularExpressions.Match]$withMatch = `
        Get-DeconstructedMatch -Source $Value -PatternRegEx $With `
        -Occurrence ($PSBoundParameters.ContainsKey('WithOccurrence') ? $WithOccurrence : 'f');

    }
    elseif ($PSBoundParameters.ContainsKey('LiteralWith')) {
      [string]$replaceWith = $LiteralWith;
    }
    else {
      # throw parameter exception instead?
      throw 'edit-ReplaceFirstMatch: missing parameter, either With or LiteralWith must be specified'
    }

    if ($PSBoundParameters.ContainsKey('Paste')) {
      [string]$format = $Paste.Replace('${_w}', $replaceWith).Replace(
        '$0', $capturedPattern);
    }
    else {
      # Just do a straight swap of the pattern match for the replaceWith
      #
      [string]$format = $replaceWith;
    }

    [string]$result = ($PatternOccurrence -eq '*') `
      ? $Pattern.Replace($Value, $format) `
      : $Pattern.Replace($Value, $format, 1, $patternMatch.Index);
  } else {
    [string]$result = $Value;
  }

  return $result;
} # invoke-ReplaceMatchAction

