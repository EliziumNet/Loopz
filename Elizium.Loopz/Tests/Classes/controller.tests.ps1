
Describe 'controller' {

  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;

    InModuleScope Elizium.Loopz {
      [scriptblock]$script:_Header = {
        param(
          [hashtable]$_exchange
        )
      };

      [scriptblock]$script:_Summary = {
        param(
          [int]$count,
          [int]$skipped,
          [int]$errors,
          [boolean]$trigger,
          [hashtable]$exchange
        )
      };

      [scriptblock]$script:_SessionHeader = {
        param(
          [hashtable]$exchange
        )
      };

      [hashtable]$script:_theme = Get-KrayolaTheme;
    }
  }

  BeforeEach {
    InModuleScope Elizium.Loopz {
      [Krayon]$krayon = New-Krayon($_theme);
      [Scribbler]$script:scribbler = New-Scribbler -Krayon $krayon -Test;

      [hashtable]$script:_exchange = @{
        'LOOPZ.SCRIBBLER' = $scribbler;
      }
    }
  }

  # NB, it would be useful to be able to test Header/Summary with Mocks. However, Pester
  # Mocks can't work with class methods; they only work with named functions, so this
  # aspect of the controller, unfortunately can't be tested.
  #
  Context 'given: ForeachController' {
    Context 'and: single index requested' {
      It 'should: iterate once' {
        InModuleScope Elizium.Loopz {
          [scriptblock]$summary = {
            param(
              [int]$count,
              [int]$skipped,
              [int]$errors,
              [boolean]$trigger,
              [hashtable]$exchange
            )
            $count | Should -Be 1;
            $skipped | Should -Be 0;
          };

          $controller = New-Controller -Type ForeachCtrl -Exchange $_exchange -Header $_Header -Summary $summary;
          $controller.ForeachBegin();
          $controller.RequestIndex();
          $controller.HandleResult(@{
              Product = 'Greetings'
            });
          $controller.ForeachEnd();
          $controller.Skipped() | Should -Be 0;
        }
      } # should: iterate once
    } # and:single index requested

    Context 'and: multiple indices requested without break' {
      # NB: testing the Break/Skip functionality of the controller doesn't really make sense
      # because we'd have to replicate the break/skip iteration logic that resides in the
      # client function(s) (eg Invoke-ForeachFsItem) in the test which would be totally pointless.
      # Instead, this break/skip logic is tested in the tests for Invoke-ForeachFsItem.
      # 
      It 'should: iterate multiple times' {
        InModuleScope Elizium.Loopz {
          [scriptblock]$summary = {
            param(
              [int]$count,
              [int]$skipped,
              [int]$errors,
              [boolean]$trigger,
              [hashtable]$exchange
            )
            $count | Should -Be 2;
            $skipped | Should -Be 3;
          };

          $controller = New-Controller -Type ForeachCtrl -Exchange $_exchange -Header $_Header -Summary $summary;
          $controller.ForeachBegin();
          0..4 | Foreach-Object {
            if ($_ -gt 2 ) {
              $controller.RequestIndex();
              $controller.HandleResult(@{
                  Product = "$_ Widget(s)"
                });
            }
            else {
              $controller.SkipItem();
            }
          }
          $controller.Skipped() | Should -Be 3;
          $controller.ForeachEnd();
        }
      } # should: iterate multiple times
    } # and: multiple indices requested without break
  } # given: ForeachController

  Context 'given: TraverseController' {
    Context 'and: single depth iteration' {
      It 'should: iterate single level multiple times' {
        InModuleScope Elizium.Loopz {
          [scriptblock]$sessionSummary = {
            param(
              [int]$count,
              [int]$skipped,
              [int]$errors,
              [boolean]$trigger,
              [hashtable]$exchange
            )
            $count | Should -Be 2;
            $skipped | Should -Be 3;
          };

          $controller = New-Controller -Type TraverseCtrl -Exchange $_exchange `
            -Header $_Header -Summary $_Summary -SessionHeader $_SessionHeader -SessionSummary $sessionSummary;
          $controller.BeginSession();
          $controller.ForeachBegin();

          0..4 | Foreach-Object {
            if ($_ -gt 2 ) {
              $controller.RequestIndex();
              $controller.HandleResult(@{
                  Product = "$_ Widget(s)"
                });
            }
            else {
              $controller.SkipItem();
            }
          }
          $controller.ForeachEnd();
          $controller.EndSession();
        }
      } # should: iterate single level multiple times
    } # and: single depth iteration

    Context 'and: multiple depth iteration' {
      It 'should: traverse multiple depths' {
        InModuleScope Elizium.Loopz {
          [scriptblock]$sessionSummary = {
            param(
              [int]$count,
              [int]$skipped,
              [int]$errors,
              [boolean]$trigger,
              [hashtable]$exchange
            )
            $count | Should -Be 12;
            $skipped | Should -Be 0;
          };
          $controller = New-Controller -Type TraverseCtrl -Exchange $_exchange `
            -Header $_Header -Summary $_Summary -SessionHeader $_SessionHeader -SessionSummary $sessionSummary;

          $controller.BeginSession();
          $controller.ForeachBegin();

          # This replicates navigating a directory structure
          #
          0..4 | Foreach-Object {
            if ($_ -eq 0) {
              $controller.ForeachBegin();
              0..3 | ForEach-Object {
                if ($_ -eq 0) {
                  $controller.ForeachBegin();

                  0..2 | ForEach-Object {
                    $controller.RequestIndex();
                    $controller.HandleResult(@{
                        Product = "$_ Deeper Widget(s)"
                      });
                  }
                  $_exchange['LOOPZ.CONTROLLER.STACK'].Peek().Value() | Should -Be 3;
                  $_exchange['LOOPZ.CONTROLLER.DEPTH'] | Should -Be 4;

                  $controller.ForeachEnd();
                }
                $controller.RequestIndex();
                $controller.HandleResult(@{
                    Product = "$_ Inner Widget(s)"
                  });
              }
              $_exchange['LOOPZ.CONTROLLER.STACK'].Peek().Value() | should -Be 4;
              $_exchange['LOOPZ.CONTROLLER.DEPTH'] | Should -Be 3;

              $controller.ForeachEnd();
            }
            $controller.RequestIndex();
            $controller.HandleResult(@{
                Product = "$_ Widget(s)"
              });
          }
          $_exchange['LOOPZ.CONTROLLER.STACK'].Peek().Value() | Should -Be 5;
          $_exchange['LOOPZ.CONTROLLER.DEPTH'] | Should -Be 2;

          $controller.ForeachEnd();

          $_exchange['LOOPZ.CONTROLLER.DEPTH'] | Should -Be 1;
          $controller.EndSession();

          $_exchange['LOOPZ.CONTROLLER.DEPTH'] | Should -Be 0;
          $_exchange['LOOPZ.CONTROLLER.STACK'] | Should -BeNullOrEmpty;
        }
      } # should: traverse multiple depths
    } # and: multiple depth iteration
  } # given: TraverseController
} # controller
