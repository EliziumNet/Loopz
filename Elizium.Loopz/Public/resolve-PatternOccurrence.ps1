
function Resolve-PatternOccurrence {
  param (
    [Parameter(Position = 0)]
    [array]$Value
  )

  $Value[0], $(($Value.Length -eq 1) ? 'f' : $Value[1]);
} # resolve-PatternOccurrence
