Describe 'Use-EliziumPath' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;

    [string]$script:HomePath = $(Join-Path -Path $TestDrive -ChildPath 'home');
    [string]$script:EliziumPath = $(Join-Path -Path $HomePath -ChildPath '.elizium');
    [string]$script:AltPath = $(Join-Path -Path $TestDrive -ChildPath 'alt' -AdditionalChildPath 'elizium');
  }

  BeforeEach {
    $null = New-Item -ItemType Directory -Path $HomePath;
  }

  Context 'given: ELIZIUM_PATH is defined' {
    BeforeEach {
      Mock -ModuleName Elizium.Loopz Get-EnvironmentVariable {
        param(
          [string]$Variable,
          [string]$Default
        )
        $result = switch ($Variable) {
          'ELIZIUM_PATH' {
            $AltPath
            break;
          }

          'HOME' {
            $HomePath
            break;
          }

          default {
            throw "bad test, unexpected Variable: '$Variable'"
          }
        }

        return $result;
      }
    }

    Context 'and: ELIZIUM_PATH location does not exist' {
      It 'should: ELIZIUM_PATH location should exist' {
        [string]$usePath = Use-EliziumPath;

        $usePath | Should -Be $AltPath;
        Test-Path -Path $AltPath | Should -BeTrue;
      }
    }

    Context 'and: ELIZIUM_PATH location already exists' {
      It 'should: ELIZIUM_PATH location should exist' {
        [string]$usePath = Use-EliziumPath;

        $usePath | Should -Be $AltPath;
        Test-Path -Path $AltPath -PathType Container | Should -BeTrue;
      }
    }
  }

  Context 'given: ELIZIUM_PATH is NOT defined' {
    BeforeEach {
      Mock -ModuleName Elizium.Loopz Get-EnvironmentVariable {
        param(
          [string]$Variable,
          [string]$Default
        )

        $result = switch ($Variable) {
          'ELIZIUM_PATH' {
            $null;
            break;
          }

          'HOME' {
            $HomePath
            break;
          }

          default {
            throw "bad test, unexpected Variable: '$Variable'"
          }
        }

        return $result;
      }
    }

    It 'should: create home path' {
      [string]$usePath = Use-EliziumPath;

      $usePath | Should -Be $EliziumPath;
      Test-Path -Path $usePath -PathType Container | Should -BeTrue;
    }
  }
}
