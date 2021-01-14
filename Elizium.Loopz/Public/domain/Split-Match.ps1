
function Split-Match {
  <#
  .NAME
    Split-Match

  .SYNOPSIS
    Splits out a match from the remainder of the $Source text returning the matched
  test, the remainder and the corresponding match object.

  .DESCRIPTION
    Helper function to get the pattern match and the remaining text. This helper
  helps us to avoid unnecessary duplicated reg ex matches. It returns
  up to 3 items inside an array, the first is the matched text, the second is
  the source with the matched text removed and the third is the match object
  that represents the matched text.

  .PARAMETER CapturedOnly
    switch parameter to indicate what should be returned. When the client does not need
  the match object or the remainder, they can use this switch to ensure only the matched
  text is returned.
  
  .PARAMETER Marker
    A character used to mark the place where the $PatternRegEx's match was removed from.
  It should be a special character that is not easily typed on the keyboard by the user
  so as to not interfere wth $Anchor/$Copy matches which occur after $Pattern match is
  removed.

  .PARAMETER Occurrence
    Denotes which match should be used.

  .PARAMETER PatternRegEx
    The regex object to apply to the $Source.

  .PARAMETER Source
    The source value against which regular expression is applied.


  #>
  param(
    [Parameter(Mandatory)]
    [string]$Source,

    [Parameter()]
    [System.Text.RegularExpressions.RegEx]$PatternRegEx,

    [Parameter()]
    [string]$Occurrence = 'f',

    [Parameter()]
    [switch]$CapturedOnly,

    [Parameter()]
    [char]$Marker = 0x20DE
  )

  [System.Text.RegularExpressions.MatchCollection]$mc = $PatternRegEx.Matches($Source);

  if ($mc.Count -gt 0) {
    # Get the match instance
    #
    [System.Text.RegularExpressions.Match]$m = if ($Occurrence -eq 'f') {
      $mc[0];
    }
    elseif ($Occurrence -eq 'l') {
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
      # Splatting the arguments fails because the parameter validation in Get-InverseSubString
      # fails, due to parameters not having been bound yet.
      # https://github.com/PowerShell/PowerShell/issues/14457
      #
      [string]$remainder = $PSBoundParameters.ContainsKey('Marker') `
        ? $(Get-InverseSubString -Source $Source -StartIndex $m.Index -Length $m.Length -Marker $Marker) `
        : $(Get-InverseSubString -Source $Source -StartIndex $m.Index -Length $m.Length);

      @($capturedText, $remainder, $m);
    }
  }

  return $result;
} # Split-Match
