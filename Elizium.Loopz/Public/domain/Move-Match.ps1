
function Move-Match {
  <#
  .NAME
    Move-Match

  .SYNOPSIS
    The core move match action function principally used by Rename-Many. Moves a
  match according to the specified anchor(s).

  .DESCRIPTION
    Returns a new string that reflects moving the specified $Pattern match to either
  the location designated by $Anchor/$AnchorOccurrence/$Relation or to the Start or
  End of the value indicated by the presence of the $Start/$End switch parameters.
    First Move-Match, removes the Pattern match from the source. This makes the With and
  Anchor match against the remainder ($patternRemoved) of the source. This way, there is
  no overlap between the Pattern match and With/Anchor and it also makes the functionality more
  understandable for the user. NB: $Pattern only tells you what to remove, but it's the
  $With, $Copy and $Paste that defines what to insert, with the $Anchor/$Start/$End
  defining where the replacement text should go. The user should not be using named capture
  groups in $Copy, or $Anchor, rather, they should be defined inside $Paste and referenced
  inside $Paste/$With.

  .PARAMETER Anchor
    Anchor is a regular expression string applied to $Value (after the $Pattern match has
  been removed). The $Pattern match that is removed is inserted at the position indicated
  by the anchor match in collaboration with the $Relation parameter.

  .PARAMETER AnchorOccurrence
    Can be a number or the letters f, l
  * f: first occurrence
  * l: last occurrence
  * <number>: the nth occurrence

  .PARAMETER Copy
    Regular expression object applied to $Value (after the $Pattern match has been removed),
  indicating a portion which should be copied and re-inserted (via the $Paste parameter;
  see $Paste or $With). Since this is a regular expression to be used in $Paste/$With, there
  is no value in the user specifying a static pattern, because that static string can just be
  defined in $Paste/$With. The value in the $Copy parameter comes when a generic pattern is
  defined eg \d{3} (is non static), specifies any 3 digits as opposed to say '123', which
  could be used directly in the $Paste/$With parameter without the need for $Copy. The match
  defined by $Copy is stored in special variable ${_c} and can be referenced as such from
  $Paste and $With.

  .PARAMETER CopyOccurrence
    Can be a number or the letters f, l
  * f: first occurrence
  * l: last occurrence
  * <number>: the nth occurrence

  .PARAMETER Cut
    Regular expression object that indicates which part of the $Value that
  either needs removed as part of overall rename operation. Those characters
  in $Value which match $Cut, are removed.

  .PARAMETER CutOccurrence
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

  .PARAMETER Drop
    A string parameter (only applicable to move operations, ie any of these Anchor/Star/End
  are present) that defines what text is used to replace the $Pattern match. So in this
  use-case, the user wants to move a particular token/pattern to another part of the name
  and at the same time drop a static string in the place where the $Pattern was removed from.
  The user can also reference named group captures defined inside Pattern or Copy. (Note that
  the whole Copy capture can be referenced with ${_c}.)

  .PARAMETER End
    Is another type of anchor used instead of $Anchor and specifies that the $Pattern match
  should be moved to the end of the new name.

  .PARAMETER Marker
    A character used to mark the place where the $Pattern was removed from. It should be a
  special character that is not easily typed on the keyboard by the user so as to not
  interfere wth $Anchor/$Copy matches which occur after $Pattern match is removed.

  .PARAMETER Pattern
    Regular expression object that indicates which part of the $Value that
  either needs to be moved or replaced as part of overall rename operation. Those characters
  in $Value which match $Pattern, are removed.

  .PARAMETER PatternOccurrence
    Can be a number or the letters f, l
  * f: first occurrence
  * l: last occurrence
  * <number>: the nth occurrence

  .PARAMETER Relation
    Used in conjunction with the $Anchor parameter and can be set to either 'before' or
  'after' (the default). Defines the relationship of the $Pattern match with the $Anchor
  match in the new name for $Value.

  .PARAMETER Start
    Is another type of anchor used instead of $Anchor and specifies that the $Pattern match
  should be moved to the start of the new name.

  .PARAMETER Value
    The source value against which regular expressions are applied.

  .PARAMETER With
    This is a NON regular expression string. It would be more accurately described as a formatter.
  Defines what text is used as the replacement for the $Pattern
  match. $With can reference special variables:
  * $0: the pattern match
  * ${_a}: the anchor match
  * ${_c}: the copy match
  When $Pattern contains named capture groups, these variables can also be referenced. Eg if the
  $Pattern is defined as '(?<day>\d{1,2})-(?<mon>\d{1,2})-(?<year>\d{4})', then the variables
  ${day}, ${mon} and ${year} also become available for use in $With.
  Typically, $With is static text which is used to replace the $Pattern match and is inserted
  according to the Anchor match, (or indeed $Start or $End).
  #>

  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSPossibleIncorrectUsageOfAssignmentOperator', '')]
  [Alias('moma')]
  [OutputType([string])]
  param (
    [Parameter(Mandatory)]
    [string]$Value,

    [Parameter(ParameterSetName = 'HybridStart', Mandatory)]
    [Parameter(ParameterSetName = 'HybridEnd', Mandatory)]
    [Parameter(ParameterSetName = 'MoveToAnchor', Mandatory)]
    [Parameter(ParameterSetName = 'MoveToStart', Mandatory)]
    [Parameter(ParameterSetName = 'MoveToEnd', Mandatory)]
    [System.Text.RegularExpressions.RegEx]$Pattern,

    [Parameter(ParameterSetName = 'HybridStart')]
    [Parameter(ParameterSetName = 'HybridEnd')]
    [Parameter(ParameterSetName = 'MoveToAnchor')]
    [Parameter(ParameterSetName = 'MoveToStart')]
    [Parameter(ParameterSetName = 'MoveToEnd')]
    [string]$PatternOccurrence = 'f',

    [Parameter(ParameterSetName = 'NoReplacement', Mandatory)]
    [System.Text.RegularExpressions.RegEx]$Cut,

    [Parameter(ParameterSetName = 'NoReplacement')]
    [string]$CutOccurrence = 'f',

    [Parameter(ParameterSetName = 'HybridStart', Mandatory)]
    [Parameter(ParameterSetName = 'HybridEnd', Mandatory)]
    [Parameter(ParameterSetName = 'MoveToAnchor', Mandatory)]
    [System.Text.RegularExpressions.RegEx]$Anchor,

    [Parameter(ParameterSetName = 'HybridStart')]
    [Parameter(ParameterSetName = 'HybridEnd')]
    [Parameter(ParameterSetName = 'MoveToAnchor')]
    [string]$AnchorOccurrence = 'f',

    [Parameter(ParameterSetName = 'HybridStart')]
    [Parameter(ParameterSetName = 'HybridEnd')]
    [Parameter(ParameterSetName = 'MoveToAnchor')]
    [ValidateSet('before', 'after')]
    [string]$Relation = 'after',

    [Parameter(ParameterSetName = 'HybridStart')]
    [Parameter(ParameterSetName = 'HybridEnd')]
    [Parameter(ParameterSetName = 'MoveToAnchor')]
    [Parameter(ParameterSetName = 'MoveToStart')]
    [Parameter(ParameterSetName = 'MoveToEnd')]
    [System.Text.RegularExpressions.RegEx]$Copy,

    [Parameter(ParameterSetName = 'HybridStart')]
    [Parameter(ParameterSetName = 'HybridEnd')]
    [Parameter(ParameterSetName = 'MoveToAnchor')]
    [Parameter(ParameterSetName = 'MoveToStart')]
    [Parameter(ParameterSetName = 'MoveToEnd')]
    [string]$CopyOccurrence = 'f',

    [Parameter(ParameterSetName = 'HybridStart')]
    [Parameter(ParameterSetName = 'HybridEnd')]
    [Parameter(ParameterSetName = 'MoveToAnchor')]
    [Parameter(ParameterSetName = 'MoveToStart')]
    [Parameter(ParameterSetName = 'MoveToEnd')]
    [string]$With,

    [Parameter(ParameterSetName = 'HybridStart', Mandatory)]
    [Parameter(ParameterSetName = 'MoveToStart', Mandatory)]
    [switch]$Start,

    [Parameter(ParameterSetName = 'HybridEnd', Mandatory)]
    [Parameter(ParameterSetName = 'MoveToEnd', Mandatory)]
    [switch]$End,

    [Parameter(ParameterSetName = 'MoveToAnchor')]
    [Parameter(ParameterSetName = 'MoveToStart')]
    [Parameter(ParameterSetName = 'MoveToEnd')]
    [string]$Drop,

    [Parameter()]
    [switch]$Diagnose,

    [Parameter()]
    [char]$Marker = 0x20DE
  )

  [string]$result = [string]::Empty;
  [string]$failedReason = [string]::Empty;
  [hashtable]$notes = [hashtable]@{}
  [PSCustomObject]$diagnostics = [PSCustomObject]@{
    Named = @{}
  }

  [boolean]$isAnchored = $PSBoundParameters.ContainsKey('Anchor') -and -not([string]::IsNullOrEmpty($Anchor));
  [boolean]$isFormattedWith = $PSBoundParameters.ContainsKey('With') -and -not([string]::IsNullOrEmpty($With));
  [boolean]$dropped = $PSBoundParameters.ContainsKey('Drop') -and -not([string]::IsNullOrEmpty($Drop));
  [boolean]$isPattern = $PSBoundParameters.ContainsKey('Pattern') -and -not([string]::IsNullOrEmpty($Pattern));
  [boolean]$isCut = $PSCmdlet.ParameterSetName -eq 'NoReplacement';
  [boolean]$isVanillaMove = -not($PSBoundParameters.ContainsKey('With')) -and -not($isCut);
  [boolean]$isCopy = $PSBoundParameters.ContainsKey('Copy');
  
  [Hashtable]$patternCaptures = @{}
  [Hashtable]$copyCaptures = @{}

  # Determine what to remove
  #
  [string]$removalText, $remainingText = if ($isPattern) {
    [hashtable]$parameters = @{
      'Source'       = $Value;
      'PatternRegEx' = $Pattern;
      'Occurrence'   = $($PSBoundParameters.ContainsKey('PatternOccurrence') ? $PatternOccurrence : 'f');
    }

    if ($dropped) {
      $parameters['Marker'] = $Marker;
    }

    [string]$capturedPattern, [string]$patternRemoved, `
      [System.Text.RegularExpressions.Match]$patternMatch = Split-Match @parameters;

    if (-not([string]::IsNullOrEmpty($capturedPattern))) {
      [hashtable]$patternCaptures = get-Captures -MatchObject $patternMatch;
      if ($Diagnose.ToBool()) {
        $diagnostics.Named['Pattern'] = $patternCaptures;
      }
    }
    else {
      # Source doesn't match Pattern
      #
      $failedReason = 'Pattern Match';
    }

    $capturedPattern, $patternRemoved;
  }
  elseif ($isCut) {
    [hashtable]$parameters = @{
      'Source'       = $Value;
      'PatternRegEx' = $Cut;
      'Occurrence'   = $($PSBoundParameters.ContainsKey('CutOccurrence') ? $CutOccurrence : 'f');
    }

    [string]$capturedCut, [string]$cutRemoved, `
      [System.Text.RegularExpressions.Match]$cutMatch = Split-Match @parameters;

    if (-not([string]::IsNullOrEmpty($capturedCut))) {
      $result = $cutRemoved;
    }
    else {
      # Source doesn't match Cut
      #
      $failedReason = 'Cut Match';
    }

    $capturedCut, $cutRemoved;
  }

  # Determine the replacement text (Copy/With)
  #
  if ([string]::IsNullOrEmpty($failedReason)) {
    if ([string]::IsNullOrEmpty($result)) {
      # The replaceWith here takes into account pattern ($0) and copy (${_c}) references inside the With
      # and also any of the user defined named group/capture no references in With, regardless of $isPattern,
      # $isCut, $Anchor, $Start or $End; ie it's universal.
      #
      [string]$replaceWith = if ($isVanillaMove) {
        # Insert the original pattern match, because there is no Copy/With.
        # If there is a Copy, without a With, the Copy is ignored, its only processed if
        # doing an exotic move (the opposite from $isVanilla)
        #
        $capturedPattern;
      }
      else {
        # Determine what to Copy
        #
        [string]$copyText = if ($isCopy) {
          [hashtable]$parameters = @{
            'Source'       = $remainingText
            'PatternRegEx' = $Copy
            'Occurrence'   = $($PSBoundParameters.ContainsKey('CopyOccurrence') ? $CopyOccurrence : 'f')
          }

          # With this implementation, it is up to the user to supply a regex proof
          # pattern, so if the Copy contains regex chars which must be treated literally, they
          # must pass in the string pre-escaped: -Copy $(esc('some-pattern') + 'other stuff').
          #
          [string]$capturedCopy, $null, `
            [System.Text.RegularExpressions.Match]$copyMatch = Split-Match @parameters;

          if (-not([string]::IsNullOrEmpty($capturedCopy))) {
            [hashtable]$copyCaptures = get-Captures -MatchObject $copyMatch;
            if ($Diagnose.ToBool()) {
              $diagnostics.Named['Copy'] = $copyCaptures;
            }
            $capturedCopy;
          }
          else {
            # Copy doesn't match so abort
            #
            $failedReason = 'Copy Match';
            [string]::Empty;
          }
        } # $copyText =
        else {
          [System.Text.RegularExpressions.Match]$copyMatch = $null;
          [string]::Empty;
        }

        # Determine With
        #
        if ([string]::IsNullOrEmpty($failedReason)) {
          # With can be something like '___ ${_a}, (${x}, ${y}, [$0], ${_c} ___', where $0
          # represents the pattern capture, the special variable _c represents $Copy,
          # _a represents the anchor and ${x} and ${y} represents user defined capture groups.
          # The With replaces the anchor, so to re-insert the anchor _a, it must be referenced
          # in the With format. Numeric captures may also be referenced.
          #

          # Handle whole Copy/Pattern reference inside the replacement text (With)
          #
          [string]$tempWith = $With.Replace('${_c}', $copyText).Replace('$0', $capturedPattern);

          # Handle Pattern group references
          #
          $tempWith = Update-GroupRefs -Source $tempWith -Captures $patternCaptures;

          # Handle Copy group references
          #
          $tempWith = Update-GroupRefs -Source $tempWith -Captures $copyCaptures;

          $tempWith;
        }
        else {
          [string]::Empty;
        }
      } # = replaceWith
    } # $result
  } # $failedReason
  else {
    [string]$replaceWith = [string]::Empty;
  }

  # Where to move match to
  #
  [string]$capturedAnchor = [string]::Empty;

  if ([string]::IsNullOrEmpty($failedReason)) {
    if ([string]::IsNullOrEmpty($result)) {
      # The anchor is the final replacement. The anchor match does not contain group
      # references. If the Anchor match should not contain group references; they will not be
      # resolved. The anchor is replaced by With (replacement text) and it's the With
      # that can contain Copy/Pattern group references. If there is no Start/End/Anchor then
      # the move operation is a Cut which is handled separately.
      #
      # Here we need to apply exotic move to Start/End as well as Anchor => move-Exotic
      # The only difference between these 3 scenarios is the destination
      #
      if ($isAnchored) {
        [hashtable]$parameters = @{
          'Source'       = $remainingText;
          'PatternRegEx' = $Anchor;
          'Occurrence'   = $($PSBoundParameters.ContainsKey('AnchorOccurrence') ? $AnchorOccurrence : 'f');
        }

        # As with the Copy parameter, if the user wants to specify an anchor by a pattern
        # which contains regex chars, then can use -Anchor $(esc('anchor-pattern')). If
        # there are no regex chars, then they can use -Anchor 'pattern'. However, if the
        # user needs to do partial escapes, then they will have to do the escaping
        # themselves: -Anchor $(esc('partial-pattern') + 'remaining-pattern').
        #
        [string]$capturedAnchor, $null, `
          [System.Text.RegularExpressions.Match]$anchorMatch = Split-Match @parameters;

        if (-not([string]::IsNullOrEmpty($capturedAnchor))) {
          [string]$format = if ($isFormattedWith) {
            $replaceWith;
          }
          else {
            ($Relation -eq 'before') ? $replaceWith + $capturedAnchor : $capturedAnchor + $replaceWith;
          }

          # Resolve anchor reference inside With
          #
          $format = $format.Replace('${_a}', $capturedAnchor);

          $result = $Anchor.Replace($remainingText, $format, 1, $anchorMatch.Index);
        }
        else {
          # Anchor doesn't match Pattern
          #
          if ($Start.ToBool()) {
            $result = $replaceWith + $remainingText;
            $notes['hybrid'] = 'Start (Anchor failed)';
          } elseif ($End.ToBool()) {
            $result = $remainingText + $replaceWith;
          }
          else {
            $failedReason = 'Anchor Match';
            $notes['hybrid'] = 'End  (Anchor failed)';
          }
        }
      }
      elseif ($Start.ToBool()) {
        $result = $replaceWith + $remainingText;
      }
      elseif ($End.ToBool()) {
        $result = $remainingText + $replaceWith;
      }
      elseif ($isCut) {
        $result = $remainingText;
      }
    } # $result
  }  # $failedReason

  # Perform Drop
  #
  if ([string]::IsNullOrEmpty($failedReason)) {
    if ($isPattern) {
      [string]$dropText = $Drop;
      if ($isCopy -and ($copyCaptures.PSBase.Count -gt 0)) {
        $dropText = $dropText.Replace('${_c}', $copyCaptures['0']);

        # Now cross reference the Copy group references
        #
        $dropText = Update-GroupRefs -Source $dropText -Captures $copyCaptures;
      }

      if (-not([string]::IsNullOrEmpty($capturedAnchor))) {
        $dropText = $dropText.Replace('${_a}', $capturedAnchor);
      }

      # Now cross reference the Pattern group references
      #
      if ($patternCaptures.Count -gt 0) {
        $dropText = Update-GroupRefs -Source $dropText -Captures $patternCaptures;
      }

      $result = $result.Replace([string]$Marker, $dropText);
    }
  } # $failedReason

  [boolean]$success = [string]::IsNullOrEmpty($failedReason);
  [PSCustomObject]$moveResult = [PSCustomObject]@{
    Payload         = $success ? $result : $Value;
    Success         = $success;
    CapturedPattern = $isPattern ? $capturedPattern : $($isCut ? $capturedCut : [string]::Empty);
  }

  if (-not([string]::IsNullOrEmpty($failedReason))) {
    $moveResult | Add-Member -MemberType NoteProperty -Name 'FailedReason' -Value $failedReason;
  }

  if ($Diagnose.ToBool() -and ($diagnostics.Named.Count -gt 0)) {
    $moveResult | Add-Member -MemberType NoteProperty -Name 'Diagnostics' -Value $diagnostics;
  }

  if ($notes.PSBase.Count -gt 0) {
    $moveResult | Add-Member -MemberType NoteProperty -Name 'Notes' -Value $notes;
  }

  return $moveResult;
}

function Move-MatchLegacy {
  <#
  .NAME
    Move-Match

  .SYNOPSIS
    The core move match action function principally used by Rename-Many. Moves a
  match according to the specified anchor(s).

  .DESCRIPTION
    Returns a new string that reflects moving the specified $Pattern match to either
  the location designated by $Anchor/$AnchorOccurrence/$Relation or to the Start or
  End of the value indicated by the presence of the $Start/$End switch parameters.
    First Move-Match, removes the Pattern match from the source. This makes the With and
  Anchor match against the remainder ($patternRemoved) of the source. This way, there is
  no overlap between the Pattern match and With/Anchor and it also makes the functionality more
  understandable for the user. NB: $Pattern only tells you what to remove, but it's the
  $With, $Copy and $Paste that defines what to insert, with the $Anchor/$Start/$End
  defining where the replacement text should go. The user should not be using named capture
  groups in $Copy, or $Anchor, rather, they should be defined inside $Paste and referenced
  inside $Paste/$With.

  .PARAMETER Anchor
    Anchor is a regular expression string applied to $Value (after the $Pattern match has
  been removed). The $Pattern match that is removed is inserted at the position indicated
  by the anchor match in collaboration with the $Relation parameter.

  .PARAMETER AnchorOccurrence
    Can be a number or the letters f, l
  * f: first occurrence
  * l: last occurrence
  * <number>: the nth occurrence

  .PARAMETER Copy
    Regular expression object applied to $Value (after the $Pattern match has been removed),
  indicating a portion which should be copied and re-inserted (via the $Paste parameter;
  see $Paste or $With). Since this is a regular expression to be used in $Paste/$With, there
  is no value in the user specifying a static pattern, because that static string can just be
  defined in $Paste/$With. The value in the $Copy parameter comes when a generic pattern is
  defined eg \d{3} (is non static), specifies any 3 digits as opposed to say '123', which
  could be used directly in the $Paste/$With parameter without the need for $Copy. The match
  defined by $Copy is stored in special variable ${_c} and can be referenced as such from
  $Paste and $With.

  .PARAMETER CopyOccurrence
    Can be a number or the letters f, l
  * f: first occurrence
  * l: last occurrence
  * <number>: the nth occurrence

  .PARAMETER Cut
    Regular expression object that indicates which part of the $Value that
  either needs removed as part of overall rename operation. Those characters
  in $Value which match $Cut, are removed.

  .PARAMETER CutOccurrence
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

  .PARAMETER Drop
    A string parameter (only applicable to move operations, ie any of these Anchor/Star/End
  are present) that defines what text is used to replace the $Pattern match. So in this
  use-case, the user wants to move a particular token/pattern to another part of the name
  and at the same time drop a static string in the place where the $Pattern was removed from.
  The user can also reference named group captures defined inside Pattern or Copy. (Note that
  the whole Copy capture can be referenced with ${_c}.)

  .PARAMETER End
    Is another type of anchor used instead of $Anchor and specifies that the $Pattern match
  should be moved to the end of the new name.

  .PARAMETER Marker
    A character used to mark the place where the $Pattern was removed from. It should be a
  special character that is not easily typed on the keyboard by the user so as to not
  interfere wth $Anchor/$Copy matches which occur after $Pattern match is removed.

  .PARAMETER Paste
    This is a NON regular expression string. It would be more accurately described as a formatter,
  similar to the $With parameter. When $Paste is defined, the $Anchor (if specified) is removed
  from $Value and needs to be be re-inserted using the special variable ${_a}. The
  other special variables that can be used inside a $Paste string is documented under the $With
  parameter.
    The $Paste string can specify a format that defines the replacement and since it removes the
  $Anchor, the $Relation is not applicable ($Relation and $Paste can't be used together).

  .PARAMETER Pattern
    Regular expression object that indicates which part of the $Value that
  either needs to be moved or replaced as part of overall rename operation. Those characters
  in $Value which match $Pattern, are removed.

  .PARAMETER PatternOccurrence
    Can be a number or the letters f, l
  * f: first occurrence
  * l: last occurrence
  * <number>: the nth occurrence

  .PARAMETER Relation
    Used in conjunction with the $Anchor parameter and can be set to either 'before' or
  'after' (the default). Defines the relationship of the $Pattern match with the $Anchor
  match in the new name for $Value.

  .PARAMETER Start
    Is another type of anchor used instead of $Anchor and specifies that the $Pattern match
  should be moved to the start of the new name.

  .PARAMETER Value
    The source value against which regular expressions are applied.

  .PARAMETER With
    This is a NON regular expression string. It would be more accurately described as a formatter,
  similar to the $Paste parameter. Defines what text is used as the replacement for the $Pattern
  match. Works in concert with $Relation (whereas $Paste does not). $With can reference special
  variables:
  * $0: the pattern match
  * ${_a}: the anchor match
  * ${_c}: the copy match
  When $Pattern contains named capture groups, these variables can also be referenced. Eg if the
  $Pattern is defined as '(?<day>\d{1,2})-(?<mon>\d{1,2})-(?<year>\d{4})', then the variables
  ${day}, ${mon} and ${year} also become available for use in $With or $Paste.
  Typically, $With is static text which is used to replace the $Pattern match and is inserted
  according to the Anchor match, (or indeed $Start or $End) and $Relation. When using $With,
  whatever is defined in the $Anchor match is not removed from $Value (this is different to how
  $Paste works).

  #>
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSPossibleIncorrectUsageOfAssignmentOperator', '')]
  [Alias('moma')]
  [OutputType([string])]
  param (
    [Parameter(Mandatory)]
    [string]$Value,

    [Parameter()]
    [System.Text.RegularExpressions.RegEx]$Pattern,

    [Parameter()]
    [ValidateScript( { ($_ -ne '*') -and ($_ -ne '0') })]
    [string]$PatternOccurrence = 'f',

    [Parameter()]
    [System.Text.RegularExpressions.RegEx]$Cut,

    [Parameter()]
    [ValidateScript( { ($_ -ne '*') -and ($_ -ne '0') })]
    [string]$CutOccurrence = 'f',

    [Parameter()]
    [System.Text.RegularExpressions.RegEx]$Anchor,

    [Parameter()]
    [ValidateScript( { ($_ -ne '*') -and ($_ -ne '0') })]
    [string]$AnchorOccurrence = 'f',

    [Parameter()]
    [ValidateSet('before', 'after')]
    [string]$Relation = 'after',

    [Parameter()]
    [System.Text.RegularExpressions.RegEx]$Copy,

    [Parameter()]
    [ValidateScript( { ($_ -ne '*') -and ($_ -ne '0') })]
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

  [string]$result = [string]::Empty;
  [string]$failedReason = [string]::Empty;
  [hashtable]$notes = [hashtable]@{}
  [PSCustomObject]$groups = [PSCustomObject]@{
    Named = @{}
  }

  # Formatted has to be redefined as With instead of Paste. Paste should probably be removed
  #
  [boolean]$isFormatted = $PSBoundParameters.ContainsKey('Paste') -and -not([string]::IsNullOrEmpty($Paste));
  [boolean]$dropped = $PSBoundParameters.ContainsKey('Drop') -and -not([string]::IsNullOrEmpty($Drop));
  [boolean]$isPattern = $PSBoundParameters.ContainsKey('Pattern') -and -not([string]::IsNullOrEmpty($Pattern));
  [boolean]$isCut = $PSBoundParameters.ContainsKey('Cut') -and -not([string]::IsNullOrEmpty($Cut));

  [hashtable]$parameters = @{
    'Source' = $Value;
  }

  if ($isPattern) {
    $parameters['PatternRegEx'] = $Pattern;
    $parameters['Occurrence'] = $($PSBoundParameters.ContainsKey('PatternOccurrence') ? $PatternOccurrence : 'f');

    if ($dropped) {
      $parameters['Marker'] = $Marker;
    }

    [string]$capturedAnchor = [string]::Empty;
    [Hashtable]$patternCaptures = @{}
    [Hashtable]$copyCaptures = @{}

    [string]$capturedPattern, [string]$patternRemoved, `
      [System.Text.RegularExpressions.Match]$patternMatch = Split-Match @parameters;

    if (-not([string]::IsNullOrEmpty($capturedPattern))) {
      # What does vanilla really mean? Vanilla concept is defunct and no longer used
      #
      [boolean]$isVanilla = -not($PSBoundParameters.ContainsKey('Copy') -or `
        ($PSBoundParameters.ContainsKey('With') -and -not([string]::IsNullOrEmpty($With))));

      $patternCaptures = get-Captures -MatchObject $patternMatch;
      if ($Diagnose.ToBool()) {
        $groups.Named['Pattern'] = $patternCaptures;
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
            [hashtable]$parameters = @{
              'Source'       = $patternRemoved
              'PatternRegEx' = $Copy
              'Occurrence'   = $($PSBoundParameters.ContainsKey('CopyOccurrence') ? $CopyOccurrence : 'f')
            }

            if ($dropped) {
              $parameters['Marker'] = $Marker;
            }

            # With this implementation, it is up to the user to supply a regex proof
            # pattern, so if the Copy contains regex chars which must be treated literally, they
            # must pass in the string pre-escaped: -Copy $(esc('some-pattern') + 'other stuff').
            #
            [string]$replaceWith, $null, `
              [System.Text.RegularExpressions.Match]$copyMatch = Split-Match @parameters;

            [hashtable]$copyCaptures = get-Captures -MatchObject $copyMatch;
            if ($Diagnose.ToBool()) {
              $groups.Named['Copy'] = $copyCaptures;
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

      # I think this is now redundant, because Paste doesn't exist and has been taken over
      # by With which has been accounted for.
      #
      if (-not($PSBoundParameters.ContainsKey('Anchor')) -and ($isFormatted)) {
        $replaceWith = $Paste.Replace('${_c}', $replaceWith).Replace('$0', $capturedPattern);

        # Now apply the user defined Pattern named group references if they exist
        # to the captured pattern
        #
        $replaceWith = $capturedPattern -replace $pattern, $replaceWith;
      }

      if ($PSBoundParameters.ContainsKey('Anchor')) {
        [hashtable]$parameters = @{
          'Source'       = $patternRemoved
          'PatternRegEx' = $Anchor
          'Occurrence'   = $($PSBoundParameters.ContainsKey('AnchorOccurrence') ? $AnchorOccurrence : 'f')
        }

        if ($dropped) {
          $parameters['Marker'] = $Marker;
        }

        # As with the Copy parameter, if the user wants to specify an anchor by a pattern
        # which contains regex chars, then can use -Anchor $(esc('anchor-pattern')). If
        # there are no regex chars, then they can use -Anchor 'pattern'. However, if the
        # user needs to do partial escapes, then they will have to do the escaping
        # themselves: -Anchor $(esc('partial-pattern') + 'remaining-pattern').
        #
        [string]$capturedAnchor, $null, `
          [System.Text.RegularExpressions.Match]$anchorMatch = Split-Match @parameters;

        if (-not([string]::IsNullOrEmpty($capturedAnchor))) {
          # Relation and Paste are not compatible, because if the user is defining the
          # replacement format, it is up to them to define the relationship of the anchor
          # with the replacement text. So exotic/vanilla-formatted can't use Relation.
          #

          # How do we handle group references in Pattern? These are done transparently
          # because any group defined in Pattern can be referenced by Paste as long as
          # there is a replace operation of the form regEx.Replace($Pattern, Paste). Of course
          # we can't do the replace in this simplistic way, because that form would replace
          # all matches, when we only want to replace the specified Pattern occurrence.
          #
          if ($isFormatted) {
            # Paste can be something like '___ ${_a}, (${a}, ${b}, [$0], ${_c} ___', where $0
            # represents the pattern capture, the special variable _c represents $Copy,
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
          if ($Start.ToBool()) {
            $result = $replaceWith + $patternRemoved;
            $notes['hybrid'] = 'Start (Anchor failed)';
          }
          elseif ($End.ToBool()) {
            $result = $patternRemoved + $replaceWith;
            $notes['hybrid'] = 'End  (Anchor failed)';
          }
          else {
            # Anchor doesn't match Pattern
            #
            $failedReason = 'Anchor Match';
          }
        }
      }
      elseif ($Start.ToBool()) {
        $result = $replaceWith + $patternRemoved;
      }
      elseif ($End.ToBool()) {
        $result = $patternRemoved + $replaceWith;
      }
      else {
        # This is an error, because there is no place to move the pattern to, as there is no Anchor,
        # Start or End specified. Actually, we're in the twilight zone here as this scenario can't
        # happen and has been engineered out of existence!
        #
        $failedReason = 'Twilight Zone: Missing Anchor';
      }
    }
    else {
      # Source doesn't match Pattern
      #
      $failedReason = 'Pattern Match';
    }

    if ($([string]::IsNullOrEmpty($failedReason))) {
      if ($dropped -and $result.Contains([string]$Marker)) {
        [string]$dropText = $Drop;

        # Now cross reference the Copy group references
        #
        if ($isCopy -and ($copyCaptures.Count -gt 0)) {
          $dropText = $dropText.Replace('${_c}', $copyCaptures['0']);
          $dropText = Update-GroupRefs -Source $dropText -Captures $copyCaptures;
        }

        if (-not([string]::IsNullOrEmpty($capturedAnchor))) {
          $dropText = $dropText.Replace('${_a}', $capturedAnchor);
        }

        # Now cross reference the Pattern group references
        #
        if ($isPattern -and ($patternCaptures.PSBase.Count -gt 0)) {
          $dropText = Update-GroupRefs -Source $dropText -Captures $patternCaptures;
        }

        $result = $result.Replace([string]$Marker, $dropText);
      }
    }
    else {
      $result = $Value;
    }
  }
  elseif ($isCut) {
    $parameters['PatternRegEx'] = $Cut;
    $parameters['Occurrence'] = $($PSBoundParameters.ContainsKey('CutOccurrence') ? $CutOccurrence : 'f');

    [string]$capturedPattern, [string]$cutRemoved, `
      [System.Text.RegularExpressions.Match]$cutMatch = Split-Match @parameters;

    if (-not([string]::IsNullOrEmpty($capturedPattern))) {
      [Hashtable]$cutCaptures = get-Captures -MatchObject $cutMatch;
      if ($Diagnose.ToBool()) {
        $groups.Named['Cut'] = $cutCaptures;
      }

      $result = $cutRemoved;
    }
    else {
      # Source doesn't match Cut
      #
      $failedReason = 'Cut Match';
    }
  }
  else {
    throw [System.Management.Automation.MethodInvocationException]::new(
      "Move-Match invalid invocation, Pattern and Cut are both missing");
  }

  [PSCustomObject]$moveResult = [PSCustomObject]@{
    Payload         = $result;
    Success         = $success;
    CapturedPattern = $capturedPattern;
  }

  if (-not([string]::IsNullOrEmpty($failedReason))) {
    $moveResult | Add-Member -MemberType NoteProperty -Name 'FailedReason' -Value $failedReason;
  }

  if ($Diagnose.ToBool() -and ($groups.Named.Count -gt 0)) {
    $moveResult | Add-Member -MemberType NoteProperty -Name 'Diagnostics' -Value $groups;
  }

  return $moveResult;
} # Move-Match
