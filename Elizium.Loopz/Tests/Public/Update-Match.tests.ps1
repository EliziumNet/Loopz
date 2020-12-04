using namespace System.Text.RegularExpressions;

Describe 'Update-Match' {
  BeforeAll {
    . .\Public\Update-Match.ps1;
    . .\Public\Split-Match.ps1;
    . .\Tests\Helpers\new-expr.ps1;
  }

  # Need Literal and Paste tests
  
  Context 'FIRST' {
    Context 'given: plain pattern' {
      Context 'and: no matches' {
        It 'should: return original string unmodified' {
          [string]$source = 'We are like the dreamer who dreams and then lives inside the dream';
          [RegEx]$pattern = new-expr('blooper');
          [string]$literalCopy = 'dandelion';

          Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy | `
            Should -BeExactly $source;
        }
      }

      Context 'and: single match' {
        It 'should: replace the single match' {
          [string]$source = 'We are like the dreamer';
          [RegEx]$pattern = new-expr('dream');
          [string]$literalCopy = 'heal';

          Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy | `
            Should -BeExactly 'We are like the healer';
        }
      }

      Context 'and: multiple matches' {
        It 'should: replace the first match only' {
          [string]$source = 'We are like the dreamer who dreams and then lives inside the dream';
          [RegEx]$pattern = new-expr('dream');
          [string]$literalCopy = 'heal';

          Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy | `
            Should -BeExactly 'We are like the healer who dreams and then lives inside the dream';
        }
      }

      Context 'and: multiple matches' {
        It 'should: replace all matches' {
          [string]$source = 'We are like the dreamer who dreams and then lives inside the dream';
          [RegEx]$pattern = new-expr('dream');
          [string]$literalCopy = 'heal';

          Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy `
            -PatternOccurrence '*' | `
            Should -BeExactly 'We are like the healer who heals and then lives inside the heal';
        }
      }

      Context 'and: Quantity specified' {
        It 'should: replace specified match only' {
          [string]$source = 'We are like the dreamer who dreams and then lives inside the dream';
          [RegEx]$pattern = new-expr('dream');
          [string]$literalCopy = 'heal';

          Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy `
            -PatternOccurrence '2' | `
            Should -BeExactly 'We are like the dreamer who heals and then lives inside the dream';
        }
      }

      Context 'Excess PatternOccurrence specified' {
        It 'should: return value unmodified' {
          [string]$source = 'We are like the dreamer who dreams and then lives inside the dream';
          [RegEx]$pattern = new-expr('dream');
          [string]$literalCopy = 'heal';

          Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy `
            -PatternOccurrence '99' | `
            Should -BeExactly $source;
        }
      }

      Context 'and: Paste references LiteralWith' {
        Context 'and: single Pattern match' {
          It 'should: replace the single match' {
            [string]$source = 'We are like the dreamer';
            [RegEx]$pattern = new-expr('dream');
            [string]$literalCopy = 'heal';
            [string]$paste = '==${_w}=='

            Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy -Paste $paste | `
              Should -BeExactly 'We are like the ==heal==er';
          }
        }
      } # and: Paste references LiteralWith

      Context 'and: Paste references Pattern' {
        Context 'and: single Pattern match' {
          It 'should: replace the single match' {
            [string]$source = 'We are like the dreamer';
            [RegEx]$pattern = new-expr('dream');
            [string]$paste = '==$0=='

            Update-Match -Value $source -Pattern $pattern -Paste $paste | `
              Should -BeExactly 'We are like the ==dream==er';
          }
        }
      } # and: Paste references Pattern

      Context 'and: Paste & With' {
        Context 'With matches' {
          It 'should: replace the single match' {
            [string]$source = 'We are like the dreamer 1234';
            [RegEx]$pattern = new-expr('dream');
            [string]$With = '\d{4}';
            [string]$paste = '==${_w}=='

            Update-Match -Value $source -Pattern $pattern -With $With -Paste $paste | `
              Should -BeExactly 'We are like the ==1234==er 1234';
          }
        }

        Context 'With does NOT match' {
          It 'should: replace the single match' {
            [string]$source = 'We are like the dreamer';
            [RegEx]$pattern = new-expr('dream');
            [string]$with = 'blah';
            [string]$paste = '==${_w}=='

            Update-Match -Value $source -Pattern $pattern -With $with -Paste $paste | `
              Should -BeExactly $source;
          }          
        }
      } # and: Paste & With

      Context 'and: Paste & LiteralWith' {
        Context 'With matches' {
          It 'should: replace the single match' {
            [string]$source = 'We are like the dreamer';
            [RegEx]$pattern = new-expr('dream');
            [string]$literalCopy = 'heal';
            [string]$paste = '==${_w}=='

            Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy -Paste $paste | `
              Should -BeExactly 'We are like the ==heal==er';
          }
        }
      } # and: Paste & With
    } # given: plain pattern

    Context 'given: regex pattern' {
      Context 'and: word boundary' {
        Context 'and: no matches' {
          It 'should: return original string unmodified' {
            [string]$source = 'We are like the dreamer who dreams and then lives inside the dream';
            [RegEx]$pattern = new-expr('\bscream\b');
            [string]$literalCopy = 'heal';

            Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy | `
              Should -BeExactly $source;
          }
        }

        Context 'and: single match' {
          It 'should: replace the single match' {
            [string]$source = 'We are like the dreamer who dreams and then lives inside the dream';
            [RegEx]$pattern = new-expr('\bdream\b');
            [string]$literalCopy = 'healer';

            Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy | `
              Should -BeExactly 'We are like the dreamer who dreams and then lives inside the healer';
          }
        }

        Context 'and: multiple matches' {
          It 'should: replace the first single match only' {
            [string]$source = 'We are like the dreamer who has a dream and then lives inside the dream';
            [RegEx]$pattern = new-expr('\bdream\b');
            [string]$literalCopy = 'healer';

            Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy | `
              Should -BeExactly 'We are like the dreamer who has a healer and then lives inside the dream';
          }
        }
      } # and: word boundary

      Context 'and: date' {
        Context 'and: single match' {
          It 'should: replace the single match' {
            [string]$source = 'Party like its 31-12-1999';
            [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
            [string]$literalCopy = 'Nineteen Ninety Nine';

            Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy | `
              Should -BeExactly 'Party like its Nineteen Ninety Nine';
          }
        }

        Context 'and: multiple matches' {
          It 'should: replace the first match only' {
            [string]$source = '01-01-2000 Party like its 31-12-1999';
            [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
            [string]$literalCopy = 'New Years Eve 1999';

            Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy `
              -PatternOccurrence 'f' | `
              Should -BeExactly 'New Years Eve 1999 Party like its 31-12-1999';
          }

          It 'should: replace identified match only' {
            [string]$source = '01-01-2000 Party like its 31-12-1999, today is 24-09-2020';
            [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
            [string]$literalCopy = '[DATE]';

            Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy `
              -PatternOccurrence '2' | `
              Should -BeExactly '01-01-2000 Party like its [DATE], today is 24-09-2020';
          }
        } # and: multiple matches
      } # and: date

      Context 'and: Pattern defines named captures' {
        It 'should: rename accessing Pattern defined capture' {
          [string]$source = '21-04-2000, Party like its 31-12-1999, today is 24-09-2020';
          [RegEx]$pattern = new-expr('(?<day>\d{2})-(?<mon>\d{2})-(?<year>\d{4})');

          Update-Match -Value $source -Pattern $pattern -PatternOccurrence '*' `
            -Paste 'Americanised: ${mon}-${day}-${year}' | `
            Should -BeExactly 'Americanised: 04-21-2000, Party like its Americanised: 12-31-1999, today is Americanised: 09-24-2020';
        }
      }
    } # given: regex pattern
  } # FIRST

  Context 'LAST' {
    Context 'given: plain pattern' {
      Context 'and: no matches' {
        It 'should: return original string unmodified' {
          [string]$source = 'The sound the wind makes in the pines';
          [RegEx]$pattern = new-expr('bear');
          [string]$literalCopy = 'woods';

          Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy | `
            Should -BeExactly 'The sound the wind makes in the pines';
        }
      }

      Context 'and: single match' {
        It 'should: replace the single match' {
          [string]$source = 'The sound the wind makes in the pines';
          [RegEx]$pattern = new-expr('wind');
          [string]$literalCopy = 'owl';

          Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy | `
            Should -BeExactly 'The sound the owl makes in the pines';
        }
      }

      Context 'and: multiple matches' {
        It 'should: replace the last single match only' {
          [string]$source = 'The sound the wind makes in the pines';
          [RegEx]$pattern = new-expr('in');
          [string]$literalCopy = '==';

          Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy `
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
            [string]$literalCopy = 'woods';

            Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy | `
              Should -BeExactly 'The sound the wind makes in the pines';
          }
        }

        Context 'and: single match' {
          It 'should: replace the single match' {
            [string]$source = 'The sound the wind makes in the pines';
            [RegEx]$pattern = new-expr('\bin\b');
            [string]$literalCopy = 'under';

            Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy | `
              Should -BeExactly 'The sound the wind makes under the pines';
          }
        }

        Context 'and: multiple matches' {
          It 'should: replace the last single match only' {
            [string]$source = 'The sound the wind makes in the pines or in the woods';
            [RegEx]$pattern = new-expr('in');
            [string]$literalCopy = 'under';

            Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy `
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
            [string]$literalCopy = 'Nineteen Ninety Nine';

            Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy | `
              Should -BeExactly 'Party like its Nineteen Ninety Nine';
          }
        }

        Context 'and: multiple matches' {
          It 'should: replace the last match only' {
            [string]$source = '01-01-2000 Party like its 31-12-1999';
            [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
            [string]$literalCopy = 'New Years Eve 1999';

            Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy `
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
        [string]$literalCopy = 'red';

        Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy `
          -PatternOccurrence '*' | `
          Should -BeExactly 'Cyanopsia: red, Cataract: red, Moody: reds, Azora: red, Azul: red, Hinto: red';
      }

      It 'should: replace all whole word matches' {
        [string]$source = 'Cyanopsia: blue, Cataract: blue, Moody: blues, Azora: blue, Azul: blue, Hinto: blue';
        [RegEx]$pattern = new-expr('\bblue\b');
        [string]$literalCopy = 'red';

        Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy `
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
        [string]$literalCopy = '(***)';

        Update-Match -Value $source -Pattern $pattern -LiteralCopy $literalCopy `
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
