
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
    [string]$Paste,

    [Parameter()]
    [switch]$Diagnose
  )

  [string]$failedReason = [string]::Empty;
  [PSCustomObject]$groups = [PSCustomObject]@{
    Named = @{}
  }

  [string]$capturedPattern, $null, [System.Text.RegularExpressions.Match]$patternMatch = `
    Split-Match -Source $Value -PatternRegEx $Pattern `
    -Occurrence ($PSBoundParameters.ContainsKey('PatternOccurrence') ? $PatternOccurrence : 'f');

  if (-not([string]::IsNullOrEmpty($capturedPattern))) {
    if ($PSBoundParameters.ContainsKey('Copy')) {
      [string]$replaceWith, $null, [System.Text.RegularExpressions.Match]$copyMatch = `
        Split-Match -Source $Value -PatternRegEx $Copy `
        -Occurrence ($PSBoundParameters.ContainsKey('CopyOccurrence') ? $CopyOccurrence : 'f');

      if ([string]::IsNullOrEmpty($replaceWith)) {
        $failedReason = 'Copy failed Match';
        [string]$result = $Value;
      }
      elseif ($Diagnose.ToBool()) {
        $groups.Named['Copy'] = get-Captures -MatchObject $copyMatch;
      }
    }
    elseif ($PSBoundParameters.ContainsKey('With')) {
      [string]$replaceWith = $With;
    }
    else {
      [string]$replaceWith = [string]::Empty;
    }

    if ([string]::IsNullOrEmpty($failedReason)) {
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

      if ($Diagnose.ToBool()) {
        $groups.Named['Pattern'] = get-Captures -MatchObject $patternMatch;
      }
    }
  }
  else {
    [string]$result = $Value;
  }

  [PSCustomObject]$updateResult = [PSCustomObject]@{
    Payload = $result;
  }

  if ($Diagnose.ToBool() -and ($groups.Named.Count -gt 0)) {
    $updateResult | Add-Member -MemberType NoteProperty -Name 'Diagnostics' -Value $groups;
  }

  return $updateResult;
} # Update-Match

