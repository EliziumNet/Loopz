using namespace System.IO;
using module Elizium.Krayola;

Describe 'Invoke-TraverseDirectory' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;

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

    [string]$dataPath = $(Join-Path -Path '.' -ChildPath 'Tests' -AdditionalChildPath 'Data');
    [string]$script:sourcePath = $(Join-Path -Path $dataPath -ChildPath 'traverse');
    [string]$script:resolvedSourcePath = Convert-Path $sourcePath;

    [hashtable]$theme = $(Get-KrayolaTheme);
    [Krayon]$script:_krayon = New-Krayon($theme);

    [scriptblock]$script:_genericTraverseBlock = {
      param(
        [Parameter(Mandatory)]
        $_underscore,

        [Parameter(Mandatory)]
        [int]$_index,

        [Parameter(Mandatory)]
        [hashtable]$_exchange,

        [Parameter(Mandatory)]
        [boolean]$_trigger
      )
      Write-Debug "+++ (Generic Traverse) DIRECTORY (Index: $_index): $_underscore"

      @{ Product = $_underscore }
    }

    function test-IsDepthInRange {
      [OutputType([boolean])]
      param(
        [hashtable]$Exchange
      )

      [boolean]$isInRange = if ($Exchange.ContainsKey('LOOPZ.TRAVERSE.LIMIT-DEPTH')) {
        [int]$limitDepth = $Exchange['LOOPZ.TRAVERSE.LIMIT-DEPTH']; # 0 based
        [int]$controllerDepth = $Exchange['LOOPZ.CONTROLLER.DEPTH']; # 1 based

        $($controllerDepth -le ($limitDepth + 2));
      }
      else {
        $true;
      }

      return $isInRange;
    }
  }

  BeforeEach {
    [Scribbler]$script:_scribbler = New-Scribbler -Krayon $_krayon -Test;
  }

  AfterEach {
    $_scribbler.Flush();
  }

  Context "given: OnBefore and OnAfter provided" {
    It "should: invoke the callbacks" {

      [scriptblock]$before = {
        param(
          [DirectoryInfo]$_directory,
          [hashtable]$_exchange
        )
        $_exchange["LOOPZ.TRAVERSE.UNIT-TEST.COUNT"]++;
        $count = $_exchange["LOOPZ.TRAVERSE.UNIT-TEST.COUNT"];
        Write-Debug ">>> BEFORE [c='$($count)']: ('$($_directory.FullName)')";
      }

      [scriptblock]$after = {
        param(
          [DirectoryInfo]$_directory,
          [hashtable]$_exchange
        )
        $_exchange["LOOPZ.TRAVERSE.UNIT-TEST.COUNT"]--;
        $count = $_exchange["LOOPZ.TRAVERSE.UNIT-TEST.COUNT"];
        Write-Debug "<<< AFTER [c='$($count)']: ('$($_directory.FullName)')";
      }
      [hashtable]$exchange = @{
        "LOOPZ.TRAVERSE.UNIT-TEST.COUNT" = 0;
      }
      Invoke-TraverseDirectory -Path $script:resolvedSourcePath -Exchange $exchange `
        -Block $script:_genericTraverseBlock -OnBefore $before -OnAfter $after;

      $result = $exchange["LOOPZ.TRAVERSE.UNIT-TEST.COUNT"];
      $result | Should -Be 0;
    }
  }

  Context 'given: custom scriptblock specified' {
    Context 'and: directory tree' {
      It 'should: traverse' {
        [scriptblock]$sessionSummary = {
          param(
            [int]$_count,
            [int]$_skipped,
            [int]$_errors,
            [boolean]$_trigger,
            [hashtable]$_exchange
          )
          $_count | Should -Be 19;
        }

        Invoke-TraverseDirectory -Path $resolvedSourcePath `
          -Block $_genericTraverseBlock -SessionSummary $sessionSummary;
      }

      Context 'and: SummaryBlock provided' {
        It 'should: write summary' {
          [scriptblock]$traverseBlock = {
            param(
              [Parameter(Mandatory)]
              $_underscore,

              [Parameter(Mandatory)]
              [int]$_index,

              [Parameter(Mandatory)]
              [hashtable]$_exchange,

              [Parameter(Mandatory)]
              [boolean]$_trigger
            )

            @{ Product = $_underscore }
          }

          [hashtable]$exchange = @{
            'LOOPZ.SUMMARY-BLOCK.LINE'    = $LoopzUI.EqualsLine;
            'LOOPZ.SUMMARY-BLOCK.MESSAGE' = 'Test Summary';
            'LOOPZ.SCRIBBLER'             = $_scribbler;
          }

          Invoke-TraverseDirectory -Path $resolvedSourcePath -Exchange $exchange `
            -Block $traverseBlock -Summary $LoopzHelpers.SummaryBlock;
        }
      }
    } # and: directory tree

    Context 'and: <Depth>' {
      It 'should: not exceed depth limit' -TestCases @(
        @{ Depth = 0; },
        @{ Depth = 1; },
        @{ Depth = 2; },
        @{ Depth = 3; }
      ) {
        [scriptblock]$summary = {
          param(
            [int]$_count,
            [int]$_skipped,
            [int]$_errors,
            [boolean]$_trigger,
            [hashtable]$_exchange
          )
          [boolean]$depthIsInRange = test-IsDepthInRange -Exchange $_exchange
          [int]$actualDepth = $_exchange['LOOPZ.CONTROLLER.DEPTH'];
          [int]$limitDepth = $_exchange['LOOPZ.TRAVERSE.LIMIT-DEPTH'];

          $depthIsInRange | Should -BeTrue -Because "Limit Depth ($($limitDepth + 1)) should be >= Actual Depth ($actualDepth)";
        }

        Invoke-TraverseDirectory -Path $resolvedSourcePath -Block $_genericTraverseBlock `
          -Summary $summary -Depth $Depth;
      }
    }

    Context 'and: directory tree and Hoist specified' {
      It 'should: traverse child directories whose ancestors don\`t match filter' {
        [scriptblock]$sessionSummary = {
          param(
            [int]$_count,
            [int]$_skipped,
            [int]$_errors,
            [boolean]$_trigger,
            [hashtable]$_exchange
          )

          $_count | Should -Be 11;
        }

        Invoke-TraverseDirectory -Path $resolvedSourcePath -Block $_genericTraverseBlock `
          -SessionSummary $sessionSummary -Condition $filterDirectories -Hoist;
      } # should: traverse child directories whose ancestors don\`t match filter

      Context 'and: <Depth>' {
        It 'should: not exceed depth limit and <ExpectedCount>' -TestCases @(
          @{ Depth = 0; ExpectedCount = 1; },
          @{ Depth = 1; ExpectedCount = 1; },
          @{ Depth = 2; ExpectedCount = 4; },
          @{ Depth = 3; ExpectedCount = 11; }
        ) {
          [scriptblock]$sessionSummary = {
            param(
              [int]$_count,
              [int]$_skipped,
              [int]$_errors,
              [boolean]$_trigger,
              [hashtable]$_exchange
            )

            $_count | Should -Be $ExpectedCount;
          }

          [scriptblock]$summary = {
            param(
              [int]$_count,
              [int]$_skipped,
              [int]$_errors,
              [boolean]$_trigger,
              [hashtable]$_exchange
            )
            [boolean]$depthIsInRange = test-IsDepthInRange -Exchange $_exchange
            [int]$actualDepth = $_exchange['LOOPZ.CONTROLLER.DEPTH'];
            [int]$limitDepth = $_exchange['LOOPZ.TRAVERSE.LIMIT-DEPTH'];

            $depthIsInRange | Should -BeTrue -Because "Limit Depth ($($limitDepth + 1)) should be >= Actual Depth ($actualDepth)";
          }

          Invoke-TraverseDirectory -Path $resolvedSourcePath -Block $_genericTraverseBlock `
            -Summary $summary -SessionSummary $sessionSummary -Condition $filterDirectories -Hoist -Depth $Depth;
        }
      }

      Context 'and: Skipped' {
        It 'should: increment skip' {
          $container = @{
            count = 0;
          }
          [scriptblock]$skipBlock = {
            param(
              [Parameter(Mandatory)]
              [System.IO.DirectoryInfo]$_underscore,

              [Parameter(Mandatory)]
              [int]$_index,

              [Parameter(Mandatory)]
              [hashtable]$_exchange,

              [Parameter(Mandatory)]
              [boolean]$_trigger
            )
            $skipped = $($container.count -le 4);
            Write-Debug "[+] Traverse with Hoist (Skipped); directory ($filter): '$($_underscore.Name)', index: $_index, Skipped: $skipped";
            @{ Product = $_underscore; Skipped = $skipped; }
            $container.count++;
          }

          [scriptblock]$summaryWithSkip = {
            param(
              [int]$_count,
              [int]$_skipped,
              [int]$_errors,
              [boolean]$_trigger,
              [hashtable]$_exchange
            )

            Write-Debug "  [Summary] Count: $_count, skipped: $_skipped, trigger: $_trigger";
            # $_count | Should -Be 5;
          }

          [hashtable]$passThruWithSkip = @{}
          Invoke-TraverseDirectory -Path $resolvedSourcePath -Block $skipBlock `
            -Summary $summaryWithSkip -Condition $filterDirectories -Hoist -Exchange $passThruWithSkip;
          # $passThruWithSkip['LOOPZ.TRAVERSE.SKIPPED'] | Should -Be 5; # this is just the top level invoke
        }
      } # and:: Skipped

      Context 'and: Error' {
        It 'should: increment error' {
          [scriptblock]$errorBlock = {
            param(
              [Parameter(Mandatory)]
              [System.IO.DirectoryInfo]$_underscore,

              [Parameter(Mandatory)]
              [int]$_index,

              [Parameter(Mandatory)]
              [hashtable]$_exchange,

              [Parameter(Mandatory)]
              [boolean]$_trigger
            )
            [PSCustomObject]$result = @{
              ErrorReason = 'the skies are falling';
            }
            return $result
          }

          [scriptblock]$summaryWithError = {
            param(
              [int]$_count,
              [int]$_skipped,
              [int]$_errors,
              [boolean]$_trigger,
              [hashtable]$_exchange
            )

            Write-Debug "  [Summary] Count: '$_count', skipped: '$_skipped', errors: '$_errors', trigger: '$_trigger'";
            $_errors | Should -Be $_count;
          }

          Invoke-TraverseDirectory -Path $resolvedSourcePath -Block $errorBlock `
            -Summary $summaryWithError -Condition $filterDirectories -Hoist;
        }

      } # and: Error
    } # and: directory tree and Hoist specified
  } # given: custom scriptblock specified

  Context 'given: custom function specified' {
    Context 'and: directory tree and Hoist specified' {
      It 'should: traverse child directories whose ancestors don\`t match filter' {
        function global:Test-HoistResult {
          [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
          param(
            [Parameter(Mandatory)]
            [System.IO.DirectoryInfo]$Underscore,

            [Parameter(Mandatory)]
            [int]$Index,

            [Parameter(Mandatory)]
            [hashtable]$Exchange,

            [Parameter(Mandatory)]
            [boolean]$Trigger,

            [Parameter(Mandatory = $false)]
            [string]$Format = "These aren't the droids you're looking for, ..., move along, move along!:___{0}___"
          )

          [string]$result = $Format -f ($Underscore.Name);
          Write-Debug "Custom function; Test-HoistResult: '$result'";
          @{ Product = $Underscore }
        }

        [scriptblock]$sessionSummary = {
          param(
            [int]$_count,
            [int]$_skipped,
            [int]$_errors,
            [boolean]$_trigger,
            [hashtable]$_exchange
          )

          $_count | Should -Be 11;
        }
        [hashtable]$parameters = @{
          'format' = "=== {0} ===";
        }

        Invoke-TraverseDirectory -Path $resolvedSourcePath -Functee 'Test-HoistResult' `
          -FuncteeParams $parameters -SessionSummary $sessionSummary -Condition $filterDirectories -Hoist;
      }
    }
  } # given: custom function specified

  Context 'given: block result' {
    Context 'and: trigger is fired' {
      Context 'and: single iteration' {
        It 'should: set trigger' {
          [string]$sourcePath = (Convert-Path '.\Tests\Data\traverse\Audio\MINIMAL\Richie Hawtin');
          Write-Debug "[+] === path: $sourcePath";

          [scriptblock]$traverseBlock = {
            param(
              $_underscore,
              [int]$_index,
              [hashtable]$_exchange,
              [boolean]$_trigger
            )
            Write-Debug "  [-] TEST-BLOCK(index: $_index): directory: $($_underscore.Name)";
            @{ Product = $_underscore; Trigger = $true }
          }

          [scriptblock]$summary = {
            param(
              [int]$_count,
              [int]$_skipped,
              [int]$_errors,
              [boolean]$_trigger,
              [hashtable]$_exchange
            )

            Write-Debug "--> TEST-SUMMARY(block/trigger/single): Count: $_count, Skipped: $_skipped, Trigger: $_trigger";
            $_trigger | Should -BeTrue;
          }

          Invoke-TraverseDirectory -Path $sourcePath -Block $traverseBlock `
            -Summary $summary;
        } # should: set trigger
      } # and: single iteration

      Context 'and: multiple iterations' {
        It 'should: set trigger' {
          [string]$sourcePath = (Convert-Path '.\Tests\Data\traverse\Audio\MINIMAL\Plastikman');
          Write-Debug "[+] === path: $sourcePath";

          [scriptblock]$traverseBlock = {
            param(
              $_underscore,
              [int]$_index,
              [hashtable]$_exchange,
              [boolean]$_trigger
            )

            $trigger = $_trigger;
            if ('EX' -eq $_underscore.Name) {
              $trigger = $true;
            }

            Write-Debug "  [-] TEST-BLOCK(index: $_index, trigger: $_trigger): directory: $($_underscore.Name)";
            @{ Product = $_underscore; Trigger = $trigger }
          }

          [scriptblock]$summary = {
            param(
              [int]$_count,
              [int]$_skipped,
              [int]$_errors,
              [boolean]$_trigger,
              [hashtable]$_exchange
            )

            Write-Debug "--> TEST-SUMMARY(block/trigger/multi): Count: $_count, Skipped: $_skipped, Trigger: $_trigger";
            $_trigger | Should -BeTrue;
          }

          Invoke-TraverseDirectory -Path $sourcePath -Block $traverseBlock `
            -Summary $summary;
        } # should: set trigger

        Context 'and: Hoist' {
          It 'should: set trigger' {
            [string]$sourcePath = (Convert-Path '.\Tests\Data\traverse\Audio\MINIMAL\Plastikman');
            Write-Debug "[+] === path: $sourcePath";

            [scriptblock]$traverseBlock = {
              param(
                $_underscore,
                [int]$_index,
                [hashtable]$_exchange,
                [boolean]$_trigger
              )

              $trigger = $_trigger;
              if ('EX' -eq $_underscore.Name) {
                $trigger = $true;
              }

              Write-Debug "  [-] TEST-BLOCK(index: $_index, trigger: $_trigger): directory: $($_underscore.Name)";
              @{ Product = $_underscore; Trigger = $trigger }
            }

            [scriptblock]$summary = {
              param(
                [int]$_count,
                [int]$_skipped,
                [int]$_errors,
                [boolean]$_trigger,
                [hashtable]$_exchange
              )

              Write-Debug "--> TEST-SUMMARY(block/trigger/multi/hoist): Count: $_count, Skipped: $_skipped, Trigger: $_trigger";
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
        It 'should: stop iterating' {
          [string]$sourcePath = (Convert-Path '.\Tests\Data\traverse\Audio\MINIMAL\Richie Hawtin');
          Write-Debug "[+] === path: $sourcePath";

          $container = @{
            count = 0
          }
          [scriptblock]$traverseBlock = {
            param(
              $_underscore,
              [int]$_index,
              [hashtable]$_exchange,
              [boolean]$_trigger
            )
            Write-Debug "  [-] TEST-BLOCK(index: $_index): directory: $($_underscore.Name)";
            $container.count++;
            @{ Product = $_underscore; Break = $true }
          }

          [scriptblock]$summary = {
            param(
              [int]$_count,
              [int]$_skipped,
              [int]$_errors,
              [boolean]$_trigger,
              [hashtable]$_exchange
            )

            Write-Debug "--> TEST-SUMMARY(block/break/single): Count: $_count, Skipped: $_skipped, Trigger: $_trigger";
            $container.count | Should -Be 1;
          }

          Invoke-TraverseDirectory -Path $sourcePath -Block $traverseBlock `
            -Summary $summary;
        } # should: stop iterating
      } # and: single iteration

      Context 'and: multiple iterations' {
        It 'should: stop iterating' {
          [string]$sourcePath = (Convert-Path '.\Tests\Data\traverse\Audio\MINIMAL\Plastikman');
          Write-Debug "[+] === path: $sourcePath";

          [scriptblock]$traverseBlock = {
            param(
              $_underscore,
              [int]$_index,
              [hashtable]$_exchange,
              [boolean]$_trigger
            )
            Write-Debug "  [-] TEST-BLOCK(index: $_index): directory: $($_underscore.Name)";

            $break = $false;
            if ('EX' -eq $_underscore.Name) {
              $break = $true;
            }
            @{ Product = $_underscore; Break = $break }
          }

          [scriptblock]$sessionSummary = {
            param(
              [int]$_count,
              [int]$_skipped,
              [int]$_errors,
              [boolean]$_trigger,
              [hashtable]$_exchange
            )

            Write-Debug "--> TEST-SUMMARY(block/break/multi): Count: $_count, Skipped: $_skipped, Trigger: $_trigger";
            $_count | Should -Be 4;
          }

          Invoke-TraverseDirectory -Path $sourcePath -Block $traverseBlock `
            -SessionSummary $sessionSummary;
        } # should: stop iterating
      } # and: multiple iterations
    } # and: break is fired
  } # given: block result

  Context 'given: fn result' {
    Context 'and: trigger is fired' {
      Context 'and: multiple iterations' {
        It 'should: stop iterating' {
          function global:Test-FireEXTrigger {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
            param(
              [Parameter(Mandatory)]
              [System.IO.DirectoryInfo]$Underscore,

              [Parameter(Mandatory)]
              [int]$Index,

              [Parameter(Mandatory)]
              [hashtable]$Exchange,

              [Parameter(Mandatory)]
              [boolean]$Trigger
            )
            $localTrigger = ('EX' -eq $Underscore.Name);
            Write-Host "  [-] Test-FireEXTrigger(index: $Index, local trigger: $localTrigger, Trigger: $Trigger): directory: $($Underscore.Name)";
            @{ Product = $Underscore; Trigger = $localTrigger }
          }

          Mock -ModuleName Elizium.Loopz Test-FireEXTrigger -Verifiable {
            param(
              [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
              [System.IO.DirectoryInfo]$Underscore,
              [int]$Index,
              [hashtable]$Exchange,
              [boolean]$Trigger
            )
            $localTrigger = ('EX' -eq $Underscore.Name);
            Write-Debug "  [-] MOCK Test-FireEXTrigger(index: $Index, local trigger: $localTrigger, Trigger: $Trigger): directory: $($Underscore.Name)";

            if (@('Musik', 'Sheet One') -contains $Underscore.Name) {
              $Trigger | Should -BeTrue;
            }
            @{ Product = $Underscore; Trigger = $localTrigger }
          }

          [string]$sourcePath = (Convert-Path '.\Tests\Data\traverse\Audio\MINIMAL\Plastikman');
          Write-Debug "[+] === path: $sourcePath";

          [scriptblock]$summary = {
            param(
              [int]$_count,
              [int]$_skipped,
              [int]$_errors,
              [boolean]$_trigger,
              [hashtable]$_exchange
            )

            Write-Debug "--> TEST-SUMMARY(fn/break/multi): Count: $_count, Skipped: $_skipped, Trigger: $_trigger";
            $_trigger | Should -BeTrue;
          }

          Invoke-TraverseDirectory -Path $sourcePath -Functee 'Test-FireEXTrigger' `
            -Summary $summary;
        } # should: stop iterating
      } # and: multiple iterations      
    } # and: trigger is fired

    Context 'and: break is fired' {
      BeforeAll {
        function global:Test-FireBreakOnFirstItem {
          [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
          param(
            [Parameter(Mandatory)]
            [System.IO.DirectoryInfo]$Underscore,

            [Parameter(Mandatory)]
            [int]$Index,

            [Parameter(Mandatory)]
            [hashtable]$Exchange,

            [Parameter(Mandatory)]
            [boolean]$Trigger
          )
          Write-Host "  [-] Test-FireBreakOnFirstItem(index: $Index): directory: $($Underscore.Name)";
          @{ Product = $Underscore; Break = $true }
        }
      }

      It 'should: stop iterating' -Skip {
        Mock -ModuleName Elizium.Loopz Test-FireBreakOnFirstItem -Verifiable {
          param(
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
            [System.IO.DirectoryInfo]$Underscore,
            [int]$Index,
            [hashtable]$Exchange,
            [boolean]$Trigger
          )
          $break = ('EX' -eq $Underscore.Name);
          Write-Debug "  [-] MOCK Test-FireBreakOnFirstItem(index: $Index, directory: $($Underscore.Name)";

          @{ Product = $Underscore; Break = $break }
        } # Mock

        [string]$sourcePath = (Convert-Path '.\Tests\Data\traverse\Audio\MINIMAL\Plastikman');
        Write-Debug "[+] === path: $sourcePath";

        Invoke-TraverseDirectory -Path $sourcePath -Functee 'Test-FireBreakOnFirstItem';
        Assert-MockCalled Test-FireBreakOnFirstItem -ModuleName Elizium.Loopz -Times 1;
      } # should: stop iterating

      Context 'and: Hoist' {
        It 'should: stop iterating and contain correct count in Exchange' -Skip {
          # The problem with this test is that it is not platform independent. This
          # is not because of this test, rather it is because Get-ChildItem which is
          # invoked in Invoke-TraverseDirectory, does not return child items in the
          # same order on different platforms, so it is difficult to test based upon
          # the number of times the Mock is called. The only way to test this reliably
          # is to break on the first item.
          #
          Mock -ModuleName Elizium.Loopz Test-FireBreakOnFirstItem -Verifiable {
            param(
              [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
              [System.IO.DirectoryInfo]$Underscore,
              [int]$Index,
              [hashtable]$Exchange,
              [boolean]$Trigger
            )
            $break = ('EX' -eq $Underscore.Name);
            Write-Debug "  [-] MOCK Test-FireBreakOnFirstItem(index: $Index, directory: $($Underscore.Name)";

            @{ Product = $Underscore; Break = $break }
          } # Mock

          [string]$sourcePath = (Convert-Path '.\Tests\Data\traverse\Audio');
          Write-Debug "[+] === path: $sourcePath";

          [hashtable]$verifiedCountPassThru = @{}
          Invoke-TraverseDirectory -Path $sourcePath -Functee 'Test-FireBreakOnFirstItem' `
            -Condition $filterDirectories -Hoist -Exchange $verifiedCountPassThru;
          Assert-MockCalled Test-FireBreakOnFirstItem -ModuleName Elizium.Loopz -Times 1;
          $verifiedCountPassThru['LOOPZ.TRAVERSE.COUNT'] | Should -Be 1;
        } # should: stop iterating
      } # and: Hoist
    } # and: break is fired
  } # given: fn result
} # Invoke-TraverseDirectory
