
Describe 'Test-Intersect' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;
  }

  Context 'given: Identical Collections' {
    It 'should: return true' {
      Test-Intersect @('A', 'B', 'C') @('A', 'B', 'C') | Should -BeTrue;
    }
  }

  Context 'given: Collections with single common element' {
    It 'should: return true' {
      Test-Intersect @('A', 'B', 'C', 'D') @('X', 'Y', 'Z', 'D') | Should -BeTrue;
    }
  }

  Context 'given: Collections with multiple common elements' {
    It 'should: return true' {
      Test-Intersect @('A', 'B', 'C', 'D', 'E') @('X', 'Y', 'Z', 'D', 'E') | Should -BeTrue;
    }
  }

  Context 'given: Two empty collections' {
    It 'should: throw' {
      {
        Test-Intersect @() @() | Should -BeFalse;
      } | Should -Throw;
    }
  }
}
