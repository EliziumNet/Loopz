
Describe 'Invoke-MirrorDirectoryTree' -Tag 'Current' {
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

    Context 'and: directory tree with Directory Creation option specified' {
      It 'Should: traverse creating directories only' {
        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -CreateDirs -WhatIf:$whatIf;

        Test-Path -Path (Join-Path -Path $destinationPath -ChildPath 'Audio') | Should -BeTrue;
      }
    }

    Context 'and: directory tree with Directory and File Creation options specified' {
      It 'Should: traverse creating files and directories' {
        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -CreateDirs -CopyFiles -WhatIf:$whatIf;

        Test-Path -Path (Join-Path -Path $destinationPath -ChildPath 'Audio') | Should -BeTrue;
        Test-Path -Path (Join-Path -Path $destinationPath -ChildPath 'Audio\audio-catalogue.txt') | Should -BeTrue;
      }
    }
  } # given: no filters applied

  Context 'given: Include file filters applied' {
    Context 'and: directory tree with Directory and File Creation options specified' {
      It 'Should: traverse creating files and directories' {
        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -CreateDirs -CopyFiles -FileIncludes @('cover.*') -WhatIf:$whatIf;

        Test-Path -Path (Join-Path -Path $destinationPath -ChildPath 'Audio') | Should -BeTrue;
        Test-Path -Path (Join-Path -Path $destinationPath `
            -ChildPath 'Audio\GOTHIC\Fields Of The Nephilim\Earth Inferno\cover.fotn.earth-inferno.jpg.txt') | Should -BeTrue;
        Test-Path -Path (Join-Path -Path $destinationPath -ChildPath 'Audio\audio-catalogue.txt') | Should -BeFalse;
      }
    }

    Context 'and: filter without wild-card' {
      Context 'and: filter without preceding "."' {
        It 'Should: traverse creating files and directories' {
          Invoke-MirrorDirectoryTree -Path $sourcePath `
            -DestinationPath $destinationPath -CreateDirs -CopyFiles -FileIncludes @('jpg.txt') -WhatIf:$whatIf;

          Test-Path -Path (Join-Path -Path $destinationPath -ChildPath 'Audio') | Should -BeTrue;
          Test-Path -Path (Join-Path -Path $destinationPath `
              -ChildPath 'Audio\GOTHIC\Fields Of The Nephilim\Earth Inferno\cover.fotn.earth-inferno.jpg.txt') | Should -BeTrue;
          Test-Path -Path (Join-Path -Path $destinationPath -ChildPath 'Audio\audio-catalogue.txt') | Should -BeFalse;
        }
      }

      Context 'and: filter with preceding "."' {
        It 'Should: traverse creating files and directories' {
          Invoke-MirrorDirectoryTree -Path $sourcePath `
            -DestinationPath $destinationPath -CreateDirs -CopyFiles -FileIncludes @('.jpg.txt') -WhatIf:$whatIf;

          Test-Path -Path (Join-Path -Path $destinationPath -ChildPath 'Audio') | Should -BeTrue;
          Test-Path -Path (Join-Path -Path $destinationPath `
              -ChildPath 'Audio\GOTHIC\Fields Of The Nephilim\Earth Inferno\cover.fotn.earth-inferno.jpg.txt') | Should -BeTrue;
          Test-Path -Path (Join-Path -Path $destinationPath -ChildPath 'Audio\audio-catalogue.txt') | Should -BeFalse;
        }
      }
    } # and: filter without wild-card
  } # given: Include file filters applied

  Context 'given: Exclude file filters applied' {
    Context 'and: directory tree with Directory and File Creation options specified' {
      It 'Should: traverse creating files and directories' {
        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -CreateDirs -CopyFiles -FileExcludes @('*mp3*') -WhatIf:$whatIf;

        Test-Path -Path (Join-Path -Path $destinationPath -ChildPath 'Audio') | Should -BeTrue;
        Test-Path -Path (Join-Path -Path $destinationPath `
            -ChildPath 'Audio\GOTHIC\Fields Of The Nephilim\Earth Inferno\cover.fotn.earth-inferno.jpg.txt') | Should -BeTrue;
        Test-Path -Path (Join-Path -Path $destinationPath `
            -ChildPath 'Audio\MINIMAL\Plastikman\Consumed\A1 - Contain.mp3.txt') | Should -BeFalse;
      }
    }
  } # given: Exclude file filters applied

  Context 'given: Include file filters applied' {
    Context 'and: directory tree with Directory and File Creation options specified' {
      It 'Should: traverse creating files and directories' {
        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -CreateDirs -DirectoryIncludes @('*o*') -WhatIf:$whatIf;

        Test-Path -Path (Join-Path -Path $destinationPath -ChildPath 'Audio') | Should -BeTrue;
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

        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -CreateDirs -DirectoryIncludes @('*e*') `
          -Hoist -Summary $summary -WhatIf:$whatIf;
      }
    }
  } # given: HoistDescendent specified

  Context 'given: directory tree' -Skip {
    It 'Should: traverse' {
      # NEED A TRAILING /
      [string]$resolvedSourcePath = Convert-Path '.\Tests\Data\traverse';
      [string]$destinationPath = Convert-Path '~\dev\TEST';

      [System.Collections.Hashtable]$passThru = @{
        # Do NOT use Resolve-Path with a wild-card
        #
        'LOOPZ.MIRROR.ROOT-SOURCE'      = $resolvedSourcePath
        'LOOPZ.MIRROR.ROOT-DESTINATION' = $destinationPath;
        'LOOPZ.MIRROR.CREATE-DIR'       = $true;
      }

      [scriptblock]$feSourceFileblock = {
        param(
          [Parameter(Mandatory)]
          $_underscore,

          [Parameter(Mandatory)]
          [int]$_index,

          [Parameter(Mandatory)]
          [System.Collections.Hashtable]$_passThru,

          [Parameter(Mandatory)]
          [boolean]$_trigger
        )
        Write-Host "    [+] File: '$($_underscore.Name)'"
        @{ Product = $_underscore }
      }

      [scriptblock]$feDirectoryFileBlock = {
        param(
          [Parameter(Mandatory)]
          $_underscore,

          [Parameter(Mandatory)]
          [int]$_index,

          [Parameter(Mandatory)]
          [System.Collections.Hashtable]$_passThru,

          [Parameter(Mandatory)]
          [boolean]$_trigger
        )
        Write-Host "  [*] Directory: '$($_underscore)', type: $($_underscore.GetType())"
        @{ Product = $_underscore }
      }

      Invoke-MirrorDirectoryTree -SourcePath $sourcePath -DestinationPath $destinationPath `
        -PassThru $passThru `
        -SourceFileBlock $feSourceFileblock -Block $feDirectoryFileBlock -WhatIf:$whatIf;
    }
  }
}
