
Describe 'Show-ParameterSetInfo' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;
  }

  Context 'given: Rename-Many command' {
    It 'should: get parameter set info' -Skip {
      'Rename-Many' | Show-ParameterSetInfo;
    }
  }

  Context 'given: Sets filter' {
    It 'should: show only Parameter Sets in Sets' {
      'Rename-Many' | Show-ParameterSetInfo -Sets @('ReplaceWith', 'MoveToEnd');
    }
  }

  Context 'given: Command with no explicit parameter sets' {
    It 'should: show __AllParameterSets' {
      'Get-Signals' | Show-ParameterSetInfo;
    }
  }

  Context 'given: Command with no parameters defined' {
    It 'should: show __AllParameterSets' {
      'Get-PlatformName' | Show-ParameterSetInfo;
    }
  }

  Context 'given: function with no explicit parameter sets defined' {
    It 'should: NOT BARF' {
      'Format-Escape' | Show-ParameterSetInfo;
    }
  }

  Context 'given: undefined parameter set' {
    It 'should: show nothing' {
      'Format-Escape' | Show-ParameterSetInfo -Sets 'barf';
    }
  }
}
