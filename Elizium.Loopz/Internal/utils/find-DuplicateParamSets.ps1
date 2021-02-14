
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
  [System.Management.Automation.CommandParameterSetInfo[]]$paramSets = $commandInfo.ParameterSets;
  [string[]]$paramSetNames = $paramSets.Name; 
  [array]$duplicates = @()

  [hashtable]$paramSetLookup = @{}
  foreach ($paramSet in $paramSets) {
    $paramSetLookup[$paramSet.Name] = $paramSet;
  }

  [PSCustomObject[]]$paramSetPairs = Get-UniqueCrossPairs -First $paramSetNames;

  foreach ($pair in $paramSetPairs) {
    [System.Management.Automation.CommandParameterSetInfo]$firstParamSet = $paramSetLookup[$pair.First];
    [System.Management.Automation.CommandParameterSetInfo]$secondParamSet = $paramSetLookup[$pair.Second];

    if ($firstParamSet -and $secondParamSet) {
      Write-Debug ">>> Checking parameter set combination: '$($pair.First), $($pair.Second)'";
      if (test-AreParamSetsEqual -FirstPsInfo $firstParamSet -SecondPsInfo $secondParamSet -Syntax $Syntax) {
        [PSCustomObject]$duplicate = [PSCustomObject]@{
          First  = $firstParamSet;
          Second = $secondParamSet;
        }

        $duplicates += $duplicate;
      }
    }
    else {
      throw "find-DuplicateParamSets: Couldn't recall previously stored parameter set(s). (This should never happen)";
    }
  }

  return $duplicates;
}
