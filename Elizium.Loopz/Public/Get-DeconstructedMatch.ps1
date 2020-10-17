
# Helper function to get the pattern match and the remaining text. This helper
# helps us to avoid unnecessary duplicated reg ex matches. It returns
# up to 3 items inside an array, the first is the matched text, the second is
# the source with the matched text removed and the third is the match object
# that represents the matched text.
#
function Get-DeconstructedMatch {
  param(
    [Parameter(Mandatory)]
    [string]$Source,

    [Parameter()]
    [string]$Pattern,

    [Parameter()]
    [string]$Occurrence = 'F',

    [Parameter()]
    [switch]$Whole,

    [Parameter()]
    [switch]$CapturedOnly
  )

  [string]$adjustedPattern = $Whole `
    ? ($adjustedPattern = '\b{0}\b' -f $Pattern.Replace('\b', '')) : $Pattern;

  [System.Text.RegularExpressions.RegEx]$patternRegEx = `
    New-Object -TypeName System.Text.RegularExpressions.RegEx -ArgumentList $adjustedPattern;

  [System.Text.RegularExpressions.MatchCollection]$mc = $patternRegEx.Matches($Source);

  if ($mc.Count -gt 0) {
    [System.Text.RegularExpressions.Match]$m = if ($Occurrence -eq 'F') {
      $mc[0];
    }
    elseif ($Occurrence -eq 'L') {
      $mc[$mc.Count - 1];
    }
    else {
      try {
        [int]$nth = [int]::Parse($Occurrence);
      }
      catch {
        [int]$nth = 1;
      }

      ($nth -le $mc.Count) ? $mc[$nth - 1] : $null;
    }
  }
  else {
    [System.Text.RegularExpressions.Match]$m = $null;
  }

  $result = $null;
  if ($m) {
    [string]$capturedText = $m.Value;

    $result = if ($CapturedOnly.ToBool()) {
      $capturedText;
    }
    else {
      [string]$remainder = Get-InverseSubString -Source $Source -StartIndex $m.Index -Length $m.Length;
      @($capturedText, $remainder, $m);
    }
  }

  return $result;
} # get-DeconstructedMatch
