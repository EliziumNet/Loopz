
function Resolve-ByPlatform {
  <#
  .NAME
    Resolve-ByPlatform

  .SYNOPSIS
    Given a hashtable, resolves to the value whose corresponding key matches
  the operating system name as returned by Get-PlatformName.

  .DESCRIPTION
    Provides a way to select data depending on the current OS as determined by 
  Get-PlatformName.

  .PARAMETER Hash
    A hashtable object whose keys are values that can be returned by Get-PlatformName. The
  values can be anything.

  #>
  param(
    [Parameter()]
    [hashtable]$Hash

    # TODO, add Default param
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
