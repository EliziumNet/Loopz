Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1
Describe 'New-ShellOperant' -Tag 'Current' {
  BeforeAll {
    InModuleScope -ModuleName Elizium.Loopz {
      Get-Module Elizium.Loopz | Remove-Module -Force; ;
      Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
        -ErrorAction 'stop' -DisableNameChecking -Force;
    }
  }

  Context 'given: default date format' {
    BeforeEach {
      InModuleScope Elizium.Loopz {
        Mock -ModuleName Elizium.Loopz get-CurrentTime {
          return '2021-01-04_10-28-34';
        }
      }
    }

    Context 'given: invoked with defaults' {
      It 'should: return UndoRename instance' {
        InModuleScope Elizium.Loopz {
          [UndoRename]$operant = New-ShellOperant -BaseFilename 'undo-rename' `
            -Directory $TestDrive;

          $operant | Should -Not -BeNullOrEmpty;
          $operant.GetType() | Should -Be UndoRename;

          [string]$fullPath = $operant.Shell.FullPath;
          $fullPath | Should -Match '2021-01-04';
        }
      }
    }

    Context 'given: invoked explicitly with UndoRename and PoShShell' {
      It 'should: return UndoRename instance' {
        InModuleScope Elizium.Loopz {
          [UndoRename]$operant = New-ShellOperant -BaseFilename 'undo-rename' `
            -Directory $TestDrive -Operant 'UndoRename' -Shell 'PoShShell';

          $operant | Should -Not -BeNullOrEmpty;
          $operant.GetType() | Should -Be UndoRename;

          [string]$fullPath = $operant.Shell.FullPath;
          $fullPath | Should -Match '2021-01-04';
        }
      }
    }
  } # default date format

  Context 'given: custom date format' {
    BeforeEach {
      InModuleScope Elizium.Loopz {
        Mock -ModuleName Elizium.Loopz get-CurrentTime {
          param(
            [string]$Format
          )
          return [DateTime]::new(2021, 1, 4, 10, 28, 34).ToString($Format);
        }
      }
    }

    Context 'given: invoked with custom date format' {
      It 'should: return UndoRename instance with customised date' {
        InModuleScope Elizium.Loopz {
          [UndoRename]$operant = New-ShellOperant -BaseFilename 'undo-rename' `
            -Directory $TestDrive -DateTimeFormat 'dd-MMM-yyyy_HH-mm-ss';

          $operant | Should -Not -BeNullOrEmpty;
          $operant.GetType() | Should -Be UndoRename;

          [string]$fullPath = $operant.Shell.FullPath;
          $fullPath | Should -Match '04-jan-2021';
        }
      }
    }
  }
}
