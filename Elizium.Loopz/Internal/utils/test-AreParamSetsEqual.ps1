
function test-AreParamSetsEqual {
  [OutputType([boolean])]
  param(
    [Parameter(Mandatory)]
    [System.Management.Automation.CommandParameterSetInfo]$FirstPsInfo,

    [Parameter(Mandatory)]
    [System.Management.Automation.CommandParameterSetInfo]$SecondPsInfo,

    [Parameter(Mandatory)]
    [Syntax]$syntax
  )

  if ($FirstPsInfo -and $SecondPsInfo) {
    [array]$firstPsParams = $FirstPsInfo.Parameters | Where-Object Name -NotIn $Syntax.AllCommonParamSet;
    [array]$secondPsParams = $SecondPsInfo.Parameters | Where-Object Name -NotIn $Syntax.AllCommonParamSet;

    [string[]]$paramNamesFirst = $($firstPsParams).Name | Sort-Object;
    [string[]]$paramNamesSecond = $($secondPsParams).Name | Sort-Object;

    return $($null -eq $(Compare-Object -ReferenceObject $paramNamesFirst -DifferenceObject $paramNamesSecond));
  }
}
