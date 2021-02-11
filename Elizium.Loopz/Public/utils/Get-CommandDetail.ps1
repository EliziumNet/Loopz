
function Get-CommandDetail {
  #  by KirkMunro (https://github.com/PowerShell/PowerShell/issues/8692)
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $Name
  )
  process {
    if ($_ -isnot [System.Management.Automation.CommandInfo]) {
      Get-Command -Name $_ | Get-CommandDetail
    }
    else {
      $commandPropDetails = ($_ | Format-List @{Name = 'CommandName'; Expression = { $_.Name } }, CommandType, ImplementingType, Dll, HelpFile | Out-String) -replace '^[\r\n]+|[\r\n]+$'

      $sb = [System.Text.StringBuilder]::new()
      $null = $sb.AppendLine($commandPropDetails)
      $null = $sb.AppendLine()

      foreach ($parameterSet in $_.ParameterSets) {
        $parametersToShow = $parameterSet.Parameters | Where-Object Name -NotIn @('Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'InformationAction', 'VerboseAction', 'DebugAction', 'ProgressAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable', 'DebugVariable', 'VerboseVariable', 'ProgressVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable', 'WhatIf', 'Confirm')
        $parameterGroups = $parametersToShow.where( { $_.Position -ge 0 }, 'split')
        $parameterGroups[0] = @($parameterGroups[0] | Sort-Object -Property Position)
        $parametersToShow = $parameterGroups[0] + $parameterGroups[1]
        $parameterDetails = ($parametersToShow `
          | Select-Object -Property @(
            'Name'
            @{Name = 'Type'; Expression = { $_.ParameterType.Name } }
            @{Name = 'Mandatory'; Expression = { $_.IsMandatory } }
            @{Name = 'Pos'; Expression = { if ($_.Position -eq [int]::MinValue) { 'named' } else { $_.Position } } }
            @{Name = 'PipeValue'; Expression = { $_.ValueFromPipeline } }
            @{Name = 'PipeName'; Expression = { $_.ValueFromPipelineByPropertyName } }
            @{Name = 'Alias'; Expression = { $_.Aliases -join ',' } }
          ) `
          | Format-Table -Property Name, Type, Mandatory, Pos, PipeValue, PipeName, Alias `
          | Out-String) -replace '^[\r\n]+|[\r\n]+$'

        $null = $sb.AppendLine("Parameter Set: $($ParameterSet.Name)$(if ($_.DefaultParameterSet -eq $ParameterSet.Name) {' (Default)'})")
        $null = $sb.AppendLine()
        $null = $sb.Append("Syntax: $($_.Name) ")
        $null = $sb.AppendLine($parameterSet.ToString())
        $null = $sb.AppendLine()
        $null = $sb.AppendLine('Parameters:')
        $null = $sb.AppendLine($parameterDetails)
        $null = $sb.AppendLine()
      }
      $sb.ToString()
    }
  }
}
