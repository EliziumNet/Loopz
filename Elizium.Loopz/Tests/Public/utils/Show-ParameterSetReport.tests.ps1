
Describe 'Show-ParameterSetReport' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;
  }

  Context 'given: test-WithDuplicatePs' {
    It 'should: show duplicate parameter sets' {
      InModuleScope Elizium.Loopz {
        'test-WithDuplicatePs' | Show-ParameterSetReport
      }
    }
  }
}
