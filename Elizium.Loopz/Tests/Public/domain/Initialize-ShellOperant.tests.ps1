using module Elizium.Klassy

Describe 'initialize-ShellOperant' {
  # PROBLEMS: Mocking of 3rd part module (Get-EnvironmentVariable in Krayola)
  # is not working
  #
  BeforeAll {
    InModuleScope -ModuleName Elizium.Loopz {
      Mock -ModuleName Elizium.Loopz New-Item {
        Write-Host "!!! New-Item MOCKED.";
      }
      Get-Module Elizium.Loopz | Remove-Module -Force;;
      Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
        -ErrorAction 'stop' -DisableNameChecking -Force;
    }
  }

  Context 'given: LOOPZ_UNDO_RENAME_DISABLED is defined' {
    Context 'and: LOOPZ_UNDO_RENAME_DISABLED is true' {
      Context 'and: ELIZIUM_PATH is defined' {
        Context 'and: path is relative' {
          It 'should: return Undo Rename operant' -Skip {
            InModuleScope -ModuleName Elizium.Loopz {

            }

            Mock -ModuleName Elizium.Loopz Get-EnvironmentVariable {
              param(
                [Parameter()]
                [string]$Variable
              )
              Write-Debug "enter !!! Get-EnvironmentVariable MOCK!, Variable: '$Variable'"
              [string]$result = switch ($Variable) {
                'LOOPZ_UNDO_RENAME_DISABLED' { 'true' }
                'ELIZIUM_PATH' { "app$([System.IO.Path]::DirectorySeparatorChar)data" }
              }
              return $result;
            }

            [PSCustomObject]$options = [PSCustomObject]@{
              ShortCode    = 'remy';
              OperantName  = 'UndoRename';
              Shell        = 'PoShShell';
              BaseFilename = 'undo-rename';
              DisabledEnVar  = 'LOOPZ_UNDO_RENAME';
            }
            [string]$homePath = "$TestDrive$([System.IO.Path]::DirectorySeparatorChar)username";
            [UndoRename]$operant = initialize-ShellOperant -HomePath $homePath `
              -Options $options;

            $operant | Should -Not -BeNullOrEmpty;
          }
        }

        Context 'and: path is absolute' {

        }
      }

      Context 'and: ELIZIUM_PATH is NOT defined' {

      }
    }

    Context 'and: LOOPZ_UNDO_RENAME_DISABLED is false' {
      Context 'and: ELIZIUM_PATH is defined' {
        Context 'and: path is relative' {

        }

        Context 'and: path is absolute' {

        }
      }

      Context 'and: ELIZIUM_PATH is NOT defined' {

      }
    }

    Context 'and: LOOPZ_UNDO_RENAME_DISABLED is invalid' {
      Context 'and: ELIZIUM_PATH is defined' {
        Context 'and: path is relative' {

        }

        Context 'and: path is absolute' {

        }
      }

      Context 'and: ELIZIUM_PATH is NOT defined' {

      }
    }
  }

  Context 'given: LOOPZ_UNDO_RENAME_DISABLED is defined' {
    Context 'and: ELIZIUM_PATH is defined' {

    }

    Context 'and: ELIZIUM_PATH is NOT defined' {

    }
  }
}
