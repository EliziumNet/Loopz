
Describe 'Get-ParameterSetInfo' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;
  }

  Context 'given: Rename-Many command' {
    It 'should: get parameter set info' -Skip {
      'Rename-Many' | Get-ParameterSetInfo
    }
  }
}
