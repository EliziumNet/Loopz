
function Resolve-ByPlatform {
  param(
    [Parameter()]
    [System.Collections.Hashtable]$Hash,

    [Parameter()]
    $Default
  )

  $result = $null;
  [string]$platform = Get-PlatformName;

  if ($Hash.ContainsKey($platform)) {
    $result = $Hash[$platform];
  } elseif ($PSBoundParameters.ContainsKey('Default')) {
    $result = $Default;
  }

  return $result;
}
