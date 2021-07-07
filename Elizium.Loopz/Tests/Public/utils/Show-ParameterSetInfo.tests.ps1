using module Elizium.Krayola;

Describe 'Show-ParameterSetInfo' -Tag 'PSTools' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;
  }

  Context 'given: Invoke-Command command' {
    It 'should: get parameter set info' {
      'Invoke-Command' | Show-ParameterSetInfo -Test;
    }
  }

  Context 'given: Sets filter' {
    It 'should: show only Parameter Sets in Sets' {
      'Invoke-Command' | Show-ParameterSetInfo -Sets @('InProcess', 'Session') -Test;
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
      'Invoke-MirrorDirectoryTree' | Show-ParameterSetInfo -Test;
    }
  }

  Context 'given: undefined parameter set' {
    It 'should: show nothing' {
      'Invoke-MirrorDirectoryTree' | Show-ParameterSetInfo -Sets 'barf' -Test;
    }
  }

  Context 'given: byName' {
    It 'should: Show parameter set info' {
      Show-ParameterSetInfo -Name 'Invoke-MirrorDirectoryTree' -Sets 'InProcess' -Test;
    }
  }

  Context 'given: Command alias' {
    It 'should: should: Show parameter set info' {
      Show-ParameterSetInfo -Name 'Mirror-Directory' -Sets 'InvokeFunction' -Test;
    }
  }

  Context 'given: bad Command' {
    It 'should: Not Show parameter set info' {
      Show-ParameterSetInfo -Name 'blah' -Test -ErrorAction SilentlyContinue
    }
  }

  Context 'given: external Scribbler' {
    BeforeEach {
      [Scribbler]$script:_scribbler = New-Scribbler -Test;
    }

    Context 'and: byName' {
      It 'should: show command name' {
        Show-ParameterSetInfo -Name 'Invoke-MirrorDirectoryTree' -Sets @('InvokeFunction') -Test -Scribbler $_scribbler;

        [string]$contents = $_scribbler.Builder.ToString();
        $contents | Should -Match "Command: [^*]+Invoke-MirrorDirectoryTree[^*]+ Showed 1 of 2 parameter set\(s\).";

        $_scribbler.Flush();
      }
    }
  }
}
