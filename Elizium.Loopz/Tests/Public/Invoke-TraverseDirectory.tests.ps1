Describe 'Invoke-TraverseDirectory' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking
  }

  Context 'given: directory tree' {
    It 'Should: traverse' -tag 'Current' {
      $sourcePath = '.\Tests\Data\traverse\';
      $destinationPath = '~\dev\TEST\';

      [string]$resolvedSourcePath = Convert-Path $sourcePath;
      [string]$destinationPath = Convert-Path $destinationPath;

      [System.Collections.Hashtable]$passThru = @{
        # Do NOT use Resolve-Path with a wild-card
        #
        'ROOT-SOURCE'      = $resolvedSourcePath
        'ROOT-DESTINATION' = $destinationPath;
      }

      [scriptblock]$feDirectoryBlock = {
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
        Write-Host "  [*] Directory: '$($_underscore.Name)', index: '$($_passThru['LOOPZ.FOREACH-INDEX'])'"
        @{ Product = $_underscore }
      }

      Invoke-TraverseDirectory -Path $resolvedSourcePath -PassThru $passThru `
        -SourceDirectoryBlock $feDirectoryBlock;
    }
  }
}
