
Describe 'controller' {

  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;

    InModuleScope Elizium.Loopz {
      [scriptblock]$script:_Header = {
        param(
          [hashtable]$_passThru
        )
      };

      [scriptblock]$script:_Summary = {
        param(
          [int]$_count,
          [int]$_skipped,
          [boolean]$_trigger,
          [hashtable]$_passThru
        )
      };

      [scriptblock]$script:_SessionHeader = {
        param(
          [hashtable]$_passThru
        )
      };
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
              [int]$_count,
              [int]$_skipped,
              [boolean]$_trigger,
              [hashtable]$_passThru
            )
            $_count | Should -Be 1;
            $_skipped | Should -Be 0;
          };

          [hashtable]$passThru = @{}

          $controller = New-Controller -Type ForeachCtrl -PassThru $passThru -Header $_Header -Summary $summary;
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
              [int]$_count,
              [int]$_skipped,
              [boolean]$_trigger,
              [hashtable]$_passThru
            )
            $_count | Should -Be 2;
            $_skipped | Should -Be 3;
          };
          [hashtable]$passThru = @{}

          $controller = New-Controller -Type ForeachCtrl -PassThru $passThru -Header $_Header -Summary $summary;
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
              [int]$_count,
              [int]$_skipped,
              [boolean]$_trigger,
              [hashtable]$_passThru
            )
            $_count | Should -Be 2;
            $_skipped | Should -Be 3;
          };
          [hashtable]$passThru = @{}

          $controller = New-Controller -Type TraverseCtrl -PassThru $passThru `
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
              [int]$_count,
              [int]$_skipped,
              [boolean]$_trigger,
              [hashtable]$_passThru
            )
            $_count | Should -Be 12;
            $_skipped | Should -Be 0;
          };
          [hashtable]$passThru = @{}

          $controller = New-Controller -Type TraverseCtrl -PassThru $passThru `
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
                  $passThru['LOOPZ.CONTROLLER.STACK'].Peek().Value() | Should -Be 3;
                  $passThru['LOOPZ.CONTROLLER.DEPTH'] | Should -Be 4;

                  $controller.ForeachEnd();
                }
                $controller.RequestIndex();
                $controller.HandleResult(@{
                    Product = "$_ Inner Widget(s)"
                  });
              }
              $passThru['LOOPZ.CONTROLLER.STACK'].Peek().Value() | should -Be 4;
              $passThru['LOOPZ.CONTROLLER.DEPTH'] | Should -Be 3;

              $controller.ForeachEnd();
            }
            $controller.RequestIndex();
            $controller.HandleResult(@{
                Product = "$_ Widget(s)"
              });
          }
          $passThru['LOOPZ.CONTROLLER.STACK'].Peek().Value() | Should -Be 5;
          $passThru['LOOPZ.CONTROLLER.DEPTH'] | Should -Be 2;

          $controller.ForeachEnd();

          $passThru['LOOPZ.CONTROLLER.DEPTH'] | Should -Be 1;
          $controller.EndSession();

          $passThru['LOOPZ.CONTROLLER.DEPTH'] | Should -Be 0;
          $passThru['LOOPZ.CONTROLLER.STACK'] | Should -BeNullOrEmpty;
        }
      } # should: traverse multiple depths
    } # and: multiple depth iteration
  } # given: TraverseController
} # controller
