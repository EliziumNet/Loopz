using namespace System.Management.Automation;
Describe 'find-InAllParameterSetsByAccident' -Tag 'PSTools' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;
  }

  BeforeEach {
    InModuleScope Elizium.Loopz {
      [Krayon]$script:_krayon = Get-Krayon;
      [hashtable]$script:_signals = Get-Signals;
      [Scribbler]$script:_scribbler = New-Scribbler -Krayon $_krayon -Test;
    }
  }

  Context 'given: invoke-command' {
    It 'should: not report any accidental parameters' {
      InModuleScope Elizium.Loopz {
        [string]$commandName = 'Invoke-Command';
        [CommandInfo]$commandInfo = Get-Command $commandName;
        [Syntax]$syntax = New-Syntax -CommandName $commandName -Signals $_signals `
          -Scribbler $_scribbler;

        [PSCustomObject[]]$accidents = find-InAllParameterSetsByAccident -CommandInfo $commandInfo `
          -Syntax $syntax;
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
        [Syntax]$syntax = New-Syntax -CommandName $commandName -Signals $_signals `
          -Scribbler $_scribbler;

        [PSCustomObject[]]$accidents = find-InAllParameterSetsByAccident -CommandInfo $commandInfo `
          -Syntax $syntax;
        $accidents | Should -Not -BeNullOrEmpty;
        $accidents.Count | Should -Be 4;
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
<#
  $ gcm test-MultipleInAllParameterSetsByAccident | sharp
  =========================================================================================================================
  >>>>> SUMMARY:  Found the following 18 violations:
    🔶 'Non Unique Parameter Set', Count: 6
        🟨 Reasons: 
          💠 {Alpha/Beta}
          💠 {Alpha/Delta}
          💠 {Alpha/Ok}
          💠 {Beta/Delta}
          💠 {Beta/Ok}
          💠 {Delta/Ok}
    🔶 'In All Parameter Sets By Accident', Count: 12
        🟨 Reasons: 
          💠 { parameter 'AccidentalA' of parameter set Ok
          💠 { parameter 'AccidentalB' of parameter set Ok
          💠 { parameter 'AccidentalC' of parameter set Ok
          💠 { parameter 'AccidentalA' of parameter set Alpha
          💠 { parameter 'AccidentalB' of parameter set Alpha
          💠 { parameter 'AccidentalC' of parameter set Alpha
          💠 { parameter 'AccidentalA' of parameter set Beta
          💠 { parameter 'AccidentalB' of parameter set Beta
          💠 { parameter 'AccidentalC' of parameter set Beta
          💠 { parameter 'AccidentalA' of parameter set Delta
          💠 { parameter 'AccidentalB' of parameter set Delta
          💠 { parameter 'AccidentalC' of parameter set Delta
  =========================================================================================================================
#>
        [string]$commandName = 'test-MultipleInAllParameterSetsByAccident';
        [CommandInfo]$commandInfo = Get-Command $commandName;
        [Syntax]$syntax = New-Syntax -CommandName $commandName -Signals $_signals `
          -Scribbler $_scribbler;

        [PSCustomObject[]]$accidents = find-InAllParameterSetsByAccident -CommandInfo $commandInfo `
          -Syntax $syntax;
        $accidents | Should -Not -BeNullOrEmpty;
        $accidents.Count | Should -Be 12;
      }
    }
  }
}
