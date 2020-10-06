
Describe 'edit-ReplaceLastMatch' {
  BeforeAll {
    . .\Internal\edit-ReplaceLastMatch.ps1
  }

  Context 'given: plain pattern' {
    Context 'and: no matches' {
      It 'should: return original string unmodified' {
        [string]$source = 'The sound the wind makes in the pines';
        [string]$pattern = 'bear';
        [string]$with = 'woods';

        edit-ReplaceLastMatch -Source $source -Pattern $pattern -With $with | `
          Should -BeExactly 'The sound the wind makes in the pines';
      }
    }

    Context 'and: single match' {
      It 'should: replace the single match' {
        [string]$source = 'The sound the wind makes in the pines';
        [string]$pattern = 'wind';
        [string]$with = 'owl';

        edit-ReplaceLastMatch -Source $source -Pattern $pattern -With $with | `
          Should -BeExactly 'The sound the owl makes in the pines';
      }
    }

    Context 'and: multiple matches' {
      It 'should: replace the last single match only' {
        [string]$source = 'The sound the wind makes in the pines';
        [string]$pattern = 'in';
        [string]$with = '==';

        edit-ReplaceLastMatch -Source $source -Pattern $pattern -With $with | `
          Should -BeExactly 'The sound the wind makes in the p==es';
      }
    }
  } # given: plain pattern

  Context 'given: regex pattern' {
    Context 'and: word boundary' {
      Context 'and: no matches' {
        It 'should: return original string unmodified' {
          [string]$source = 'The sound the wind makes in the pines';
          [string]$pattern = '\bbear\b';
          [string]$with = 'woods';

          edit-ReplaceLastMatch -Source $source -Pattern $pattern -With $with | `
            Should -BeExactly 'The sound the wind makes in the pines';
        }
      }

      Context 'and: single match' {
        It 'should: replace the single match' {
          [string]$source = 'The sound the wind makes in the pines';
          [string]$pattern = '\bin\b';
          [string]$with = 'under';

          edit-ReplaceLastMatch -Source $source -Pattern $pattern -With $with | `
            Should -BeExactly 'The sound the wind makes under the pines';
        }
      }

      Context 'and: multiple matches' {
        It 'should: replace the last single match only' {
          [string]$source = 'The sound the wind makes in the pines or in the woods';
          [string]$pattern = 'in';
          [string]$with = 'under';

          edit-ReplaceLastMatch -Source $source -Pattern $pattern -With $with | `
            Should -BeExactly 'The sound the wind makes in the pines or under the woods';
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

            edit-ReplaceLastMatch -Source $source -Pattern $pattern -With $with -Whole | `
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

          edit-ReplaceLastMatch -Source $source -Pattern $pattern -With $with -Whole | `
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

          edit-ReplaceLastMatch -Source $source -Pattern $pattern -With $with | `
            Should -BeExactly 'Party like its Nineteen Ninety Nine';
        }
      }

      Context 'and: multiple matches' {
        It 'should: replace the last match only' {
          [string]$source = '01-01-2000 Party like its 31-12-1999';
          [string]$pattern = '\d{2}-\d{2}-\d{4}';
          [string]$with = 'New Years Eve 1999';

          edit-ReplaceLastMatch -Source $source -Pattern $pattern -With $with | `
            Should -BeExactly '01-01-2000 Party like its New Years Eve 1999';
        }
      }
    } # and: date
  } # given: regex pattern
} # edit-ReplaceLastMatch
