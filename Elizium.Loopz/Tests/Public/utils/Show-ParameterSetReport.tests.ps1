
Describe 'Show-ParameterSetReport' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;
  }

  Context 'given: Invoke-Command' {
    It 'should: show duplicate parameter sets' -Skip {
      InModuleScope Elizium.Loopz {
        'Invoke-Command' | Show-ParameterSetReport
      }
    }
  }
}
