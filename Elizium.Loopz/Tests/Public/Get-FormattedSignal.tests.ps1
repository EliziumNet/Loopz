
Describe 'Get-FormattedSignal' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;

    [hashtable]$script:signals = @{
      'GO'   = @('Go', '@@');
      'STOP' = @('Stop', '!!');
    }
  }

  Context 'given: Valid Signal Name' {
    It 'should: Get Formatted Signal' {
      Get-FormattedSignal -Name 'GO' -Value 'getter' -Signals $signals | `
        Should -BeExactly @('[@@] Go', 'getter');
    }

    Context 'and: Custom Label' {
      It 'should: Get Formatted Signal' {
        Get-FormattedSignal -Name 'GO' -Value 'getter' -Signals $signals -CustomLabel 'Gone' | `
          Should -BeExactly @('[@@] Gone', 'getter');
      }
    }

    Context 'and: Format' {
      It 'should: Get Formatted Signal' {
        Get-FormattedSignal -Name 'GO' -Value 'getter' -Signals $signals -Format '{0} => [{1}]' | `
          Should -BeExactly @('Go => [@@]', 'getter');
      }
    }

    Context 'and: Value Not Specified' {
      It 'should: Get Formatted Signal' {
        Get-FormattedSignal -Name 'GO' -Signals $signals | `
          Should -BeExactly '[@@] Go';
      }
    }

    Context 'and: Emoji Only' {
      It 'should: Get un-labelled Formatted Signal' {
        Get-FormattedSignal -Name 'GO' -Value 'getter' -Signals $signals `
          -EmojiOnlyFormat '[{0}] ' -EmojiOnly | `
          Should -BeExactly @('[@@] ', 'getter');
      }
    }

    Context 'and: Emoji As Value' {
      It 'should: Get Formatted Signal With Emoji As Value' {
        Get-FormattedSignal -Name 'GO' -Signals $signals -EmojiAsValue -EmojiOnlyFormat '=({0})=' | `
          Should -BeExactly @('Go', '=(@@)=');
      }
    }
  }

  Context 'given: Missing Signal Name' {
    It 'should: Get the Missing Signal' {
      Mock -ModuleName Elizium.Loopz Resolve-ByPlatform { return @('Missing', '**') }
      Get-FormattedSignal -Name 'ABORT' -Value 'aborted' -Signals $signals | `
        Should -BeExactly @('[**] ??? (ABORT)', 'aborted');
    }
  }
}
