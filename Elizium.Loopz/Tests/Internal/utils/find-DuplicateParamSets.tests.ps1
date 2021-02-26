using module Elizium.Krayola;
using namespace System.Management.Automation;

Describe 'find-DuplicateParamSets' -Tag 'PSTools' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;
  }

  BeforeEach {
    InModuleScope Elizium.Loopz {
      [Krayon]$script:_krayon = Get-Krayon;
      [hashtable]$script:_theme = $_krayon.Theme;
      [hashtable]$script:_signals = Get-Signals;
    }
  }

  Context 'given: a command containing duplicate parameters sets' {
    It 'should: return the parameter set pair' {
      InModuleScope Elizium.Loopz {
        function test-FnWithDuplicateParamSets {
          [CmdletBinding(DefaultParameterSetName = 'Alpha')]
          param(
            [Parameter(ParameterSetName = 'Alpha')]
            [Parameter(ParameterSetName = 'Beta')]
            [Parameter()]$A,

            [Parameter(ParameterSetName = 'Alpha')]
            [Parameter(ParameterSetName = 'Beta')]
            [Parameter()]$B
          )
        }

        [string]$commandName = 'test-FnWithDuplicateParamSets';
        [Syntax]$script:_syntax = [Syntax]::new($commandName, $_signals, $_krayon);
        [CommandInfo]$CommandInfo = $(Get-Command $commandName);
        [array]$duplicates = find-DuplicateParamSets -CommandInfo $CommandInfo -Syntax $_syntax;
        $duplicates.Count | Should -Be 1;
      }
    }
  }

  Context 'given: Rename-Many command set' {
    It 'should: not find amy duplicates' {
      InModuleScope Elizium.Loopz {
        [string]$commandName = 'Rename-Many'
        [Syntax]$script:_syntax = [Syntax]::new($commandName, $_signals, $_krayon);
        [CommandInfo]$CommandInfo = $(Get-Command $commandName);
        [array]$duplicates = find-DuplicateParamSets -CommandInfo $CommandInfo -Syntax $_syntax;
        $duplicates | Should -BeNullOrEmpty;
      }
    }
  }

  Context 'given: Command with non distinguishable parameter set' {
    It 'should: return that duplicate' {
      InModuleScope Elizium.Loopz {
        function test-WithDuplicateParamSets {
          param(
            [Parameter()]
            [object]$Chaff,

            [Parameter(ParameterSetName = 'Alpha', Mandatory, Position = 1)]
            [Parameter(ParameterSetName = 'Beta', Mandatory, Position = 1)]
            [object]$DuplicatePosA,

            [Parameter(ParameterSetName = 'Alpha', Position = 2)]
            [Parameter(ParameterSetName = 'Beta', Position = 2)]
            [object]$DuplicatePosB,

            [Parameter(ParameterSetName = 'Alpha', Position = 3)]
            [Parameter(ParameterSetName = 'Beta', Position = 3)]
            [object]$DuplicatePosC
          )
        }

        [string]$commandName = 'test-WithDuplicateParamSets'
        [Syntax]$script:_syntax = [Syntax]::new($commandName, $_signals, $_krayon);
        [CommandInfo]$CommandInfo = $(Get-Command $commandName);
        [array]$duplicates = find-DuplicateParamSets -CommandInfo $CommandInfo -Syntax $_syntax;

        $duplicates.Count | Should -Be 1;
      }
    }
  }
}
