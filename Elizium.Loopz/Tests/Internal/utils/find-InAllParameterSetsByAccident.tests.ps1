using namespace System.Management.Automation;
Describe 'find-InAllParameterSetsByAccident' -Tag '!Current' {
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

  Context 'given: invoke-command' {
    It 'should: not report any accidental parameters' {
      InModuleScope Elizium.Loopz {
        [string]$commandName = 'Invoke-Command';
        [CommandInfo]$commandInfo = Get-Command $commandName;
        [Syntax]$syntax = New-Syntax -CommandName $commandName -Signals $_signals -Krayon $_krayon;

        [PSCustomObject[]]$accidents = find-InAllParameterSetsByAccident -CommandInfo $commandInfo -Syntax $syntax;
        $accidents | Should -BeNullOrEmpty;
      }
    }
  }

  Context 'given: single parameter in AllParameterSets by accident' {
    It 'should: report violation' {
      InModuleScope Elizium.Loopz {
        function test-SingleInAllParameterSetsByAccident {
          param(
            [object]$Wheat,

            [parameter()]
            [object]$Chaff,

            [Parameter(ParameterSetName = 'Alpha', Mandatory, Position = 1)]
            [Parameter(ParameterSetName = 'Ok', Mandatory, Position = 1)]
            [object]$PosA,

            [Parameter(ParameterSetName = 'Beta', Position = 2)]
            [Parameter(ParameterSetName = 'Ok', Mandatory, Position = 2)]
            [object]$PosB,

            [parameter()]
            [Parameter(ParameterSetName = 'Delta', Position = 3)]
            [object]$Accidental
          )
        }
        [string]$commandName = 'test-SingleInAllParameterSetsByAccident';
        [CommandInfo]$commandInfo = Get-Command $commandName;
        [Syntax]$syntax = New-Syntax -CommandName $commandName -Signals $_signals -Krayon $_krayon;

        [PSCustomObject[]]$accidents = find-InAllParameterSetsByAccident -CommandInfo $commandInfo -Syntax $syntax;
        $accidents | Should -Not -BeNullOrEmpty;
        $accidents.Count | Should -Be 1;
      }
    }
  }

  Context 'given: multiple parameter in AllParameterSets by accident' {
    It 'should: report violation' {
      InModuleScope Elizium.Loopz {
        function test-MultipleInAllParameterSetsByAccident {
          param(
            [object]$Wheat,

            [parameter()]
            [object]$Chaff,

            [Parameter()]
            [Parameter(ParameterSetName = 'Alpha', Mandatory, Position = 1)]
            [Parameter(ParameterSetName = 'Ok', Mandatory, Position = 1)]
            [object]$AccidentalA,

            [Parameter()]
            [Parameter(ParameterSetName = 'Beta', Position = 2)]
            [Parameter(ParameterSetName = 'Ok', Mandatory, Position = 2)]
            [object]$AccidentalB,

            [parameter()]
            [Parameter(ParameterSetName = 'Delta', Position = 3)]
            [object]$AccidentalC
          )
        }
        [string]$commandName = 'test-MultipleInAllParameterSetsByAccident';
        [CommandInfo]$commandInfo = Get-Command $commandName;
        [Syntax]$syntax = New-Syntax -CommandName $commandName -Signals $_signals -Krayon $_krayon;

        [PSCustomObject[]]$accidents = find-InAllParameterSetsByAccident -CommandInfo $commandInfo -Syntax $syntax;
        $accidents | Should -Not -BeNullOrEmpty;
        $accidents.Count | Should -Be 3;
      }
    }
  }
}
