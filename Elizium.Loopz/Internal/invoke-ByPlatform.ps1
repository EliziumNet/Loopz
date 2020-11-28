
function invoke-ByPlatform {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
  param(
    [System.Collections.Hashtable]$Hash,

    [PSCustomObject]$Default
  )

  $result = $null;
  [string]$platform = get-PlatformName;

  if ($Hash.ContainsKey($platform)) {
    [System.Collections.Hashtable]$invokeInfo = $Hash[$platform];

    if (($null -ne $invokeInfo.FunctionName) -and ($null -ne $invokeInfo.FunctionParameters)) {

      [System.Collections.Hashtable]$parameters = $invokeInfo.FunctionParameters;
      $result = &($invokeInfo.FunctionName) @parameters;
    } else {
      Write-warning $("Function info for '{0}' platform is missing 'FunctionName' and/or 'FunctionParameters'" -f $platform);
    }
  } elseif ($PSBoundParameters.ContainsKey('Default')) {
    Write-Error "!!!!!! Missing platform: '$platform'" -ErrorAction Continue;
    $result = &($Default.FunctionName) @($Default.FunctionParameters);
  }
  return $result;
}
