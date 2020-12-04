
function Update-Match {
  [OutputType([string])]
  param(
    [Parameter()]
    [string]$Value,

    [Parameter()]
    [System.Text.RegularExpressions.RegEx]$Pattern,

    [Parameter()]
    [string]$PatternOccurrence = 'f',

    [Parameter()]
    [System.Text.RegularExpressions.RegEx]$Copy,

    [Parameter()]
    [string]$WithOccurrence = 'f',

    [Parameter()]
    [string]$LiteralCopy,

    [Parameter()]
    [string]$Paste
  )

  [string]$capturedPattern, $null, [System.Text.RegularExpressions.Match]$patternMatch = `
    Split-Match -Source $Value -PatternRegEx $Pattern `
    -Occurrence ($PSBoundParameters.ContainsKey('PatternOccurrence') ? $PatternOccurrence : 'f');

  if (-not([string]::IsNullOrEmpty($capturedPattern))) {
    if ($PSBoundParameters.ContainsKey('Copy')) {
      [string]$replaceWith, $null, [System.Text.RegularExpressions.Match]$withMatch = `
        Split-Match -Source $Value -PatternRegEx $Copy `
        -Occurrence ($PSBoundParameters.ContainsKey('WithOccurrence') ? $WithOccurrence : 'f');

        if ([string]::IsNullOrEmpty($replaceWith)) {
          return $Value;
        }
    }
    elseif ($PSBoundParameters.ContainsKey('LiteralCopy')) {
      [string]$replaceWith = $LiteralCopy;
    }
    else {
      [string]$replaceWith = [string]::Empty;
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
} # Update-Match

