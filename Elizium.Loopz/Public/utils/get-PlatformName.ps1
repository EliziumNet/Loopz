
function Get-PlatformName {
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
