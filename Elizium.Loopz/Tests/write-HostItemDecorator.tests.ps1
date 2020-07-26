
Describe 'write-HostItemDecorator' {
  BeforeAll {
    # This is a temporary fix (there is a legacy version of Write-HostItemDecorator
    # in it which is conflicting with the location version being tested.)
    #
    # Get-Module Elizium.TerminalBuddy | Remove-Module
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking
  }

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
  
      [scriptblock]$decorator = {
        param(
          $_underscore, $_index, $_passthru, $_trigger
        )
  
        return Write-HostItemDecorator -Underscore $_underscore `
          -Index $_index `
          -PassThru $_passthru `
          -Trigger $_trigger
      }

      $underscore = 'What is the answer to the universe';
      $result = $decorator.Invoke($underscore, 0, $passThru, $false)

      $result.Product | Should -Be "What is the answer to the universe: Fourty Two";
    }
  }

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
  
      [scriptblock]$decorator = {
        param(
          $_underscore, $_index, $_passthru, $_trigger
        )
  
        return write-HostItemDecorator -Underscore $_underscore `
          -Index $_index `
          -PassThru $_passthru `
          -Trigger $_trigger
      }

      $underscore = 'What is the answer to the universe';
      $result = $decorator.Invoke($underscore, $index, $PassThru, $false)

      $result.Product | Should -Be "What is the answer to the universe: Fourty Two";
    }
  }
}
