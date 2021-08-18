using namespace Elizium.Loopz;

# Warning about Mocks and classes. MUST re-created the session in-between runs
# See: https://pester.dev/docs/usage/mocking
#
Describe 'DatedFile' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;

    InModuleScope -ModuleName Elizium.Loopz {
      [string]$script:_EliziumPath = $(Join-Path -Path $TestDrive -ChildPath 'elizium');
      [DateTime]$script:_Now = [DateTime]::new(2021, 2, 24, 15, 30, 45);
      [DateTime]$script:_Legacy = [DateTime]::new(2020, 3, 18, 21, 15, 08);

      . .\Tests\Helpers\deploy-file.ps1
    }
  }

  BeforeEach {
    InModuleScope -ModuleName Elizium.Loopz {
      Mock -ModuleName Elizium.Loopz Get-EnvironmentVariable {
        return $_EliziumPath;
      }
    }
  }

  Describe 'TryTouch' {
    Context 'given: file does not exist' {
      Context 'and: create is $true' {
        It 'should: create file and return Exists = $true' {
          InModuleScope Elizium.Loopz {
            [string]$childPath = 'solar-system';
            [string]$fileName = 'mercury.txt';

            [DatedFile]$file = [DatedFile]::new($childPath, $fileName, $_Now);
            [PSCustomObject]$result = $file.TryTouch($true);
            $result.Found | Should -BeTrue;
          }
        }
      }

      Context 'and: create is $false' {
        It 'should: return Exists = $false' {
          InModuleScope Elizium.Loopz {
            [string]$childPath = 'solar-system';
            [string]$fileName = 'venus.txt';

            [DatedFile]$file = [DatedFile]::new($childPath, $fileName, $_Now);
            [PSCustomObject]$result = $file.TryTouch($false);
            $result.Found | Should -BeFalse;
          }
        }
      }
    } # file does not exist

    Context 'given: file does exist' {
      It 'should: update the last write time' {
        InModuleScope Elizium.Loopz {
          [string]$childPath = 'solar-system';
          [string]$fileName = 'earth.txt';
          $null = deploy-file -BasePath $_EliziumPath -ChildPath $childPath `
            -FileName $fileName -Content 'earth' -AsOf $_Legacy;
          
          [DatedFile]$file = [DatedFile]::new($childPath, $fileName, $_Now);
          [PSCustomObject]$result = $file.TryTouch($false);
          $result.Found | Should -BeTrue;
          $result.LastWriteTime -gt $_Legacy | Should -BeTrue;
        }
      }
    } # file does exist
  } # TryTouch

  Describe 'Exists' {
    Context 'given: file does not exist' {
      It 'should: return $false' {
        InModuleScope Elizium.Loopz {
          [string]$childPath = 'solar-system';
          [string]$fileName = 'mars.txt';

          [DatedFile]$file = [DatedFile]::new($childPath, $fileName, $_Now);
          $file.Exists() | Should -BeFalse;
        }
      }
    }

    Context 'given: file does exist' {
      It 'should: return $true' {
        InModuleScope Elizium.Loopz {
          [string]$childPath = 'solar-system';
          [string]$fileName = 'jupiter.txt';
          $null = deploy-file -BasePath $_EliziumPath -ChildPath $childPath `
            -FileName $fileName -Content 'jupiter' -AsOf $_Legacy;

          [DatedFile]$file = [DatedFile]::new($childPath, $fileName, $_Now);
          $file.Exists() | Should -BeTrue;
        }
      }
    }
  } # Exists

  Describe 'TryGetLastWriteTime' {
    Context 'given: file does not exist' {
      It 'should: return Found = $false' {
        InModuleScope Elizium.Loopz {
          [string]$childPath = 'solar-system';
          [string]$fileName = 'saturn.txt';

          [DatedFile]$file = [DatedFile]::new($childPath, $fileName, $_Now);
          [PSCustomObject]$lastWriteTimeInfo = $file.TryGetLastWriteTime();
          $lastWriteTimeInfo.Found | Should -BeFalse;
        }
      }
    } # file does not exist

    Context 'given: file does exist' {
      It 'should: return Found = $true' {
        InModuleScope Elizium.Loopz {
          [string]$childPath = 'solar-system';
          [string]$fileName = 'uranus.txt';
          $null = deploy-file -BasePath $_EliziumPath -ChildPath $childPath `
            -FileName $fileName -Content 'uranus' -AsOf $_Legacy;

          [DatedFile]$file = [DatedFile]::new($childPath, $fileName, $_Now);
          [PSCustomObject]$lastWriteTimeInfo = $file.TryGetLastWriteTime();
          $lastWriteTimeInfo.Found | Should -BeTrue;
          $lastWriteTimeInfo.LastWriteTime | Should -Not -BeNullOrEmpty;
        }
      }
    } # file does exist
  } # TryGetLastWriteTime

  Describe 'Persist' {
    Context 'given: content' {
      It 'should: write to file' {
        InModuleScope Elizium.Loopz {
          [string]$childPath = 'solar-system';
          [string]$fileName = 'neptune.txt';

          [DatedFile]$file = [DatedFile]::new($childPath, $fileName, $_Now);
          $file.Persist('neptune');

          Test-Path -Path $file.FullPath -PathType Leaf;
        }
      }
    }
  } # Persist
} # DatedFile
