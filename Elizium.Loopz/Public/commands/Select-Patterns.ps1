
function Select-Patterns {
  <#
  .NAME
    Select-Patterns

  .SYNOPSIS
    This is a simplified yet enhanced version of standard Select-String command (or
  the grep command on Linux/Unix/mac) that allows the user to run multiple searches
  which are chained together to produce its final result.

  .DESCRIPTION
    The main rationale for using this command ("greps" as in multiple grep invokes) instead
  of Select-String, is for the provision of multiple patterns. Now, Select-String does
  allow the user to provide multiple Patterns, but the result is a logical OR rather
  than an AND. greps uses AND by piping the result of each individual Pattern search to
  the next Pattern search so the result is those lines found that match all the patterns
  provided rather than all lines that match 1 or more of the patterns. The user can achieve
  OR functionality by using a | inside the same string; for example to find all lines
  that contain any of the patterns 'red', 'green' or 'blue', they could just use
  'red|green|blue'.
    At the end of the run, greps displays the full command (containing multiple pipeline
  legs, one for each pattern provided). If so required, the user can re-run the command
  by running the full command which is displayed and providing different parameters not
  directly supported by greps.
    'greps', does not currently support input from the pipeline. Perhaps this will be
  implemented in a future release.
    At some point in the future, it is intended to further enhance greps using a coloured
  output, whereby a colour is assigned to each pattern and that colour is used to render the
  result. So where the user has provided multiple patterns, currently, only the first pattern
  is highlighted in the result. With the coloured enhancement, the user will be able to see
  all pattern matches in the result with each match displayed in the corresponding allocated
  colour.

  .PARAMETER filter
    Defines which files are considered in the search. It can be a path with a wildcard or
  simply a wildcard. If its just a wildcard (eg *.txt), then files considered will be from
  the current directory only.
    The user can define a default filter in the environment as variable 'LOOPZ_GREPS_FILTER'
  which should be a glob such as '*.txt' to represent all text files. If no filter parameter
  is supplied to the greps invoke, then the filter is defined by the value of
  'LOOPZ_GREPS_FILTER'.

  .PARAMETER Patterns
    An array of patterns. The result shows all lines that match all the patterns specified.
  An individual pattern can be prefixed with a not op: '!', which means exclude those lines
  which match the subsequent pattern; it is a more succinct way of specifying the -NotMatch
  operator on Select-String. The '!' is not part of the pattern.

  .EXAMPLE 1
    Show lines in all .txt files in the current directory files that contain the patterns
  'red' and 'blue':
  greps red, blue *.txt

  .EXAMPLE 2
    Show lines in all .txt files in home directory that contain the patterns 'green lorry' and
  'yellow lorry':
  greps 'green lorry', 'yellow lorry' ~/*.txt

  .EXAMPLE 3
    Show lines in all files defined in environment as 'LOOPZ_GREPS_FILTER' that contains
  'foo' but not 'bar':
  greps foo, !bar
  
  #>
  [CmdletBinding()]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression', '')]
  [Alias("greps")]
  param
  (
    [parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [String[]]$Patterns,

    [parameter(Position = 1)]
    [String]$Filter = $(Get-EnvironmentVariable -Variable 'LOOPZ_GREPS_FILTER' -Default './*.*')
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

  foreach ($pat in $Patterns) {
    $count++;

    if ($count -eq 1) {
      $command = build-command -Pattern $Patterns[0] -Filter $Filter;
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
