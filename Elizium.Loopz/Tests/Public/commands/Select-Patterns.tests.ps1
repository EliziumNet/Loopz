
Describe 'Select-Patterns' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;
  }

  Context 'given: multiple patterns' {
    It 'should: perform multiple searches chained together' {
      Select-Patterns -Patterns 'a', 'b', 'c' -Filter '*.txt' -Test;
    }
  }
}
