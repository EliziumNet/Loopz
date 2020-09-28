
function edit-MoveToken {
  [Alias('Move-Token', 'moto')]
  [OutputType([string])]
  param (
    [Parameter(Mandatory)]
    [string]$Source,

    [Parameter(Mandatory)]
    [string]$Pattern,

    [Parameter(Mandatory)]
    [string]$Target,

    [ValidateSet('before', 'after')]
    [string]$Relation = 'after',

    [Parameter()]
    [switch]$Whole
  )

  [string]$result = $Source;
  [string]$adjustedPattern = $Whole `
    ? ($adjustedPattern = '\b{0}\b' -f $Pattern.Replace('\b', '')) : $Pattern;

  # Source = '31-12-1999 new years eve is: ';
  # Pattern = '\d{2}-\d{2}-\d{4}'
  # Target = 'is: '
  # Relation = 'after'

  if ($Source -match $Pattern) {
    # isn't it better to use a back ref via \k?
    [string]$sourceMatched = $matches[0]; # => 31-12-1999
    # [string]$captureExpression = '(?<src>{0})' -f $sourceMatched;

    [string]$patternRemoved = $Source -replace $sourceMatched, ''; # => ' new years eve is: '

    if ($patternRemoved -match $Target) {
      [string]$targetMatched = $matches[0]; # 'is: '
      [string]$captureExpression = ('(?<target>{0})' -f $targetMatched).Replace(' ', '\s'); # => '(?<target>is:\s)'

      [string]$withPattern = ($Relation -eq 'after') `
        ? $targetMatched + $sourceMatched `
        : $sourceMatched + $targetMatched;

      $result = $patternRemoved -replace $captureExpression, $withPattern;
    }
  }

  $result;
}
