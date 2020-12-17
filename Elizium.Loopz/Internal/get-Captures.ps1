function get-Captures {
  [OutputType([System.Collections.Hashtable])]
  param(
    [Parameter(Mandatory)]
    [System.Text.RegularExpressions.Match]$MatchObject
  )

  [System.Collections.Hashtable]$captures = @{}
  [System.Text.RegularExpressions.GroupCollection]$groups = $MatchObject.Groups;

  foreach ($key in $groups.Keys) {
    $captures[$key] = $groups[$key];
  }
  
  return $captures;
}
