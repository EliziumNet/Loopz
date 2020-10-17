
Describe 'edit-ReplaceFirstMatch' {
  BeforeAll {
    . .\Internal\edit-ReplaceFirstMatch.ps1
  }

  Context 'given: plain pattern' {
    Context 'and: no matches' {
      It 'should: return original string unmodified' {
        [string]$source = 'We are like the dreamer who dreams and then lives inside the dream';
        [string]$pattern = 'blooper';
        [string]$with = 'dandelion';

        edit-ReplaceFirstMatch -Source $source -Pattern $pattern -With $with | `
          Should -BeExactly 'We are like the dreamer who dreams and then lives inside the dream';
      }
    }

    Context 'and: single match' {
      It 'should: replace the single match' {
        [string]$source = 'We are like the dreamer';
        [string]$pattern = 'dream';
        [string]$with = 'heal';
        [int]$quantity = 1;

        edit-ReplaceFirstMatch -Source $source -Pattern $pattern -With $with -Quantity $quantity | `
          Should -BeExactly 'We are like the healer';
      }
    }

    Context 'and: multiple matches' {
      It 'should: replace the first match only' {
        [string]$source = 'We are like the dreamer who dreams and then lives inside the dream';
        [string]$pattern = 'dream';
        [string]$with = 'heal';
        [int]$quantity = 1;

        edit-ReplaceFirstMatch -Source $source -Pattern $pattern -With $with -Quantity $quantity | `
          Should -BeExactly 'We are like the healer who dreams and then lives inside the dream';
      }
    }

    Context 'and: multiple matches' {
      It 'should: replace all matches' {
        [string]$source = 'We are like the dreamer who dreams and then lives inside the dream';
        [string]$pattern = 'dream';
        [string]$with = 'heal';

        edit-ReplaceFirstMatch -Source $source -Pattern $pattern -With $with | `
          Should -BeExactly 'We are like the healer who heals and then lives inside the heal';
      }
    }

    Context 'and: Quantity specified' {
      It 'should: replace specified number of matches only' {
        [string]$source = 'We are like the dreamer who dreams and then lives inside the dream';
        [string]$pattern = 'dream';
        [string]$with = 'heal';
        [int]$quantity = 2;

        edit-ReplaceFirstMatch -Source $source -Pattern $pattern -With $with -Quantity $quantity | `
          Should -BeExactly 'We are like the healer who heals and then lives inside the dream';
      }
    }
  } # given: plain pattern

  Context 'given: regex pattern' {
    Context 'and: word boundary' {
      Context 'and: no matches' {
        It 'should: return original string unmodified' {
          [string]$source = 'We are like the dreamer who dreams and then lives inside the dream';
          [string]$pattern = '\bscream\b';
          [string]$with = 'heal';
          [int]$quantity = 1;

          edit-ReplaceFirstMatch -Source $source -Pattern $pattern -With $with -Quantity $quantity | `
            Should -BeExactly 'We are like the dreamer who dreams and then lives inside the dream';
        }
      }

      Context 'and: single match' {
        It 'should: replace the single match' {
          [string]$source = 'We are like the dreamer who dreams and then lives inside the dream';
          [string]$pattern = '\bdream\b';
          [string]$with = 'healer';
          [int]$quantity = 1;

          edit-ReplaceFirstMatch -Source $source -Pattern $pattern -With $with -Quantity $quantity | `
            Should -BeExactly 'We are like the dreamer who dreams and then lives inside the healer';
        }
      }

      Context 'and: multiple matches' {
        It 'should: replace the first single match only' {
          [string]$source = 'We are like the dreamer who has a dream and then lives inside the dream';
          [string]$pattern = '\bdream\b';
          [string]$with = 'scream';
          [int]$quantity = 1;

          edit-ReplaceFirstMatch -Source $source -Pattern $pattern -With $with -Quantity $quantity | `
            Should -BeExactly 'We are like the dreamer who has a scream and then lives inside the dream';
        }
      }
    } # and: word boundary

    Context 'and: Whole' {
      Context 'and: \b omitted' {
        Context 'and: single match' {
          It 'should: replace the single match' {
            [string]$source = 'We are like the dreamer who dreams and then lives inside the dream';
            [string]$pattern = 'dream';
            [string]$with = 'healer';
            [int]$quantity = 1;

            edit-ReplaceFirstMatch -Source $source -Pattern $pattern -With $with -Whole -Quantity $quantity | `
              Should -BeExactly 'We are like the dreamer who dreams and then lives inside the healer';
          }
        }
      }

      Context 'and: Pattern already includes \b' {
        It 'should: replace the single match' {
          # This scenario tests a case where the user has accidentally specified \b in
          # the pattern which is not required if -Whole switch is set; this test
          # checks that edit-ReplaceFirstMatch does not double apply \b
          #
          [string]$source = 'We are like the dreamer who dreams and then lives inside the dream';
          [string]$pattern = '\bdream\b';
          [string]$with = 'healer';
          [int]$quantity = 1;

          edit-ReplaceFirstMatch -Source $source -Pattern $pattern -With $with -Whole -Quantity $quantity | `
            Should -BeExactly 'We are like the dreamer who dreams and then lives inside the healer';
        }
      }
    } # and: Whole

    Context 'and: date' {
      Context 'and: single match' {
        It 'should: replace the single match' {
          [string]$source = 'Party like its 31-12-1999';
          [string]$pattern = '\d{2}-\d{2}-\d{4}';
          [string]$with = 'Nineteen Ninety Nine';
          [int]$quantity = 1;

          edit-ReplaceFirstMatch -Source $source -Pattern $pattern -With $with -Quantity $quantity | `
            Should -BeExactly 'Party like its Nineteen Ninety Nine';
        }
      }

      Context 'and: multiple matches' {
        It 'should: replace the first match only' {
          [string]$source = '01-01-2000 Party like its 31-12-1999';
          [string]$pattern = '\d{2}-\d{2}-\d{4}';
          [string]$with = 'New Years Eve 1999';
          [int]$quantity = 1;

          edit-ReplaceFirstMatch -Source $source -Pattern $pattern -With $with -Quantity $quantity | `
            Should -BeExactly 'New Years Eve 1999 Party like its 31-12-1999';
        }
      }
    } # and: date

    Context 'and: Quantity specified' {
      It 'should: replace specified number of matches only' {
        [string]$source = '01-01-2000 Party like its 31-12-1999, today is 24-09-2020';
        [string]$pattern = '\d{2}-\d{2}-\d{4}';
        [string]$with = '[DATE]';
        [int]$quantity = 2;

        edit-ReplaceFirstMatch -Source $source -Pattern $pattern -With $with -Quantity $quantity | `
          Should -BeExactly '[DATE] Party like its [DATE], today is 24-09-2020';
      }
    } # and: Quantity specified
  } # given: regex pattern
} # edit-ReplaceFirstMatch
