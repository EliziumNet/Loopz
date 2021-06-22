
Describe 'Test-ContainsAll' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;
  }

  Context 'given: set is subset' {
    It 'should: return true' {
      Test-ContainsAll @('A', 'B', 'C') @('A', 'B') | Should -BeTrue;
    }
  }

  Context 'given: set is NOT subset' {
    It 'should: return true' {
      Test-ContainsAll @('A', 'B', 'C') @('A', 'X') | Should -BeFalse;
    }
  }
}
