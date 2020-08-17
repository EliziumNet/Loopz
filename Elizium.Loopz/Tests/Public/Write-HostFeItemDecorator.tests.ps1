
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

  Context 'given: PassThru contains ITEM-LABEL/VALUE' -Tag 'DUFF' {
    Context 'given: a function' {
      It 'should: invoke the function' {
        Mock Write-ThemedPairsInColour -ModuleName Elizium.Loopz { }

        [System.Collections.Hashtable]$passThru = @{
          'LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME' = 'get-AnswerAdvancedFn';
          'ANSWER'                                   = 'Fourty Two';
          'LOOPZ.WH-FOREACH-DECORATOR.MESSAGE'       = 'Test Advanced Function';
          'LOOPZ.WH-FOREACH-DECORATOR.KRAYOLA-THEME' = $(Get-KrayolaTheme);
          'LOOPZ.WH-FOREACH-DECORATOR.ITEM-LABEL'    = 'Question';
          'LOOPZ.WH-FOREACH-DECORATOR.ITEM-VALUE'    = 'The Wrong Answer';
          'LOOPZ.WH-FOREACH-DECORATOR.PRODUCT-LABEL' = 'Test product';
          'LOOPZ.WH-FOREACH-DECORATOR.WHAT-IF'       = $false;
        }

        $underscore = 'What is the answer to the universe';
        $result = $decorator.Invoke($underscore, 0, $passThru, $false);

        $result.Product | Should -Be "What is the answer to the universe: Fourty Two";
      }
    } # given: a function

    Context 'given: a script block' {
      It 'should: inovke the script block' {
        Mock Write-ThemedPairsInColour -ModuleName Elizium.Loopz { }

        [scriptblock]$block = {
          param(
            [Parameter(Mandatory)]
            $Underscore,

            [Parameter(Mandatory)]
            [int]$Index,

            [Parameter(Mandatory)]
            [System.Collections.Hashtable]$PassThru,

            [Parameter(Mandatory)]
            [boolean]$Trigger
          )

          @{ Product = "{0}: {1}" -f $Underscore, $PassThru['ANSWER'] }
        }

        [System.Collections.Hashtable]$passThru = @{
          'LOOPZ.WH-FOREACH-DECORATOR.BLOCK'         = $block;
          'ANSWER'                                   = 'Fourty Two';
          'LOOPZ.WH-FOREACH-DECORATOR.MESSAGE'       = 'Test Advanced Function';
          'LOOPZ.WH-FOREACH-DECORATOR.KRAYOLA-THEME' = $(Get-KrayolaTheme);
          'LOOPZ.WH-FOREACH-DECORATOR.ITEM-LABEL'    = 'Question';
          'LOOPZ.WH-FOREACH-DECORATOR.ITEM-VALUE'    = 'The Wrong Answer';
          'LOOPZ.WH-FOREACH-DECORATOR.PRODUCT-LABEL' = 'Test product';
          'LOOPZ.WH-FOREACH-DECORATOR.WHAT-IF'       = $false;
        }

        $underscore = 'What is the answer to the universe';
        $result = $decorator.Invoke($underscore, $index, $PassThru, $false);

        $result.Product | Should -Be "What is the answer to the universe: Fourty Two";
      }
    } # given: a script block
  } # given: PassThru contains ITEM-LABEL/VALUE

  Context 'given: Invoke Result contains Properties TRASH' -Tag 'RE-WRITE' {
    $script:tests = @{
      'PassThru with single item PROPERTIES defined'             = , @('Author', 'Douglas Adams');
      'PassThru with two item PROPERTIES defined'                = @(@('Author', 'Douglas Adams'), @('Genre', 'Sci-Fi'));
      'PassThru with many item PROPERTIES defined'               = @(@('One', 'A'), @('Two', 'B'), @('Three', 'C'), @('Four', 'D'));
      'PassThru with PROPERTIES incorrectly defined as a string' = "Bad Properties";
      'PassThru with PROPERTIES incorrectly defined as null'     = $null;
    }

    It 'given: <Description>, should: invoke and write' -TestCases @(
      # Mock Write-ThemedPairsInColour -ModuleName Elizium.Loopz { }

      @{ Description = 'PassThru with single item PROPERTIES defined' },
      @{ Description = 'PassThru with two item PROPERTIES defined' },
      @{ Description = 'PassThru with many item PROPERTIES defined' },
      @{ Description = 'PassThru with PROPERTIES incorrectly defined as a string' },
      @{ Description = 'PassThru with PROPERTIES incorrectly defined as null' }
    ) {
      [System.Collections.Hashtable]$passThru = @{
        'LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME' = 'get-AnswerAdvancedFn';
        'ANSWER'                                   = 'Fourty Two';
        'LOOPZ.WH-FOREACH-DECORATOR.MESSAGE'       = 'Test Advanced Function';
        'LOOPZ.WH-FOREACH-DECORATOR.KRAYOLA-THEME' = $(Get-KrayolaTheme);
        'LOOPZ.WH-FOREACH-DECORATOR.PROPERTIES'    = $tests[$Description];
        'LOOPZ.WH-FOREACH-DECORATOR.PRODUCT-LABEL' = 'Test product';
        'LOOPZ.WH-FOREACH-DECORATOR.WHAT-IF'       = $false;
      }

      $underscore = 'What is the answer to the universe';
      $result = $decorator.Invoke($underscore, 0, $passThru, $false);

      $result.Product | Should -Be "What is the answer to the universe: Fourty Two";

    }
  } # given: PassThru contains PROPERTIES

  Context 'given: Invoke Result contains Properties' {
    [System.Collections.Hashtable]$script:_passThru = @{
      'LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME' = 'get-AnswerAdvancedFn';
      'LOOPZ.WH-FOREACH-DECORATOR.MESSAGE'       = 'Test Advanced Function';
      'LOOPZ.WH-FOREACH-DECORATOR.KRAYOLA-THEME' = $(Get-KrayolaTheme);
      'LOOPZ.WH-FOREACH-DECORATOR.PRODUCT-LABEL' = 'Test product';
      'LOOPZ.WH-FOREACH-DECORATOR.WHAT-IF'       = $false;
    }

    Context 'and: contains single item' {
      It 'should: invoke and write' {
        Mock get-AnswerAdvancedFn -ModuleName Elizium.Loopz {
          # $p = , @('Author', 'Douglas Adams');
          # Write-Host "MOCK: pair count: $($p.Count)"

          # $obj = [PSCustomObject]@{ Pairs = $p }
          # Write-Host "MOCK: OBJ pair count: $($obj.Pairs.Count)"
          # return $obj;
          ([PSCustomObject]@{ Pairs = @(@('Author', 'Douglas Adams'), @('beer', 'duff')) })
        }

        Mock Write-ThemedPairsInColour -ModuleName Elizium.Loopz {
          param(
            [string[][]]$Pairs,
            [System.Collections.Hashtable]$Theme,
            [string]$Message
          )
          $first = $Pairs[1];
          $first[0] | Should -BeExactly 'Author';
          $first[1] | Should -BeExactly 'Douglas Adams';
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
      It 'should: invoke and write' -Tag 'Current' {
        Mock get-AnswerAdvancedFn -ModuleName Elizium.Loopz {
          ([PSCustomObject]@{ Pairs = @(@('One', 'A'), @('Two', 'B'), @('Three', 'C'), @('Four', 'D')) })
        }

        $underscore = 'What is the answer to the universe';
        $decorator.Invoke($underscore, 0, $_passThru, $false);
      }
    } # and: contains many items
  } # given: Invoke Result contains Properties

  Context 'given: IF-TRIGGERED is set' {
    Context 'and: an item sets the Trigger' {
      It 'should: invoke Write-ThemedPairsInColour' {
        Mock Write-ThemedPairsInColour -ModuleName Elizium.Loopz -Verifiable { }

        [System.Collections.Hashtable]$passThru = @{
          'LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME' = 'get-AnswerAdvancedFnWithTrigger';
          'ANSWER'                                   = 'Fourty Two';
          'LOOPZ.WH-FOREACH-DECORATOR.MESSAGE'       = 'Test Advanced Function';
          'LOOPZ.WH-FOREACH-DECORATOR.KRAYOLA-THEME' = $(Get-KrayolaTheme);
          'LOOPZ.WH-FOREACH-DECORATOR.ITEM-LABEL'    = 'Question';
          'LOOPZ.WH-FOREACH-DECORATOR.ITEM-VALUE'    = 'The Wrong Answer';
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
          'LOOPZ.WH-FOREACH-DECORATOR.ITEM-LABEL'    = 'Question';
          'LOOPZ.WH-FOREACH-DECORATOR.ITEM-VALUE'    = 'The Wrong Answer';
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
