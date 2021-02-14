
function get-ParameterSetTableData {
  # meta, headers, content
  #
  [OutputType([array])]
  param(
    [Parameter()]
    [System.Management.Automation.CommandInfo]$CommandInfo,

    [Parameter()]
    [System.Management.Automation.CommandParameterSetInfo]$ParamSet,

    [Parameter()]
    [Syntax]$Syntax
  )

  $parametersToShow = $ParamSet.Parameters | Where-Object Name -NotIn $syntax.CommonParamSet;
  $parameterGroups = $parametersToShow.where( { $CommandInfo.Position -ge 0 }, 'split');
  $parameterGroups[0] = @($parameterGroups[0] | Sort-Object -Property Position);
  $parametersToShow = $parameterGroups[0] + $parameterGroups[1];

  [PSCustomObject[]]$resultSet = ($parametersToShow `
    | Select-Object -Property @( # this is a query statement
      'Name'
      @{Name = 'Type'; Expression = { $_.ParameterType.Name }; }
      @{Name = 'Mandatory'; Expression = { $_.IsMandatory } }
      @{Name = 'Pos'; Expression = { if ($_.Position -eq [int]::MinValue) { 'named' } else { $_.Position } } }
      @{Name = 'PipeValue'; Expression = { $_.ValueFromPipeline } }
      @{Name = 'PipeName'; Expression = { $_.ValueFromPipelineByPropertyName } }
      @{Name = 'Alias'; Expression = { $_.Aliases -join ',' } }
    ));

  [array]$result = if (-not($($null -eq $resultSet)) -and ($resultSet.Count -gt 0)) {
    [hashtable]$fieldMetaData = Get-FieldMetaData -Data $resultSet;
    $Syntax.TableOptions.Custom.ParameterSetInfo = $ParamSet;

    [hashtable]$headers, [hashtable]$tableContent = Get-AsTable -MetaData $fieldMetaData `
      -TableData $resultSet -Options $Syntax.TableOptions;

    @($fieldMetaData, $headers, $tableContent);
  }
  else {
    @()
  }

  return $result;
}
