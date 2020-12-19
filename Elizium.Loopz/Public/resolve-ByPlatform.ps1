
function Resolve-ByPlatform {
  param(
    [Parameter()]
    [hashtable]$Hash
  )

  $result = $null;
  [string]$platform = Get-PlatformName;

  if ($Hash.ContainsKey($platform)) {
    $result = $Hash[$platform];
  }
  elseif ($Hash.ContainsKey('default')) {
    $result = $Hash['default'];
  }

  return $result;
}
