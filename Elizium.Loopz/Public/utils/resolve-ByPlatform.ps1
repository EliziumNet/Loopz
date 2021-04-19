
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

  .LINK
    https://eliziumnet.github.io/Loopz/

  .PARAMETER Hash
    A hashtable object whose keys are values that can be returned by Get-PlatformName. The
  values can be anything.

  .EXAMPLE 1

  [hashtable]$platforms = @{
    'windows' = 'windows-info';
    'linux'   = 'linux-info';
    'mac'     = 'mac-info';
  }
  Resolve-ByPlatform -Hash $platforms

  .EXAMPLE 2 (With default)

  [hashtable]$platforms = @{
    'windows' = 'windows-info';
    'default' = 'default-info';
  }
  Resolve-ByPlatform -Hash $platforms

  #>
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
