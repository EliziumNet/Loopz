
function Get-TableDisplayOptions {
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

  [PSCustomObject]$tableOptions = [PSCustomObject]@{
    Select   = $Select;

    Chrome   = [PSCustomObject]@{
      Indent    = 3;
      Underline = '=';
      Inter     = 1;
    }

    Colours  = [PSCustomObject]@{
      Header    = 'blue';
      Cell      = 'white';
      Underline = 'yellow';
      HiLight   = 'green';
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
      Reset   = $($Scribbler.snippets('Reset'));
      Ln      = $($Scribbler.snippets('Ln'));
    }

    Custom   = $Custom;
  }

  return $tableOptions;
}
