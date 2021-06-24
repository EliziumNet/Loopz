function get-Captures {
  [OutputType([hashtable])]
  param(
    [Parameter(Mandatory)]
    [System.Text.RegularExpressions.Match]$MatchObject
  )

  [hashtable]$captures = @{}
  [System.Text.RegularExpressions.GroupCollection]$groups = $MatchObject.Groups;

  foreach ($key in $groups.Keys) {
    $captures[$key] = $groups[$key];
  }

  return $captures;
}
