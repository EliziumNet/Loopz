
function Get-PlatformName {
  <#
  .NAME
    Get-PlatformName

  .SYNOPSIS
    Get the name of the operating system.

  .DESCRIPTION
    There are multiple ways to get the OS type in PowerShell but they are convoluted
  and can return an unfriendly name such as 'Win32NT'. This command simply returns
  'windows', 'linux' or 'mac', simples! This function is typically used alongside
  Invoke-ByPlatform and Resolve-ByPlatform.

  #>
  $result = if ($IsWindows) {
    'windows';
  } elseif ($IsLinux) {
    'linux';
  } elseif ($IsMacOS) {
    'mac';
  } else {
    [string]::Empty;
  }

  $result;
}
