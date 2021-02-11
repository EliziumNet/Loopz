using module Elizium.Krayola;
using namespace System.Management.Automation;

Describe 'test-AreParamSetsEqual' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;
  }

  BeforeEach {
    InModuleScope Elizium.Loopz {
      [string]$script:_commandName = 'Rename-Many';
      [Krayon]$krayon = Get-Krayon;
      [hashtable]$theme = $krayon.Theme;
      [hashtable]$signals = Get-Signals;
      [Syntax]$script:_syntax = [Syntax]::new($_commandName, $theme, $signals, $krayon);

      [CommandInfo]$commandInfo = Get-Command $_commandName;
      [CommandParameterSetInfo]$script:_appendPsi = $commandInfo.ParameterSets | Where-Object Name -eq 'Append';
      [CommandParameterSetInfo]$script:_prependPsi = $commandInfo.ParameterSets | Where-Object Name -eq 'Prepend';
    }
  }

  Context 'given: parameter sets which are different' {
    It 'should: return false' {
      InModuleScope Elizium.Loopz {
        test-AreParamSetsEqual -FirstPsInfo $_prependPsi -SecondPsInfo $_appendPsi `
          -Syntax $_syntax | Should -BeFalse;
      }
    }
  }

  Context 'given: parameter sets which are the same' {
    It 'should: return true' {
      InModuleScope Elizium.Loopz {
        test-AreParamSetsEqual -FirstPsInfo $_prependPsi -SecondPsInfo $_prependPsi `
          -Syntax $_syntax | Should -BeTrue;
      }
    }
  }
} # test-AreParamSetsEqual
