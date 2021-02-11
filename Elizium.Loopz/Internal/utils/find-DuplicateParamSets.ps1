
function find-DuplicateParamSets {
  [CmdletBinding()]
  [OutputType([array])]
  param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [System.Management.Automation.CommandInfo]$CommandInfo,

    [Parameter(Mandatory)]
    [Syntax]$syntax
  )
  [System.Management.Automation.CommandParameterSetInfo[]]$paramSets = $commandInfo.ParameterSets;
  [string[]]$paramSetNames = $paramSets.Name; 
  [System.Collections.ArrayList]$duplicates = @{}

  [hashtable]$paramSetLookup = @{}
  foreach ($paramSet in $paramSets) {
    $paramSetLookup[$paramSet.Name] = $paramSet;
  }

  [PSCustomObject[]]$paramSetPairs = Get-UniqueCrossPairs -First $paramSetNames;

  foreach ($pair in $paramSetPairs) {
    [System.Management.Automation.CommandParameterSetInfo]$firstParamSet = $paramSetLookup[$pair.First];
    [System.Management.Automation.CommandParameterSetInfo]$secondParamSet = $paramSetLookup[$pair.Second];

    if ($firstParamSet -and $secondParamSet) {
      Write-Debug ">>> Checking parameter set combination: '$($pair.First), $($pair.Second)'"
      if (test-AreParamSetsEqual -FirstPsInfo $firstParamSet -SecondPsInfo $secondParamSet -Syntax $syntax) {
        $duplicates.Add([PSCustomObject]@{
            First = $firstParamSet;
            Second = $secondParamSet;
        });
      }
    }
    else {
      throw "find-DuplicateParamSets: Couldn't recall previously stored parameter set(s). (This should never happen)";
    }
  }
}
