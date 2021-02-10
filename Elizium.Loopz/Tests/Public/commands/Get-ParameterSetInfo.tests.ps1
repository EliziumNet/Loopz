
Describe 'Get-ParameterSetInfo' -Tag 'Current' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;
  }

  Context 'given: Rename-Many command' {
    It 'should: get parameter set info' -Skip {
      'Rename-Many' | Get-ParameterSetInfo;
    }
  }

  Context 'given: Sets filter' {
    It 'should: show only Parameter Sets in Sets' {
      'Rename-Many' | Get-ParameterSetInfo -Sets @('ReplaceWith', 'MoveToEnd');
    }
  }

  Context 'given: Command with no explicit parameter sets' {
    It 'should: show __AllParameterSets' {
      'Get-Signals' | Get-ParameterSetInfo;
    }
  }

  Context 'given: Command with no parameters defined' {
    It 'should: show __AllParameterSets' -Tag 'Current' {
      'Get-PlatformName' | Get-ParameterSetInfo;
    }
  }

  Context 'given: function with no explicit parameter sets defined' {
    It 'should: NOT BARF' {
      'Format-Escape' | Get-ParameterSetInfo;
    }
  }

  Context 'given: undefined parameter set' {
    It 'should: show nothing' {
      'Format-Escape' | Get-ParameterSetInfo -Sets 'barf';
    }
  }
}
