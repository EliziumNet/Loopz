using namespace System.Text;
using namespace System.Management.Automation;

Describe 'Rules' -Tag 'PSTools' {
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
      It 'should: return violation' {
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
          [PSCustomObject]$vo = $rule.Query($verifyInfo);

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
      It 'should: return violation' {
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
          [PSCustomObject]$vo = $rule.Query($verifyInfo);

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

  Describe 'MustNotHaveMultiplePipelineParams' {
    BeforeAll {
      InModuleScope Elizium.Loopz {
        function script:test-MultipleClaimsToPipelineValue {
          param(
            [parameter(ValueFromPipeline = $true)]
            [object]$Chaff,

            [Parameter(ParameterSetName = 'Alpha', Mandatory, Position = 1, ValueFromPipeline = $true)]
            [object]$ClaimA,

            [Parameter(ParameterSetName = 'Alpha', Position = 2, ValueFromPipeline = $true)]
            [object]$ClaimB,

            [Parameter(ParameterSetName = 'Alpha', Position = 3, ValueFromPipeline = $true)]
            [object]$ClaimC,

            [Parameter(ParameterSetName = 'Beta', Position = 1, ValueFromPipeline = $true)]
            [object]$ClaimD,

            [Parameter(ParameterSetName = 'Beta', Position = 2, ValueFromPipeline = $true)]
            [object]$ClaimE
          )
        }
      }
    }

    Context 'given: multiple claims to pipeline item' {
      It 'should: report violations' {
        InModuleScope Elizium.Loopz {
          [string]$commandName = 'test-MultipleClaimsToPipelineValue';
          [CommandInfo]$commandInfo = Get-Command $commandName;
          [Syntax]$syntax = New-Syntax -CommandName $commandName -Signals $_signals -Krayon $_krayon;
          [string]$ruleName = 'SINGLE-PIPELINE-PARAM';

          [PSCustomObject]$verifyInfo = [PSCustomObject]@{
            CommandInfo = $commandInfo;
            Syntax      = $syntax;
            Builder     = $_builder;
          }

          [MustNotHaveMultiplePipelineParams]$rule = [MustNotHaveMultiplePipelineParams]::new($ruleName);
          [PSCustomObject]$vo = $rule.Query($verifyInfo);

          $vo | Should -Not -BeNullOrEmpty;
          $vo.Violations.Count | Should -Be 2;

          $alphaClaims = $($vo.Violations | Where-Object { $_.ParamSet.Name -eq 'Alpha' })[0];
          $alphaClaims | Should -Not -BeNullOrEmpty;
          $resultA = $alphaClaims.Params | Sort-Object | Compare-Object @(
            'Chaff', 'ClaimA', 'ClaimB', 'ClaimC'
          );
          $resultA | Should -BeNullOrEmpty;

          $betaClaims = $($vo.Violations | Where-Object { $_.ParamSet.Name -eq 'Beta' })[0];
          $betaClaims | Should -Not -BeNullOrEmpty;
          $resultB = $betaClaims.Params | Sort-Object | Compare-Object @(
            'Chaff', 'ClaimD', 'ClaimE'
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
  } # MustNotHaveMultiplePipelineParams

  Describe 'Test' {
    BeforeAll {
      InModuleScope Elizium.Loopz {
        function script:test-runTest {
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
      }
    }
    # InModuleScope doesn't work well with -ForEach(TestCases)
    #
    Context 'given: functions with violations' {
      It 'should: report violations' {
        InModuleScope Elizium.Loopz {
          [string]$commandName = 'test-runTest';
          [CommandInfo]$commandInfo = Get-Command $commandName;
          [Rules]$rules = [Rules]::new($commandInfo);
          [syntax]$syntax = New-Syntax -CommandName $commandName -Signals $_signals -Krayon $_krayon;
          $rules.Test($syntax).Result | Should -Be $false;
        }
      }
    } # given: functions with violations

    Context 'given: functions without violations' {
      It 'should: report no violations' {
        InModuleScope Elizium.Loopz {
          [string]$commandName = 'Invoke-Command';
          [CommandInfo]$commandInfo = Get-Command $commandName;
          [Rules]$rules = [Rules]::new($commandInfo);
          [syntax]$syntax = New-Syntax -CommandName $commandName -Signals $_signals -Krayon $_krayon;
          $rules.Test($syntax).Result | Should -Be $true;
        }
      }
    } # given: functions without violations
  } # Test

  Describe 'module public functions' {
    It 'should: report no parameter set violations' {
      InModuleScope Elizium.Loopz {
        [string]$directoryPath = './Public/';

        if (Test-Path -Path $directoryPath) {
          [array]$files = Get-ChildItem -Path $directoryPath -File -Recurse -Filter '*.ps1';
          [string[]]$except = @(, 'globals')
          foreach ($file in $files) {
            [string]$command = [System.IO.Path]::GetFileNameWithoutExtension($file.Name);
            if ($except -notContains $command) {
              [CommandInfo]$commandInfo = Get-Command $command -ErrorAction SilentlyContinue;

              if ($commandInfo) {
                [Rules]$rules = [Rules]::new($commandInfo);
                [syntax]$syntax = New-Syntax -CommandName $command -Signals $_signals -Krayon $_krayon;
                [PSCustomObject]$testResult = $rules.Test($syntax);

                $testResult.Result | Should -BeTrue;
              }
              else {
                Write-Error "+ --- Couldn't get command info for '$($command)'";
              } 
            }
          }
        }
        else {
          Write-Host "FAILED: to find public functions to test"
        }
      }
    }
  }
} # Rules
