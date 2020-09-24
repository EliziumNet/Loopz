
function edit-ReplaceLastMatch {
  [Alias('Replace-LastMatch')]
  [OutputType([string])]
  param(
    [Parameter(Mandatory)]
    [string]$Source,

    [Parameter(Mandatory)]
    [string]$Pattern,

    [Parameter(Mandatory)]
    [string]$With
  )

    [string]$expression = "(.*){0}(.*)" -f $Pattern;
    [string]$replacement = '$1{0}$2' -f $With;
    return $Source -replace $expression, $replacement;

  # if ($literalPattern) {
  #   # The user says the pattern ($replacePattern) is not a regular expression, so take it as it is
  #   #
  #   [string]$expression = "(.*){0}(.*)" -f $replacePattern;
  #   [string]$replacement = '$1{0}$2' -f $replaceWith;
  #   $newItemName = ($_underscore.Name -replace $expression, $replacement).Trim();
  # }
  # else {
  #   # The pattern is a regular expression. However, it is quite dangerous to use Last in
  #   # this scenario, so to be on the safe side, we'll ignore and register an error.
  #   #
  #   $errorOccurred = $true;
  # }
}
