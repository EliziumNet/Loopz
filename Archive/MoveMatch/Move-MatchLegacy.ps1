
function Move-MatchLegacy {
  # PowerShell ParameterSets are too unmanageable and over-bearing for commands that have complex usage
  # scenarios such as with this command. Ideally, ParameterSets should be defined, but the correct definition
  # for this function would be too complex and unmaintainable.
  # TODO: Optimisation, all pattern parameters should be passed in as pre-validated regex objects
  #
  [OutputType([string])]
  param (
    [Parameter(Mandatory)]
    [string]$Source,

    [Parameter()]
    [string]$Pattern,

    [Parameter()]
    [string]$EscapedPattern,

    [Parameter()]
    [string]$PatternOccurrence = 'F',

    [Parameter()]
    [switch]$WholePattern,

    [Parameter()]
    [string]$Anchor,

    [Parameter()]
    [string]$EscapedAnchor,

    [Parameter()]
    [string]$AnchorOccurrence = 'F',

    [Parameter()]
    [switch]$WholeAnchor,

    [Parameter()]
    [ValidateSet('before', 'after')]
    [string]$Relation = 'after',

    [Parameter()]
    [switch]$Start,

    [Parameter()]
    [switch]$End,

    [Parameter()]
    [string]$With,

    [Parameter()]
    [string]$EscapedWith,

    [Parameter()]
    [string]$LiteralWith,

    [Parameter()]
    [string]$WithOccurrence = 'F',

    [Parameter()]
    [switch]$WholeWith,

    [Parameter()]
    [int]$Quantity = 1,

    [Parameter()]
    [string]$Paste
  )

  # If the move fails, we need to return the reason for the failure so it can be reported back to he user

  # vanilla,
  # vanilla-formatted,
  # exotic,
  # exotic-formatted

  [boolean]$doPatternMatch = $true;
  [string]$result = $Source;
  [string]$adjustedPattern = [string]::Empty;

  if ($PSBoundParameters.ContainsKey('Pattern')) {
    $adjustedPattern = $Pattern;
  }
  elseif ($PSBoundParameters.ContainsKey('EscapedPattern')) {
    $adjustedPattern = [regex]::Escape($EscapedPattern);
  }
  else {
    # Not a match operation, we just want to append/prepend With/LiteralWith to Start/End
    # Actually, this is not a genuine move operation so should be implemented elsewhere
    #
    $doPatternMatch = $false;
  }

  [boolean]$isFormatted = $PSBoundParameters.ContainsKey('Paste') -and -not([string]::IsNullOrEmpty($Paste));
  [boolean]$failed = $false;

  if ($doPatternMatch) {
    # First remove the Pattern match from the source. This makes the With and Anchor match
    # against the remainder ($patternRemoved) of the source. This way, there is no overlap
    # between the Pattern match and With/Anchor and it also makes the functionality more
    # understandable for the user. NB: Pattern only tells you what to remove, but it's the
    # With and/or Anchor that defines what to insert. The user should not be using named
    # capture groups in Pattern, rather, they should be defined inside Anchor/With and
    # referenced inside Paste. Another important point of note is that With et al applies
    # to the anchor not the original Pattern capture.
    #
    [boolean]$isVanilla = -not($PSBoundParameters.ContainsKey('With') -or `
        $PSBoundParameters.ContainsKey('EscapedWith') -or $PSBoundParameters.ContainsKey('LiteralWith'));

    [System.Text.RegularExpressions.RegEx]$adjustedPatternRegEx = new-RegularExpression $adjustedPattern;

    # TODO: There is an unnecessary match happening here, we should short circuit this, by just doing
    # the match and checking the result. IsMatch is not necessary.
    #
    if ($adjustedPatternRegEx.IsMatch($Source)) {

      [string]$capturedPattern, [string]$patternRemoved, $patternMatch = Get-DeconstructedMatch `
        -Source $Source -Pattern $adjustedPattern `
        -Occurrence ($PSBoundParameters.ContainsKey('PatternOccurrence') ? $PatternOccurrence : 'F') `
        -Whole:$WholePattern;

      # Determine the replacement text
      #
      if ($isVanilla) {
        # Insert the original pattern match, because there is no With/LiteralWith.
        #
        [string]$replaceWith = $capturedPattern;
      }
      else {
        [string]$replaceWith = [string]::Empty;
        if ($PSBoundParameters.ContainsKey('With') -or ($PSBoundParameters.ContainsKey('EscapedWith'))) {
          [string]$adjustedWith = $PSBoundParameters.ContainsKey('With') ? $With : [regex]::Escape($EscapedWith);
          if ($patternRemoved -match $adjustedWith) {
            # With this implementation, it is up to the user to supply a regex proof
            # pattern, so if the With contains regex chars, they must pass in the string
            # pre-escaped: -With $(esc('some-pattern') + 'other stuff') or -EscapedWith 'some-pattern'
            #
            [string]$replaceWith = Get-DeconstructedMatch `
              -Source $patternRemoved -Pattern $adjustedWith `
              -Occurrence ($PSBoundParameters.ContainsKey('WithOccurrence') ? $WithOccurrence : 'F') `
              -Whole:$WholeWith -CapturedOnly;
          }
          else {
            # With doesn't match so abort and return unmodified source
            #
            $failed = $true;
          }
        }
        elseif ($PSBoundParameters.ContainsKey('LiteralWith')) {
          [string]$replaceWith = $LiteralWith;
        }
      }

      if ($Start.ToBool()) {
        $result = $replaceWith + $patternRemoved;
      }
      elseif ($End.ToBool()) {
        $result = $patternRemoved + $replaceWith;
      }
      else {
        if ($PSBoundParameters.ContainsKey('Anchor') -or ($PSBoundParameters.ContainsKey('EscapedAnchor'))) {
          # As with the With/EscapedWith parameters, if the user wants to specify an anchor by a pattern which
          # contains regex chars, then can use -EscapedAnchor 'anchor-pattern'. If there are no regex chars,
          # then they can use -Anchor 'pattern'. However, if the user needs to do partial escapes, then they will
          # have to do the escaping themselves: -Anchor $(esc('some-pattern') + 'other stuff')
          #
          [string]$adjustedAnchor = $PSBoundParameters.ContainsKey('Anchor') ? $Anchor : [regex]::Escape($EscapedAnchor);

          [string]$capturedAnchor, $null, [System.Text.RegularExpressions.Match]$anchorMatch = `
            Get-DeconstructedMatch -Source $patternRemoved -Pattern $adjustedAnchor `
            -Occurrence ($PSBoundParameters.ContainsKey('AnchorOccurrence') ? $AnchorOccurrence : 'F') `
            -Whole:$WholeAnchor;

          [System.Text.RegularExpressions.RegEx]$captureAnchorPatternRegEx = new-RegularExpression $adjustedAnchor;

          if (-not([string]::IsNullOrEmpty($capturedAnchor))) {
            # Relation and Paste are not compatible, because if the user is defining the
            # replacement format, it is up to them to define the relationship of the anchor
            # with the replacement text. So exotic/vanilla-formatted can't use Relation.
            #
            # If the user has defined a With/LiteralWith without a format(Paste), we define the format
            # in terms of the relationship specified.
            #

            # How do we handle group references in the Anchor? These are done transparently
            # because any group defined in Anchor can be referenced by Paste as long as
            # there is a replace operation of the form regEx.Replace($Pattern, Paste). Of course
            # we can't do the replace in this simplistic way, because that form would replace
            # all matches, when we only want to replace the specified Pattern occurrence.
            #
            if ($isFormatted) {
              # Paste can be something like '=== ${_a}, (${a}, ${b}, [$0], ${_w} ===', where $0
              # represents the pattern capture, the special variable _w represents With/LiteralWith,
              # _a represents the anchor and ${a} and ${b} represents user defined capture groups.
              # The Paste replaces the anchor, so to re-insert the anchor _a, it must be referenced
              # in the Paste format. Numeric captures may also be referenced.
              #
              [string]$format = $Paste.Replace('${_w}', $replaceWith).Replace(
                '$0', $capturedPattern).Replace('${_a}', $capturedAnchor);
            }
            else {
              [string]$format = ($Relation -eq 'before') `
                ? $replaceWith + $capturedAnchor : $capturedAnchor + $replaceWith;
            }

            $result = $captureAnchorPatternRegEx.Replace($patternRemoved, $format, 1, $anchorMatch.Index);
          }
          else {
            # Anchor doesn't match Pattern
            #
            $failed = $true;
          }
        }
        else {
          # This is an error, because there is no place to move the pattern to, as there is no Anchor,
          # Start or End specified. Ideally this would be prevented by parameter set definition;
          $failed = $true;
        }
      }
    }
    else {
      # Source doesn't match Pattern
      #
      $failed = $true;
    }
  }

  $result;
} # Move-MatchLegacy
