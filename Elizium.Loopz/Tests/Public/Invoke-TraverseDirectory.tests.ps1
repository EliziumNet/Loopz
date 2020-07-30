Describe 'Invoke-TraverseDirectory' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking
  }

  Context 'given: directory tree' {
    It 'Should: traverse' -tag 'Current' {
      [string]$resolvedSourcePath = Convert-Path '.\Tests\Data\traverse\';

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

        Write-Host "  [-] Directory: '$($_underscore.Name)', index: '$($_passThru['LOOPZ.FOREACH-INDEX'])'"
        @{ Product = $_underscore }
      }

      [scriptblock]$summary = {
        param(
          [Parameter(Mandatory)]
          [System.Collections.Hashtable]$_passThru
        )
        $index = $_passThru['LOOPZ.FOREACH-INDEX'];
        $index | Should -Be 19;
      }

      Invoke-TraverseDirectory -Path $resolvedSourcePath `
        -SourceDirectoryBlock $feDirectoryBlock -Summary $summary;
    }
  }
}
