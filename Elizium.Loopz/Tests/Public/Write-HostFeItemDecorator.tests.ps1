
Describe 'Write-HostFeItemDecorator' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking

    [scriptblock]$script:decorator = {
      param(
        $_underscore, $_index, $_passthru, $_trigger
      )

      return Write-HostFeItemDecorator -Underscore $_underscore `
        -Index $_index `
        -PassThru $_passthru `
        -Trigger $_trigger
    }
  }

  Context 'given: Invoke Result contains Pairs' {
    [System.Collections.Hashtable]$script:_passThru = @{
      'LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME' = 'get-AnswerAdvancedFn';
      'LOOPZ.WH-FOREACH-DECORATOR.MESSAGE'       = 'Test Advanced Function';
      'LOOPZ.WH-FOREACH-DECORATOR.KRAYOLA-THEME' = $(Get-KrayolaTheme);
      'LOOPZ.WH-FOREACH-DECORATOR.PRODUCT-LABEL' = 'Test product';
      'LOOPZ.WH-FOREACH-DECORATOR.WHAT-IF'       = $false;
    }

    Context 'and: contains single item' {
      It 'should: invoke and write' -Tag 'Current' {
        Mock get-AnswerAdvancedFn -ModuleName Elizium.Loopz {
          ([PSCustomObject]@{ Pairs = , @(, @('Author', 'Douglas Madcap Adams')) })
        }

        Mock Write-ThemedPairsInColour -ModuleName Elizium.Loopz {
          param(
            [string[][]]$Pairs,
            [System.Collections.Hashtable]$Theme,
            [string]$Message
          )
          $first = $Pairs[1];
          $first[0] | Should -BeExactly 'Author';
          $first[1] | Should -BeExactly 'Douglas Madcap Adams';
        }

        $underscore = 'What is the answer to the universe';
        $decorator.Invoke($underscore, 0, $_passThru, $false);
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
            [System.Collections.Hashtable]$Theme,
            [string]$Message
          )
          $second = $Pairs[2];
          $second[0] | Should -BeExactly 'Genre';
          $second[1] | Should -BeExactly 'Sci-Fi';
        }

        $underscore = 'What is the answer to the universe';
        $decorator.Invoke($underscore, 0, $_passThru, $false);
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
            [System.Collections.Hashtable]$Theme,
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


        $underscore = 'What is the answer to the universe';
        $decorator.Invoke($underscore, 0, $_passThru, $false);
      } # should: invoke and write
    } # and: contains many items
  } # given: Invoke Result contains Pairs

  Context 'given: IF-TRIGGERED is set' {
    Context 'and: an item sets the Trigger' {
      It 'should: invoke Write-ThemedPairsInColour' {
        Mock Write-ThemedPairsInColour -ModuleName Elizium.Loopz -Verifiable { }

        [System.Collections.Hashtable]$passThru = @{
          'LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME' = 'get-AnswerAdvancedFnWithTrigger';
          'ANSWER'                                   = 'Fourty Two';
          'LOOPZ.WH-FOREACH-DECORATOR.MESSAGE'       = 'Test Advanced Function';
          'LOOPZ.WH-FOREACH-DECORATOR.KRAYOLA-THEME' = $(Get-KrayolaTheme);
          'LOOPZ.WH-FOREACH-DECORATOR.PRODUCT-LABEL' = 'Test product';
          'LOOPZ.WH-FOREACH-DECORATOR.WHAT-IF'       = $false;
          'LOOPZ.WH-FOREACH-DECORATOR.IF-TRIGGERED'  = $true;
        }

        $underscore = 'What is the answer to the universe';
        $decorator.Invoke($underscore, 0, $passThru, $false);

        Assert-MockCalled Write-ThemedPairsInColour -ModuleName Elizium.Loopz -Times 1;
      } # should: invoke Write-ThemedPairsInColour
    } # and: IF-TRIGGERED is set

    Context 'and: an item does not sets the Trigger' {
      It 'should: NOT invoke Write-ThemedPairsInColour' {
        Mock Write-ThemedPairsInColour -ModuleName Elizium.Loopz -Verifiable { }

        [System.Collections.Hashtable]$passThru = @{
          'LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME' = 'get-AnswerAdvancedFn';
          'ANSWER'                                   = 'Fourty Two';
          'LOOPZ.WH-FOREACH-DECORATOR.MESSAGE'       = 'Test Advanced Function';
          'LOOPZ.WH-FOREACH-DECORATOR.KRAYOLA-THEME' = $(Get-KrayolaTheme);
          'LOOPZ.WH-FOREACH-DECORATOR.PRODUCT-LABEL' = 'Test product';
          'LOOPZ.WH-FOREACH-DECORATOR.WHAT-IF'       = $false;
          'LOOPZ.WH-FOREACH-DECORATOR.IF-TRIGGERED'  = $true;
        }

        $underscore = 'What is the answer to the universe';
        $decorator.Invoke($underscore, 0, $passThru, $false);

        Assert-MockCalled Write-ThemedPairsInColour -ModuleName Elizium.Loopz -Times 0;
      } # should: NOT invoke Write-ThemedPairsInColour
    } # and: IF-TRIGGERED is set
  } # given: IF-TRIGGERED is set
} # Write-HostFeItemDecorator
