
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

        if ([string]::IsNullOrEmpty($replaceWith)) {
          return $Value;
        }
    }
    elseif ($PSBoundParameters.ContainsKey('LiteralWith')) {
      [string]$replaceWith = $LiteralWith;
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

