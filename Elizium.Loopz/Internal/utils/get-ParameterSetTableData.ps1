
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
    [Syntax]$Syntax,

    [Parameter()]
    [scriptblock]$Where = $([scriptblock] {
        [OutputType([boolean])]
        param (
          [Parameter()]
          [PSCustomObject]$row
        )
        return $true;
      })
  )

  $parametersToShow = $Syntax.TableOptions.Custom.IncludeCommon `
    ? $ParamSet.Parameters : $($ParamSet.Parameters | Where-Object Name -NotIn $Syntax.CommonParamSet);

  [PSCustomObject[]]$resultSet = ($parametersToShow `
    | Select-Object -Property @(
      'Name'
      @{Name = 'Type'; Expression = { $_.ParameterType.Name }; }
      @{Name = 'Mandatory'; Expression = { $_.IsMandatory } }
      @{Name = 'Pos'; Expression = { if ($_.Position -eq [int]::MinValue) { 'named' } else { $_.Position } } }
      @{Name = 'PipeValue'; Expression = { $_.ValueFromPipeline } }
      @{Name = 'PipeName'; Expression = { $_.ValueFromPipelineByPropertyName } }
      @{Name = 'Alias'; Expression = { $_.Aliases -join ',' } }
      @{Name = 'Unique'; Expression = { test-IsParameterUnique -Name $_.Name -CommandInfo $CommandInfo } }
    ));

  [array]$result = if (-not($($null -eq $resultSet)) -and ($resultSet.Count -gt 0)) {
    $resultSet = $resultSet | Where-Object { $Where.InvokeReturnAsIs($_); }

    if ($resultSet) {
      [hashtable]$fieldMetaData = Get-FieldMetaData -Data $resultSet;
      $Syntax.TableOptions.Custom.ParameterSetInfo = $ParamSet;

      [hashtable]$headers, [hashtable]$tableContent = Get-AsTable -MetaData $fieldMetaData `
        -TableData $resultSet -Options $Syntax.TableOptions;

      @($fieldMetaData, $headers, $tableContent);
    }
    else {
      @()
    }
  }
  else {
    @()
  }

  return $result;
}
