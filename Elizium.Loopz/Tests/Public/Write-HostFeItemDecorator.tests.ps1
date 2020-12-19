
Describe 'Write-HostFeItemDecorator' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking

    InModuleScope Elizium.Loopz {
      [scriptblock]$script:decorator = {
        param(
          $_underscore, $_index, $_passthru, $_trigger
        )

        return Write-HostFeItemDecorator -Underscore $_underscore `
          -Index $_index `
          -PassThru $_passthru `
          -Trigger $_trigger
      }

      [hashtable]$script:_passThru = @{
        'LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME' = 'get-AnswerAdvancedFn';
        'LOOPZ.WH-FOREACH-DECORATOR.MESSAGE'       = 'Test Advanced Function';
        'LOOPZ.KRAYOLA-THEME'                      = $(Get-KrayolaTheme);
        'LOOPZ.WH-FOREACH-DECORATOR.PRODUCT-LABEL' = 'Test product';
        'WHAT-IF'                                  = $false;
      }

      function script:get-AnswerAdvancedFn {

        # This function is only required because the tests using the invoke operator
        # on a string can not correctly pick up the local function name (ie defined as part
        # of the test fixture) and see its definition to be invoked.
        #
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
        [CmdletBinding(SupportsShouldProcess)]
        param(
          [Parameter(Mandatory)]
          $Underscore,

          [Parameter(Mandatory)]
          [int]$Index,

          [Parameter(Mandatory)]
          [hashtable]$PassThru,

          [Parameter(Mandatory)]
          [boolean]$Trigger
        )

        [PSCustomObject]@{ Product = "{0}: {1}" -f $Underscore, $PassThru['ANSWER'] }
      }
    } # InModuleScope Elizium.Loopz
  } # BeforeAll

  Context 'given: Invoke Result contains Pairs' {
    Context 'and: contains single item' {
      It 'should: invoke and write' {
        Mock get-AnswerAdvancedFn -ModuleName Elizium.Loopz {
          ([PSCustomObject]@{ Pairs = , @(, @('Author', 'Douglas Madcap Adams')) })
        }

        Mock Write-ThemedPairsInColour -ModuleName Elizium.Loopz {
          param(
            [string[][]]$Pairs,
            [hashtable]$Theme,
            [string]$Message
          )
          $first = $Pairs[1];
          $first[0] | Should -BeExactly 'Author';
          $first[1] | Should -BeExactly 'Douglas Madcap Adams';
        }

        InModuleScope ELizium.Loopz {
          $underscore = 'What is the answer to the universe';
          $decorator.Invoke($underscore, 0, $_passThru, $false);
        }
      }

      Context 'and: using pre-defined WhItemDecoratorBlock' {
        It 'should: invoke and write' {
          Mock get-AnswerAdvancedFn -ModuleName Elizium.Loopz {
            ([PSCustomObject]@{ Pairs = , @(, @('Author', 'Douglas Madcap Adams')) })
          }

          Mock Write-ThemedPairsInColour -ModuleName Elizium.Loopz {
            param(
              [string[][]]$Pairs,
              [hashtable]$Theme,
              [string]$Message
            )
            $first = $Pairs[1];
            $first[0] | Should -BeExactly 'Author';
            $first[1] | Should -BeExactly 'Douglas Madcap Adams';
          }

          InModuleScope ELizium.Loopz {
            $underscore = 'What is the answer to the universe';
            $LoopzHelpers.WhItemDecoratorBlock.Invoke($underscore, 0, $_passThru, $false);
          }
        }
      }
    } # and: contains single item

    Context 'and: contains 2 items' {
      It 'should: invoke and write' {
        Mock get-AnswerAdvancedFn -ModuleName Elizium.Loopz {
          ([PSCustomObject]@{ Pairs = @(@('Author', 'Douglas Adams'), @('Genre', 'Sci-Fi')) })
        }

        Mock Write-ThemedPairsInColour -ModuleName Elizium.Loopz {
          param(
            [string[][]]$Pairs,
            [hashtable]$Theme,
            [string]$Message
          )
          $second = $Pairs[2];
          $second[0] | Should -BeExactly 'Genre';
          $second[1] | Should -BeExactly 'Sci-Fi';
        }

        InModuleScope ELizium.Loopz {
          $underscore = 'What is the answer to the universe';
          $decorator.Invoke($underscore, 0, $_passThru, $false);
        }
      }
    } # and: contains 2 items

    Context 'and: contains many items' {
      It 'should: invoke and write' {
        Mock get-AnswerAdvancedFn -ModuleName Elizium.Loopz {
          ([PSCustomObject]@{ Pairs = @(@('One', 'A'), @('Two', 'B'), @('Three', 'C'), @('Four', 'D')) })
        }

        Mock Write-ThemedPairsInColour -ModuleName Elizium.Loopz {
          param(
            [string[][]]$Pairs,
            [hashtable]$Theme,
            [string]$Message
          )

          # NB: The item in position 0, is the item no
          #
          $first = $Pairs[1]
          $second = $Pairs[2];
          $third = $Pairs[3];
          $fourth = $Pairs[4];

          $first[0] | Should -BeExactly 'One';
          $first[1] | Should -BeExactly 'A';

          $second[0] | Should -BeExactly 'Two';
          $second[1] | Should -BeExactly 'B';

          $third[0] | Should -BeExactly 'Three';
          $third[1] | Should -BeExactly 'C';

          $fourth[0] | Should -BeExactly 'Four';
          $fourth[1] | Should -BeExactly 'D';
        }

        InModuleScope ELizium.Loopz {
          $underscore = 'What is the answer to the universe';
          $decorator.Invoke($underscore, 0, $_passThru, $false);
        }
      } # should: invoke and write
    } # and: contains many items
  } # given: Invoke Result contains Pairs

  Context 'given: Product is Affirmed' {
    It 'should: write affirmed Product' {
      Mock Write-ThemedPairsInColour -ModuleName Elizium.Loopz {
        param(
          [string[][]]$Pairs,
          [hashtable]$Theme,
          [string]$Message
        )
        $productValue = $Pairs[1];
        $productValue[1] | Should -BeExactly 'The owls are not what they seem';
        $productValue[2] | Should -BeTrue; # affirm value
      }

      InModuleScope Elizium.Loopz {
        function get-AffirmedProduct {
          [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
          [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
          param(
            [Alias('Underscore')]
            [System.IO.FileInfo]$FileInfo,
            [int]$Index,
            [hashtable]$PassThru,
            [boolean]$Trigger
          )

          [PSCustomObject]@{ Product = $FileInfo; Affirm = $true }
        }

        $myPassThru = $_passThru.Clone();
        $myPassThru['LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME'] = 'get-AffirmedProduct';

        $underscore = 'The owls are not what they seem';
        $decorator.Invoke($underscore, 0, $myPassThru, $false);
      }
    } # should: write affirmed Product
  } # given: Product is Affirmed

  Context 'given: IF-TRIGGERED is set' {
    Context 'and: an item sets the Trigger' {
      It 'should: invoke Write-ThemedPairsInColour' {
        Mock Write-ThemedPairsInColour -ModuleName Elizium.Loopz -Verifiable { }

        InModuleScope Elizium.Loopz {
          function get-AnswerAdvancedFnWithTrigger {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
            [CmdletBinding(SupportsShouldProcess)]
            param(
              [Parameter(Mandatory)]
              $Underscore,

              [Parameter(Mandatory)]
              [int]$Index,

              [Parameter(Mandatory)]
              [hashtable]$PassThru,

              [Parameter(Mandatory)]
              [boolean]$Trigger
            )

            [PSCustomObject]@{ Product = ("{0}: {1}" -f $Underscore, $PassThru['ANSWER']);
              Trigger                  = $true 
            }
          }

          [hashtable]$passThru = @{
            'LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME' = 'get-AnswerAdvancedFnWithTrigger';
            'ANSWER'                                   = 'Fourty Two';
            'LOOPZ.WH-FOREACH-DECORATOR.MESSAGE'       = 'Test Advanced Function';
            'LOOPZ.KRAYOLA-THEME'                      = $(Get-KrayolaTheme);
            'LOOPZ.WH-FOREACH-DECORATOR.PRODUCT-LABEL' = 'Test product';
            'WHAT-IF'                                  = $false;
            'LOOPZ.WH-FOREACH-DECORATOR.IF-TRIGGERED'  = $true;
          }

          $underscore = 'What is the answer to the universe';
          $decorator.Invoke($underscore, 0, $passThru, $false);

          Assert-MockCalled Write-ThemedPairsInColour -ModuleName Elizium.Loopz -Times 1;
        }
      } # should: invoke Write-ThemedPairsInColour
    } # and: IF-TRIGGERED is set

    Context 'and: an item does not sets the Trigger' {
      It 'should: NOT invoke Write-ThemedPairsInColour' {
        Mock Write-ThemedPairsInColour -ModuleName Elizium.Loopz -Verifiable { }

        InModuleScope Elizium.Loopz {
          [hashtable]$passThru = @{
            'LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME' = 'get-AnswerAdvancedFn';
            'ANSWER'                                   = 'Fourty Two';
            'LOOPZ.WH-FOREACH-DECORATOR.MESSAGE'       = 'Test Advanced Function';
            'LOOPZ.KRAYOLA-THEME'                      = $(Get-KrayolaTheme);
            'LOOPZ.WH-FOREACH-DECORATOR.PRODUCT-LABEL' = 'Test product';
            'WHAT-IF'                                  = $false;
            'LOOPZ.WH-FOREACH-DECORATOR.IF-TRIGGERED'  = $true;
          }

          $underscore = 'What is the answer to the universe';
          $decorator.Invoke($underscore, 0, $passThru, $false);

          Assert-MockCalled Write-ThemedPairsInColour -ModuleName Elizium.Loopz -Times 0;
        }
      } # should: NOT invoke Write-ThemedPairsInColour
    } # and: IF-TRIGGERED is set
  } # given: IF-TRIGGERED is set
} # Write-HostFeItemDecorator
