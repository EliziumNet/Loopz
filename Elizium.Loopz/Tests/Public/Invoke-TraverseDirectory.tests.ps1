Describe 'Invoke-TraverseDirectory' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;

    [string]$script:filter = '*e*';

    [scriptblock]$script:filterDirectories = {
      [OutputType([boolean])]
      param(
        [System.IO.DirectoryInfo]$directoryInfo
      )
      [string[]]$directoryIncludes = @($filter);
      [string[]]$directoryExcludes = @();

      Select-FsItem -Name $directoryInfo.Name `
        -Includes $directoryIncludes -Excludes $directoryExcludes;
    }

    [string]$script:sourcePath = '.\Tests\Data\traverse\';
    [string]$script:resolvedSourcePath = Convert-Path $sourcePath;
  }
  Context 'given: custom scriptblock specified' {
    Context 'and: directory tree' {
      It 'should: traverse' {
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
          -Block $feDirectoryBlock -Summary $summary;
      }
    } # and: directory tree

    Context 'and: directory tree and Hoist specified' {
      It 'should: traverse child directories whose ancestors don\`t match filter' {
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

          $_count | Should -Be 11;
        }

        Invoke-TraverseDirectory -Path $resolvedSourcePath -Block $feDirectoryBlock `
          -Summary $summary -Condition $filterDirectories -Hoist;
      } # should: traverse child directories whose ancestors don\`t match filter
    } # and: directory tree and Hoist specified
  } # given: custom scriptblock specified

  Context 'given: custom function specified' {
    Context 'and: directory tree and Hoist specified' {
      It 'should: traverse child directories whose ancestors don\`t match filter' {
        [scriptblock]$summary = {
          param(
            [int]$_count,
            [int]$_skipped,
            [boolean]$_trigger,
            [System.Collections.Hashtable]$_passThru
          )

          $_count | Should -Be 11;
        }
        [System.Collections.Hashtable]$parameters = @{
          'format' = "=== {0} ===";
        }

        Invoke-TraverseDirectory -Path $resolvedSourcePath -Functee 'Test-HoistResult' `
          -FuncteeParams $parameters -Summary $summary -Condition $filterDirectories -Hoist;
      }
    }
  } # given: custom function specified
} # Invoke-TraverseDirectory
