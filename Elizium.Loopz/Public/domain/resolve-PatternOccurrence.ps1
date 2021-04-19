
function Resolve-PatternOccurrence {
  <#
  .NAME
    Resolve-PatternOccurrence

  .SYNOPSIS
    Helper function to assist in processing regular expression parameters that can
  be adorned with an occurrence value.

  .DESCRIPTION
    Since the occurrence part is optional and defaults to mean first occurrence only,
  this function will fill in the default 'f' when occurrence is not specified.

  .LINK
    https://eliziumnet.github.io/Loopz/

  .PARAMETER Value
    The value of a regex parameter, which is an array whose first element is the
  pattern and the second if present is the match occurrence.

  #>
  param (
    [Parameter(Position = 0)]
    [array]$Value
  )

  $Value[0], $(($Value.Length -eq 1) ? 'f' : $Value[1]);
} # resolve-PatternOccurrence
