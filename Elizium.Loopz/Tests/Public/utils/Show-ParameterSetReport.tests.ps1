
Describe 'Show-ParameterSetReport' -Tag 'Current' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;

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
          [object]$DuplicatePosC,

          [Parameter(ParameterSetName = 'SamePos', Mandatory, Position = 111)]
          [object]$SameA,

          [Parameter(ParameterSetName = 'SamePos', Position = 111)]
          [object]$SameB
        )
      }

      function script:test-WithMultipleRuleViolations {
        param(
          [Parameter()]
          [object]$Chaff,

          [Parameter(ParameterSetName = 'Alpha', Mandatory, Position = 1, ValueFromPipeline = $true)]
          [Parameter(ParameterSetName = 'Beta', Mandatory, Position = 11)]
          [object]$DuplicatePosA,

          [Parameter(ParameterSetName = 'Alpha', Position = 2, ValueFromPipeline = $true)]
          [Parameter(ParameterSetName = 'Beta', Position = 12)]
          [Parameter(ParameterSetName = 'Delta', Position = 21)]
          [object]$DuplicatePosB,

          [Parameter(ParameterSetName = 'Alpha', Position = 3)]
          [Parameter(ParameterSetName = 'Beta', Position = 13)]
          [Parameter(ParameterSetName = 'Delta', Position = 22)]
          [object]$DuplicatePosC
        )
      }

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

  Context 'given: Invoke-Command' {
    It 'should: not report any violations' {
      'Invoke-Command' | Show-ParameterSetReport;
    }
  }

  Context 'given: a command containing a Param Set with duplicated position numbers' {
    It 'should: report UNIQUE-POSITIONS violation' {
      InModuleScope Elizium.Loopz {
        'test-MultipleSetsWithDuplicatedPositions' | Show-ParameterSetReport;
      }
    }
  }

  Context 'given: a command containing a duplicated Param Sets' {
    It 'should: report UNIQUE-PARAM-SET violation' {
      InModuleScope Elizium.Loopz {
        'test-WithDuplicateParamSets' | Show-ParameterSetReport;
      }
    }
  }

  Context 'given: a command containing a duplicated Param Sets' {
    It 'should: report SINGLE-PIPELINE-PARAM violation' {
      InModuleScope Elizium.Loopz {
        'test-MultipleClaimsToPipelineValue' | Show-ParameterSetReport;
      }
    }
  }

  Context 'given: a command with multiple rule violations' {
    It 'should: report all violation types' {
      InModuleScope Elizium.Loopz {
        'test-WithMultipleRuleViolations' | Show-ParameterSetReport;
      }
    }
  }
}
