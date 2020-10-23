
function invoke-MoveMatchAction {
  # This action function doesn't appear to be as useful as originally intended. It
  # was originally designed to help remove the parameter building code in the source
  # but in actuality, this is not happening and just adds a further unnecessary layer
  # and imposes more tests. Consider removing or absorbing MoveMatch directly into
  # this function.
  #
  [OutputType([string])]
  param(
    [Parameter()]
    [string]$Value,

    [Parameter()]
    [System.Text.RegularExpressions.RegEx]$Pattern,

    [Parameter()]
    [string]$PatternOccurrence,

    [Parameter()]
    [System.Text.RegularExpressions.RegEx]$Anchor,

    [Parameter()]
    [string]$AnchorOccurrence,

    [Parameter()]
    [System.Text.RegularExpressions.RegEx]$With,

    [Parameter()]
    [string]$WithOccurrence,

    [Parameter()]
    [string]$AnchorType,

    [Parameter()]
    [string]$Relation,

    [Parameter()]
    [string]$LiteralWith,

    [Parameter()]
    [string]$Paste
  )
  [string]$result = [string]::Empty;

  # This is simply pointless!!!!
  #
  [System.Collections.Hashtable]$moveMatchParameters = @{
    'Source'  = $Value;
    'Pattern' = $Pattern;
  }

  if ($PSBoundParameters.ContainsKey('PatternOccurrence')) {
    $moveMatchParameters['PatternOccurrence'] = $PatternOccurrence;
  }

  if ($PSBoundParameters.ContainsKey('WithOccurrence')) {
    $moveMatchParameters['WithOccurrence'] = $WithOccurrence;
  }

  if ($PSBoundParameters.ContainsKey('AnchorOccurrence')) {
    $moveMatchParameters['AnchorOccurrence'] = $AnchorOccurrence;
  }

  switch ($AnchorType) {
    'MATCHED-ITEM' {
      $moveMatchParameters['Anchor'] = $Anchor;
      if ($PSBoundParameters.ContainsKey('Relation')) {
        $moveMatchParameters['Relation'] = $Relation;
      }
      break;
    }
    'START' {
      $moveMatchParameters['Start'] = $true;
      break;
    }
    'END' {
      $moveMatchParameters['End'] = $true;
      break;
    }
    default {
      throw "invoke-MoveMatchAction: encountered Invalid AnchorType: '$AnchorType'";
    }
  }

  if ($PSBoundParameters.ContainsKey('With')) {
    $moveMatchParameters['With'] = $With;
  }
  elseif ($PSBoundParameters.ContainsKey('LiteralWith')) {
    $moveMatchParameters['LiteralWith'] = $LiteralWith;
  }

  if ($PSBoundParameters.ContainsKey('Paste')) {
    $moveMatchParameters['Paste'] = $Paste;
  }

  $result = (Move-Match @moveMatchParameters).Trim();

  $result;
} # invoke-MoveMatchAction
