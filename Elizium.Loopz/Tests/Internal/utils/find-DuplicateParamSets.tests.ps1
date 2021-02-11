using module Elizium.Krayola;

Describe 'find-DuplicateParamSets' {
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
        [Syntax]$script:_syntax = [Syntax]::new($commandName, $_theme, $_signals, $_krayon);
        [System.Management.Automation.CommandInfo]$CommandInfo = $(Get-Command $commandName);
        [array]$result = find-DuplicateParamSets -CommandInfo $CommandInfo -Syntax $_syntax;
        $result.Count | Should -Be 1;
      }
    }
  }

  Context 'given: Rename-Many command set' {
    It 'should: not find amy duplicates' {
      InModuleScope Elizium.Loopz {
        [string]$commandName = 'Rename-Many'
        [Syntax]$script:_syntax = [Syntax]::new($commandName, $_theme, $_signals, $_krayon);
        [System.Management.Automation.CommandInfo]$CommandInfo = $(Get-Command $commandName);
        [array]$result = find-DuplicateParamSets -CommandInfo $CommandInfo -Syntax $_syntax;
        $result.Count | Should -Be 0;
      }
    }
  }
}
