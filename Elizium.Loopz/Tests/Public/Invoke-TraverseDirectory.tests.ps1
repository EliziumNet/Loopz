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
        [scriptblock]$traverseBlock = {
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
          -Block $traverseBlock -Summary $summary;
      }
    } # and: directory tree

    Context 'and: directory tree and Hoist specified' {
      It 'should: traverse child directories whose ancestors don\`t match filter' {
        [scriptblock]$traverseBlock = {
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

        Invoke-TraverseDirectory -Path $resolvedSourcePath -Block $traverseBlock `
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

  Context 'given: block result' {
    Context 'and: trigger is fired' {
      Context 'and: single iteration' {
        It 'should: set trigger' {
          [string]$sourcePath = (Convert-Path '.\Tests\Data\traverse\Audio\MINIMAL\Richie Hawtin');
          Write-Host "[+] === path: $sourcePath";

          [scriptblock]$traverseBlock = {
            param(
              $_underscore,
              [int]$_index,
              [System.Collections.Hashtable]$_passThru,
              [boolean]$_trigger
            )
            Write-Host "  [-] TEST-BLOCK(index: $_index): directory: $($_underscore.Name)";
            @{ Product = $_underscore; Trigger = $true }
          }

          [scriptblock]$summary = {
            param(
              [int]$_count,
              [int]$_skipped,
              [boolean]$_trigger,
              [System.Collections.Hashtable]$_passThru
            )

            Write-Host "--> TEST-SUMMARY(block/trigger/single): Count: $_count, Skipped: $_skipped, Trigger: $_trigger";
            $_trigger | Should -BeTrue;
          }

          Invoke-TraverseDirectory -Path $sourcePath -Block $traverseBlock `
            -Summary $summary;
        } # should: set trigger
      } # and: single iteration

      Context 'and: multiple iterations' {
        It 'should: set trigger' {
          [string]$sourcePath = (Convert-Path '.\Tests\Data\traverse\Audio\MINIMAL\Plastikman');
          Write-Host "[+] === path: $sourcePath";

          [scriptblock]$traverseBlock = {
            param(
              $_underscore,
              [int]$_index,
              [System.Collections.Hashtable]$_passThru,
              [boolean]$_trigger
            )

            $trigger = $_trigger;
            if ('EX' -eq $_underscore.Name) {
              $trigger = $true;
            }

            Write-Host "  [-] TEST-BLOCK(index: $_index, trigger: $_trigger): directory: $($_underscore.Name)";
            @{ Product = $_underscore; Trigger = $trigger }
          }

          [scriptblock]$summary = {
            param(
              [int]$_count,
              [int]$_skipped,
              [boolean]$_trigger,
              [System.Collections.Hashtable]$_passThru
            )

            Write-Host "--> TEST-SUMMARY(block/trigger/multi): Count: $_count, Skipped: $_skipped, Trigger: $_trigger";
            $_trigger | Should -BeTrue;
          }

          Invoke-TraverseDirectory -Path $sourcePath -Block $traverseBlock `
            -Summary $summary;
        } # should: set trigger

        Context 'and: Hoist' {
          It 'should: set trigger' {
            [string]$sourcePath = (Convert-Path '.\Tests\Data\traverse\Audio\MINIMAL\Plastikman');
            Write-Host "[+] === path: $sourcePath";

            [scriptblock]$traverseBlock = {
              param(
                $_underscore,
                [int]$_index,
                [System.Collections.Hashtable]$_passThru,
                [boolean]$_trigger
              )

              $trigger = $_trigger;
              if ('EX' -eq $_underscore.Name) {
                $trigger = $true;
              }

              Write-Host "  [-] TEST-BLOCK(index: $_index, trigger: $_trigger): directory: $($_underscore.Name)";
              @{ Product = $_underscore; Trigger = $trigger }
            }

            [scriptblock]$summary = {
              param(
                [int]$_count,
                [int]$_skipped,
                [boolean]$_trigger,
                [System.Collections.Hashtable]$_passThru
              )

              Write-Host "--> TEST-SUMMARY(block/trigger/multi/hoist): Count: $_count, Skipped: $_skipped, Trigger: $_trigger";
              $_trigger | Should -BeTrue;
            }

            Invoke-TraverseDirectory -Path $sourcePath -Block $traverseBlock `
              -Summary $summary -Hoist;
          } # should: set trigger
        } # and: Hoist
      } # and: multiple iterations
    } # and: trigger is fired

    Context 'and: break is fired' {
      Context 'and: single iteration' {
        It 'should: set break' {
          [string]$sourcePath = (Convert-Path '.\Tests\Data\traverse\Audio\MINIMAL\Richie Hawtin');
          Write-Host "[+] === path: $sourcePath";

          $container = @{
            count = 0
          }
          [scriptblock]$traverseBlock = {
            param(
              $_underscore,
              [int]$_index,
              [System.Collections.Hashtable]$_passThru,
              [boolean]$_trigger
            )
            Write-Host "  [-] TEST-BLOCK(index: $_index): directory: $($_underscore.Name)";
            $container.count++;
            @{ Product = $_underscore; Break = $true }
          }

          [scriptblock]$summary = {
            param(
              [int]$_count,
              [int]$_skipped,
              [boolean]$_trigger,
              [System.Collections.Hashtable]$_passThru
            )

            Write-Host "--> TEST-SUMMARY(block/break/single): Count: $_count, Skipped: $_skipped, Trigger: $_trigger";
            $container.count | Should -Be 2;
          }

          Invoke-TraverseDirectory -Path $sourcePath -Block $traverseBlock `
            -Summary $summary;
        } # should: set break
      } # and: single iteration

      Context 'and: multiple iterations' {
        It 'should: set break' {
          [string]$sourcePath = (Convert-Path '.\Tests\Data\traverse\Audio\MINIMAL\Plastikman');
          Write-Host "[+] === path: $sourcePath";

          [scriptblock]$traverseBlock = {
            param(
              $_underscore,
              [int]$_index,
              [System.Collections.Hashtable]$_passThru,
              [boolean]$_trigger
            )
            Write-Host "  [-] TEST-BLOCK(index: $_index): directory: $($_underscore.Name)";

            $break = $false;
            if ('EX' -eq $_underscore.Name) {
              $break = $true;
            }
            @{ Product = $_underscore; Break = $break }
          }

          [scriptblock]$summary = {
            param(
              [int]$_count,
              [int]$_skipped,
              [boolean]$_trigger,
              [System.Collections.Hashtable]$_passThru
            )

            Write-Host "--> TEST-SUMMARY(block/break/multi): Count: $_count, Skipped: $_skipped, Trigger: $_trigger";
            $_count | Should -Be 4;
          }

          Invoke-TraverseDirectory -Path $sourcePath -Block $traverseBlock `
            -Summary $summary;
        } # should: set break
      } # and: multiple iterations
    } # and: break is fired
  } # given: block result

  Context 'given: fn result' { #@@@@
    Context 'and: trigger is fired' {
      Context 'and: multiple iterations' {
        It 'should: set break' -Tag 'Current' {
          [string]$sourcePath = (Convert-Path '.\Tests\Data\traverse\Audio\MINIMAL\Plastikman');
          Write-Host "[+] === path: $sourcePath";

          [scriptblock]$summary = {
            param(
              [int]$_count,
              [int]$_skipped,
              [boolean]$_trigger,
              [System.Collections.Hashtable]$_passThru
            )

            Write-Host "--> TEST-SUMMARY(fn/break/multi): Count: $_count, Skipped: $_skipped, Trigger: $_trigger";
            # $_count | Should -Be 4;
          }

          Invoke-TraverseDirectory -Path $sourcePath -Functee 'Test-FireEXTrigger' `
            -Summary $summary;
        } # should: set break

        Context 'and: Hoist' { #@@@@
          It 'should: set trigger' {
            [string]$sourcePath = (Convert-Path '.\Tests\Data\traverse\Audio\MINIMAL\Plastikman');
            Write-Host "[+] === path: $sourcePath";

            [scriptblock]$traverseBlock = {
              param(
                $_underscore,
                [int]$_index,
                [System.Collections.Hashtable]$_passThru,
                [boolean]$_trigger
              )

              $trigger = $_trigger;
              if ('EX' -eq $_underscore.Name) {
                $trigger = $true;
              }

              Write-Host "  [-] TEST-FN(index: $_index, trigger: $_trigger): directory: $($_underscore.Name)";
              @{ Product = $_underscore; Trigger = $trigger }
            }

            [scriptblock]$summary = {
              param(
                [int]$_count,
                [int]$_skipped,
                [boolean]$_trigger,
                [System.Collections.Hashtable]$_passThru
              )

              Write-Host "--> TEST-SUMMARY(fn/trigger/multi/hoist): Count: $_count, Skipped: $_skipped, Trigger: $_trigger";
              # $_trigger | Should -BeTrue;
            }

            Invoke-TraverseDirectory -Path $sourcePath -Block $traverseBlock `
              -Summary $summary -Hoist;
          } # should: set trigger
        } # and: Hoist
      } # and: multiple iterations      
    }
  }
} # Invoke-TraverseDirectory
