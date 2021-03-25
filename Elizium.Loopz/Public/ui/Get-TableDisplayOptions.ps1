
function Get-TableDisplayOptions {
  <#
  .NAME
    Get-TableDisplayOptions

  .SYNOPSIS
    Gets the default table display options.

  .DESCRIPTION
    The client can further customise by overwriting the members on the
  PSCustomObject returned.
  #>
  [OutputType([PSCustomObject])]
  param(
    [Parameter()]
    [hashtable]$Signals,

    [Parameter()]
    [Object]$Scribbler,

    [Parameter()]
    [string[]]$Select,

    [Parameter()]
    [PSCustomObject]$Custom = $null
  )

  [string]$trueValue = ($PSBoundParameters.ContainsKey('Signals') -and
    $Signals.ContainsKey('SWITCH-ON')) `
    ? $signals['SWITCH-ON'].Value : 'true';

  [string]$falseValue = ($PSBoundParameters.ContainsKey('Signals') -and
    $Signals.ContainsKey('SWITCH-OFF')) `
    ? $signals['SWITCH-OFF'].Value : 'false';

  [string]$titleMainColour = if (${Custom}?.Colours?.Title) {
    $Custom.Colours.Title;
  }
  else {
    'darkYellow';
  }

  [string]$titleLoColour = 'black';
  [string]$titleBackColour = 'bg' + $titleMainColour;

  [PSCustomObject]$tableOptions = [PSCustomObject]@{
    Select   = $Select;

    Chrome   = [PSCustomObject]@{
      Indent         = 3;
      Underline      = '=';
      TitleUnderline = '-<>-';
      Inter          = 1;
    }

    Colours  = [PSCustomObject]@{
      Header    = 'blue';
      Cell      = 'white';
      Underline = 'yellow';
      HiLight   = 'green';
      Title     = $titleMainColour;
      TitleLo   = $titleLoColour;
    }

    Values   = [PSCustomObject]@{
      True  = $trueValue;
      False = $falseValue;
    }

    Align    = [PSCustomObject]@{
      Header = 'right';
      Cell   = 'left';
    }

    Snippets = [PSCustomObject]@{
      Reset          = $($Scribbler.Snippets('Reset'));
      Ln             = $($Scribbler.Snippets('Ln'));
      Title          = $($Scribbler.Snippets(@($titleLoColour, $titleBackColour)));
      TitleUnderline = $($Scribbler.Snippets($titleMainColour));
    }

    Custom   = $Custom;
  }

  return $tableOptions;
}
