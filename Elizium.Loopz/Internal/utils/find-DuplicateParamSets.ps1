
function find-DuplicateParamSets {
  [CmdletBinding()]
  [OutputType([array])]
  param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [System.Management.Automation.CommandInfo]$CommandInfo,

    [Parameter(Mandatory)]
    [Syntax]$Syntax
  )
  [System.Management.Automation.CommandParameterSetInfo[]]$paramSets = $(
    $commandInfo.ParameterSets | Where-Object { $_.Name -ne '__AllParameterSets' }
  );

  [string[]]$paramSetNames = $paramSets.Name; 
  [array]$pods = @()

  [hashtable]$paramSetLookup = @{}
  foreach ($paramSet in $paramSets) {
    $paramSetLookup[$paramSet.Name] = $paramSet;
  }

  if ($paramSetNames -and ($paramSetNames.Count -gt 0)) {
    [PSCustomObject[]]$paramSetPairs = Get-UniqueCrossPairs -First $paramSetNames;

    foreach ($pair in $paramSetPairs) {
      [System.Management.Automation.CommandParameterSetInfo]$firstParamSet = $paramSetLookup[$pair.First];
      [System.Management.Automation.CommandParameterSetInfo]$secondParamSet = $paramSetLookup[$pair.Second];

      if ($firstParamSet -and $secondParamSet) {
        if (test-AreParamSetsEqual -FirstPsInfo $firstParamSet -SecondPsInfo $secondParamSet -Syntax $Syntax) {
          [PSCustomObject]$seed = [PSCustomObject]@{
            First  = $firstParamSet;
            Second = $secondParamSet;
          }

          $pods += $seed;
        }
      }
      else {
        throw "find-DuplicateParamSets: Couldn't recall previously stored parameter set(s). (This should never happen)";
      }
    }
  }

  return ($pods.Count -gt 0) ? $pods : $null;
}
