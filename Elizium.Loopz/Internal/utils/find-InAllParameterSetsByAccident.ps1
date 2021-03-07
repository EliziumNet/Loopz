
function find-InAllParameterSetsByAccident {
  [CmdletBinding()]
  [OutputType([array])]
  param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [System.Management.Automation.CommandInfo]$CommandInfo,

    [Parameter(Mandatory)]
    [Syntax]$Syntax
  )
  [System.Management.Automation.CommandParameterSetInfo[]]$paramSets = $commandInfo.ParameterSets;
  [System.Collections.Generic.List[PSCustomObject]]$pods = `
    [System.Collections.Generic.List[PSCustomObject]]::new();

  foreach ($paramSet in $paramSets) {
    [System.Management.Automation.CommandParameterInfo[]]$params = $paramSet.Parameters |`
      Where-Object { $_.Name -NotIn $Syntax.AllCommonParamSet };

    if ($params -and $params.Count -gt 0) {
      [System.Management.Automation.CommandParameterInfo[]]$candidates = $($params | Where-Object {
          ($_.Attributes.ParameterSetName.Count -gt 1) -and
          ($_.Attributes.ParameterSetName -contains [Syntax]::AllParameterSets)
        });

      foreach ($candidate in $candidates) {
        [string[]]$otherParamSetNames = $candidate.Attributes.ParameterSetName;
        [System.Management.Automation.CommandParameterSetInfo[]]$others = `
          $paramSets | Where-Object { ($_.Name -in $otherParamSetNames) -and ($_.Name -ne $paramSet.Name) }

        [PSCustomObject]$seed = [PSCustomObject]@{
          Param    = $candidate.Name;
          ParamSet = $paramSet;
          Others   = $others;
        }
        $pods.Add($seed);
      }
    }

    return ($pods.Count -gt 0) ? $pods : $null;
  }
}
