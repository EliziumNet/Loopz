Describe 'Move-Match' -Tag 'Current' {
  BeforeAll {
    . .\Public\Move-Match.ps1;
  }

  # TODO: make Edit-ShiftToken a public function and call it Move-Match

  # vanilla move (Pattern): you move the same text that is captured by the Pattern match
  # vanilla-formatted (Pattern, Paste): insert what is captured by Pattern in the format
  #   specified by Paste. Any capture groups in Pattern would be available to the Paste.
  #
  # Exotic move (2 kinds): you insert something different to what was captured by the Pattern match
  # exotic: (Pattern, With), which means you replace the match with what is captured by With
  # exotic-formatted: (Pattern, With and Paste), which means you remove the Pattern match, and you
  #   insert what is captured by the With but in the format specified by Paste
  #
  Context 'given: Literal pattern' { # LiteralPattern is a plain pattern
    Context 'and: Pattern match' {
      Context 'and: Anchor match' {
        Context 'and: vanilla move before' { # Pattern
          It 'should: move the first match before the first anchor' {
            [string]$source = 'fight +fire with +fire';
            [string]$literalPattern = '+fire';
            [string]$anchor = 'fight';
            [string]$relation = 'before'

            Move-Match -Source $source -LiteralPattern $literalPattern -Relation $relation -Anchor $anchor | `
              Should -BeExactly '+firefight  with +fire';
          }

          It 'should: move the last match before the first anchor' {
            [string]$source = 'fight +fire with +fire';
            [string]$literalPattern = '+fire';
            [string]$anchor = 'fight';
            [string]$relation = 'before'

            Move-Match -Source $source -LiteralPattern $literalPattern -PatternOccurrence 'L' `
              -Relation $relation -Anchor $anchor | `
              Should -BeExactly '+firefight +fire with ';
          }

          It 'should: move the first match before the last literal anchor' {
            [string]$source = '*fight +fire with *fight +fire';
            [string]$literalPattern = '+fire';
            [string]$literalAnchor = '*fight';
            [string]$relation = 'before'

            Move-Match -Source $source -LiteralPattern $literalPattern `
              -Relation $relation -LiteralAnchor $literalAnchor -AnchorOccurrence 'L' | `
              Should -BeExactly '*fight  with +fire*fight +fire';
          }

          It 'should: move the last match before the last literal anchor' {
            [string]$source = '*fight +fire with *fight +fire';
            [string]$literalPattern = '+fire';
            [string]$literalAnchor = '*fight';
            [string]$relation = 'before'

            Move-Match -Source $source -LiteralPattern $literalPattern -PatternOccurrence 'L' `
              -Relation $relation -Anchor $literalAnchor -AnchorOccurrence 'L' | `
              Should -BeExactly '*fight +fire with +fire*fight ';
          }
        } # and: vanilla move before

        Context 'and: vanilla move after' { # Pattern
          It 'should: move the first match after the first anchor' {
            [string]$source = 'so fight the +fire with +fire';
            [string]$literalPattern = '+fire';
            [string]$anchor = 'fight ';
            [string]$relation = 'after'

            Move-Match -Source $source -LiteralPattern $literalPattern -Relation $relation -Anchor $anchor | `
              Should -BeExactly '+firefight  with +fire';
          }

          It 'should: move the last match after the first anchor' {
            [string]$source = 'so fight the +fire with +fire';
            [string]$literalPattern = '+fire';
            [string]$anchor = 'fight ';
            [string]$relation = 'after'

            Move-Match -Source $source -LiteralPattern $literalPattern -PatternOccurrence 'L' `
              -Relation $relation -Anchor $anchor | `
              Should -BeExactly 'so fight +fire the +fire with ';
          }

          It 'should: move the first match after the last literal anchor' {
            [string]$source = 'so *fight the +fire with +fire *fight';
            [string]$literalPattern = '+fire';
            [string]$literalAnchor = '*fight';
            [string]$relation = 'after'

            Move-Match -Source $source -LiteralPattern $literalPattern `
              -Relation $relation -LiteralAnchor $literalAnchor -AnchorOccurrence 'L' | `
              Should -BeExactly 'so *fight the  with +fire *fight+fire';
          }

          It 'should: move the last match after the last literal anchor' {
            [string]$source = '*fight +fire with *fight bump +fire';
            [string]$literalPattern = '+fire';
            [string]$literalAnchor = '*fight';
            [string]$relation = 'after'

            Move-Match -Source $source -LiteralPattern $literalPattern -PatternOccurrence 'L' `
              -Relation $relation -Anchor $literalAnchor -AnchorOccurrence 'L' | `
              Should -BeExactly '*fight +fire with *fight+fire bump ';
          }
        } # and: vanilla move after

        Context 'and: vanilla formatted move before' { # Pattern, Paste

        }

        Context 'and: vanilla formatted move after' { # Pattern, Paste

        }

        Context 'and: exotic move match before anchor' { # Pattern, With

        } # and: exotic move match before anchor

        Context 'and: exotic move match after anchor' { # Pattern, With

        } # and: exotic move match after anchor

        Context 'and: exotic-formatted move match before anchor' { # Pattern, With, Paste

        }

        Context 'and: exotic-formatted move match after anchor' { # Pattern, With, Paste
          Context 'and: LiteralWith' {
            It 'should: cut the first match and paste after the first anchor' {
              [string]$source = 'There is where +fire your +fire is going';
              [string]$literalPattern = '+fire ';
              [string]$anchor = 'is ';
              [string]$relation = 'after'
              [string]$literalWith = 'ice^';
              [string]$paste = '($0) ';

              Move-Match -Source $source -LiteralPattern $literalPattern -Relation $relation -Anchor $anchor `
                -LiteralWith $literalWith -Paste $paste | `
                Should -BeExactly 'There is (ice^) where your +fire is going';
            }

            It 'should: cut the last match and paste after the first anchor' {
              [string]$source = 'There is where +fire your +fire is going';
              [string]$literalPattern = '+fire ';
              [string]$anchor = 'is ';
              [string]$relation = 'after'
              [string]$literalWith = 'ice^';
              [string]$paste = '($0) ';

              Move-Match -Source $source -LiteralPattern $literalPattern -Relation $relation -Anchor $anchor `
                -LiteralWith $literalWith -Paste $paste | `
                Should -BeExactly 'There is (ice^) where +fire your is going';
            }

            It 'should: cut the first match and paste after the last literal anchor' {
              [string]$source = 'There is$ where +fire your +fire is$ going';
              [string]$literalPattern = '+fire';
              [string]$literalAnchor = 'is$';
              [string]$relation = 'after'
              [string]$literalWith = 'ice^';
              [string]$paste = '($0)';

              Move-Match -Source $source -LiteralPattern $literalPattern -Relation $relation -LiteralAnchor $literalAnchor `
                -AnchorOccurrence 'L' -LiteralWith $literalWith -Paste $paste | `
                Should -BeExactly 'There is$ where  your +fire is$(ice^) going';
            }

            It 'should: cut the last match paste after the last literal anchor' {
              [string]$source = 'There is$ where +fire your +fire is$ going';
              [string]$literalPattern = '+fire';
              [string]$literalAnchor = 'is$';
              [string]$relation = 'after'
              [string]$literalWith = 'ice^';
              [string]$paste = '';

              Move-Match -Source $source -LiteralPattern $literalPattern -Relation $relation -LiteralAnchor $literalAnchor `
                -AnchorOccurrence 'L' -LiteralWith $literalWith -WithOccurrence 'L' -Paste $paste | `
                Should -BeExactly 'There is where you are ice going';
            }
          } # and: LiteralWith

          Context 'and: With' {
            It 'should: cut the first match and paste after the first anchor' {
              [string]$source = 'In the ZZZ year: +2525, Mourning +2525 ZZZ 12345 Sun';
              [string]$literalPattern = '+2525';
              [string]$anchor = 'ZZZ ';
              [string]$relation = 'after'
              [string]$with = '\d{5}';
              [string]$paste = '==($0)==';

              Move-Match -Source $source -LiteralPattern $literalPattern -Relation $relation -Anchor $anchor `
                -With $with -Paste $paste | `
                Should -BeExactly 'In the ZZZ ===(12345)== year: , Mourning +2525 ZZZ 12345 Sun';
            }

            It 'should: cut the last match and paste after the first anchor' {
              [string]$source = 'In the ZZZ year: +2525, Mourning +2525 ZZZ 12345 Sun';
              [string]$literalPattern = '+2525';
              [string]$anchor = 'ZZZ ';
              [string]$relation = 'after'
              [string]$with = '\d{5}';
              [string]$paste = '==($0)==';

              Move-Match -Source $source -LiteralPattern $literalPattern -Relation $relation -Anchor $anchor `
                -With $with -Paste $paste | `
                Should -BeExactly 'In the ZZZ ==(12345)== year: +2525, Mourning  ZZZ 12345 Sun';
            }

            It 'should: cut the first match and paste after the last literal anchor' {
              [string]$source = 'In the ZZZ+ year: +2525, Mourning +2525 ZZZ+ 12345 Sun';
              [string]$literalPattern = '+2525';
              [string]$literalAnchor = 'ZZZ+ ';
              [string]$relation = 'after'
              [string]$with = '\d{5}';
              [string]$paste = '==($0)== ';

              Move-Match -Source $source -LiteralPattern $literalPattern -Relation $relation -LiteralAnchor $literalAnchor `
                -AnchorOccurrence 'L' -With $with -Paste $paste | `
                Should -BeExactly 'In the ZZZ+ year: , Mourning +2525 ZZZ+ ==(12345)== 12345 Sun';
            }

            It 'should: cut the last match paste after the last literal anchor' {
              [string]$source = 'In the ZZZ+ year: +2525, Mourning +2525 ZZZ+ 12345 Sun';
              [string]$literalPattern = '+2525';
              [string]$literalAnchor = 'ZZZ+ ';
              [string]$relation = 'after'
              [string]$with = '\d{5}';
              [string]$paste = ' ==($0)==';

              Move-Match -Source $source -LiteralPattern $literalPattern -Relation $relation -LiteralAnchor $literalAnchor `
                -AnchorOccurrence 'L' -With $with -WithOccurrence 'L' -Paste $paste | `
                Should -BeExactly 'In the ZZZ+ year: +2525, Mourning  ZZZ+ ==(12345)== 12345 Sun';
            }
          }
        } # and: exotic-formatted move match after anchor
      } # and: Anchor match

      Context 'given: cut match' {
        # first, last, all
        #
        # Actually, this is a replaceWith operation not move, because you don't have to specify an
        # Anchor, Start or End. Make sure there are tests in the appropriate location.
      }

      Context 'and: Anchor NOT match' {
        Context 'and: vanilla move before' { # Pattern
          It 'should: return source unmodified' {
            [string]$source = 'fight +fire with +fire';
            [string]$literalPattern = '+fire';
            [string]$anchor = 'blooper';
            [string]$relation = 'before'

            Move-Match -Source $source -LiteralPattern $literalPattern -Relation $relation -Anchor $anchor | `
              Should -BeExactly 'fight +fire with +fire';
          }
        }
      } # and: Anchor NOT match

      Context 'and: Start specified' {
        Context 'and Pattern is midway in source' {
          It 'should: Move Pattern to Start' {
            [string]$source = 'There is fire where you are going';
            [string]$literalPattern = 'fire ';

            Move-Match -Source $source -LiteralPattern $literalPattern -Start | `
              Should -BeExactly 'fire There is where you are going';
          }
        } # and Pattern is midway in source

        Context 'and Pattern is already at Start in source' {
          It 'should: return source unmodified' {
            [string]$source = 'There is fire where you are going';
            [string]$literalPattern = 'There';

            Move-Match -Source $source -LiteralPattern $literalPattern -Start | `
              Should -BeExactly 'There is fire where you are going';
          }
        } # and Pattern is already at Start in source
      } # and: Start specified

      Context 'and: End specified' {
        Context 'and Pattern is midway in source' {
          It 'should: Move Pattern to End' {
            [string]$source = 'There is fire where you are going';
            [string]$literalPattern = ' fire';

            Move-Match -Source $source -LiteralPattern $literalPattern -End | `
              Should -BeExactly 'There is where you are going fire';
          }
        } # and Pattern is midway in source

        Context 'and Pattern is already at End in source' {
          It 'should: return source unmodified' {
            [string]$source = 'There is fire where you are going';
            [string]$literalPattern = ' fire';

            Move-Match -Source $source -LiteralPattern $literalPattern -End | `
              Should -BeExactly 'There is where you are going fire';
          }
        } # and Pattern is midway in source

      } # and: End specified
    } # and: Pattern match

    Context 'and: No Pattern match' {
      It 'should: return source unmodified' {
        [string]$source = 'There is fire where you are going';
        [string]$literalPattern = 'bomb!';
        [string]$anchor = 'are ';

        Move-Match -Source $source -LiteralPattern $literalPattern -Relation 'before' -Anchor $anchor | `
          Should -BeExactly 'There is fire where you are going' -Because "No ('$literalPattern') match found";
      }
    } # and: No Pattern match
  } # given: Literal pattern

  Context 'given: regex Pattern' {
    Context 'and: Pattern match' {
      Context 'and: Anchor match' {
        Context 'and: vanilla move before' { # Pattern
          It 'should: move the first match before the first anchor' {
            [string]$source = 'Judgement Day: [06-06-2626], Judgement Day: [28-02-2727], take your pick!';
            [string]$pattern = '\d{2}-\d{2}-\d{4}';
            [string]$anchor = 'Judgement';
            [string]$relation = 'before'

            Move-Match -Source $source -Pattern $pattern -Relation $relation -Anchor $anchor | `
              Should -BeExactly '06-06-2626Judgement Day: [], Judgement Day: [28-02-2727], take your pick!';
          }

          It 'should: move the last match before the first anchor' {
            [string]$source = 'Judgement Day: [06-06-2626], Judgement Day: [28-02-2727], take your pick!';
            [string]$pattern = '\d{2}-\d{2}-\d{4}';
            [string]$anchor = 'Judgement';
            [string]$relation = 'before'

            Move-Match -Source $source -Pattern $pattern -Relation $relation -Anchor $anchor | `
              Should -BeExactly '28-02-2727Judgement Day: [06-06-2626], Judgement Day: [], take your pick!';
          }

          It 'should: move the first match before the last literal anchor' {
            [string]$source = 'Judgement+ Day: [06-06-2626], Judgement+ Day: [28-02-2727], take your pick!';
            [string]$pattern = '\d{2}-\d{2}-\d{4}';
            [string]$literalAnchor = 'Judgement+';
            [string]$relation = 'before'

            Move-Match -Source $source -Pattern $pattern -Relation $relation -Anchor $literalAnchor | `
              Should -BeExactly 'Judgement+ Day: [], 06-06-2626Judgement+ Day: [28-02-2727], take your pick!';
          }

          It 'should: move the last match before the last literal anchor' {
            [string]$source = 'Judgement+ Day: [06-06-2626], Judgement+ Day: [28-02-2727], take your pick!';
            [string]$pattern = '\d{2}-\d{2}-\d{4}';
            [string]$literalAnchor = 'Judgement+';
            [string]$relation = 'before'

            Move-Match -Source $source -Pattern $pattern -Relation $relation -Anchor $literalAnchor | `
              Should -BeExactly 'Judgement+ Day: [06-06-2626], 28-02-2727Judgement+ Day: [], take your pick!';
          }
        } # and: vanilla move before

        Context 'and: vanilla move after' { # Pattern
        } # and: vanilla move after

        Context 'and: vanilla formatted move before' { # Pattern, Paste

        }

        Context 'and: vanilla formatted move after' { # Pattern, Paste

        }

        Context 'and: exotic move match before anchor' { # Pattern, With

        } # and: exotic move match before anchor

        Context 'and: exotic move match after anchor' { # Pattern, With

        } # and: exotic move match after anchor

        Context 'and: exotic-formatted move match before anchor' { # Pattern, With, Paste

        }

        Context 'and: exotic-formatted move match after anchor' { # Pattern, With, Paste
          Context 'and: LiteralWith' {
            It 'should: move the first match after the first anchor' {
              [string]$source = 'Judgement Day [06-06-2626], Judgement Day [28-02-2727], Day: <Friday>';
              [string]$pattern = '\d{2}-\d{2}-\d{4}';
              [string]$anchor = 'Judgement';
              [string]$relation = 'after'
              [string]$literalWith = 'Day: <(?<day>\w+)>';
              [string]$paste = '==(${day})==';

              Move-Match -Source $source -Pattern $pattern -Relation $relation -Anchor $anchor `
                -LiteralWith $literalWith -Paste $paste | `
                Should -BeExactly 'Judgement Day: [==(Friday)==], Judgement Day: [28-02-2727], take your pick!';
            }

            It 'should: move the last match after the first anchor' {
              [string]$source = 'Judgement Day [06-06-2626], Judgement Day [28-02-2727], Day: <Friday>';
              [string]$pattern = '\d{2}-\d{2}-\d{4}';
              [string]$anchor = 'Judgement';
              [string]$relation = 'after'
              [string]$literalWith = 'Day: <(?<day>\w+)>';
              [string]$paste = '==(${day})==';

              Move-Match -Source $source -Pattern $pattern -Relation $relation -Anchor $anchor `
                -LiteralWith $literalWith -Paste $paste | `
                Should -BeExactly 'Judgement==(Friday)== Day [06-06-2626], Judgement Day [], Day: <Friday>';
            }

            It 'should: move the first match after the last literal anchor' {
              [string]$source = 'Judgement^ Day [06-06-2626], Judgement^ Day [28-02-2727], Day: <Friday>';
              [string]$pattern = '\d{2}-\d{2}-\d{4}';
              [string]$literalAnchor = 'Judgement^';
              [string]$relation = 'after'
              [string]$literalWith = 'Day: <(?<day>\w+)>';
              [string]$paste = '==(${day})==';

              Move-Match -Source $source -Pattern $pattern -Relation $relation -Anchor $literalAnchor `
                -AnchorOccurrence 'L' -LiteralWith $literalWith -Paste $paste | `
                Should -BeExactly 'Judgement^ Day [], Judgement^==(Friday)== Day [28-02-2727], Day: <Friday>';
            }

            It 'should: move the last match after the last literal anchor' {
              [string]$source = 'Judgement^ Day [06-06-2626], Judgement^ Day [28-02-2727], Day: <Friday>';
              [string]$pattern = '\d{2}-\d{2}-\d{4}';
              [string]$literalAnchor = 'Judgement^';
              [string]$relation = 'after'
              [string]$literalWith = 'Day: <(?<day>\w+)>';
              [string]$paste = '==(${day})==';

              Move-Match -Source $source -Pattern $pattern -Relation $relation -Anchor $literalAnchor `
                -AnchorOccurrence 'L' -LiteralWith $literalWith -Paste $paste | `
                Should -BeExactly 'Judgement^ Day [06-06-2626], Judgement^==(Friday)== Day [], Day: <Friday>';
            }
          } # and: LiteralWith

          Context 'and: With' {

          } # and: With
        } # and: exotic-formatted move match after anchor

        # Context 'and: move before' {
        #   It 'should: move the match after the anchor' {
        #     [string]$source = 'There 23-03-1984 will be fire on where you are going';
        #     [string]$pattern = '\d{2}-\d{2}-\d{4}\s';
        #     [string]$anchor = 'on ';

        #     Move-Match -Source $source -Pattern $pattern -Relation 'after' -Anchor $anchor | `
        #       Should -BeExactly 'There will be fire on \d{2}-\d{2}-\d{4}\swhere you are going';

        #     # ----------------------
        #     # Ideally, we would like the result of this test to be:
        #     # 'There will be fire on 23-03-1984 where you are going'
        #     # but for now it is:
        #     # 'There will be fire on \d{2}-\d{2}-\d{4}\swhere you are going'
        #     #                   --->|===================|<---
        #     #
        #     # This is because, the pattern is literally inserted as the text replacement as opposed
        #     # to it being re-parsed from the source. This is an additional feature. So this is a
        #     # stop-gap test until this functionality has been implemented; probably as an extra
        #     # parameters such as "Capture" and "Format", where the user defines:
        #     #
        #     # Capture = '(?<date>\d{2}-\d{2}-\d{4}\s)'
        #     # Format = 'date:${date}'
        #     #
        #     # where the capture groups specified in Capture, must be in sync with the Format
        #     # string; ie, the fields referenced in the Format, must be defined in the Capture
        #     # pattern. [Let's call this the 'Capture' parameter set]
        #     #
        #     # which actually would should result in 
        #     # 'There will be fire on date:23-03-1984 where you are going'
        #   }

        #   It 'should: move the match after the literal anchor' -Skip {

        #   }
        # } # and: move after
      } # and: Anchor match

      Context 'and: Anchor NOT match' {
        It 'should: return source unmodified' {
          [string]$source = 'There 23-03-1984 will be fire on where you are going';
          [string]$pattern = '\d{2}-\d{2}-\d{4}\s';
          [string]$anchor = 'spanner!';

          Move-Match -Source $source -Pattern $pattern -Relation 'before' -Anchor $anchor | `
            Should -BeExactly 'There 23-03-1984 will be fire on where you are going' -Because "No ('$anchor') match found";
        }
      } # and: Anchor NOT match
    } # and: Pattern match

    Context 'and: No Pattern match' {
      It 'should: return source unmodified' {
        [string]$source = 'There 23-03-1984 will be fire on where you are going';
        [string]$pattern = 'bomb!';
        [string]$anchor = '\d{2}-\d{2}-\d{4}\s';

        Move-Match -Source $source -Pattern $pattern -Relation 'before' -Anchor $anchor | `
          Should -BeExactly 'There 23-03-1984 will be fire on where you are going' -Because "No ('$pattern') match found";
      }
    } # and: No Pattern match
  } # given: regex Pattern

  Context 'and: Whole' {
    Context 'and: Anchor match' {
      Context 'and: move before' {
        It 'should: move the whole word match before the anchor' -Tag 'BROKEN' {
          [string]$source = 'The quick brown firefox fox fox';
          [string]$pattern = 'fox';
          [string]$anchor = ' quick';

          Move-Match -Whole -Source $source -Pattern $pattern `
            -Anchor $anchor -Relation 'before' | Should -BeExactly 'Thefox quick brown firefox  fox';
        }

        It 'should: move the whole word match before the literal anchor' -Skip {

        }
      } # and: Anchor match

      Context 'and: move after' {
        It 'should: move the match after the anchor' {
          [string]$source = 'There is fire where you are going';
          [string]$pattern = 'fire ';
          [string]$anchor = 'are ';

          Move-Match -Source $source -Pattern $pattern -Anchor $anchor -Relation 'after' | `
            Should -BeExactly 'There is where you are fire going';
        }

        It 'should: move the match after the literal anchor' {

        }
      } # and: move after
    } # and: Anchor match
  } # and: Whole
} # Move-Match
