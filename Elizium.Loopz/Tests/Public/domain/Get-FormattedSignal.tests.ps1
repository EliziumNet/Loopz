using module Elizium.Krayola;

Describe 'Get-FormattedSignal' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;

    [hashtable]$script:signals = @{
      'GO'   = (kp(@('Go', '@@')));
      'STOP' = (kp(@('Stop', '!!')));
    }
  }

  Context 'given: Valid Signal Name' {
    It 'should: Get Formatted Signal' {
      [couplet]$formattedSignal = Get-FormattedSignal -Name 'GO' -Value 'getter' `
        -Signals $signals;
      $formattedSignal.cequal($(kp(@('[@@] Go', 'getter')))) | Should -BeTrue;
    }

    Context 'and: Custom Label' {
      It 'should: Get Formatted Signal' {
        [couplet]$formattedSignal = Get-FormattedSignal -Name 'GO' -Value 'getter' `
          -Signals $signals -CustomLabel 'Gone';
        $formattedSignal.cequal($(kp(@('[@@] Gone', 'getter')))) | Should -BeTrue;
      }
    }

    Context 'and: Format' {
      It 'should: Get Formatted Signal' {
        [couplet]$formattedSignal = Get-FormattedSignal -Name 'GO' -Value 'getter' `
          -Signals $signals -Format '{0} => [{1}]'
        $formattedSignal.cequal($(kp(@('Go => [@@]', 'getter')))) | Should -BeTrue;
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
        [couplet]$formattedSignal = Get-FormattedSignal -Name 'GO' -Value 'getter' `
          -Signals $signals -EmojiOnlyFormat '[{0}] ' -EmojiOnly;
        $formattedSignal.cequal($(kp(@('[@@] ', 'getter')))) | Should -BeTrue;
      }
    }

    Context 'and: Emoji As Value' {
      It 'should: Get Formatted Signal With Emoji As Value' {
        [couplet]$formattedSignal = Get-FormattedSignal -Name 'GO' `
          -Signals $signals -EmojiAsValue -EmojiOnlyFormat '=({0})=';
        $formattedSignal.cequal($(kp(@('Go', '=(@@)=')))) | Should -BeTrue;
      }
    }
  }

  Context 'given: Missing Signal Name' {
    It 'should: Get the Missing Signal' {
      Mock -ModuleName Elizium.Loopz Resolve-ByPlatform { return $(kp(@('Missing', '**'))) }
      [couplet]$formattedSignal = Get-FormattedSignal -Name 'ABORT' -Value 'aborted' `
        -Signals $signals;
      $formattedSignal.cequal($(kp(@('[**] ??? (ABORT)', 'aborted')))) | Should -BeTrue;
    }
  }
}
