
Describe 'controller' -Tag 'Current' {

  BeforeAll {
    . .\Internal\controller.class.ps1

    [scriptblock]$script:_Header = {
      param(
        [System.Collections.Hashtable]$_passThru
      )
    };

    [scriptblock]$script:_Summary = {
      param(
        [int]$_count,
        [int]$_skipped,
        [boolean]$_trigger,
        [System.Collections.Hashtable]$_passThru
      )
    };

    [scriptblock]$script:_SessionHeader = {
      param(
        [System.Collections.Hashtable]$_passThru
      )
    };
  }

  Context 'given: ForeachController' {
    Context 'and: Single index requested' {
      It 'should: iterate once' {
        [scriptblock]$summary = {
          param(
            [int]$_count,
            [int]$_skipped,
            [boolean]$_trigger,
            [System.Collections.Hashtable]$_passThru
          )
          $_count | Should -Be 1;
          $_skipped | Should -Be 0;
        };

        [System.Collections.Hashtable]$passThru = @{}

        $controller = New-Controller -Type ForeachCtrl -PassThru $passThru -Header $_Header -Summary $summary;
        $controller.ForeachBegin();
        $controller.RequestIndex();
        $controller.HandleResult(@{
            Product = 'Greetings'
          });
        $controller.ForeachEnd();
        $controller.Skipped() | Should -Be 0;
      } # should: iterate once
    } # and: Single index requested

    Context 'and: Single index requested' {
      It 'should: iterate multiple times' {
        [scriptblock]$summary = {
          param(
            [int]$_count,
            [int]$_skipped,
            [boolean]$_trigger,
            [System.Collections.Hashtable]$_passThru
          )
          $_count | Should -Be 2;
          $_skipped | Should -Be 3;
        };
        [System.Collections.Hashtable]$passThru = @{}

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
      } # should: iterate multiple times
    } # and: Single index requested
  }

  Context 'given: TraverseController' {
    Context 'and: single depth iteration' {
      It 'should: iterate single level multiple times' {
        [scriptblock]$sessionSummary = {
          param(
            [int]$_count,
            [int]$_skipped,
            [boolean]$_trigger,
            [System.Collections.Hashtable]$_passThru
          )
          $_count | Should -Be 2;
          $_skipped | Should -Be 3;
        };
        [System.Collections.Hashtable]$passThru = @{}

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
      } # should: iterate single level multiple times
    } # and: single depth iteration

    Context 'and: multiple depth iteration' {
      It 'should: iterate single level multiple times' {
        [scriptblock]$sessionSummary = {
          param(
            [int]$_count,
            [int]$_skipped,
            [boolean]$_trigger,
            [System.Collections.Hashtable]$_passThru
          )
          $_count | Should -Be 10;
          $_skipped | Should -Be 0;
        };
        [System.Collections.Hashtable]$passThru = @{}

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
                $passThru['LOOPZ.CONTROLLER.STACK'].Peek().Value() | Should -Be 3; # (0..2)

                $controller.ForeachEnd();
              } else {
                $controller.RequestIndex();
                $controller.HandleResult(@{
                    Product = "$_ Inner Widget(s)"
                  });
              }
            }
            $passThru['LOOPZ.CONTROLLER.STACK'].Peek().Value() | should -Be 3; # (1..3)

            $controller.ForeachEnd();
          } else {
            $controller.RequestIndex();
            $controller.HandleResult(@{
                Product = "$_ Widget(s)"
              });
          }
        }
        $passThru['LOOPZ.CONTROLLER.STACK'].Peek().Value() | Should -Be 4; # (1..4)

        $controller.ForeachEnd();
        $controller.EndSession();
      }
    } # and: multiple depth iteration
  } # given: TraverseController
} # controller
