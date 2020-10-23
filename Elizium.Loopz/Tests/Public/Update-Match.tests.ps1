using namespace System.Text.RegularExpressions;

Describe 'Update-Match' {
  BeforeAll {
    . .\Public\Update-Match.ps1;
    . .\Public\Get-DeconstructedMatch.ps1;
    . .\Tests\Helpers\new-expr.ps1;
  }

  # Need Literal and Paste tests
  
  Context 'FIRST' {
    Context 'given: plain pattern' {
      Context 'and: no matches' {
        It 'should: return original string unmodified' {
          [string]$source = 'We are like the dreamer who dreams and then lives inside the dream';
          [RegEx]$pattern = new-expr('blooper');
          [string]$literalWith = 'dandelion';

          Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith | `
            Should -BeExactly $source;
        }
      }

      Context 'and: single match' {
        It 'should: replace the single match' {
          [string]$source = 'We are like the dreamer';
          [RegEx]$pattern = new-expr('dream');
          [string]$literalWith = 'heal';

          Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith | `
            Should -BeExactly 'We are like the healer';
        }
      }

      Context 'and: multiple matches' {
        It 'should: replace the first match only' {
          [string]$source = 'We are like the dreamer who dreams and then lives inside the dream';
          [RegEx]$pattern = new-expr('dream');
          [string]$literalWith = 'heal';

          Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith | `
            Should -BeExactly 'We are like the healer who dreams and then lives inside the dream';
        }
      }

      Context 'and: multiple matches' {
        It 'should: replace all matches' {
          [string]$source = 'We are like the dreamer who dreams and then lives inside the dream';
          [RegEx]$pattern = new-expr('dream');
          [string]$literalWith = 'heal';

          Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith `
            -PatternOccurrence '*' | `
            Should -BeExactly 'We are like the healer who heals and then lives inside the heal';
        }
      }

      Context 'and: Quantity specified' {
        It 'should: replace specified match only' {
          [string]$source = 'We are like the dreamer who dreams and then lives inside the dream';
          [RegEx]$pattern = new-expr('dream');
          [string]$literalWith = 'heal';

          Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith `
            -PatternOccurrence '2' | `
            Should -BeExactly 'We are like the dreamer who heals and then lives inside the dream';
        }
      }

      Context 'Excess PatternOccurrence specified' {
        It 'should: return value unmodified' {
          [string]$source = 'We are like the dreamer who dreams and then lives inside the dream';
          [RegEx]$pattern = new-expr('dream');
          [string]$literalWith = 'heal';

          Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith `
            -PatternOccurrence '99' | `
            Should -BeExactly $source;
        }
      }
    } # given: plain pattern

    Context 'given: regex pattern' {
      Context 'and: word boundary' {
        Context 'and: no matches' {
          It 'should: return original string unmodified' {
            [string]$source = 'We are like the dreamer who dreams and then lives inside the dream';
            [RegEx]$pattern = new-expr('\bscream\b');
            [string]$literalWith = 'heal';

            Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith | `
              Should -BeExactly $source;
          }
        }

        Context 'and: single match' {
          It 'should: replace the single match' {
            [string]$source = 'We are like the dreamer who dreams and then lives inside the dream';
            [RegEx]$pattern = new-expr('\bdream\b');
            [string]$literalWith = 'healer';

            Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith | `
              Should -BeExactly 'We are like the dreamer who dreams and then lives inside the healer';
          }
        }

        Context 'and: multiple matches' {
          It 'should: replace the first single match only' {
            [string]$source = 'We are like the dreamer who has a dream and then lives inside the dream';
            [RegEx]$pattern = new-expr('\bdream\b');
            [string]$literalWith = 'healer';

            Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith | `
              Should -BeExactly 'We are like the dreamer who has a healer and then lives inside the dream';
          }
        }
      } # and: word boundary

      Context 'and: date' {
        Context 'and: single match' {
          It 'should: replace the single match' {
            [string]$source = 'Party like its 31-12-1999';
            [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
            [string]$literalWith = 'Nineteen Ninety Nine';

            Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith | `
              Should -BeExactly 'Party like its Nineteen Ninety Nine';
          }
        }

        Context 'and: multiple matches' {
          It 'should: replace the first match only' {
            [string]$source = '01-01-2000 Party like its 31-12-1999';
            [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
            [string]$literalWith = 'New Years Eve 1999';

            Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith `
              -PatternOccurrence 'f' | `
              Should -BeExactly 'New Years Eve 1999 Party like its 31-12-1999';
          }

          It 'should: replace identified match only' {
            [string]$source = '01-01-2000 Party like its 31-12-1999, today is 24-09-2020';
            [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
            [string]$literalWith = '[DATE]';

            Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith `
              -PatternOccurrence '2' | `
              Should -BeExactly '01-01-2000 Party like its [DATE], today is 24-09-2020';
          }
        } # and: multiple matches
      } # and: date
    } # given: regex pattern
  } # FIRST

  Context 'LAST' {
    Context 'given: plain pattern' {
      Context 'and: no matches' {
        It 'should: return original string unmodified' {
          [string]$source = 'The sound the wind makes in the pines';
          [RegEx]$pattern = new-expr('bear');
          [string]$literalWith = 'woods';

          Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith | `
            Should -BeExactly 'The sound the wind makes in the pines';
        }
      }

      Context 'and: single match' {
        It 'should: replace the single match' {
          [string]$source = 'The sound the wind makes in the pines';
          [RegEx]$pattern = new-expr('wind');
          [string]$literalWith = 'owl';

          Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith | `
            Should -BeExactly 'The sound the owl makes in the pines';
        }
      }

      Context 'and: multiple matches' {
        It 'should: replace the last single match only' {
          [string]$source = 'The sound the wind makes in the pines';
          [RegEx]$pattern = new-expr('in');
          [string]$literalWith = '==';

          Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith `
            -PatternOccurrence 'l' | `
            Should -BeExactly 'The sound the wind makes in the p==es';
        }
      }
    } # given: plain pattern

    Context 'given: regex pattern' {
      Context 'and: word boundary' {
        Context 'and: no matches' {
          It 'should: return original string unmodified' {
            [string]$source = 'The sound the wind makes in the pines';
            [RegEx]$pattern = new-expr('\bbear\b');
            [string]$literalWith = 'woods';

            Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith | `
              Should -BeExactly 'The sound the wind makes in the pines';
          }
        }

        Context 'and: single match' {
          It 'should: replace the single match' {
            [string]$source = 'The sound the wind makes in the pines';
            [RegEx]$pattern = new-expr('\bin\b');
            [string]$literalWith = 'under';

            Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith | `
              Should -BeExactly 'The sound the wind makes under the pines';
          }
        }

        Context 'and: multiple matches' {
          It 'should: replace the last single match only' {
            [string]$source = 'The sound the wind makes in the pines or in the woods';
            [RegEx]$pattern = new-expr('in');
            [string]$literalWith = 'under';

            Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith `
              -PatternOccurrence 'l' | `
              Should -BeExactly 'The sound the wind makes in the pines or under the woods';
          }
        }
      } # and: word boundary

      Context 'and: date' {
        Context 'and: single match' {
          It 'should: replace the single match' {
            [string]$source = 'Party like its 31-12-1999';
            [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
            [string]$literalWith = 'Nineteen Ninety Nine';

            Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith | `
              Should -BeExactly 'Party like its Nineteen Ninety Nine';
          }
        }

        Context 'and: multiple matches' {
          It 'should: replace the last match only' {
            [string]$source = '01-01-2000 Party like its 31-12-1999';
            [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
            [string]$literalWith = 'New Years Eve 1999';

            Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith `
              -PatternOccurrence 'l' | `
              Should -BeExactly '01-01-2000 Party like its New Years Eve 1999';
          }
        }
      } # and: date
    } # given: regex pattern
  } # LAST

  Context 'ALL' {
    Context 'given: plain pattern' {
      It 'should: replace all matches' {
        [string]$source = 'Cyanopsia: blue, Cataract: blue, Moody: blues, Azora: blue, Azul: blue, Hinto: blue';
        [RegEx]$pattern = new-expr('blue');
        [string]$literalWith = 'red';

        Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith `
          -PatternOccurrence '*' | `
          Should -BeExactly 'Cyanopsia: red, Cataract: red, Moody: reds, Azora: red, Azul: red, Hinto: red';
      }

      It 'should: replace all whole word matches' {
        [string]$source = 'Cyanopsia: blue, Cataract: blue, Moody: blues, Azora: blue, Azul: blue, Hinto: blue';
        [RegEx]$pattern = new-expr('\bblue\b');
        [string]$literalWith = 'red';

        Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith `
          -PatternOccurrence '*' | `
          Should -BeExactly 'Cyanopsia: red, Cataract: red, Moody: blues, Azora: red, Azul: red, Hinto: red';
      }
    }

    Context 'given: regex pattern' {
      It 'should: replace all matches' {
        # NB, character classes like [[:alpha:]] don't work on PowerShell! Apparently (regex101),
        # [[::]] is posix notation
        #
        [string]$source = 'Currencies: [GBP], [CHF], [CUC], [CZK], [GHS]';
        [RegEx]$pattern = new-expr('\[(?<ccy>[A-Z]{3})\]');
        [string]$literalWith = '(***)';

        Update-Match -Value $source -Pattern $pattern -LiteralWith $literalWith `
          -PatternOccurrence '*' | `
          Should -BeExactly 'Currencies: (***), (***), (***), (***), (***)';
      }
    }
  } # ALL

  Context 'legacy' -Skip {
    Context 'given: First Occurrence' {
      Context 'and: no match' {
        It 'should: return original value unmodified' {
          [string]$source = 'We are like the dreamer';
          [RegEx]$pattern = new-expr('rose');
          [RegEx]$with = new-expr('healer');
          [int]$quantity = 1;

          Update-Match -Occurrence 'FIRST' -Value $source -Pattern $pattern `
            -With $with -Quantity $quantity | Should -BeExactly 'We are like the dreamer';
        } # should: replace the single match
      } # and: no match

      Context 'and: single match' {
        It 'should: replace the single match' {
          [string]$source = 'We are like the dreamer';
          [RegEx]$pattern = new-expr('dreamer');
          [RegEx]$with = new-expr('healer');
          [int]$quantity = 1;

          Update-Match -Occurrence 'FIRST' -Value $source -Pattern $pattern `
            -With $with -Quantity $quantity | Should -BeExactly 'We are like the healer';
        } # should: replace the single match
      } # and: single match

      Context 'and: single whole word match' {
        It 'should: replace the single match' {
          [string]$source = 'We are like the dreamer dream';
          [RegEx]$pattern = new-expr('\bdream\b');
          [RegEx]$with = new-expr('heal');
          [int]$quantity = 1;

          Update-Match -Occurrence 'FIRST' -Value $source -Pattern $pattern `
            -With $with -Quantity $quantity | Should -BeExactly 'We are like the dreamer heal';
        } # should: replace the single match
      } # and: single match

      Context 'and: multiple matches, replace first only' {
        It 'should: replace the single match' {
          [string]$source = 'We are like the dreamer, dreamer';
          [RegEx]$pattern = new-expr('dreamer');
          [RegEx]$with = new-expr('healer');
          [int]$quantity = 1;

          Update-Match -Occurrence 'FIRST' -Value $source -Pattern $pattern `
            -With $with -Quantity $quantity | Should -BeExactly 'We are like the healer, dreamer';
        }
      } # and: multiple matches, replace first only

      Context 'and: multiple matches, replace first 2' {
        It 'should: replace the single match' {
          [string]$source = 'We are like the dreamer, dreamer';
          [RegEx]$pattern = new-expr('dreamer');
          [RegEx]$with = new-expr('healer');
          [int]$quantity = 2;

          Update-Match -Occurrence 'FIRST' -Value $source -Pattern $pattern `
            -With $with -Quantity $quantity | Should -BeExactly 'We are like the healer, healer';
        }
      } # and: multiple matches, replace first 2
    }

    Context 'given: Last Occurrence' {
      Context 'and: single match' {
        It 'should: replace the single match' {
          [string]$source = 'We are like the dreamer';
          [RegEx]$pattern = new-expr('dreamer');
          [RegEx]$with = new-expr('healer');
          [int]$quantity = 1;

          Update-Match -Occurrence 'LAST' -Value $source -Pattern $pattern `
            -With $with -Quantity $quantity | Should -BeExactly 'We are like the healer';
        } # should: replace the single match
      } # and: single match

      Context 'and: multiple matches, replace first only' {
        It 'should: replace the single match' {
          [string]$source = 'We are like the dreamer, dreamer';
          [RegEx]$pattern = new-expr('dreamer');
          [RegEx]$with = new-expr('healer');
          [int]$quantity = 1;

          Update-Match -Occurrence 'LAST' -Value $source -Pattern $pattern `
            -With $with -Quantity $quantity | Should -BeExactly 'We are like the dreamer, healer';
        }
      } # and: multiple matches, replace first only
    }

    Context 'given: Occurrence not specified (All)' {
      It 'should: replace the single match' {
        [string]$source = 'We are like the dreamer, dreamer';
        [RegEx]$pattern = new-expr('dreamer');
        [RegEx]$with = new-expr('healer');
        [int]$quantity = 1;

        Update-Match -Value $source -Pattern $pattern `
          -With $with -Quantity $quantity | Should -BeExactly 'We are like the healer, healer';
      }
    }
  }
} # Update-Match
