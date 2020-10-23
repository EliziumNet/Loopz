function edit-ReplaceFirstMatch {
  [Alias('Replace-FirstMatch')]
  [OutputType([string])]
  param(
    [Parameter(Mandatory)]
    [string]$Source,

    [Parameter(Mandatory)]
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
  [string]$result = $source;

  [string]$capturedPattern, $null, [System.Text.RegularExpressions.Match]$patternMatch = `
    Get-DeconstructedMatch -Source $Source -PatternRegEx $Pattern `
    -Occurrence ($PSBoundParameters.ContainsKey('PatternOccurrence') ? $PatternOccurrence : 'f');

  if ($PSBoundParameters.ContainsKey('With')) {
    [string]$replaceWith, $null, [System.Text.RegularExpressions.Match]$withMatch = `
      Get-DeconstructedMatch -Source $Source -PatternRegEx $With `
      -Occurrence ($PSBoundParameters.ContainsKey('WithOccurrence') ? $WithOccurrence : 'f');

  } elseif ($PSBoundParameters.ContainsKey('LiteralWith')) {
    [string]$replaceWith = $LiteralWith;
  } else {
    # throw parameter exception instead?
    throw 'edit-ReplaceFirstMatch: missing parameter, either With or LiteralWith must be specified'
  }

  if ($PSBoundParameters.ContainsKey('Paste')) {
    [string]$format = $Paste.Replace('${_w}', $replaceWith).Replace(
      '$0', $capturedPattern);
  } else {
    # Just do a straight swap of the pattern match for the replaceWith
    #
    [string]$format = $replaceWith;
  }

  if ($PatternOccurrence -eq 'f') {
    $result = $Pattern.Replace($Source, $format, 1, $patternMatch.Index);
  } elseif ($PatternOccurrence -eq '*') {
    $result = $Pattern.Replace($Source, $replaceWith);
  }

  return $result;
} # edit-ReplaceFirstMatch
