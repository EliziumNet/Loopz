
Describe 'Select-SignalContainer' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;

    [System.Collections.Hashtable]$script:signals = @{
      'GO'    = @('Go', '@@');
      'STOP'  = @('Stop', '!!');
      'ALERT' = @('Alert', '$$');
      'ERROR' = @('Error', '^^');
    }
  }

  BeforeEach {
    [System.Collections.Hashtable]$script:containers = @{
      Wide  = @();
      Props = @();
    }
  }

  Context 'given: Valid Signal Name' {
    It 'should: Select signal into Wide' {
      Select-SignalContainer -Containers $containers -Name 'GO' -Value 'getter' `
        -Signals $signals -Threshold 4;
      $containers.Wide.Count | Should -Be 1;
      $containers.Wide[0] | Should -BeExactly @('[@@] Go', 'getter');
    }

    Context 'and: Multiple Signals' {
      It 'should: Select all signals into Wide' {
        Select-SignalContainer -Containers $containers -Name 'GO' -Value 'getter' `
          -Signals $signals -Threshold 4;

        Select-SignalContainer -Containers $containers -Name 'STOP' -Value 'no soup for you' `
          -Signals $signals -Threshold 4;

        $containers.Wide.Count | Should -Be 2;
        $containers.Wide[0] | Should -BeExactly @('[@@] Go', 'getter');
        $containers.Wide[1] | Should -BeExactly @('[!!] Stop', 'no soup for you');
      }
    }

    Context 'and: Value less than wide threshold' {
      It 'should: Select signal into Props' {
        Select-SignalContainer -Containers $containers -Name 'GO' -Value 'getter' `
          -Signals $signals -Threshold 8;

        $containers.Props.Count | Should -Be 1;
        $containers.Props[0] | Should -BeExactly @('[@@] Go', 'getter');
      }
    }

    Context 'and: Multiple Wide and Props Signals' {
      It 'should: Select signals into Wide and Props' {
        Select-SignalContainer -Containers $containers -Name 'GO' -Value 'getter' `
          -Signals $signals -Threshold 4;

        Select-SignalContainer -Containers $containers -Name 'STOP' -Value 'no soup for you' `
          -Signals $signals -Threshold 4;

        Select-SignalContainer -Containers $containers -Name 'ALERT' -Value 'watch it' `
          -Signals $signals -Threshold 10;

        Select-SignalContainer -Containers $containers -Name 'ERROR' -Value 'computer says no' `
          -Signals $signals -Threshold 20;

        $containers.Wide.Count | Should -Be 2;
        $containers.Wide[0] | Should -BeExactly @('[@@] Go', 'getter');
        $containers.Wide[1] | Should -BeExactly @('[!!] Stop', 'no soup for you');

        $containers.Props.Count | Should -Be 2;
        $containers.Props[0] | Should -BeExactly @('[$$] Alert', 'watch it');
        $containers.Props[1] | Should -BeExactly @('[^^] Error', 'computer says no');
      }
    }
  }
}
