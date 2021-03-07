
function find-MultipleValueFromPipeline {
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

  [scriptblock]$paramIsValueFromPipeline = [scriptblock] {
    [OutputType([boolean])]
    param (
      [Parameter()]
      [PSCustomObject]$row
    )
    return [boolean]$row.PipeValue;
  };

  [array]$pods = foreach ($paramSet in $paramSets) {
    $null, $null, [hashtable]$tableContent = `
      get-ParameterSetTableData -CommandInfo $CommandInfo `
      -ParamSet $paramSet -Syntax $Syntax -Where $paramIsValueFromPipeline;

    if ($tableContent -and ($tableContent.PSBase.Count -gt 1)) {
      [PSCustomObject]$seed = [PSCustomObject]@{
        ParamSet = $paramSet;
        Params   = $tableContent.PSBase.Keys;
      }
      $seed;
    }
  }

  return ($pods.Count -gt 0) ? $pods : $null;
}
