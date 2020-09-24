function edit-ReplaceFirstMatch {
  [Alias('Replace-FirstMatch')]
  [OutputType([string])]
  param(
    [Parameter(Mandatory)]
    [string]$Source,

    [Parameter(Mandatory)]
    [string]$Pattern,

    [Parameter(Mandatory)]
    [string]$With,

    [Parameter()]
    [string]$Quantity = 1
  )

  [System.Text.RegularExpressions.RegEx]$patternRegEx = `
    New-Object -TypeName System.Text.RegularExpressions.RegEx -ArgumentList $Pattern;
  return $patternRegEx.Replace($Source, $With, $Quantity);
}
