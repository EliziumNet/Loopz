using namespace System.Text;
using namespace System.Management.Automation;

Describe 'Rules' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;

    InModuleScope Elizium.Loopz {
      [hashtable]$script:_signals = Get-Signals;
      [hashtable]$script:_theme = Get-KrayolaTheme;
    }
  }

  BeforeEach {
    InModuleScope Elizium.Loopz {
      [StringBuilder]$script:_builder = [StringBuilder]::new();
      [krayon]$script:_krayon = New-Krayon -Theme $_theme;
    }
  }

  Describe 'MustContainUniqueSetOfParams' {
    BeforeAll {
      InModuleScope Elizium.Loopz {
        function script:test-WithDuplicateParamSets {
          param(
            [Parameter()]
            [object]$Chaff,

            [Parameter(ParameterSetName = 'Alpha', Mandatory, Position = 1)]
            [Parameter(ParameterSetName = 'Beta', Mandatory, Position = 11)]
            [object]$DuplicatePosA,

            [Parameter(ParameterSetName = 'Alpha', Position = 2)]
            [Parameter(ParameterSetName = 'Beta', Position = 12)]
            [Parameter(ParameterSetName = 'Delta', Position = 21)]
            [object]$DuplicatePosB,

            [Parameter(ParameterSetName = 'Alpha', Position = 3)]
            [Parameter(ParameterSetName = 'Beta', Position = 13)]
            [Parameter(ParameterSetName = 'Delta', Position = 22)]
            [object]$DuplicatePosC
          )
        }

        [string[]]$script:_WithDuplicateParamSets = @('Alpha', 'Beta', 'Delta');
      }
    }

    Context 'given: function with duplicate parameter sets' {
      It 'should: return violation' -Tag 'What' {
        InModuleScope Elizium.Loopz {
          [string]$commandName = 'test-WithDuplicateParamSets';
          [CommandInfo]$commandInfo = Get-Command $commandName;
          [syntax]$syntax = New-Syntax -CommandName $commandName -Signals $_signals -Krayon $_krayon;
          [string]$ruleName = 'UNIQUE-PARAM-SET';

          [PSCustomObject]$verifyInfo = [PSCustomObject]@{
            CommandInfo = $commandInfo;
            Syntax      = $syntax;
            Builder     = $_builder;
          }

          [MustContainUniqueSetOfParams]$rule = [MustContainUniqueSetOfParams]::new($ruleName);
          [PSCustomObject]$vo = $rule.Violation($verifyInfo);

          $vo | Should -Not -BeNullOrEmpty;
          $vo.Violations.Count | Should -Be 1;

          $_WithDuplicateParamSets | Should -Contain $vo.Violations[0].First.Name;
          $_WithDuplicateParamSets | Should -Contain $vo.Violations[0].Second.Name;

          # Now check the statement execution doesn't fail in some way
          #
          $rule.ViolationStmt($vo.Violations, $verifyInfo);

          if ($DebugPreference -ne [ActionPreference]::SilentlyContinue) {
            $_krayon.ScribbleLn($_builder.ToString());
          }
        }
      }
    }
  } # MustContainUniqueSetOfParams

  Describe 'MustContainUniquePositions' {
    BeforeAll {
      InModuleScope Elizium.Loopz {
        function script:test-MultipleSetsWithDuplicatedPositions {
          param(
            [parameter()]
            [object]$Chaff,

            [Parameter(ParameterSetName = 'Alpha', Mandatory, Position = 999)]
            [object]$DuplicatePosA,

            [Parameter(ParameterSetName = 'Alpha', Position = 999)]
            [object]$DuplicatePosB,

            [Parameter(ParameterSetName = 'Alpha', Position = 999)]
            [object]$DuplicatePosC,

            [Parameter(ParameterSetName = 'Beta', Mandatory, Position = 111)]
            [object]$SameA,

            [Parameter(ParameterSetName = 'Beta', Position = 111)]
            [object]$SameB
          )
        }

        [string[]]$script:_MultipleSetsWithDuplicatedPositions = @('Alpha', 'Beta');
      }
    }

    Context 'given: function with Parameter Sets containing parameters with same position' {
      It 'should: return violation' -Tag 'What' {
        InModuleScope Elizium.Loopz {
          [string]$commandName = 'test-MultipleSetsWithDuplicatedPositions';
          [CommandInfo]$commandInfo = Get-Command $commandName;
          [syntax]$syntax = New-Syntax -CommandName $commandName -Signals $_signals -Krayon $_krayon;
          [string]$ruleName = 'UNIQUE-POSITIONS';

          [PSCustomObject]$verifyInfo = [PSCustomObject]@{
            CommandInfo = $commandInfo;
            Syntax      = $syntax;
            Builder     = $_builder;
          }

          [MustContainUniquePositions]$rule = [MustContainUniquePositions]::new($ruleName);
          [PSCustomObject]$vo = $rule.Violation($verifyInfo);

          $vo | Should -Not -BeNullOrEmpty;
          $vo.Violations.Count | Should -Be 2;

          $alphaDuplicate = $($vo.Violations | Where-Object { $_.ParamSet.Name -eq 'Alpha' })[0];
          $alphaDuplicate | Should -Not -BeNullOrEmpty;
          $resultA = $alphaDuplicate.Params | Sort-Object | Compare-Object @(
            'DuplicatePosA', 'DuplicatePosB', 'DuplicatePosC'
          );
          $resultA | Should -BeNullOrEmpty;

          $betaDuplicate = $($vo.Violations | Where-Object { $_.ParamSet.Name -eq 'Beta' })[0];
          $betaDuplicate | Should -Not -BeNullOrEmpty;
          $resultB = $betaDuplicate.Params | Sort-Object | Compare-Object @(
            'SameA', 'SameB'
          );
          $resultB | Should -BeNullOrEmpty;

          # Now check the statement execution doesn't fail in some way
          #
          $rule.ViolationStmt($vo.Violations, $verifyInfo);

          if ($DebugPreference -ne [ActionPreference]::SilentlyContinue) {
            $_krayon.ScribbleLn($_builder.ToString());
          }
        }
      }
    }
  } # MustContainUniquePositions
} # Rules
