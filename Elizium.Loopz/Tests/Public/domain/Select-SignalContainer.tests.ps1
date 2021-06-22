using module Elizium.Krayola;
Describe 'Select-SignalContainer' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;

    [hashtable]$script:signals = @{
      'GO'    = $(kp(@('Go', '@@')));
      'STOP'  = $(kp(@('Stop', '!!')));
      'ALERT' = $(kp(@('Alert', '$$')));
      'ERROR' = $(kp(@('Error', '^^')));
    }
  }

  BeforeEach {
    [hashtable]$script:containers = @{
      Wide  = [line]::new();
      Props = [line]::new();
    }
  }

  Context 'given: Valid Signal Name' {
    It 'should: Select signal into Wide' {
      Select-SignalContainer -Containers $containers -Name 'GO' -Value 'getter' `
        -Signals $signals -Threshold 4;
      $containers.Wide.Line.Count | Should -Be 1;
      $containers.Wide.Line[0].cequal($(kp(@('[@@] Go', 'getter')))) | Should -BeTrue;
    }

    Context 'and: Multiple Signals' {
      It 'should: Select all signals into Wide' {
        Select-SignalContainer -Containers $containers -Name 'GO' -Value 'getter' `
          -Signals $signals -Threshold 4;

        Select-SignalContainer -Containers $containers -Name 'STOP' -Value 'no soup for you' `
          -Signals $signals -Threshold 4;

        $containers.Wide.Line.Count | Should -Be 2;
        $containers.Wide.Line[0].cequal($(kp(@('[@@] Go', 'getter')))) | Should -BeTrue;
        $containers.Wide.Line[1].cequal($(kp(@('[!!] Stop', 'no soup for you')))) | Should -BeTrue;
      }
    }

    Context 'and: Value less than wide threshold' {
      It 'should: Select signal into Props' {
        Select-SignalContainer -Containers $containers -Name 'GO' -Value 'getter' `
          -Signals $signals -Threshold 8;

        $containers.Props.Line.Count | Should -Be 1;
        $containers.Props.Line[0].cequal($(kp(@('[@@] Go', 'getter')))) | Should -BeTrue;
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

        $containers.Wide.Line.Count | Should -Be 2;
        $containers.Wide.Line[0].cequal($(kp(@('[@@] Go', 'getter')))) | Should -BeTrue;
        $containers.Wide.Line[1].cequal($(kp(@('[!!] Stop', 'no soup for you')))) | Should -BeTrue;

        $containers.Props.Line.Count | Should -Be 2;
        $containers.Props.Line[0].cequal($(kp(@('[$$] Alert', 'watch it')))) | Should -BeTrue;
        $containers.Props.Line[1].cequal($(kp(@('[^^] Error', 'computer says no')))) | Should -BeTrue;
      }
    }

    Context 'and: Force into Props' {
      It 'should: Ignore Threshold and Select signal into Props' {
        Select-SignalContainer -Containers $containers -Name 'GO' -Value 'getter' `
          -Signals $signals -Threshold 4 -Force 'Props';

        $containers.Wide.Line.Count | Should -Be 0;
        $containers.Props.Line.Count | Should -Be 1;
        $containers.Props.Line[0].cequal($(kp(@('[@@] Go', 'getter')))) | Should -BeTrue;
      }
    }
  }
}
