
function Invoke-ByPlatform {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
  param(
    [Parameter()]
    [hashtable]$Hash
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
  
  if ($invokeInfo -and $invokeInfo.FnInfo) {
    if ($invokeInfo.psobject.properties.match('Positional') -and $invokeInfo.Positional) {
      [array]$positional = $invokeInfo.Positional;

      if ([scriptblock]$block = $invokeInfo.FnInfo.ScriptBlock) {
        $result = $block.InvokeReturnAsIs($positional);
      }
      else {
        Write-Error $("ScriptBlock for function: '$($invokeInfo.FnInfo.Name)', ('$platform': platform) is missing") `
          -ErrorAction Continue;
      }
    }
    elseif ($invokeInfo.psobject.properties.match('Named') -and $invokeInfo.Named) {
      [hashtable]$named = $invokeInfo.Named;

      $result = & $invokeInfo.FnInfo.Name @named;
    }
    else {
      Write-Error $("Missing Positional/Named: '$($invokeInfo.FnInfo.Name)', ('$platform': platform)") `
        -ErrorAction Continue;
    }
  }

  return $result;
}
