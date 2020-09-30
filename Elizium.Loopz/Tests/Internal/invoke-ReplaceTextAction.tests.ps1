Describe 'invoke-ReplaceTextAction' {
  BeforeAll {
    . .\Internal\edit-ReplaceFirstMatch.ps1;
    . .\Internal\edit-ReplaceLastMatch.ps1;
    . .\Internal\invoke-ReplaceTextAction.ps1;
  }

  Context 'given: First Occurrence' {
    Context 'and: no match' {
      It 'should: return original value unmodified' {
        [string]$source = 'We are like the dreamer';
        [string]$pattern = 'rose';
        [string]$with = 'healer';
        [int]$quantity = 1;

        invoke-ReplaceTextAction -Occurrence 'FIRST' -Value $source -Pattern $pattern `
          -With $with -Quantity $quantity | Should -BeExactly 'We are like the dreamer';
      } # should: replace the single match
    } # and: no match

    Context 'and: single match' {
      It 'should: replace the single match' {
        [string]$source = 'We are like the dreamer';
        [string]$pattern = 'dreamer';
        [string]$with = 'healer';
        [int]$quantity = 1;

        invoke-ReplaceTextAction -Occurrence 'FIRST' -Value $source -Pattern $pattern `
          -With $with -Quantity $quantity | Should -BeExactly 'We are like the healer';
      } # should: replace the single match
    } # and: single match

    Context 'and: single whole word match' {
      It 'should: replace the single match' {
        [string]$source = 'We are like the dreamer dream';
        [string]$pattern = 'dream';
        [string]$with = 'heal';
        [int]$quantity = 1;

        invoke-ReplaceTextAction -Occurrence 'FIRST' -Value $source -Pattern $pattern `
          -With $with -Quantity $quantity -Whole | Should -BeExactly 'We are like the dreamer heal';
      } # should: replace the single match
    } # and: single match

    Context 'and: multiple matches, replace first only' {
      It 'should: replace the single match' {
        [string]$source = 'We are like the dreamer, dreamer';
        [string]$pattern = 'dreamer';
        [string]$with = 'healer';
        [int]$quantity = 1;

        invoke-ReplaceTextAction -Occurrence 'FIRST' -Value $source -Pattern $pattern `
          -With $with -Quantity $quantity | Should -BeExactly 'We are like the healer, dreamer';
      }
    } # and: multiple matches, replace first only

    Context 'and: multiple matches, replace first 2' {
      It 'should: replace the single match' {
        [string]$source = 'We are like the dreamer, dreamer';
        [string]$pattern = 'dreamer';
        [string]$with = 'healer';
        [int]$quantity = 2;

        invoke-ReplaceTextAction -Occurrence 'FIRST' -Value $source -Pattern $pattern `
          -With $with -Quantity $quantity | Should -BeExactly 'We are like the healer, healer';
      }
    } # and: multiple matches, replace first 2
  }

  Context 'given: Last Occurrence' {
    Context 'and: single match' {
      It 'should: replace the single match' {
        [string]$source = 'We are like the dreamer';
        [string]$pattern = 'dreamer';
        [string]$with = 'healer';
        [int]$quantity = 1;

        invoke-ReplaceTextAction -Occurrence 'LAST' -Value $source -Pattern $pattern `
          -With $with -Quantity $quantity | Should -BeExactly 'We are like the healer';
      } # should: replace the single match
    } # and: single match

    Context 'and: multiple matches, replace first only' {
      It 'should: replace the single match' {
        [string]$source = 'We are like the dreamer, dreamer';
        [string]$pattern = 'dreamer';
        [string]$with = 'healer';
        [int]$quantity = 1;

        invoke-ReplaceTextAction -Occurrence 'LAST' -Value $source -Pattern $pattern `
          -With $with -Quantity $quantity | Should -BeExactly 'We are like the dreamer, healer';
      }
    } # and: multiple matches, replace first only
  }

  Context 'given: Occurrence not specified (All)' {
    It 'should: replace the single match' {
      [string]$source = 'We are like the dreamer, dreamer';
      [string]$pattern = 'dreamer';
      [string]$with = 'healer';
      [int]$quantity = 1;

      invoke-ReplaceTextAction -Value $source -Pattern $pattern `
        -With $with -Quantity $quantity | Should -BeExactly 'We are like the healer, healer';
    }
  }
} # invoke-ReplaceTextAction
