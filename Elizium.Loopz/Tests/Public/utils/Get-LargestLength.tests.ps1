
Describe 'Get-LargestLength' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;
  }

  Context 'given: empty array' {
    It 'should: return 0' {
      Get-LargestLength @() | Should -Be 0;
    }
  }

  Context 'given: single string item array' {
    It 'should: return 1' {
      Get-LargestLength @('greetings') | Should -Be 9;
    }
  }

  Context 'given: multi-item string array' {
    It 'should: return largest length' {
      Get-LargestLength @('who', 'watches', 'the', 'watchers') | Should -Be 8;
    }
  }

  Context 'given: multi-item string array with empty strings' {
    It 'should: return 0' {
      Get-LargestLength @('', '', '', '') | Should -Be 0;
    }
  }
}
