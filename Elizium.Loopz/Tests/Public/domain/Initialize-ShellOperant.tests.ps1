using module '../../../Output/Elizium.Loopz/Elizium.Loopz.psd1';

Describe 'Initialize-ShellOperant' {
  # Ideally we'd use data driven test cases, but because we need to use TestDrive which is not accessible during
  # discovery time when the TestCase template parameters are populated, we can't. Instead we have to manually
  # define each test case and the problem is made worse by our need to mock out Get-EnvironmentVariable which
  # needs the full path including TestDrive. Due to these restrictions these tests are really awful.
  #
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force; ;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;

    [string]$script:_HomePath = $(Join-Path -Path $TestDrive -ChildPath 'username');
    [string]$script:_EliziumPath = $(Join-Path -Path $_HomePath -ChildPath 'elizium');

    function script:Invoke-CoreTest {
      [CmdletBinding()]
      param(
        [Parameter()]
        [string]$HomePath,

        [Parameter()]
        [string]$ShouldExist,

        [Parameter()]
        [string]$ExpectedOperantPath
      )

      [PSCustomObject]$options = [PSCustomObject]@{
        ShortCode     = 'remy';
        OperantName   = 'UndoRename';
        Shell         = 'PoShShell';
        BaseFilename  = 'undo-rename';
        DisabledEnVar = 'UNDO_DISABLED';
      }

      [object]$operant = Initialize-ShellOperant -HomePath $HomePath -Options $options;
      ($null -eq $operant) | Should -Not -Be $ShouldExist;

      [string]$directoryPath = [System.IO.Path]::GetDirectoryName($operant.Shell.FullPath);

      if ($PSBoundParameters.ContainsKey('ExpectedOperantPath') -and
        -not([string]::IsNullOrEmpty($ExpectedOperantPath))) {
        $ExpectedOperantPath | Should -Be $($directoryPath);
      }
    }
  }

  Context 'given: UNDO_DISABLED is defined' {
    Context 'and: UNDO_DISABLED is true' {
      BeforeAll {
        [boolean]$script:_disabled = $true;
      }

      Context 'and: ELIZIUM_PATH is defined' {
        It 'should: not create shell operant' {
          [string]$h = $_HomePath;

          Mock -ModuleName Elizium.Loopz Get-EnvironmentVariable {
            param(
              [Parameter()][string]$Variable
            )
            $result = switch ($Variable) {
              'UNDO_DISABLED' { $_disabled; break; }
              'ELIZIUM_PATH' { $_EliziumPath; break; }
              'HOME' { $h; break; }
            }
            return $result;
          }
          [hashtable]$parameters = @{
            'HomePath'    = $h;
            'ShouldExist' = -not($_disabled);
          }
          Invoke-CoreTest @parameters;
        }
      }
    } # and: UNDO_DISABLED is true

    Context 'and: UNDO_DISABLED is false' {
      BeforeAll {
        [boolean]$script:_disabled = $false;
      }

      Context 'and: ELIZIUM_PATH is defined' {
        Context 'and: path is relative' {
          It 'should: not create shell operant' {
            [string]$p = 'child-path';
            [string]$expectedPath = $(Join-Path -Path $_HomePath -ChildPath $p);

            Mock -ModuleName Elizium.Loopz Get-EnvironmentVariable {
              param(
                [Parameter()][string]$Variable
              )
              $result = switch ($Variable) {
                'UNDO_DISABLED' { $_disabled; break; }
                'ELIZIUM_PATH' { $p ; break; }
                'HOME' { $_HomePath; break; }
              }
              return $result;
            }
            [hashtable]$parameters = @{
              'HomePath'            = $_HomePath;
              'ShouldExist'         = -not($_disabled);
              'ExpectedOperantPath' = $expectedPath;
            }
            Invoke-CoreTest @parameters;
          }
        } # path is relative

        Context 'and: path is absolute' {
          It 'should: not create shell operant' {
            [string]$p = $(Join-Path -Path $TestDrive -ChildPath 'child-path');
            [string]$expectedPath = $p;

            Mock -ModuleName Elizium.Loopz Get-EnvironmentVariable {
              param(
                [Parameter()][string]$Variable
              )
              $result = switch ($Variable) {
                'UNDO_DISABLED' { $_disabled; break; }
                'ELIZIUM_PATH' { $p ; break; }
                'HOME' { $_HomePath; break; }
              }
              return $result;
            }
            [hashtable]$parameters = @{
              'HomePath'            = $_HomePath;
              'ShouldExist'         = -not($_disabled);
              'ExpectedOperantPath' = $expectedPath;
            }
            Invoke-CoreTest @parameters;
          } # not create shell operant
        } # path is absolute
      } # ELIZIUM_PATH is defined

      Context 'and: ELIZIUM_PATH is NOT defined' {
        It 'should: not create shell operant' {
          [string]$expectedPath = $(Join-Path -Path $_HomePath -ChildPath '.elizium');

          Mock -ModuleName Elizium.Loopz Get-EnvironmentVariable {
            param(
              [Parameter()][string]$Variable
            )
            $result = switch ($Variable) {
              'UNDO_DISABLED' { $_disabled; break; }
              'ELIZIUM_PATH' { $null ; break; }
              'HOME' { $_HomePath; break; }
            }
            return $result;
          }
          [hashtable]$parameters = @{
            'HomePath'            = $_HomePath;
            'ShouldExist'         = -not($_disabled);
            'ExpectedOperantPath' = $expectedPath;
          }
          Invoke-CoreTest @parameters;
        }
      }
    } # UNDO_DISABLED is false

    Context 'and: UNDO_DISABLED is invalid' {
      Context 'and: ELIZIUM_PATH is defined' {
        Context 'and: path is absolute' {
          It 'should: not create shell operant' {
            [string]$p = $(Join-Path -Path $TestDrive -ChildPath 'child-path');
            [string]$expectedPath = $p;

            Mock -ModuleName Elizium.Loopz Get-EnvironmentVariable {
              param(
                [Parameter()][string]$Variable
              )
              $result = switch ($Variable) {
                'UNDO_DISABLED' { 'Invalid-Value'; break; }
                'ELIZIUM_PATH' { $p ; break; }
                'HOME' { $_HomePath; break; }
              }
              return $result;
            }
            [hashtable]$parameters = @{
              'HomePath'            = $_HomePath;
              'ShouldExist'         = -not($_disabled);
              'ExpectedOperantPath' = $expectedPath;
            }
            Invoke-CoreTest @parameters;
          } # not create shell operant
        } # path is absolute
      } # ELIZIUM_PATH is defined
    } # UNDO_DISABLED is invalid
  } # UNDO_DISABLED is defined
} # Initialize-ShellOperant
