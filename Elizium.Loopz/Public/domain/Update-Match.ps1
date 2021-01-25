
function Update-Match {

  <#
  .NAME
    Update-Match

  .SYNOPSIS
    The core update match action function principally used by Rename-Many. Updates
  $Pattern match in it's current location and can update all $Pattern matches if
  '*' is specified as the $PatternOccurrence.

  .DESCRIPTION
    Returns a new string that reflects updating the specified $Pattern match.
    First Update-Match, removes the Pattern match from $Value. This makes the With and
  Copy match against the remainder ($patternRemoved) of $Value. This way, there is
  no overlap between the Pattern match and $With and it also makes the functionality more
  understandable for the user. NB: Pattern only tells you what to remove, but it's the
  With, Copy and Paste that defines what to insert. The user should not be using named
  capture groups in Copy rather, they should be defined inside $Paste and referenced
  inside Paste.

  .PARAMETER Copy
    Regular expression string applied to $Value (after the $Pattern match has been removed),
  indicating a portion which should be copied and re-inserted (via the $Paste parameter;
  see $Paste or $With). Since this is a regular expression to be used in $Paste/$With, there
  is no value in the user specifying a static pattern, because that static string can just be
  defined in $Paste/$With. The value in the $Copy parameter comes when a generic pattern is
  defined eg \d{3} (is non static), specifies any 3 digits as opposed to say '123', which
  could be used directly in the $Paste/$With parameter without the need for $Copy. The match
  defined by $Copy is stored in special variable ${_p} and can be referenced as such from
  $Paste and $With.

  .PARAMETER CopyOccurrence
    Can be a number or the letters f, l
  * f: first occurrence
  * l: last occurrence
  * <number>: the nth occurrence

  .PARAMETER Diagnose
    switch parameter that indicates the command should be run in WhatIf mode. When enabled
  it presents additional information that assists the user in correcting the un-expected
  results caused by an incorrect/un-intended regular expression. The current diagnosis
  will show the contents of named capture groups that they may have specified. When an item
  is not renamed (usually because of an incorrect regular expression), the user can use the
  diagnostics along side the 'Not Renamed' reason to track down errors. When $Diagnose has
  been specified, $WhatIf does not need to be specified.

  .PARAMETER Paste
    This is a NON regular expression string. It would be more accurately described as a formatter,
  similar to the $With parameter. The other special variables that can be used inside a $Paste
  string is documented under the $With parameter.

  .PARAMETER Pattern
    Regular expression string that indicates which part of the $Value that either needs
  to be moved or replaced as part of overall rename operation. Those characters in $Value
  which match $Pattern, are removed.

  .PARAMETER PatternOccurrence
    Can be a number or the letters f, l
  * f: first occurrence
  * l: last occurrence
  * <number>: the nth occurrence

  .PARAMETER Value
    The source value against which regular expressions are applied.

  .PARAMETER With
    This is a NON regular expression string. It would be more accurately described as a formatter,
  similar to the $Paste parameter. Defines what text is used as the replacement for the $Pattern
  match. Works in concert with $Relation (whereas $Paste does not). $With can reference special
  variables:
  * $0: the pattern match
  * ${_c}: the copy match
  When $Pattern contains named capture groups, these variables can also be referenced. Eg if the
  $Pattern is defined as '(?<day>\d{1,2})-(?<mon>\d{1,2})-(?<year>\d{4})', then the variables
  ${day}, ${mon} and ${year} also become available for use in $With or $Paste.
  Typically, $With is static text which is used to replace the $Pattern match.

  #>
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
  [OutputType([string])]
  param(
    [Parameter()]
    [string]$Value,

    [Parameter()]
    [System.Text.RegularExpressions.RegEx]$Pattern,

    [Parameter()]
    [ValidateScript( { $_ -ne '0' })]
    [string]$PatternOccurrence = 'f',

    [Parameter()]
    [System.Text.RegularExpressions.RegEx]$Copy,

    [Parameter()]
    [ValidateScript( { $_ -ne '0' })]
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

  [string]$capturedPattern, $patternRemoved, [System.Text.RegularExpressions.Match]$patternMatch = `
    Split-Match -Source $Value -PatternRegEx $Pattern `
    -Occurrence ($PSBoundParameters.ContainsKey('PatternOccurrence') ? $PatternOccurrence : 'f');

  if (-not([string]::IsNullOrEmpty($capturedPattern))) {
    if ($PSBoundParameters.ContainsKey('Copy')) {
      [string]$replaceWith, $null, [System.Text.RegularExpressions.Match]$copyMatch = `
        Split-Match -Source $patternRemoved -PatternRegEx $Copy `
        -Occurrence ($PSBoundParameters.ContainsKey('CopyOccurrence') ? $CopyOccurrence : 'f');

      if ([string]::IsNullOrEmpty($replaceWith)) {
        $failedReason = 'Copy Match';
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
    $failedReason = 'Pattern Match';
  }

  [boolean]$success = $([string]::IsNullOrEmpty($failedReason));
  if (-not($success)) {
    $result = $Value;
  }

  [PSCustomObject]$updateResult = [PSCustomObject]@{
    Payload         = $result;
    Success         = $success;
    CapturedPattern = $capturedPattern;
  }

  if (-not([string]::IsNullOrEmpty($failedReason))) {
    $updateResult | Add-Member -MemberType NoteProperty -Name 'FailedReason' -Value $failedReason;
  }

  if ($Diagnose.ToBool() -and ($groups.Named.Count -gt 0)) {
    $updateResult | Add-Member -MemberType NoteProperty -Name 'Diagnostics' -Value $groups;
  }

  return $updateResult;
} # Update-Match

