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
    [string]$Quantity = 1,

    [Parameter()]
    [switch]$Whole
  )

  [string]$adjustedPattern = $Whole `
    ? ($adjustedPattern = '\b{0}\b' -f $Pattern.Replace('\b', '')) : $Pattern;

  [System.Text.RegularExpressions.RegEx]$patternRegEx = `
    New-Object -TypeName System.Text.RegularExpressions.RegEx -ArgumentList $adjustedPattern;
  return $patternRegEx.Replace($Source, $With, $Quantity);
}
