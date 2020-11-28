
function resolve-ByPlatform {
  param(
    [System.Collections.Hashtable]$Hash,
    $Default
  )

  $result = $null;
  [string]$platform = get-PlatformName;

  if ($Hash.ContainsKey($platform)) {
    $result = $Hash[$platform];
  } elseif ($PSBoundParameters.ContainsKey('Default')) {
    $result = $Default;
  }

  return $result;
}
