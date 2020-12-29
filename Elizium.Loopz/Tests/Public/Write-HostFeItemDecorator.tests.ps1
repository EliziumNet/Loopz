using module Elizium.Krayola;

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

  BeforeEach {
    InModuleScope Elizium.Loopz {
      [hashtable]$theme = $(Get-KrayolaTheme);
      [writer]$writer = New-Writer -Theme $theme;
      $_passThru['LOOPZ.WRITER'] = $writer;
    }
  }

  Context 'given: Invoke Result contains Pairs' {
    Context 'and: contains single item' {
      It 'should: invoke and write' {
        Mock get-AnswerAdvancedFn -ModuleName Elizium.Loopz {
          ([PSCustomObject]@{ Pairs = [line]::new(@($(kp('Author', 'Douglas Madcap Adams !!!')))) })
        }

        InModuleScope ELizium.Loopz {
          $underscore = 'What is the answer to the universe';
          $decorator.Invoke($underscore, 0, $_passThru, $false);
        }
      }

      Context 'and: using pre-defined WhItemDecoratorBlock' {
        It 'should: invoke and write' {
          Mock get-AnswerAdvancedFn -ModuleName Elizium.Loopz {
            ([PSCustomObject]@{ Pairs = [line]::new(@($(kp(@('Author', 'Douglas Madcap Adams'))))) })
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
          ([PSCustomObject]@{ Pairs = [line]::new(
                @( $(kp('Author', 'Douglas Adams')), $(kp('Genre', 'Sci-Fi'))) )
            })
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
          ([PSCustomObject]@{
              Pairs = [line]::new(
                @(
                  $(kp('One', 'A')),
                  $(kp('Two', 'B')),
                  $(kp('Three', 'C')),
                  $(kp('Four', 'D'))
                )
              )
            })
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

          [hashtable]$theme = $(Get-KrayolaTheme);
          [hashtable]$passThru = @{
            'LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME' = 'get-AnswerAdvancedFnWithTrigger';
            'ANSWER'                                   = 'Fourty Two';
            'LOOPZ.WH-FOREACH-DECORATOR.MESSAGE'       = 'Test Advanced Function';
            'LOOPZ.KRAYOLA-THEME'                      = $theme;
            'LOOPZ.WH-FOREACH-DECORATOR.PRODUCT-LABEL' = 'Test product';
            'WHAT-IF'                                  = $false;
            'LOOPZ.WH-FOREACH-DECORATOR.IF-TRIGGERED'  = $true;
            'LOOPZ.WRITER'                             = New-Writer -Theme $theme;
          }

          $underscore = 'What is the answer to life, love and unity';
          $decorator.Invoke($underscore, 0, $passThru, $false);
        }
      } # should: invoke Write-ThemedPairsInColour
    } # and: IF-TRIGGERED is set

    Context 'and: an item does not sets the Trigger' {
      It 'should: NOT invoke Write-ThemedPairsInColour' {
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
        }
      } # should: NOT invoke Write-ThemedPairsInColour
    } # and: IF-TRIGGERED is set
  } # given: IF-TRIGGERED is set
} # Write-HostFeItemDecorator
