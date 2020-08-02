Describe 'Invoke-TraverseDirectory' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking
  }

  Context 'given: directory tree' -Tag 'BROKEN' {
    It 'Should: traverse' {
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

        @{ Product = $_underscore }
      }

      [scriptblock]$summary = {
        param(
          [int]$_count,
          [int]$_skipped,
          [boolean]$_trigger,
          [System.Collections.Hashtable]$_passThru
        )
        $index = $_passThru['LOOPZ.FOREACH-INDEX'];
        $index | Should -Be 19;
      }

      Invoke-TraverseDirectory -Path $resolvedSourcePath `
        -SourceDirectoryBlock $feDirectoryBlock -Summary $summary;
    }
  } # given: directory tree

  Context 'given: directory tree and Hoist specified' {
    It 'Should: traverse child directories whose ancestors don\`t match filter' {
      [string]$resolvedSourcePath = Convert-Path '.\Tests\Data\traverse\';

      [string]$filter = '*e*';
      [scriptblock]$feDirectoryBlock = {
        param(
          [Parameter(Mandatory)]
          [System.IO.DirectoryInfo]$_underscore,

          [Parameter(Mandatory)]
          [int]$_index,

          [Parameter(Mandatory)]
          [System.Collections.Hashtable]$_passThru,

          [Parameter(Mandatory)]
          [boolean]$_trigger
        )

        Write-Debug "[+] Traverse with Hoist; directory ($filter): '$($_underscore.Name)', index: $_index";
        @{ Product = $_underscore }
      }

      [scriptblock]$summary = {
        param(
          [int]$_count,
          [int]$_skipped,
          [boolean]$_trigger,
          [System.Collections.Hashtable]$_passThru
        )

        Write-Warning "TBD (Invoke-TraverseDirectory.tests): Apply Assert"
      }

      [scriptblock]$filterDirectories = {
        [OutputType([boolean])]
        param(
          [System.IO.DirectoryInfo]$directoryInfo
        )
        [string[]]$directoryIncludes = @($filter);
        [string[]]$directoryExcludes = @();

        Select-Directory -DirectoryInfo $directoryInfo `
          -Includes $directoryIncludes -Excludes $directoryExcludes;
      }

      Invoke-TraverseDirectory -Path $resolvedSourcePath -SourceDirectoryBlock $feDirectoryBlock `
        -Summary $summary -Condition $filterDirectories -Hoist;
    }
  }
}
