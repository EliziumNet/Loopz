
function test-IsParameterUnique {
  param(
    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter(Mandatory)]
    [System.Management.Automation.CommandInfo]$CommandInfo
  )
  [System.Management.Automation.ParameterMetadata]$parameterMetaData = `
    $CommandInfo.Parameters?[$Name];

  [boolean]$unique = if ($null -ne $parameterMetaData) {
    if ($parameterMetaData.ParameterSets.PSBase.ContainsKey('__AllParameterSets')) {
      $false;
    }
    else {
      $($parameterMetaData.ParameterSets.PSBase.Count -le 1) 
    }
  }
  else {
    $false;
  }
  return $unique;
}
