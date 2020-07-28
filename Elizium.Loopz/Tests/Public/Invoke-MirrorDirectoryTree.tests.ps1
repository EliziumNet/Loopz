
Describe 'Invoke-MirrorDirectoryTree' -Tag 'Current' -Skip {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking
  }

  Context 'given: directory tree' {
    It 'Should: traverse' {
      $sourcePath = '.\Tests\Data\traverse\';
      $destinationPath = '~\dev\TEST\';

      # NEED A TRAILING /
      [string]$resolvedSourcePath = Convert-Path '.\Tests\Data\traverse';
      [string]$destinationPath = Convert-Path '~\dev\TEST';

      [System.Collections.Hashtable]$passThru = @{
        # Do NOT use Resolve-Path with a wild-card
        #
        'ROOT-SOURCE'      = $resolvedSourcePath
        'ROOT-DESTINATION' = $destinationPath;
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
        -SourceFileBlock $feSourceFileblock -SourceDirectoryBlock $feDirectoryFileBlock;
    }
  }
}
