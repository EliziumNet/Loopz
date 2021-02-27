using namespace System.Management.Automation;

Describe 'test-IsParameterUnique' -Tag 'PSTools', 'Current' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;
  }

  Context 'given: command with multiple parameter sets' {
    BeforeAll {
      InModuleScope Elizium.Loopz {
        function script:test-UniqueParams {
          param(
            [object]$Wheat,

            [Parameter()]
            [object]$Chaff,

            [Parameter(ParameterSetName = 'Alpha')]
            [object]$UniqueA,

            [Parameter(ParameterSetName = 'Bravo')]
            [object]$uniqueB,

            [Parameter(ParameterSetName = 'Charlie')]
            [object]$UniqueC,

            [Parameter(ParameterSetName = 'Delta')]
            [Parameter(ParameterSetName = 'Foxtrot')]
            [object]$CommonD,

            [Parameter(ParameterSetName = 'Delta')]
            [Parameter(ParameterSetName = 'Echo')]
            [object]$CommonE,

            [Parameter(ParameterSetName = 'Foxtrot')]
            [object]$CommonF
          )
        }
        [CommandInfo]$script:_commandInfo = Get-Command 'test-UniqueParams';
      }
    }

    Context 'and: parameter defined without Parameter attribute' {
      It 'should: return false' {
        InModuleScope Elizium.Loopz {
          test-IsParameterUnique -Name 'Wheat' -CommandInfo $_commandInfo | `
            Should -BeFalse;
        }
      }
    }

    Context 'and: parameter with Parameter attribute & without Parameter Set' {
      It 'should: return false' {
        InModuleScope Elizium.Loopz {
          test-IsParameterUnique -Name 'Chaff' -CommandInfo $_commandInfo | `
            Should -BeFalse;
        }
      }
    }

    Context 'and: parameter defined in single Parameter Set' {
      It 'should: return true' {
        InModuleScope Elizium.Loopz {
          test-IsParameterUnique -Name 'UniqueA' -CommandInfo $_commandInfo | `
            Should -BeTrue;
        }
      }
    }

    Context 'and: parameter defined in multiple ParameterSets' {
      It 'should: return false' {
        InModuleScope Elizium.Loopz {
          test-IsParameterUnique -Name 'CommonD' -CommandInfo $_commandInfo | `
            Should -BeFalse;
        }
      }
    }
  } # given: command with multiple parameter sets

  Context 'given: command with no parameter sets' {
    BeforeAll {
      InModuleScope Elizium.Loopz {
        function script:test-NoParamSets {
          param(
            [parameter()]
            [object]$Wheat,

            [parameter()]
            [object]$Chaff
          )
        }
        [CommandInfo]$script:_ci = Get-Command 'test-NoParamSets';
      }
    }

    Context 'and: parameter defined without Parameter attribute' {
      It 'should: return false' {
        InModuleScope Elizium.Loopz {
          test-IsParameterUnique -Name 'Wheat' -CommandInfo $_ci | `
            Should -BeFalse;
        }
      }
    }

    Context 'and: parameter with Parameter attribute & without Parameter Set' {
      It 'should: return false' {
        InModuleScope Elizium.Loopz {
          test-IsParameterUnique -Name 'Chaff' -CommandInfo $_ci | `
            Should -BeFalse;
        }
      }
    }
  } # given: command with no parameter sets

  Context 'given: a parameter name that does not exist' {
    # ....
  } 
}
