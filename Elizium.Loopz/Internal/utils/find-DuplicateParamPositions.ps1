
function find-DuplicateParamPositions {
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
  [array]$pods = @();

  [scriptblock]$paramIsPositional = [scriptblock] {
    [OutputType([boolean])]
    param (
      [Parameter()]
      [PSCustomObject]$row
    )
    return $row.Pos -ne 'named';
  };

  foreach ($paramSet in $paramSets) {
    $null, $null, [hashtable]$tableContent = `
      get-ParameterSetTableData -CommandInfo $CommandInfo `
      -ParamSet $paramSet -Syntax $Syntax -Where $paramIsPositional;

    # We might encounter a parameter set which does not contain positional parameters,
    # in which case, we should ignore.
    #
    if ($tableContent -and ($tableContent.PSBase.Count -gt 0)) {
      [hashtable]$partitioned = Get-PartitionedPcoHash -Hash $tableContent -Field 'Pos';
      # partitioned is indexed by the Pos value, not 'Pos'
      #
      if ($partitioned.PSBase.Count -gt -0) {
        $partitioned.GetEnumerator() | ForEach-Object {
          [hashtable]$positional = $_.Value;

          if ($positional -and ($positional.PSBase.Count -gt 1)) {
            # found duplicate positions
            #
            [string[]]$params = $($positional.GetEnumerator() | ForEach-Object { $_.Key } | Sort-Object);

            [PSCustomObject]$seed = [PSCustomObject]@{
              ParamSet = $paramSet;
              Params   = $params;
              Number   = $_.Key;
            }

            $pods += $seed;
          }
        }
      }
    }
  }
  return ($pods.Count -gt 0) ? $pods : $null;
}
