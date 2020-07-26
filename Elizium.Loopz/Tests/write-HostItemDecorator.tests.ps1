
Describe 'write-HostItemDecorator' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking

    [scriptblock]$script:decorator = {
      param(
        $_underscore, $_index, $_passthru, $_trigger
      )

      return Write-HostItemDecorator -Underscore $_underscore `
        -Index $_index `
        -PassThru $_passthru `
        -Trigger $_trigger
    }
  }

  Context 'given: PassThru contains ITEM-LABEL/VALUE' {
    Context 'given: a function' {
      It 'should: invoke the function' {
        Mock Write-ThemedPairsInColour -ModuleName Elizium.Loopz { }

        [System.Collections.Hashtable]$passThru = @{
          'FUNCTION-NAME' = 'get-AnswerAdvancedFn';
          'ANSWER'        = 'Fourty Two';
          'MESSAGE'       = 'Test Advanced Function';
          'KRAYOLA-THEME' = $(Get-KrayolaTheme);
          'ITEM-LABEL'    = 'Question';
          'ITEM-VALUE'    = 'The Wrong Answer';
          'PRODUCT-LABEL' = 'Test product';
          'WHAT-IF'       = $false;
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
          'BLOCK'         = $block;
          'ANSWER'        = 'Fourty Two';
          'MESSAGE'       = 'Test Advanced Function';
          'KRAYOLA-THEME' = $(Get-KrayolaTheme);
          'ITEM-LABEL'    = 'Question';
          'ITEM-VALUE'    = 'The Wrong Answer';
          'PRODUCT-LABEL' = 'Test product';
          'WHAT-IF'       = $false;
        }
  
        $underscore = 'What is the answer to the universe';
        $result = $decorator.Invoke($underscore, $index, $PassThru, $false);

        $result.Product | Should -Be "What is the answer to the universe: Fourty Two";
      }
    } # given: a script block
  } # given: PassThru contains ITEM-LABEL/VALUE

  Context 'given: PassThru contains PROPERTIES' {
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
        'FUNCTION-NAME' = 'get-AnswerAdvancedFn';
        'ANSWER'        = 'Fourty Two';
        'MESSAGE'       = 'Test Advanced Function';
        'KRAYOLA-THEME' = $(Get-KrayolaTheme);
        'PROPERTIES'    = $tests[$Description];
        'PRODUCT-LABEL' = 'Test product';
        'WHAT-IF'       = $false;
      }
  
      $underscore = 'What is the answer to the universe';
      $result = $decorator.Invoke($underscore, 0, $passThru, $false);

      $result.Product | Should -Be "What is the answer to the universe: Fourty Two";

    }
  } # given: PassThru contains PROPERTIES
} # write-HostItemDecorator
