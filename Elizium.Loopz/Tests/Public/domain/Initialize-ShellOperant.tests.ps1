
Describe 'Initialize-ShellOperant' -Tag 'Flaky' {
  BeforeAll {
    InModuleScope -ModuleName Elizium.Loopz {
      Get-Module Elizium.Loopz | Remove-Module -Force; ;
      Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
        -ErrorAction 'stop' -DisableNameChecking -Force;
    }
  }

  BeforeEach {
    [string]$global:_HomePath = $(Join-Path -Path $TestDrive -ChildPath 'username');
    [string]$global:_EliziumPath = $(Join-Path -Path $_HomePath -ChildPath 'elizium');
  }

  Context 'given: <UndoRenameDisabled>, <EliziumPath>' {
    It 'should: ' -TestCases @(
      @{ UndoRenameDisabled = $true; EliziumPath = 'not-applicable' }
      , @{ UndoRenameDisabled = $false; EliziumPath = $(Join-Path -Path 'app' -ChildPath 'data'); }
      , @{ UndoRenameDisabled = $false; EliziumPath = $($TestDrive); }
    ) {
      [hashtable]$parameters = @{
        UndoRenameDisabled = $UndoRenameDisabled;
        EliziumPath        = $EliziumPath;
        HomePath           = $_HomePath;
      };
      # Write-Host "??? EliziumPath: '$EliziumPath'"
      # Write-Host "??? TestDrive: '$TestDrive'"

      # Need to artificially run inside module scope so we can access template
      # parameters.
      #
      InModuleScope -ModuleName Elizium.Loopz -Parameters $parameters {

        Mock -ModuleName Elizium.Loopz Get-EnvironmentVariable {
          param(
            [Parameter()]
            [string]$Variable
          )
          $result = switch ($Variable) {
            'LOOPZ_UNDO_RENAME' {
              $UndoRenameDisabled;
              break;
            }

            'ELIZIUM_PATH' {
              $EliziumPath;
              break;
            }

            'HOME' {
              $HomePath;
              break;
            }
          }

          Write-Debug "enter !!! Get-EnvironmentVariable MOCK!, Variable: '$Variable', Result: '$($result)'";
          return $result;
        }

        # Write-Host ">>> EliziumPath: '$EliziumPath'"
        # Write-Host ">>> _EliziumPath: '$_EliziumPath'"

        [PSCustomObject]$options = [PSCustomObject]@{
          ShortCode     = 'remy';
          OperantName   = 'UndoRename';
          Shell         = 'PoShShell';
          BaseFilename  = 'undo-rename';
          DisabledEnVar = 'LOOPZ_UNDO_RENAME';
        }
        # [UndoRename]
        [object]$operant = Initialize-ShellOperant -HomePath $(Join-Path -Path $TestDrive -ChildPath 'username') `
          -Options $options;

        ($null -eq $operant) | Should -Be $UndoRenameDisabled;
      }
    }
  }

  Context 'given: LOOPZ_UNDO_RENAME_DISABLED is defined' -Skip {
    Context 'and: LOOPZ_UNDO_RENAME_DISABLED is true' {
      Context 'and: ELIZIUM_PATH is defined' {
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
