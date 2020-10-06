
function edit-ReplaceLastMatch {
  [Alias('Replace-LastMatch')]
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
    [switch]$Whole
  )
  [string]$adjustedPattern = $Whole `
    ? ($adjustedPattern = '\b{0}\b' -f $Pattern.Replace('\b', '')) : $Pattern;

  [string]$expression = "(?<_f1>.*){0}(?<_f2>.*)" -f $adjustedPattern;
  [string]$replacement = '${_f1}' + $With + '${_f2}';
  return $Source -replace $expression, $replacement;
}
