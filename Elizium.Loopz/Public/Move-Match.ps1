
function Move-Match {
  [Alias('moma')]
  [OutputType([string])]
  param (
    [Parameter(Mandatory)]
    [string]$Value,

    [Parameter()]
    [System.Text.RegularExpressions.RegEx]$Pattern,

    [Parameter()]
    [string]$PatternOccurrence = 'f',

    [Parameter()]
    [System.Text.RegularExpressions.RegEx]$Anchor,

    [Parameter()]
    [string]$AnchorOccurrence = 'f',

    [Parameter()]
    [ValidateSet('before', 'after')]
    [string]$Relation = 'after',

    [Parameter()]
    [System.Text.RegularExpressions.RegEx]$Copy,

    [Parameter()]
    [string]$CopyOccurrence = 'f',

    [Parameter()]
    [string]$With,

    [Parameter()]
    [string]$Paste,

    [Parameter()]
    [switch]$Start,

    [Parameter()]
    [switch]$End,

    [Parameter()]
    [switch]$Diagnose,

    [Parameter()]
    [string]$Drop,

    [Parameter()]
    [char]$Marker = 0x20DE
  )

  # If the move fails, we need to return the reason for the failure so it can be reported back to he user

  # vanilla,
  # vanilla-formatted,
  # exotic,
  # exotic-formatted

  [string]$result = [string]::Empty;
  [string]$failedReason = [string]::Empty;
  [PSCustomObject]$groups = [PSCustomObject]@{
    Named = @{}
  }

  [boolean]$isFormatted = $PSBoundParameters.ContainsKey('Paste') -and -not([string]::IsNullOrEmpty($Paste));
  [boolean]$dropped = $PSBoundParameters.ContainsKey('Drop') -and -not([string]::IsNullOrEmpty($Drop));

  # First remove the Pattern match from the source. This makes the With and Anchor match
  # against the remainder ($patternRemoved) of the source. This way, there is no overlap
  # between the Pattern match and With/Anchor and it also makes the functionality more
  # understandable for the user. NB: Pattern only tells you what to remove, but it's the
  # With and/or Anchor that defines what to insert. The user should not be using named
  # capture groups in Pattern, rather, they should be defined inside Anchor/With and
  # referenced inside Paste. Another important point of note is that With et al applies
  # to the anchor not the original Pattern capture.
  #
  [System.Collections.Hashtable]$parameters = @{
    'Source'       = $Value
    'PatternRegEx' = $Pattern
    'Occurrence'   = ($PSBoundParameters.ContainsKey('PatternOccurrence') ? $PatternOccurrence : 'f')
  }

  if ($dropped) {
    $parameters['Marker'] = $Marker;
  }

  [string]$capturedPattern, [string]$patternRemoved, `
    [System.Text.RegularExpressions.Match]$patternMatch = Split-Match @parameters;

  if (-not([string]::IsNullOrEmpty($capturedPattern))) {
    [boolean]$isVanilla = -not($PSBoundParameters.ContainsKey('Copy') -or `
      ($PSBoundParameters.ContainsKey('With') -and -not([string]::IsNullOrEmpty($With))));

    if ($Diagnose.ToBool()) {
      $groups.Named['Pattern'] = get-Captures -MatchObject $patternMatch;
    }

    # Determine the replacement text
    #
    if ($isVanilla) {
      # Insert the original pattern match, because there is no Copy/With.
      #
      [string]$replaceWith = $capturedPattern;
    }
    else {
      [string]$replaceWith = [string]::Empty;
      if ($PSBoundParameters.ContainsKey('Copy')) {
        if ($patternRemoved -match $Copy) {
          [System.Collections.Hashtable]$parameters = @{
            'Source'       = $patternRemoved
            'PatternRegEx' = $Copy
            'Occurrence'   = ($PSBoundParameters.ContainsKey('CopyOccurrence') ? $CopyOccurrence : 'f')
          }

          if ($dropped) {
            $parameters['Marker'] = $Marker;
          }

          # With this implementation, it is up to the user to supply a regex proof
          # pattern, so if the Copy contains regex chars, they must pass in the string
          # pre-escaped: -Copy $(esc('some-pattern') + 'other stuff').
          #
          [string]$replaceWith, $null, [System.Text.RegularExpressions.Match]$copyMatch = Split-Match @parameters;

          if ($Diagnose.ToBool()) {
            $groups.Named['Copy'] = get-Captures -MatchObject $copyMatch;
          }
        }
        else {
          # Copy doesn't match so abort and return unmodified source
          #
          $failedReason = 'Copy Match';
        }
      }
      elseif ($PSBoundParameters.ContainsKey('With')) {
        [string]$replaceWith = $With;
      }
      else {
        [string]$replaceWith = [string]::Empty;
      }
    }

    if (-not($PSBoundParameters.ContainsKey('Anchor')) -and ($isFormatted)) {
      $replaceWith = $Paste.Replace('${_c}', $replaceWith).Replace('$0', $capturedPattern);

      # Now apply the user defined Pattern named group references if they exist
      # to the captured pattern
      #
      $replaceWith = $capturedPattern -replace $pattern, $replaceWith;
    }

    if ($Start.ToBool()) {
      $result = $replaceWith + $patternRemoved;
    }
    elseif ($End.ToBool()) {
      $result = $patternRemoved + $replaceWith;
    }
    elseif ($PSBoundParameters.ContainsKey('Anchor')) {
      [System.Collections.Hashtable]$parameters = @{
        'Source'       = $patternRemoved
        'PatternRegEx' = $Anchor
        'Occurrence'   = ($PSBoundParameters.ContainsKey('AnchorOccurrence') ? $AnchorOccurrence : 'f')
      }

      if ($dropped) {
        $parameters['Marker'] = $Marker;
      }

      # As with the Copy parameter, if the user wants to specify an anchor by a pattern which
      # contains regex chars, then can use -Anchor $(esc('anchor-pattern')). If there are no regex chars,
      # then they can use -Anchor 'pattern'. However, if the user needs to do partial escapes, then they will
      # have to do the escaping themselves: -Anchor $(esc('partial-pattern') + 'remaining-pattern')
      #
      [string]$capturedAnchor, $null, [System.Text.RegularExpressions.Match]$anchorMatch = `
        Split-Match @parameters;

      if (-not([string]::IsNullOrEmpty($capturedAnchor))) {
        # Relation and Paste are not compatible, because if the user is defining the
        # replacement format, it is up to them to define the relationship of the anchor
        # with the replacement text. So exotic/vanilla-formatted can't use Relation.
        #

        # How do we handle group references in the Anchor? These are done transparently
        # because any group defined in Anchor can be referenced by Paste as long as
        # there is a replace operation of the form regEx.Replace($Pattern, Paste). Of course
        # we can't do the replace in this simplistic way, because that form would replace
        # all matches, when we only want to replace the specified Pattern occurrence.
        #
        if ($isFormatted) {
          # Paste can be something like '=== ${_a}, (${a}, ${b}, [$0], ${_c} ===', where $0
          # represents the pattern capture, the special variable _w represents Copy/With,
          # _a represents the anchor and ${a} and ${b} represents user defined capture groups.
          # The Paste replaces the anchor, so to re-insert the anchor _a, it must be referenced
          # in the Paste format. Numeric captures may also be referenced.
          #
          [string]$format = $Paste.Replace('${_c}', $replaceWith).Replace(
            '$0', $capturedPattern).Replace('${_a}', $capturedAnchor);

          # Now apply the user defined Pattern named group references if they exist
          # to the captured pattern
          #
          $format = $capturedPattern -replace $pattern, $format;
        }
        else {
          # If the user has defined a Copy/With without a format(Paste), we define the format
          # in terms of the relationship specified.
          #
          [string]$format = ($Relation -eq 'before') `
            ? $replaceWith + $capturedAnchor : $capturedAnchor + $replaceWith;
        }

        if ($Diagnose.ToBool()) {
          $groups.Named['Anchor'] = get-Captures -MatchObject $anchorMatch;
        }

        $result = $Anchor.Replace($patternRemoved, $format, 1, $anchorMatch.Index);
      }
      else {
        # Anchor doesn't match Pattern
        #
        $failedReason = 'Anchor Match';
      }
    }
    else {
      # This is an error, because there is no place to move the pattern to, as there is no Anchor,
      # Start or End specified. Ideally this would be prevented by parameter set definition;
      #
      $failedReason = 'Missing Anchor';
    }
  }
  else {
    # Source doesn't match Pattern
    #
    $failedReason = 'Pattern Match';
  }

  if ([boolean]$success = $([string]::IsNullOrEmpty($failedReason))) {
    if ($dropped -and $result.Contains([string]$Marker)) {
      $result = $result.Replace([string]$Marker, $Drop);
    }
  }
  else {
    $result = $Value;
  }

  [PSCustomObject]$moveResult = [PSCustomObject]@{
    Payload = $result;
    Success = $success;
  }

  if (-not([string]::IsNullOrEmpty($failedReason))) {
    $moveResult | Add-Member -MemberType NoteProperty -Name 'FailedReason' -Value $failedReason;
  }

  if ($Diagnose.ToBool() -and ($groups.Named.Count -gt 0)) {
    $moveResult | Add-Member -MemberType NoteProperty -Name 'Diagnostics' -Value $groups;
  }

  return $moveResult;
} # Move-Match
