using namespace System.Management.Automation;

Describe 'Syntax' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;

    InModuleScope Elizium.Loopz {
      [krayon]$script:_krayon = Get-Krayon;
      [hashtable]$script:_theme = $_krayon.Theme;
      [hashtable]$script:_signals = Get-Signals;
    }
  }

  Describe 'ParamSetStmt' {
    Context 'given: Rename-Many' {
      It 'should: show parameter set statements' {
        InModuleScope Elizium.Loopz {
          [string]$command = 'Rename-Many';
          [syntax]$syntax = New-Syntax -CommandName $command -Signals $_signals -Krayon $_krayon;
          [CommandInfo]$commandInfo = Get-Command $command;

          foreach ($paramSet in $commandInfo.ParameterSets) {
            [string]$paramSetStmt = $syntax.ParamSetStmt($commandInfo, $paramSet);
            $_krayon.Scribble($paramSetStmt).Ln().End();
          }
        }
      }
    }
  } # ParamSetStmt

  Describe 'SyntaxStmt' {
    Context 'given: Rename-Many' {
      It 'should: show parameter set statements' {
        InModuleScope Elizium.Loopz {
          [string]$command = 'Rename-Many';
          [syntax]$syntax = New-Syntax -CommandName $command -Signals $_signals -Krayon $_krayon;
          [CommandInfo]$commandInfo = Get-Command $command;

          foreach ($paramSet in $commandInfo.ParameterSets) {
            [string]$syntaxStmt = $syntax.SyntaxStmt($paramSet);
            $_krayon.Scribble($syntaxStmt).Ln().Ln().End();
          }
        }
      }
    }
  }

  Describe 'query mandatory switch' -Skip {
    It 'blah' {
      InModuleScope Elizium.Loopz {
        [string]$command = 'Rename-Many';
        [CommandInfo]$commandInfo = Get-Command $command;

        foreach ($paramSet in $commandInfo.ParameterSets) {
          if ($paramSet.Name -in @('MoveToStart', 'MoveToEnd')) {
            Write-Host ">>> '$($paramSet.Name)'"
            [string[]]$names = ($paramSet.Parameters | Where-Object {
                ($_.Name -NotIn $Syntax.CommonParamSet) -and
                ($_.IsMandatory) -and ($_.ParameterType.Name -eq 'SwitchParameter')
              }).Name;

            [PSCustomObject[]]$resultSet = $($paramSet.Parameters | Where-Object {
                ($_.Name -NotIn $Syntax.CommonParamSet) -and
                ($_.IsMandatory) -and ($_.ParameterType.Name -eq 'SwitchParameter')
              });

            if ($resultSet) {
              [string[]]$names = $resultSet.Name;
            }
          }
        }
      }
    }
  }
}
