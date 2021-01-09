
function Select-Text {
  [CmdletBinding()]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression', '')]
  [Alias("greps")]
  param
  (
    [parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [String[]] $patterns,
  
    [parameter(Position = 1)]
    [ValidateNotNullOrEmpty()]
    [String]$filter = $(Get-EnvironmentVariable 'LOOPZ_GREPS_FILTER')
  )

  function build-command {
    [OutputType([string])]
    param(
      [String]$Pattern,
      [String]$Filter,
      [Switch]$Pipe,
      [string]$NotOpSymbol = '!'
    )
    [string]$platform = Get-PlatformName;
    [string]$builder = [string]::Empty;

    if ($Pipe.ToBool()) {
      $builder += ' | ';
    }

    if ($platform -eq 'windows') {
      $builder += 'select-string ';
      if ($pattern.StartsWith($NotOpSymbol)) {
        $builder += ('-notmatch -pattern "{0}" ' -f $Pattern.Substring(1));
      }
      else {
        $builder += ('-pattern "{0}" ' -f $Pattern);
      }
    }
    else {
      $builder += 'grep ';
      if ($pattern.StartsWith($NotOpSymbol)) {
        $builder += ('-v -i "{0}" ' -f $Pattern.Substring(1));
      }
      else {
        $builder += ('-i "{0}" ' -f $Pattern);
      }
    }

    if (-not([string]::IsNullOrWhiteSpace($Filter))) {
      $builder += "$Filter ";
    }

    return $builder;
  } # build-command

  [string]$command = [string]::Empty;
  [int]$count = 0;

  foreach ($pat in $patterns) {
    $count++;

    if ($count -eq 1) {
      $command = build-command -Pattern $patterns[0] -Filter $filter;
    }
    else {
      $segment = build-command -Pipe -Pattern $pat;
      $command += $segment;
    }
  }

  [hashtable]$signals = $(Get-Signals);
  [hashtable]$theme = $(Get-KrayolaTheme);
  [Krayon]$krayon = New-Krayon -Theme $theme;
  [couplet]$formattedSignal = Get-FormattedSignal -Name 'GREPS' -Value $command -Signals $signals;
  Invoke-Expression $command;

  $null = $krayon.blue().Text($formattedSignal.Key). `
    red().Text(' --> '). `
    green().Text($formattedSignal.Value);
}
