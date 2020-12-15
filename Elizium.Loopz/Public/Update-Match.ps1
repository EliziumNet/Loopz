
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
    [string]$CopyOccurrence = 'f',

    [Parameter()]
    [string]$With,

    [Parameter()]
    [string]$Paste
  )

  [string]$capturedPattern, $null, [System.Text.RegularExpressions.Match]$patternMatch = `
    Split-Match -Source $Value -PatternRegEx $Pattern `
    -Occurrence ($PSBoundParameters.ContainsKey('PatternOccurrence') ? $PatternOccurrence : 'f');

  [boolean]$failed = $false;

  if (-not([string]::IsNullOrEmpty($capturedPattern))) {
    if ($PSBoundParameters.ContainsKey('Copy')) {
      [string]$replaceWith, $null, [System.Text.RegularExpressions.Match]$copyMatch = `
        Split-Match -Source $Value -PatternRegEx $Copy `
        -Occurrence ($PSBoundParameters.ContainsKey('CopyOccurrence') ? $CopyOccurrence : 'f');

        if ([string]::IsNullOrEmpty($replaceWith)) {
          $failed = $true;
          [string]$result = $Value;
        }
    }
    elseif ($PSBoundParameters.ContainsKey('With')) {
      [string]$replaceWith = $With;
    }
    else {
      [string]$replaceWith = [string]::Empty;
    }

    if (-not($failed)) {
      if ($PSBoundParameters.ContainsKey('Paste')) {
        [string]$format = $Paste.Replace('${_c}', $replaceWith).Replace(
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
    }
  } else {
    [string]$result = $Value;
  }

  [PSCustomObject]$updateResult = [PSCustomObject]@{
    Payload = $result;
  }

  return $updateResult;
} # Update-Match

