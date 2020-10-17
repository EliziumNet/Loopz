function edit-ReplaceFirstMatch {
  [Alias('Replace-FirstMatch')]
  [OutputType([string])]
  param(
    [Parameter(Mandatory)]
    [string]$Source,

    [Parameter(Mandatory)]
    [string]$Pattern,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [string]$With,

    [Parameter()]
    [int]$Quantity = 1,

    [Parameter()]
    [switch]$Whole
  )

  [string]$adjustedPattern = $Whole `
    ? ($adjustedPattern = '\b{0}\b' -f $Pattern.Replace('\b', '')) : $Pattern;

  [System.Text.RegularExpressions.RegEx]$patternRegEx = `
    New-Object -TypeName System.Text.RegularExpressions.RegEx -ArgumentList $adjustedPattern;

  [string]$result = if ($PSBoundParameters.ContainsKey('Quantity') -and ($Quantity -gt 0)) {
    $patternRegEx.Replace($Source, $With, $Quantity)
  } else {
    $patternRegEx.Replace($Source, $With)
  }
  return $result;
}
