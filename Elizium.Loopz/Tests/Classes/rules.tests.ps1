using namespace System.Text;
using namespace System.Management.Automation;
using module Elizium.Krayola;

Describe 'Rules' -Tag 'PSTools' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;

    InModuleScope Elizium.Loopz {
      [hashtable]$script:_signals = Get-Signals;
      [hashtable]$script:_theme = Get-KrayolaTheme;
    }
  }

  BeforeEach {
    InModuleScope Elizium.Loopz {
      [krayon]$script:_krayon = New-Krayon -Theme $_theme;
      [Scribbler]$script:_scribbler = New-Scribbler -Krayon $_krayon -Test;
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
          [syntax]$syntax = New-Syntax -CommandName $commandName `
            -Signals $_signals -Scribbler $_scribbler;
          [string]$ruleName = 'UNIQUE-PARAM-SET';

          [PSCustomObject]$queryInfo = [PSCustomObject]@{
            CommandInfo = $commandInfo;
            Syntax      = $syntax;
            Scribbler   = $_scribbler;
          }

          [MustContainUniqueSetOfParams]$rule = [MustContainUniqueSetOfParams]::new($ruleName);
          [PSCustomObject]$vo = $rule.Query($queryInfo);

          $vo | Should -Not -BeNullOrEmpty;
          $vo.Violations.Count | Should -Be 1;

          $_WithDuplicateParamSets | Should -Contain $vo.Violations[0].First.Name;
          $_WithDuplicateParamSets | Should -Contain $vo.Violations[0].Second.Name;

          # Now check the statement execution doesn't fail in some way
          #
          $rule.ViolationStmt($vo.Violations, $queryInfo);

          if ($DebugPreference -ne [ActionPreference]::SilentlyContinue) {
            $_krayon.ScribbleLn($_scribbler.ToString());
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
          [syntax]$syntax = New-Syntax -CommandName $commandName -Signals $_signals -Scribbler $_scribbler;
          [string]$ruleName = 'UNIQUE-POSITIONS';

          [PSCustomObject]$queryInfo = [PSCustomObject]@{
            CommandInfo = $commandInfo;
            Syntax      = $syntax;
            Scribbler   = $_scribbler;
          }

          [MustContainUniquePositions]$rule = [MustContainUniquePositions]::new($ruleName);
          [PSCustomObject]$vo = $rule.Query($queryInfo);

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
          $rule.ViolationStmt($vo.Violations, $queryInfo);

          $_scribbler.Flush();
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
          [Syntax]$syntax = New-Syntax -CommandName $commandName -Signals $_signals -Scribbler $_scribbler;
          [string]$ruleName = 'SINGLE-PIPELINE-PARAM';

          [PSCustomObject]$queryInfo = [PSCustomObject]@{
            CommandInfo = $commandInfo;
            Syntax      = $syntax;
            Scribbler   = $_scribbler;
          }

          [MustNotHaveMultiplePipelineParams]$rule = [MustNotHaveMultiplePipelineParams]::new($ruleName);
          [PSCustomObject]$vo = $rule.Query($queryInfo);

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
          $rule.ViolationStmt($vo.Violations, $queryInfo);

          if ($DebugPreference -ne [ActionPreference]::SilentlyContinue) {
            $_krayon.ScribbleLn($_scribbler.ToString());
          }
        }
      }
    }
  } # MustNotHaveMultiplePipelineParams

  Describe 'MustNotBeInAllParameterSetsByAccident' {
    BeforeAll {
      InModuleScope Elizium.Loopz {
        function script:test-ParamInAllParameterSetsByAccident {
          param(
            [Parameter(ValueFromPipeline = $true)]
            [object]$Chaff,

            [Parameter(ParameterSetName = 'Alpha', Mandatory, Position = 1)]
            [object]$paramA,

            [Parameter()]
            [Parameter(ParameterSetName = 'Alpha', Position = 2)]
            [object]$paramB,

            [Parameter(ParameterSetName = 'Alpha', Position = 3)]
            [object]$paramC,

            [Parameter(ParameterSetName = 'Beta', Position = 1)]
            [object]$paramD,

            [Parameter()]
            [Parameter(ParameterSetName = 'Beta', Position = 2)]
            [object]$paramE
          )
        }
      }
    }

    Context 'given: functions with violations' {
      It 'should: report violations' {
        InModuleScope Elizium.Loopz {
          [string]$commandName = 'test-ParamInAllParameterSetsByAccident';
          [CommandInfo]$commandInfo = Get-Command $commandName;
          [RuleController]$controller = [RuleController]::new($commandInfo);
          [syntax]$syntax = New-Syntax -CommandName $commandName -Signals $_signals -Scribbler $_scribbler;
          $controller.Test($syntax).Result | Should -Be $false;

          $commandInfo | Show-ParameterSetReport;
        }
      }
    } # given: functions with violations
  } # MustNotBeInAllParameterSetsByAccident

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
          [RuleController]$controller = [RuleController]::new($commandInfo);
          [syntax]$syntax = New-Syntax -CommandName $commandName -Signals $_signals -Scribbler $_scribbler;
          $controller.Test($syntax).Result | Should -Be $false;
        }
      }
    } # given: functions with violations

    Context 'given: functions without violations' {
      It 'should: report no violations' {
        InModuleScope Elizium.Loopz {
          [string]$commandName = 'Invoke-Command';
          [CommandInfo]$commandInfo = Get-Command $commandName;
          [RuleController]$controller = [RuleController]::new($commandInfo);
          [syntax]$syntax = New-Syntax -CommandName $commandName -Signals $_signals -Scribbler $_scribbler;
          $controller.Test($syntax).Result | Should -Be $true;
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
                [RuleController]$controller = [RuleController]::new($commandInfo);
                [syntax]$syntax = New-Syntax -CommandName $command -Signals $_signals -Scribbler $_scribbler;
                [PSCustomObject]$testResult = $controller.Test($syntax);

                [string]$because = $("'{0}' contains violations" -f $command);
                $testResult.Result | Should -BeTrue -Because $because;
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

  Describe 'DryRunner' {
    BeforeEach {
      InModuleScope Elizium.Loopz {
        function script:test-FakeMany {
          [CmdletBinding(DefaultParameterSetName = 'ReplaceWith')]
          param(
            [Parameter(Mandatory, ValueFromPipeline = $true)]
            [System.IO.FileSystemInfo]$underscore,

            [Parameter(ParameterSetName = 'MoveToAnchor', Mandatory, Position = 0)]
            [Parameter(ParameterSetName = 'ReplaceWith', Mandatory, Position = 0)]
            [Parameter(ParameterSetName = 'MoveToStart', Mandatory, Position = 0)]
            [Parameter(ParameterSetName = 'MoveToEnd', Mandatory, Position = 0)]
            [array]$Pattern,

            [Parameter(ParameterSetName = 'MoveToAnchor', Mandatory)]
            [array]$Anchor,

            [Parameter(ParameterSetName = 'MoveToAnchor')]
            [string]$Relation = 'after',

            [Parameter(ParameterSetName = 'MoveToAnchor')]
            [Parameter(ParameterSetName = 'ReplaceWith')]
            [Parameter(ParameterSetName = 'Prepend')]
            [Parameter(ParameterSetName = 'Append')]
            [array]$Copy,

            [Parameter(ParameterSetName = 'MoveToAnchor')]
            [Parameter(ParameterSetName = 'ReplaceWith')]
            [Parameter(ParameterSetName = 'MoveToStart')]
            [Parameter(ParameterSetName = 'MoveToEnd')]
            [string]$With,

            [Parameter(ParameterSetName = 'ReplaceWith')]
            [Parameter(ParameterSetName = 'MoveToStart', Mandatory)]
            [switch]$Start,

            [Parameter(ParameterSetName = 'ReplaceWith')]
            [Parameter(ParameterSetName = 'MoveToEnd', Mandatory)]
            [switch]$End,

            [Parameter(ParameterSetName = 'MoveToAnchor')]
            [Parameter(ParameterSetName = 'ReplaceWith')]
            [Parameter(ParameterSetName = 'MoveToStart')]
            [Parameter(ParameterSetName = 'MoveToEnd')]
            [string]$Paste,

            [Parameter(ParameterSetName = 'MoveToAnchor')]
            [Parameter(ParameterSetName = 'ReplaceWith')]
            [Parameter(ParameterSetName = 'MoveToStart')]
            [Parameter(ParameterSetName = 'MoveToEnd')]
            [string]$Drop,

            [Parameter(ParameterSetName = 'Prepend', Mandatory)]
            [string]$Prepend,

            [Parameter(ParameterSetName = 'Append', Mandatory)]
            [string]$Append,

            [Parameter()]
            [switch]$File,

            [Parameter()]
            [switch]$Directory,

            [Parameter()]
            [string]$Except = [string]::Empty,

            [Parameter()]
            [string]$Include
          )
        } # test-FakeMany

        [string]$commandName = 'test-FakeMany';
        [DryRunner]$script:_runner = New-DryRunner -CommandName $commandName `
          -Signals $_signals -Scribbler $_scribbler;
      } # InModuleScope Elizium.Loopz
    } # BeforeEach

    Context 'given: valid parameter list' {
      It 'should: resolve to parameter set -> "ReplaceWith"' {
        InModuleScope Elizium.Loopz {
          [CommandParameterSetInfo[]]$paramSets = $_runner.Resolve(
            @('underscore', 'Pattern', 'With')
          );
          $paramSets.Count | Should -Be 1;
          $paramSets[0].Name | Should -Be 'ReplaceWith';
        }
      }

      It 'should: weak resolve to parameter set -> "ReplaceWith"' {
        InModuleScope Elizium.Loopz {
          [CommandParameterSetInfo[]]$paramSets = $_runner.Weak(
            @('underscore', 'Pattern', 'With')
          );
          $paramSets.Count | Should -Be 4;
          $paramSets[0].Name | Should -Be 'ReplaceWith';
        }
      }
    }

    Context 'given: parameter list that does not resolve' {
      It 'should: return empty list' {
        InModuleScope Elizium.Loopz {
          [CommandParameterSetInfo[]]$paramSets = $_runner.Resolve(
            @('Pattern', 'Anchor', 'Paste')
          );
          $paramSets.Count | Should -Be 0;
        }
      }
    }

    Context 'given: ambiguous but should not be' {
      It 'should: resolve to 1 parameter set (ReplacePaste)' -Tag 'FIX-ME' -Skip {
        InModuleScope Elizium.Loopz {
          [string]$commandName = 'Rename-Many';
          [DryRunner]$runner = New-DryRunner -CommandName $commandName `
            -Signals $_signals -Scribbler $_scribbler;

          [CommandParameterSetInfo[]]$paramSets = $runner.Resolve(
            @('underscore', 'Pattern', 'Anchor', 'Paste')
          );

          $paramSets.Count | Should -Be 999;
        }
      }
    }
  }
} # Rules
