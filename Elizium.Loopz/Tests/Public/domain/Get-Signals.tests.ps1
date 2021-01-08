
Describe 'Get-Signals' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;

    [hashtable]$script:signals = @{
      'GO'   = (kp(@('Go', '@@')));
      'STOP' = (kp(@('Stop', '!!')));
    }
  }

  Context 'given: Custom Overrides' {
    It 'should: return signals with overrides' {
      [hashtable]$script:custom = @{
        'GO'   = (kp(@('Going', '!!')));
      }
      [hashtable]$customSignals = Get-Signals -SourceSignals $signals -Custom $custom;
      $customSignals['GO'].Key | Should -BeExactly 'Going';
      $customSignals['GO'].Value | Should -BeExactly '!!';
    }

    It 'should: return signals with overrides' {
      [hashtable]$script:custom = @{
        'GO' = (kp(@('Going', '!!')));
      }
      [hashtable]$customSignals = Get-Signals -Custom $custom;
      $customSignals['GO'].Key | Should -BeExactly 'Going';
      $customSignals['GO'].Value | Should -BeExactly '!!';
    }

    It 'should: return signals with overrides' {
      [hashtable]$script:custom = @{
        'IMAGE' = (kp(@('Picture', '@@')));
      }
      [hashtable]$customSignals = Get-Signals -Custom $custom;
      $customSignals['IMAGE'].Key | Should -BeExactly 'Picture';
      $customSignals['IMAGE'].Value | Should -BeExactly '@@';
    }
  }
}
