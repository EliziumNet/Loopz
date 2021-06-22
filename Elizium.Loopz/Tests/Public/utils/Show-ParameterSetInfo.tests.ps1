
Describe 'Show-ParameterSetInfo' -Tag 'PSTools' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;
  }

  Context 'given: Rename-Many command' {
    It 'should: get parameter set info' -Skip {
      'Rename-Many' | Show-ParameterSetInfo -Test;
    }
  }

  Context 'given: Sets filter' {
    It 'should: show only Parameter Sets in Sets' {
      'Rename-Many' | Show-ParameterSetInfo -Sets @('ReplaceWith', 'MoveToEnd') -Test;
    }
  }

  Context 'given: Command with no explicit parameter sets' {
    It 'should: show __AllParameterSets' {
      'Get-Signals' | Show-ParameterSetInfo -Test;
    }
  }

  Context 'given: Command with no parameters defined' {
    It 'should: show __AllParameterSets' {
      'Get-PlatformName' | Show-ParameterSetInfo -Test;
    }
  }

  Context 'given: function with no explicit parameter sets defined' {
    It 'should: NOT BARF' {
      'Format-Escape' | Show-ParameterSetInfo -Test;
    }
  }

  Context 'given: undefined parameter set' {
    It 'should: show nothing' {
      'Format-Escape' | Show-ParameterSetInfo -Sets 'barf' -Test;
    }
  }

  Context 'given: byName' {
    It 'should: Show parameter set info' {
      Show-ParameterSetInfo -Name 'Rename-Many' -Sets 'MoveToAnchor' -Test
    }
  }

  Context 'given: Command alias' {
    It 'should: should: Show parameter set info' {
      Show-ParameterSetInfo -Name 'remy' -Sets 'MoveToAnchor' -Test
    }
  }

  Context 'given: bad Command' {
    It 'should: Not Show parameter set info' {
      Show-ParameterSetInfo -Name 'blah' -Test -ErrorAction SilentlyContinue
    }
  }
}
