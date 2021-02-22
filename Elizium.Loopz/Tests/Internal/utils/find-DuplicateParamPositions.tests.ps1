using namespace System.Management.Automation;

Describe 'find-DuplicateParamPositions' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;
  }

  BeforeEach {
    InModuleScope Elizium.Loopz {
      [Krayon]$script:_krayon = Get-Krayon;
      [hashtable]$script:_signals = Get-Signals;
    }
  }

  Context 'given: a command containing no parameter sets with duplicated positions' {
    It 'should: report no violations' {
      InModuleScope Elizium.Loopz {
        function test-NoDuplicatedPositions {
          param(
            [parameter()]
            [object]$Chaff,

            [Parameter(ParameterSetName = 'Alpha', Mandatory, Position = 1)]
            [object]$DuplicatePosA,

            [Parameter(ParameterSetName = 'Beta', Position = 2)]
            [object]$DuplicatePosB,

            [Parameter(ParameterSetName = 'Delta', Position = 3)]
            [object]$DuplicatePosC
          )
        }

        [string]$commandName = 'test-NoDuplicatedPositions';
        [CommandInfo]$commandInfo = Get-Command $commandName;
        [Syntax]$syntax = New-Syntax -CommandName $commandName -Signals $_signals -Krayon $_krayon;

        [array]$duplicates = find-DuplicateParamPositions -CommandInfo $commandInfo -Syntax $syntax;
        $duplicates | Should -BeNullOrEmpty;
      }
    }
  }

  Context 'given: a command containing a single set with duplicated positions' {
    It 'should: return the violating Parameter set' {
      InModuleScope Elizium.Loopz {
        function test-SingleSetWithDuplicatedPositions {
          param(
            [parameter()]
            [object]$Chaff,

            [Parameter(ParameterSetName = 'Alpha', Mandatory, Position = 999)]
            [object]$DuplicatePosA,

            [Parameter(ParameterSetName = 'Alpha', Position = 999)]
            [object]$DuplicatePosB,

            [Parameter(ParameterSetName = 'Alpha', Position = 999)]
            [object]$DuplicatePosC
          )
        }

        [string]$commandName = 'test-SingleSetWithDuplicatedPositions';
        [CommandInfo]$commandInfo = Get-Command $commandName;
        [Syntax]$syntax = New-Syntax -CommandName $commandName -Signals $_signals -Krayon $_krayon;

        [array]$duplicates = find-DuplicateParamPositions -CommandInfo $commandInfo -Syntax $syntax;
        $duplicates.Count | Should -Be 1;

        ($duplicates | Where-Object { $_.ParamSet.Name -eq 'Alpha' }) | `
          Should -Not -BeNullOrEmpty;
      }
    }
  }

  Context 'given: a command containing multiple sets with duplicated positions' {
    It 'should: return the violating Parameter sets' {
      InModuleScope Elizium.Loopz {
        function test-MultipleSetsWithDuplicatedPositions {
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

        [string]$commandName = 'test-MultipleSetsWithDuplicatedPositions';
        [CommandInfo]$commandInfo = Get-Command $commandName;
        [Syntax]$syntax = New-Syntax -CommandName $commandName -Signals $_signals -Krayon $_krayon;

        [array]$duplicates = find-DuplicateParamPositions -CommandInfo $commandInfo -Syntax $syntax;
        $duplicates.Count | Should -Be 2;

        ($duplicates | Where-Object { $_.ParamSet.Name -eq 'Alpha' }) | `
          Should -Not -BeNullOrEmpty;

        ($duplicates | Where-Object { $_.ParamSet.Name -eq 'Beta' }) | `
          Should -Not -BeNullOrEmpty;
      }
    }
  }
}
