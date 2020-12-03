
function Invoke-ByPlatform {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
  param(
    [Parameter()]
    [System.Collections.Hashtable]$Hash
  )

  $result = $null;
  [string]$platform = Get-PlatformName;

  [PSCustomObject]$invokeInfo = if ($Hash.ContainsKey($platform)) {
    $Hash[$platform];
  }
  elseif ($Hash.ContainsKey('default')) {
    $Hash['default'];
  }
  else {
    Write-Error "!!!!!! Missing platform: '$platform' (and no default available)" -ErrorAction Continue;
    $null;
  }
  
  if ($invokeInfo.FnInfo) {
    if ($invokeInfo.psobject.properties.match('Positional') -and $invokeInfo.Positional) {
      [object[]]$positional = $invokeInfo.Positional;

      if ([scriptblock]$block = $invokeInfo.FnInfo.ScriptBlock) {
        $result = $block.Invoke($positional);
      }
      else {
        Write-Error $("ScriptBlock for function: '$($invokeInfo.FnInfo.Name)', ('$platform': platform) is missing") `
          -ErrorAction Continue;
      }
    } elseif ($invokeInfo.psobject.properties.match('Named') -and $invokeInfo.Named) {
      [System.Collections.Hashtable]$named = $invokeInfo.Named;

      $result = & $invokeInfo.FnInfo.Name @named;
    } else {
      Write-Error $("Missing Positional/Named: '$($invokeInfo.FnInfo.Name)', ('$platform': platform)") `
        -ErrorAction Continue;
    }
  }

  return $result;
}
