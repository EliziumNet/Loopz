
function Get-TableDisplayOptions {
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory)]
    [string[]]$Select,

    [Parameter()]
    [hashtable]$Signals,

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

    Align    = @{
      Header = 'right';
      Cell   = 'left';
    }

    Snippets = [PSCustomObject]@{
      Reset = $(snippets('Reset'));
    }

    Custom = $Custom;
  }

  return $tableOptions;
}
