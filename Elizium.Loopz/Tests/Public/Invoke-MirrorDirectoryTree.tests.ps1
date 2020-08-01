
Describe 'Invoke-MirrorDirectoryTree' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking
  }

  # WhatIf set on function calls. This makes the test output very chatty, but if there are
  # no errors in the output, the tests are considered to have passed. This could be done
  # using TestDrive and checking existence of files/directories, but this would slow the
  # tests down further as real test resources are created and destroyed.
  #

  Context 'given: no filters applied' {
    Context 'given: directory tree without Creation option specified' {
      It 'Should: traverse without creating files or directories' {
        [string]$sourcePath = '.\Tests\Data\traverse\';
        [string]$destinationPath = '~\dev\TEST\';

        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -WhatIf;
      }
    }

    Context 'given: directory tree with Directory Creation option specified' {
      It 'Should: traverse creating directories only' {
        [string]$sourcePath = '.\Tests\Data\traverse\';
        [string]$destinationPath = '~\dev\TEST\';

        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -CreateDirs -WhatIf;
      }
    }

    Context 'given: directory tree with Directory and File Creation options specified' {
      It 'Should: traverse creating files and directories' {
        [string]$sourcePath = '.\Tests\Data\traverse\';
        [string]$destinationPath = '~\dev\TEST\';

        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -CreateDirs -CopyFiles -WhatIf;
      }
    }
  } # given: no filters applied

  Context 'given: Include file filters applied' {
    Context 'and: directory tree with Directory and File Creation options specified' {
      It 'Should: traverse creating files and directories' {
        [string]$sourcePath = '.\Tests\Data\traverse\';
        [string]$destinationPath = '~\dev\TEST\';

        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -CreateDirs -CopyFiles -FileIncludes @('cover.*') -WhatIf;
      }
    }
  } # given: Include file filters applied

  Context 'given: Exclude file filters applied' {
    Context 'and: directory tree with Directory and File Creation options specified' {
      It 'Should: traverse creating files and directories' {
        [string]$sourcePath = '.\Tests\Data\traverse\';
        [string]$destinationPath = '~\dev\TEST\';

        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -CreateDirs -CopyFiles -FileExcludes @('*mp3*') -WhatIf;
      }
    }
  } # given: Exclude file filters applied

  Context 'given: Include file filters applied' {
    Context 'and: directory tree with Directory and File Creation options specified' {
      It 'Should: traverse creating files and directories' {
        [string]$sourcePath = '.\Tests\Data\traverse\';
        [string]$destinationPath = '~\dev\TEST\';

        Invoke-MirrorDirectoryTree -Path $sourcePath `
          -DestinationPath $destinationPath -CreateDirs -DirectoryIncludes @('*o*') -WhatIf;
      }
    }
  } # given: Include file filters applied

  Context 'given: directory tree' -Skip {
    It 'Should: traverse' {
      $sourcePath = '.\Tests\Data\traverse\';
      $destinationPath = '~\dev\TEST\';

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
        -SourceFileBlock $feSourceFileblock -SourceDirectoryBlock $feDirectoryFileBlock -WhatIf;
    }
  }
}
