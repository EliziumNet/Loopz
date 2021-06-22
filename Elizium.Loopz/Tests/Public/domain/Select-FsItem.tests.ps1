
Describe 'Select-FsItem' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;

    [string]$script:sourcePath = '.\Tests\Data\traverse\Audio\GOTHIC\Fields Of The Nephilim\';
    [System.IO.DirectoryInfo]$script:directoryInfo = Get-Item -Path $sourcePath;
  }

  Context 'given: single element Filters' {
    Context 'and: Matching Include Filter' {
      It 'should: select the directory (return true)' {
        [string[]]$includes = @('Fields*');
        [string[]]$excludes = @();

        Select-FsItem -Name $directoryInfo.Name `
          -Includes $includes -Excludes $excludes | Should -BeTrue;
      }

      Context 'and: NO Matching Excludes' {
        It 'should: select the directory (return true)' {
          [string[]]$includes = @('Fields*');
          [string[]]$excludes = @('Pop*');

          Select-FsItem -Name $directoryInfo.Name `
            -Includes $includes -Excludes $excludes | Should -BeTrue;
        }
      }

      Context 'and: Matching Excludes' {
        It 'should: reject the directory (return false)' {
          [string[]]$includes = @('Fields*');
          [string[]]$excludes = @('*Nephilim*');

          Select-FsItem -Name $directoryInfo.Name `
            -Includes $includes -Excludes $excludes | Should -BeFalse;
        }
      }

      Context 'and: Excludes does not contain *' {
        It 'should: ignore Excludes and select the directory (return true)' {
          [string[]]$includes = @('Fields*');
          [string[]]$excludes = @('Nephilim');

          Select-FsItem -Name $directoryInfo.Name `
            -Includes $includes -Excludes $excludes | Should -BeTrue;
        }
      }
    } # given: Matching Include Filter

    Context 'and: Matching Include Filter, but differs in case' {
      It 'should: be case insensitive and select the directory (return true)' {
        [string[]]$includes = @('fields*');
        [string[]]$excludes = @();

        Select-FsItem -Name $directoryInfo.Name `
          -Includes $includes -Excludes $excludes | Should -BeTrue;
      }
    }

    Context 'and: NO Matching Include Filter' {
      It 'should: reject the directory (return false)' {
        [string[]]$includes = @('Rock*');
        [string[]]$excludes = @();

        Select-FsItem -Name $directoryInfo.Name `
          -Includes $includes -Excludes $excludes | Should -BeFalse;
      }
    }

    Context 'given: Includes does not contain *' {
      It 'should: reject the directory (return false)' {
        [string[]]$includes = @('Rock');
        [string[]]$excludes = @();

        Select-FsItem -Name $directoryInfo.Name `
          -Includes $includes -Excludes $excludes | Should -BeFalse;
      }
    }
  } # given: single element Filters

  Context 'given: multi element Filters' {
    Context 'and: Matching Include Filter' {
      It 'should: select the directory (return true)' {
        [string[]]$includes = @('Fields*', 'Goth*', '*Of');
        [string[]]$excludes = @();

        Select-FsItem -Name $directoryInfo.Name `
          -Includes $includes -Excludes $excludes | Should -BeTrue;
      }

      Context 'and: NO Matching Excludes' {
        It 'should: select the directory (return true)' {
          [string[]]$includes = @('Fields*');
          [string[]]$excludes = @('Pop*', 'Prog*', 'Techno*');

          Select-FsItem -Name $directoryInfo.Name `
            -Includes $includes -Excludes $excludes | Should -BeTrue;
        }
      }

      Context 'and: Matching Excludes' {
        It 'should: reject the directory (return false)' {
          [string[]]$includes = @('Fields*');
          [string[]]$excludes = @('Pop*', 'Prog*', 'Techno*', '*Nephilim*');

          Select-FsItem -Name $directoryInfo.Name `
            -Includes $includes -Excludes $excludes | Should -BeFalse;
        }
      }

      Context 'and: Excludes does not contain *' {
        It 'should: ignore Excludes and select the directory (return true)' {
          [string[]]$includes = @('Fields*');
          [string[]]$excludes = @('Pop*', 'Prog*', 'Techno*', 'Nephilim');

          Select-FsItem -Name $directoryInfo.Name `
            -Includes $includes -Excludes $excludes | Should -BeTrue;
        }
      }
    } # and: Matching Include Filter

    Context 'and: NO Matching Include Filter' {
      It 'should: reject the directory (return false)' {
        [string[]]$includes = @('Rock*', 'Pop*', 'Techno*');
        [string[]]$excludes = @();

        Select-FsItem -Name $directoryInfo.Name `
          -Includes $includes -Excludes $excludes | Should -BeFalse;
      }
    }

    Context 'given: Includes does not contain *' {
      It 'should: reject the directory (return false)' {
        [string[]]$includes = @('Rock', 'Pop', 'Techno');
        [string[]]$excludes = @();

        Select-FsItem -Name $directoryInfo.Name `
          -Includes $includes -Excludes $excludes | Should -BeFalse;
      }
    }
  } # given: multi element Filters

  Context 'given: empty filters' {
    It 'should: reject the directory (return false)' {
      [string[]]$includes = @();
      [string[]]$excludes = @();

      Select-FsItem -Name $directoryInfo.Name `
        -Includes $includes -Excludes $excludes | Should -BeFalse;
    }
  }

  Context 'given: Case sensitive' {
    Context 'and: Matching Include Filter, but differs in case' {
      It 'should: be case insensitive and select the directory (return false)' {
        [string[]]$includes = @('fields*');
        [string[]]$excludes = @();

        Select-FsItem -Name $directoryInfo.Name `
          -Includes $includes -Excludes $excludes -Case | Should -BeFalse;
      }
    }
  }
} # Select-FsItem
