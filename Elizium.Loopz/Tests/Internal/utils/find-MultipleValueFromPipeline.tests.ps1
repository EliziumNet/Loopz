using namespace System.Management.Automation;

Describe 'find-MultipleValueFromPipeline' -Tag 'PSTools' {
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

  Context 'given: no multiple claims to pipeline item' {
    It 'should: report no violations' {
      InModuleScope Elizium.Loopz {
        function test-WithoutMultipleClaimsToPipelineValue {
          param(
            [parameter()]
            [object]$Chaff,

            [Parameter(ParameterSetName = 'Alpha', Mandatory, Position = 1, ValueFromPipeline = $true)]
            [object]$ClaimA,

            [Parameter(ParameterSetName = 'Beta', Position = 2)]
            [object]$ClaimB,

            [Parameter(ParameterSetName = 'Delta', Position = 3)]
            [object]$ClaimC
          )
        }

        [string]$commandName = 'test-WithoutMultipleClaimsToPipelineValue';
        [CommandInfo]$commandInfo = Get-Command $commandName;
        [Syntax]$syntax = New-Syntax -CommandName $commandName -Signals $_signals -Krayon $_krayon;

        [array]$multiples = find-MultipleValueFromPipeline -CommandInfo $commandInfo -Syntax $syntax;
        $multiples | Should -BeNullOrEmpty;
      }
    }
  }

  Context 'given: multiple claims to pipeline item' {
    It 'should: report violations'  {
      InModuleScope Elizium.Loopz {
        function test-MultipleClaimsToPipelineValue {
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

        [string]$commandName = 'test-MultipleClaimsToPipelineValue';
        [CommandInfo]$commandInfo = Get-Command $commandName;
        [Syntax]$syntax = New-Syntax -CommandName $commandName -Signals $_signals -Krayon $_krayon;

        [array]$multiples = find-MultipleValueFromPipeline -CommandInfo $commandInfo -Syntax $syntax;
        $multiples.Count | Should -Be 2;
      }
    }
  }
}
