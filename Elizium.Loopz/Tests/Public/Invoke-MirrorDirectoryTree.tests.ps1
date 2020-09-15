
Describe 'Invoke-MirrorDirectoryTree' -Skip {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;

    # WhatIf set on function calls. This makes the test output very chatty when set to true.
    # WARNING: setting whatIf to true will break the tests, but you can see the directory and
    # file locations.
    #
    [boolean]$script:whatIf = $false;
    [string]$script:sourcePath = '.\Tests\Data\traverse\';
    [string]$script:destinationPath = 'TestDrive:\dev\TEST\';
    New-Item -ItemType 'Directory' -Path $destinationPath;
  }

  Context 'given: no filters applied' {
    Context 'and: directory tree without Creation option specified' {
      It 'Should: traverse without creating files or directories' {
        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -WhatIf:$whatIf;
      }
    }

    Context 'and: function specified' {
      It 'Should: traverse and invoke function for each directory' {
        [System.Collections.Hashtable]$parameters = @{
          'Format' = '---- {0} ----';
        }
        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -CreateDirs `
          -Functee 'Test-ShowMirror' -FuncteeParams $parameters -WhatIf:$whatIf;
      }
    }

    Context 'and: script block with extra custom parameters specified' {
      It 'Should: traverse and invoke scrip block for each directory' {
        $container = @{
          count = 0;
        };

        [scriptblock]$block = {
          param(
            [System.IO.DirectoryInfo]$DirInfo,
            [int]$Index,
            [System.Collections.Hashtable]$PassThru,
            [boolean]$Trigger,
            [string]$Format
          )
          $container.count++;
          [string]$result = $Format -f ($DirInfo.Name);
          Write-Debug "### Custom block: '$result'";
          @{ Product = $DirInfo }
        }
        $parameters = , @('---- {0} ----');

        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -CreateDirs `
          -Block $block -BlockParams $parameters -WhatIf:$whatIf;
        $container.count | Should -Be 19;
      }
    }

    Context 'and: script-block specified' {
      It 'Should: traverse and invoke function for each directory' {
        [scriptblock]$testShowMirrorBlock = {
          param(
            [Parameter(Mandatory)]
            [System.IO.DirectoryInfo]$Underscore,

            [Parameter(Mandatory)]
            [int]$Index,

            [Parameter(Mandatory)]
            [System.Collections.Hashtable]$PassThru,

            [Parameter(Mandatory)]
            [boolean]$Trigger,

            [Parameter(Mandatory)]
            [string]$Format = "DEFAULT: >>>> {0} >>>>"
          )

          [string]$result = $Format -f ($Underscore.Name);
          Write-Debug "Custom function; Show-Mirror: '$result'";
          @{ Product = $Underscore }
        }

        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -CreateDirs `
          -Block $testShowMirrorBlock -WhatIf:$whatIf;
      }
    }

    Context 'and: directory tree with Directory Creation option specified' {
      It 'Should: traverse creating directories only' {
        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -CreateDirs -WhatIf:$whatIf;

        $testPath = Join-Path -Path $destinationPath -ChildPath 'Audio';
        Test-Path -Path $testPath | Should -BeTrue - Because "Path $testPath does not exist";
      }
    }

    Context 'and: directory tree with Directory and File Creation options specified' {
      It 'Should: traverse creating files and directories' {
        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -CreateDirs -CopyFiles -WhatIf:$whatIf;

        $testPath = Join-Path -Path $destinationPath -ChildPath 'Audio';
        Test-Path -Path $testPath | Should -BeTrue -Because "Path $testPath does not exist";

        $testFile = Join-Path -Path $destinationPath -ChildPath 'Audio\audio-catalogue.txt';
        Test-Path -Path $testFile | Should -BeTrue -Because "Path $testFile does not exist";
      }
    }
  } # given: no filters applied

  Context 'given: Include file filters applied' {
    Context 'and: directory tree with Directory and File Creation options specified' {
      It 'Should: traverse creating files and directories' {
        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -CreateDirs -CopyFiles -FileIncludes @('cover.*') -WhatIf:$whatIf;

        $testPath = Join-Path -Path $destinationPath -ChildPath 'Audio';
        Test-Path -Path $testPath | Should -BeTrue -Because "Path $testPath does not exist";

        $coverFile = Join-Path -Path $destinationPath `
          -ChildPath 'Audio\GOTHIC\Fields Of The Nephilim\Earth Inferno\cover.fotn.earth-inferno.jpg.txt'
        Test-Path -Path $coverFile | Should -BeTrue -Because "Path $coverFile does not exist";

        $testFile = Join-Path -Path $destinationPath -ChildPath 'Audio\audio-catalogue.txt';
        Test-Path -Path $testFile | Should -BeTrue -Because "Path $testFile does not exist";
      }
    }

    Context 'and: filter without wild-card' {
      Context 'and: filter without preceding "."' {
        It 'Should: traverse creating files and directories' {
          Invoke-MirrorDirectoryTree -Path $sourcePath `
            -DestinationPath $destinationPath -CreateDirs -CopyFiles -FileIncludes @('jpg.txt') -WhatIf:$whatIf;

          $testPath = Join-Path -Path $destinationPath -ChildPath 'Audio';
          Test-Path -Path $testPath | Should -BeTrue -Because "Path $testPath does not exist";

          $coverFile = Join-Path -Path $destinationPath `
            -ChildPath 'Audio\GOTHIC\Fields Of The Nephilim\Earth Inferno\cover.fotn.earth-inferno.jpg.txt';
          Test-Path -Path $coverFile | Should -BeTrue -Because "Path $coverFile does not exist";

          $testFile = Join-Path -Path $destinationPath -ChildPath 'Audio\audio-catalogue.txt';
          Test-Path -Path $testFile | Should -BeTrue -Because "Path $testFile does not exist";
        }
      }

      Context 'and: filter with preceding "."' {
        It 'Should: traverse creating files and directories' {
          Invoke-MirrorDirectoryTree -Path $sourcePath `
            -DestinationPath $destinationPath -CreateDirs -CopyFiles -FileIncludes @('.jpg.txt') -WhatIf:$whatIf;

          $testPath = Join-Path -Path $destinationPath -ChildPath 'Audio';
          Test-Path -Path $testPath | Should -BeTrue -Because "Path $testPath does not exist";

          $coverFile = Join-Path -Path $destinationPath `
            -ChildPath 'Audio\GOTHIC\Fields Of The Nephilim\Earth Inferno\cover.fotn.earth-inferno.jpg.txt';
          Test-Path -Path $coverFile | Should -BeTrue -Because "Path $coverFile does not exist";

          $testFile = Join-Path -Path $destinationPath -ChildPath 'Audio\audio-catalogue.txt';
          Test-Path -Path $testFile | Should -BeTrue -Because "Path $testFile does not exist";
        }
      }
    } # and: filter without wild-card
  } # given: Include file filters applied

  Context 'given: Exclude file filters applied' {
    Context 'and: directory tree with Directory and File Creation options specified' {
      It 'Should: traverse creating files and directories' {
        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -CreateDirs -CopyFiles -FileExcludes @('*mp3*') -WhatIf:$whatIf;

        $testPath = Join-Path -Path $destinationPath -ChildPath 'Audio';
        Test-Path -Path $testPath | Should -BeTrue -Because "Path $testPath does not exist";

        $coverFile = Join-Path -Path $destinationPath `
          -ChildPath 'Audio\GOTHIC\Fields Of The Nephilim\Earth Inferno\cover.fotn.earth-inferno.jpg.txt';
        Test-Path -Path $coverFile | Should -BeTrue -Because "Path $coverFile does not exist";

        $testFile = Join-Path -Path $destinationPath -ChildPath 'Audio\MINIMAL\Plastikman\Consumed\A1 - Contain.mp3.txt';
        Test-Path -Path $testFile | Should -BeTrue -Because "Path $testFile does not exist";
      }
    }
  } # given: Exclude file filters applied

  Context 'given: Include file filters applied' {
    Context 'and: directory tree with Directory Creation option specified' -Tag 'INVALID' {
      # THESE TESTS DO NOT MAKE SENSE, because Hoist not specified and top level directory
      # 'traverse' does not match the condition *o*
      #
      It 'Should: traverse creating files and directories' {
        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -CreateDirs -DirectoryIncludes @('*o*') -WhatIf:$whatIf;

        $testPath = Join-Path -Path $destinationPath -ChildPath 'Audio';
        Write-Host ">>> SRC-PATH: $sourcePath"
        Write-Host ">>> TEST-PATH: $testPath"
        Test-Path -Path $testPath | Should -BeTrue -Because "Path: $testPath does not exist";
      }
    }

    Context 'and: File copy specified without directory creation' {
      It 'should: still copy matching files'  -Tag 'INVALID' {
        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -CopyFiles -FileIncludes @('cover.*')`
          -DirectoryIncludes @('*e*') -WhatIf:$whatIf;

        $testPath = Join-Path -Path $destinationPath -ChildPath 'Audio';
        Test-Path -Path $testPath | Should -BeTrue -Because "Path $testFile does not exist";
      }
    }
  } # given: Include file filters applied

  Context 'given: HoistDescendent specified' {
    Context 'and: Include directory filters applied' {
      It 'Should: traverse creating files and hoisted descendant directories' {
        [scriptblock]$summary = {
          param(
            [int]$_count,
            [int]$_skipped, 
            [boolean]$_triggered,
            [System.Collections.Hashtable]$_passThru
          )

          $_count | Should -Be 11;
        }

        [System.Collections.Hashtable]$verifiedCountPassThru = @{}

        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -CreateDirs -DirectoryIncludes @('*e*') `
          -Hoist -Summary $summary -PassThru $verifiedCountPassThru -WhatIf:$whatIf;
      }
    }
  } # given: HoistDescendent specified
} # Invoke-MirrorDirectoryTree
