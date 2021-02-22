
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
  [array]$multiples = @();

  [scriptblock]$paramIsValueFromPipeline = [scriptblock] {
    [OutputType([boolean])]
    param (
      [Parameter()]
      [PSCustomObject]$row
    )
    return [boolean]$row.PipeValue;
  };

  foreach ($paramSet in $paramSets) {
    [hashtable]$fieldMetaData, [hashtable]$headers, [hashtable]$tableContent = `
      get-ParameterSetTableData -CommandInfo $CommandInfo `
      -ParamSet $paramSet -Syntax $Syntax -Where $paramIsValueFromPipeline;

    if ($tableContent -and ($tableContent.Count -gt 1)) {
      [PSCustomObject]$pipelineClaim = [PSCustomObject]@{
        ParamSet = $paramSet;
        Params   = $tableContent.Keys;
      }
      $multiples += $pipelineClaim;
    }
  }
  return ($multiples.Count -gt 0) ? $multiples : $null;
}
