Describe 'Move-MatchLegacy' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking
  }

  Context 'given: Pattern' -Skip {
    Context 'and: Pattern matches' {
      Context 'and: vanilla move' { # Pattern
        Context 'and: Anchor matches' {
          Context 'and: before' -Tag 'DONE' {
            It 'should: move the first match before the first anchor' -Tag 'DONE' {
              [string]$source = 'Judgement Day: [06-06-2626], Judgement Day: [28-02-2727], take your pick!';
              [string]$pattern = '\d{2}-\d{2}-\d{4}';
              [string]$anchor = 'Judgement';
              [string]$relation = 'before'

              Move-MatchLegacy -Source $source -Pattern $pattern -Relation $relation -Anchor $anchor | `
                Should -BeExactly '06-06-2626Judgement Day: [], Judgement Day: [28-02-2727], take your pick!';
            }

            It 'should: move the last match before the first anchor' {
              [string]$source = 'Judgement Day: [06-06-2626], Judgement Day: [28-02-2727], take your pick!';
              [string]$pattern = '\d{2}-\d{2}-\d{4}';
              [string]$anchor = 'Judgement';
              [string]$relation = 'before'

              Move-MatchLegacy -Source $source -Pattern $pattern -PatternOccurrence 'L' `
                -Relation $relation -Anchor $anchor | `
                Should -BeExactly '28-02-2727Judgement Day: [06-06-2626], Judgement Day: [], take your pick!';
            }

            It 'should: move the 2nd match before the first anchor' {
              [string]$source = 'Judgement Day: [06-06-2626], Judgement Day: [28-02-2727], take your pick!';
              [string]$pattern = '\d{2}-\d{2}-\d{4}';
              [string]$anchor = 'Judgement';
              [string]$relation = 'before'

              Move-MatchLegacy -Source $source -Pattern $pattern -PatternOccurrence '2' `
                -Relation $relation -Anchor $anchor | `
                Should -BeExactly '28-02-2727Judgement Day: [06-06-2626], Judgement Day: [], take your pick!';
            }

            It 'should: move the first match before the last escaped anchor' {
              [string]$source = 'Judgement+ Day: [06-06-2626], Judgement+ Day: [28-02-2727], take your pick!';
              [string]$pattern = '\d{2}-\d{2}-\d{4}';
              [string]$escapedAnchor = 'Judgement+';
              [string]$relation = 'before'

              Move-MatchLegacy -Source $source -Pattern $pattern -Relation $relation -EscapedAnchor $escapedAnchor `
                -AnchorOccurrence 'L' | `
                Should -BeExactly 'Judgement+ Day: [], 06-06-2626Judgement+ Day: [28-02-2727], take your pick!';

              Move-MatchLegacy -Source $source -Pattern $pattern -Relation $relation -Anchor $(esc($escapedAnchor)) `
                -AnchorOccurrence 'L' | `
                Should -BeExactly 'Judgement+ Day: [], 06-06-2626Judgement+ Day: [28-02-2727], take your pick!';
            }

            It 'should: move the last match before the last escaped anchor' {
              [string]$source = 'Judgement+ Day: [06-06-2626], Judgement+ Day: [28-02-2727], take your pick!';
              [string]$pattern = '\d{2}-\d{2}-\d{4}';
              [string]$escapedAnchor = 'Judgement+';
              [string]$relation = 'before'

              Move-MatchLegacy -Source $source -Pattern $pattern -PatternOccurrence 'L' `
                -Relation $relation -EscapedAnchor $escapedAnchor  -AnchorOccurrence 'L' | `
                Should -BeExactly 'Judgement+ Day: [06-06-2626], 28-02-2727Judgement+ Day: [], take your pick!';

              Move-MatchLegacy -Source $source -Pattern $pattern -PatternOccurrence 'L' `
                -Relation $relation -Anchor $(esc($escapedAnchor))  -AnchorOccurrence 'L' | `
                Should -BeExactly 'Judgement+ Day: [06-06-2626], 28-02-2727Judgement+ Day: [], take your pick!';
            }

            It 'should: move the first match before the first anchor' {
              [string]$source = 'fight +fire with +fire';
              [string]$escapedPattern = '+fire';
              [string]$anchor = 'fight';
              [string]$relation = 'before'

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -Relation $relation -Anchor $anchor | `
                Should -BeExactly '+firefight  with +fire';
            }

            It 'should: move the last match before the first anchor' {
              [string]$source = 'fight +fire with +fire';
              [string]$escapedPattern = '+fire';
              [string]$anchor = 'fight';
              [string]$relation = 'before'

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -PatternOccurrence 'L' `
                -Relation $relation -Anchor $anchor | `
                Should -BeExactly '+firefight +fire with ';
            }

            It 'should: move the first match before the last anchor' -Tag '?' {
              [string]$source = '*fight +fire with *fight +fire';
              [string]$escapedPattern = '+fire';
              [string]$escapedAnchor = '*fight';
              [string]$relation = 'before'

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern `
                -Relation $relation -EscapedAnchor $escapedAnchor -AnchorOccurrence 'L' | `
                Should -BeExactly '*fight  with +fire*fight +fire';

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern `
                -Relation $relation -Anchor $(esc($escapedAnchor)) -AnchorOccurrence 'L' | `
                Should -BeExactly '*fight  with +fire*fight +fire';
            }

            It 'should: move the last match before the last anchor' -Tag 'DONE' {
              [string]$source = '*fight +fire with *fight +fire';
              [string]$escapedPattern = '+fire';
              [string]$escapedAnchor = '*fight';
              [string]$relation = 'before'

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -PatternOccurrence 'L' `
                -Relation $relation -EscapedAnchor $escapedAnchor -AnchorOccurrence 'L' | `
                Should -BeExactly '*fight +fire with +fire*fight ';

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -PatternOccurrence 'L' `
                -Relation $relation -Anchor $(esc($escapedAnchor)) -AnchorOccurrence 'L' | `
                Should -BeExactly '*fight +fire with +fire*fight ';
            }

            # Whole Pattern
            #
            Context 'and: Whole' {
              Context 'and: Anchor match' {
                Context 'and: move before' {
                  It 'should: move the whole word Pattern match before the anchor' {
                    [string]$source = 'The quick brown firefox fox fox';
                    [string]$pattern = 'fox';
                    [string]$anchor = ' quick';

                    Move-MatchLegacy -WholePattern -Source $source -Pattern $pattern `
                      -Anchor $anchor -Relation 'before' | Should -BeExactly 'Thefox quick brown firefox  fox';
                  }

                  # It 'should: move the whole word match before the literal anchor' {

                  # }

                  # It 'should: move the match before the whole word anchor' {

                  # }
                } # and: Anchor match

                Context 'and: move after' {
                  It 'should: move the match after the anchor' {
                    [string]$source = 'There is fire where you are going';
                    [string]$pattern = 'fire ';
                    [string]$anchor = 'are ';

                    Move-MatchLegacy -WholePattern -Source $source -Pattern $pattern -Anchor $anchor -Relation 'after' | `
                      Should -BeExactly 'There is where you are fire going';
                  }

                  # It 'should: move the match after the literal anchor' {

                  # }
                } # and: move after
              } # and: Anchor match
            } # and: Whole
          } # and: before

          Context 'and: after' -Tag 'DONE' {
            It 'should: move the first match after the first anchor' {
              [string]$source = 'so fight the +fire with +fire';
              [string]$escapedPattern = '+fire';
              [string]$anchor = 'fight ';
              [string]$relation = 'after'

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -Relation $relation -Anchor $anchor | `
                Should -BeExactly 'so fight +firethe  with +fire';

              Move-MatchLegacy -Source $source -Pattern $(esc($escapedPattern)) -Relation $relation -Anchor $anchor | `
                Should -BeExactly 'so fight +firethe  with +fire';
            }

            It 'should: move the last match after the first anchor' {
              [string]$source = 'so fight the +fire with +fire';
              [string]$escapedPattern = '+fire';
              [string]$anchor = 'fight ';
              [string]$relation = 'after'

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -PatternOccurrence 'L' `
                -Relation $relation -Anchor $anchor | `
                Should -BeExactly 'so fight +firethe +fire with ';

              Move-MatchLegacy -Source $source -Pattern $(esc($escapedPattern)) -PatternOccurrence 'L' `
                -Relation $relation -Anchor $anchor | `
                Should -BeExactly 'so fight +firethe +fire with ';
            }

            It 'should: move the first match after the last escaped anchor' {
              [string]$source = 'so *fight the +fire with +fire *fight';
              [string]$escapedPattern = '+fire';
              [string]$escapedAnchor = '*fight';
              [string]$relation = 'after'

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern `
                -Relation $relation -EscapedAnchor $escapedAnchor -AnchorOccurrence 'L' | `
                Should -BeExactly 'so *fight the  with +fire *fight+fire';

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern `
                -Relation $relation -Anchor $(esc($escapedAnchor)) -AnchorOccurrence 'L' | `
                Should -BeExactly 'so *fight the  with +fire *fight+fire';
            }

            It 'should: move the last match after the last escaped anchor' {
              [string]$source = '*fight +fire with *fight bump +fire';
              [string]$escapedPattern = '+fire';
              [string]$escapedAnchor = '*fight';
              [string]$relation = 'after'

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -PatternOccurrence 'L' `
                -Relation $relation -EscapedAnchor $escapedAnchor -AnchorOccurrence 'L' | `
                Should -BeExactly '*fight +fire with *fight+fire bump ';

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -PatternOccurrence 'L' `
                -Relation $relation -Anchor $(esc($escapedAnchor)) -AnchorOccurrence 'L' | `
                Should -BeExactly '*fight +fire with *fight+fire bump ';
            }
          } # and: after
        } # and: Anchor matches

        Context 'and: Anchor NOT match' -Tag 'DONE' {
          Context 'and: vanilla move before' {
            It 'should: return source unmodified' {
              [string]$source = 'fight +fire with +fire';
              [string]$escapedPattern = '+fire';
              [string]$anchor = 'blooper';
              [string]$relation = 'before'

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -Relation $relation -Anchor $anchor | `
                Should -BeExactly 'fight +fire with +fire';
            }
          }
        } # and: Anchor NOT match

        Context 'and: Start specified' -Tag 'DONE' {
          Context 'and Pattern is midway in source' {
            It 'should: Move Pattern to Start' {
              [string]$source = 'There is fire where you are going';
              [string]$escapedPattern = 'fire ';

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -Start | `
                Should -BeExactly 'fire There is where you are going';
            }
          } # and Pattern is midway in source

          Context 'and Pattern is already at Start in source' {
            It 'should: return source unmodified' {
              [string]$source = 'There is fire where you are going';
              [string]$escapedPattern = 'There';

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -Start | `
                Should -BeExactly 'There is fire where you are going';
            }
          } # and Pattern is already at Start in source
        } # and: Start specified

        Context 'and: End specified' -Tag 'DONE' {
          Context 'and Pattern is midway in source' {
            It 'should: Move Pattern to End' {
              [string]$source = 'There is fire where you are going';
              [string]$escapedPattern = ' fire';

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -End | `
                Should -BeExactly 'There is where you are going fire';
            }
          } # and Pattern is midway in source

          Context 'and Pattern is already at End in source' {
            It 'should: return source unmodified' {
              [string]$source = 'There is fire where you are going';
              [string]$escapedPattern = ' fire';

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -End | `
                Should -BeExactly 'There is where you are going fire';
            }
          } # and Pattern is midway in source
        } # and: End specified

      } # and: vanilla move

      Context 'and: vanilla move formatted' { # Pattern, Paste

      } # and: vanilla move formatted

      Context 'and: exotic' { # Pattern, With/EscapedWith/LiteralWith

      } # and: exotic

      Context 'and: exotic formatted' { # Pattern, Paste, With/EscapedWith/LiteralWith

      } # and: exotic formatted

    } # and: Pattern matches

    Context 'and: No Pattern match' {
      It 'should: return source unmodified' {
        [string]$source = 'There 23-03-1984 will be fire on where you are going';
        [string]$pattern = 'bomb!';
        [string]$anchor = '\d{2}-\d{2}-\d{4}\s';

        Move-MatchLegacy -Source $source -Pattern $pattern -Relation 'before' -Anchor $anchor | `
          Should -BeExactly 'There 23-03-1984 will be fire on where you are going' -Because "No ('$pattern') match found";
      }
    } # and: No Pattern match
  } # given: Pattern

  Context 'given: EscapedPattern' -Skip {
    Context 'and: EscapedPattern matches' {
      Context 'and: vanilla move' { # Pattern
        Context 'and: Anchor matches' {
          Context 'and: before' { # THESE LOOK LIKE DUPLICATES
            It 'should: move the first match before the first anchor' {
              [string]$source = 'fight +fire with +fire';
              [string]$escapedPattern = '+fire';
              [string]$anchor = 'fight';
              [string]$relation = 'before'

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -Relation $relation -Anchor $anchor | `
                Should -BeExactly '+firefight  with +fire';

              Move-MatchLegacy -Source $source -Pattern $(esc($escapedPattern)) -Relation $relation -Anchor $anchor | `
                Should -BeExactly '+firefight  with +fire';
            }

            It 'should: move the last match before the first anchor' {
              [string]$source = 'fight +fire with +fire';
              [string]$escapedPattern = '+fire';
              [string]$anchor = 'fight';
              [string]$relation = 'before'

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -PatternOccurrence 'L' `
                -Relation $relation -Anchor $anchor | `
                Should -BeExactly '+firefight +fire with ';

              Move-MatchLegacy -Source $source -Pattern $(esc($escapedPattern)) -PatternOccurrence 'L' `
                -Relation $relation -Anchor $anchor | `
                Should -BeExactly '+firefight +fire with ';
            }

            It 'should: move the first match before the last escaped anchor' {
              [string]$source = '*fight +fire with *fight +fire';
              [string]$escapedPattern = '+fire';
              [string]$escapedAnchor = '*fight';
              [string]$relation = 'before'

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern `
                -Relation $relation -EscapedAnchor $escapedAnchor -AnchorOccurrence 'L' | `
                Should -BeExactly '*fight  with +fire*fight +fire';

              Move-MatchLegacy -Source $source -Pattern $(esc($escapedPattern)) `
                -Relation $relation -EscapedAnchor $escapedAnchor -AnchorOccurrence 'L' | `
                Should -BeExactly '*fight  with +fire*fight +fire';

              Move-MatchLegacy -Source $source -Pattern $(esc($escapedPattern)) `
                -Relation $relation -EscapedAnchor $escapedAnchor -AnchorOccurrence '2' | `
                Should -BeExactly '*fight  with +fire*fight +fire';
            }

            It 'should: move the last match before the last escaped anchor' {
              [string]$source = '*fight +fire with *fight +fire';
              [string]$escapedPattern = '+fire';
              [string]$escapedAnchor = '*fight';
              [string]$relation = 'before';

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -PatternOccurrence 'L' `
                -Relation $relation -EscapedAnchor $escapedAnchor -AnchorOccurrence 'L' | `
                Should -BeExactly '*fight +fire with +fire*fight ';

              Move-MatchLegacy -Source $source -Pattern $(esc($escapedPattern)) -PatternOccurrence 'L' `
                -Relation $relation -EscapedAnchor $escapedAnchor -AnchorOccurrence 'L' | `
                Should -BeExactly '*fight +fire with +fire*fight ';
            }
          } # and: before

          Context 'and: after' { # THESE LOOK LIKE DUPLICATES
            It 'should: move the first match after the first anchor' {
              [string]$source = 'so fight the +fire with +fire';
              [string]$escapedPattern = '+fire';
              [string]$anchor = 'fight ';
              [string]$relation = 'after';

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -Relation $relation -Anchor $anchor | `
                Should -BeExactly 'so fight +firethe  with +fire';

              Move-MatchLegacy -Source $source -Pattern $(esc($escapedPattern)) -Relation $relation -Anchor $anchor | `
                Should -BeExactly 'so fight +firethe  with +fire';
            }

            It 'should: move the last match after the first anchor' {
              [string]$source = 'so fight the +fire with +fire';
              [string]$escapedPattern = '+fire';
              [string]$anchor = 'fight ';
              [string]$relation = 'after';

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -PatternOccurrence 'L' `
                -Relation $relation -Anchor $anchor | `
                Should -BeExactly 'so fight +firethe +fire with ';

              Move-MatchLegacy -Source $source -Pattern $(esc($escapedPattern)) -PatternOccurrence 'L' `
                -Relation $relation -Anchor $anchor | `
                Should -BeExactly 'so fight +firethe +fire with ';
            }

            It 'should: move the first match after the last literal anchor' {
              [string]$source = 'so *fight the +fire with +fire *fight';
              [string]$escapedPattern = '+fire';
              [string]$escapedAnchor = '*fight';
              [string]$relation = 'after';

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern `
                -Relation $relation -EscapedAnchor $escapedAnchor -AnchorOccurrence 'L' | `
                Should -BeExactly 'so *fight the  with +fire *fight+fire';

              Move-MatchLegacy -Source $source -Pattern $(esc($escapedPattern)) `
                -Relation $relation -EscapedAnchor $escapedAnchor -AnchorOccurrence 'L' | `
                Should -BeExactly 'so *fight the  with +fire *fight+fire';
            }

            It 'should: move the last match after the last literal anchor' {
              [string]$source = '*fight +fire with *fight bump +fire';
              [string]$escapedPattern = '+fire';
              [string]$escapedAnchor = '*fight';
              [string]$relation = 'after';

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -PatternOccurrence 'L' `
                -Relation $relation -EscapedAnchor $escapedAnchor -AnchorOccurrence 'L' | `
                Should -BeExactly '*fight +fire with *fight+fire bump ';

              Move-MatchLegacy -Source $source -Pattern $(esc($escapedPattern)) -PatternOccurrence 'L' `
                -Relation $relation -EscapedAnchor $escapedAnchor -AnchorOccurrence 'L' | `
                Should -BeExactly '*fight +fire with *fight+fire bump ';
            }
          } # and: after
        } # and: Anchor matches
      } # and: vanilla move

      Context 'and: vanilla formatted move' -Tag 'DONE' { # Pattern, Paste
        Context 'and: Anchor matches' {
          It 'should: move the first match before the first anchor' {
            [string]$source = 'Judgement Day: [06-06-2626], Judgement Day: [28-02-2727], take your pick!';
            [string]$pattern = '\d{2}-\d{2}-\d{4}';
            [string]$anchor = 'Judgement';

            Move-MatchLegacy -Source $source -Pattern $pattern -Anchor $anchor `
              -Paste '==[$0]== ${_a}' | `
              Should -BeExactly '==[06-06-2626]== Judgement Day: [], Judgement Day: [28-02-2727], take your pick!';
          }

          It 'should: move the last match before the first anchor' {
            [string]$source = 'Judgement Day: [06-06-2626], Judgement Day: [28-02-2727], take your pick!';
            [string]$pattern = '\d{2}-\d{2}-\d{4}';
            [string]$anchor = 'Judgement';

            Move-MatchLegacy -Source $source -Pattern $pattern -PatternOccurrence 'L' `
              -Anchor $anchor `
              -Paste '==[$0]== ${_a}' | `
              Should -BeExactly '==[28-02-2727]== Judgement Day: [06-06-2626], Judgement Day: [], take your pick!';
          }
        } # and: Anchor matches
      } # and: vanilla formatted move

      Context 'and: exotic' { # Pattern, With/EscapedWith/LiteralWith
        Context 'and: before' { #!!!

        } # and: before

        Context 'and: after' {
          Context 'and: move last match after first anchor' { # Pattern, LiteralWith
            # The With tests only make sense if not using Paste, although you can use Paste with,
            # Relation, but LiteralWith is pointless, because you can just insert that text inside the
            # Paste.
            #
            Context 'and: Last With' {
              It 'should: move the first match after the first anchor' -Tag 'DONE' {
                [string]$source = 'Judgement Day [06-06-2626], Judgement Day [28-02-2727], Day: <Friday>';
                [string]$pattern = '\d{2}-\d{2}-\d{4}';
                [string]$anchor = 'Judgement\s';
                [string]$relation = 'after'
                [string]$With = '\d{2}-\d{2}-\d{4}';

                Move-MatchLegacy -Source $source -Pattern $pattern -Relation $relation -Anchor $anchor `
                  -With $With -WithOccurrence 'L' -Paste $paste | `
                  Should -BeExactly 'Judgement 28-02-2727Day [], Judgement Day [28-02-2727], Day: <Friday>';
              }
            } # With

            Context 'SKIPPED' -Skip {
              Context 'and: LiteralWith' -Tag 'DUFF' {
                It 'should: move the first match after the first anchor' {
                  [string]$source = 'Judgement Day [06-06-2626], Judgement Day [28-02-2727], Day: <Friday>';
                  [string]$pattern = '\d{2}-\d{2}-\d{4}';
                  [string]$anchor = 'Judgement';
                  [string]$relation = 'after'
                  [string]$literalWith = '**-**-**** ';

                  Move-MatchLegacy -Source $source -Pattern $pattern -Relation $relation -Anchor $anchor `
                    -LiteralWith $literalWith -Paste $paste | `
                    Should -BeExactly 'Judgement **-**-**** Day [], Judgement Day [28-02-2727], Day: <Friday>';
                }
              } # and: LiteralWith

              Context 'and: EscapedWith' {
                It 'should: move the last match after the first anchor' -Tag 'DONE' {
                  [string]$source = 'Judgement Day [06-06-2626], Judgement Day [28-02-2727], Day: <Friday>';
                  [string]$pattern = '\d{2}-\d{2}-\d{4}';
                  [string]$anchor = 'Judgement Day ';
                  [string]$relation = 'after'
                  [string]$with = '\<' + '\w+' + '\>'

                  Move-MatchLegacy -Source $source -Pattern $pattern -PatternOccurrence 'L' `
                    -Relation $relation -Anchor $anchor -With $with | `
                    Should -BeExactly 'Judgement Day <Friday>[06-06-2626], Judgement Day [], Day: <Friday>';
                }
              } # EscapedWith

              Context 'and: EscapedWith???' {
                It 'should: move the first match after the last literal anchor' -Tag 'DUFF' {
                  # There is no such thing as a literal anchor any more
                  #
                  [string]$source = 'Judgement^ Day [06-06-2626], Judgement^ Day [28-02-2727], Day: <Friday>';
                  [string]$pattern = '\d{2}-\d{2}-\d{4}';
                  [string]$literalAnchor = 'Judgement^';
                  [string]$relation = 'after'
                  [string]$literalWith = 'Day: <(?<day>\w+)>';
                  [string]$paste = '==(${day})==';

                  Move-MatchLegacy -Source $source -Pattern $pattern -Relation $relation -Anchor $literalAnchor `
                    -AnchorOccurrence 'L' -LiteralWith $literalWith -Paste $paste | `
                    Should -BeExactly 'Judgement^ Day [], Judgement^==(Friday)== Day [28-02-2727], Day: <Friday>';
                }

                It 'should: move the last match after the last literal anchor' -Tag 'DUFF' {
                  # There is no such thing as a literal anchor any more
                  #
                  [string]$source = 'Judgement^ Day [06-06-2626], Judgement^ Day [28-02-2727], Day: <Friday>';
                  [string]$pattern = '\d{2}-\d{2}-\d{4}';
                  [string]$literalAnchor = 'Judgement^';
                  [string]$relation = 'after'
                  [string]$literalWith = 'Day: <(?<day>\w+)>';
                  [string]$paste = '==(${day})==';

                  Move-MatchLegacy -Source $source -Pattern $pattern -Relation $relation -Anchor $literalAnchor `
                    -AnchorOccurrence 'L' -LiteralWith $literalWith -Paste $paste | `
                    Should -BeExactly 'Judgement^ Day [06-06-2626], Judgement^==(Friday)== Day [], Day: <Friday>';
                }

                # Cut ?
                Context 'and: LiteralWith???' {
                  It 'should: cut the first match and paste after the first anchor' -Tag 'DONE' {
                    [string]$source = 'There is where +fire your +fire is going';
                    [string]$escapedPattern = '+fire ';
                    [string]$anchor = 'is ';
                    [string]$relation = 'after'
                    [string]$literalWith = 'ice^';
                    [string]$paste = '($0) ';

                    Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -Relation $relation -Anchor $anchor `
                      -LiteralWith $literalWith -Paste $paste | `
                      Should -BeExactly 'There is (ice^) where your +fire is going';
                  }

                  It 'should: cut the last match and paste after the first anchor' -Tag 'DONE' {
                    [string]$source = 'There is where +fire your +fire is going';
                    [string]$escapedPattern = '+fire ';
                    [string]$anchor = 'is ';
                    [string]$relation = 'after'
                    [string]$literalWith = 'ice^';
                    [string]$paste = '($0) ';

                    Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -Relation $relation -Anchor $anchor `
                      -LiteralWith $literalWith -Paste $paste | `
                      Should -BeExactly 'There is (ice^) where +fire your is going';
                  }

                  It 'should: cut the first match and paste after the last literal anchor' {
                    [string]$source = 'There is$ where +fire your +fire is$ going';
                    [string]$escapedPattern = '+fire';
                    [string]$literalAnchor = 'is$';
                    [string]$relation = 'after'
                    [string]$literalWith = 'ice^';
                    [string]$paste = '($0)';

                    Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -Relation $relation -LiteralAnchor $literalAnchor `
                      -AnchorOccurrence 'L' -LiteralWith $literalWith -Paste $paste | `
                      Should -BeExactly 'There is$ where  your +fire is$(ice^) going';
                  }

                  It 'should: cut the last match paste after the last literal anchor' -Tag 'DONE' {
                    [string]$source = 'There is$ where +fire your +fire is$ going';
                    [string]$escapedPattern = '+fire';
                    [string]$literalAnchor = 'is$';
                    [string]$relation = 'after'
                    [string]$literalWith = 'ice^';
                    [string]$paste = '';

                    Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -Relation $relation -LiteralAnchor $literalAnchor `
                      -AnchorOccurrence 'L' -LiteralWith $literalWith -WithOccurrence 'L' -Paste $paste | `
                      Should -BeExactly 'There is where you are ice going';
                  }
                } # and: LiteralWith???
              }
            } # and: With
          } # and: move last match after first anchor
        } # and: after
      } # and: exotic formatted

      Context 'exotic formatted' -Tag 'DONE' { # Pattern, Paste, With/EscapedWith/LiteralWith
        Context 'and: Anchor matches' {
          # It's looking like there is little point in having the With parameter, because the
          # LiteralWith functionality is provided by the Paste and the With is actually Copy.
          # But With is useful with Relation if not using Paste.
          #
          It 'should: cut the first match and paste after the first anchor' {
            [string]$source = 'In the ZZZ year: +2525, Mourning +2525 ZZZ 12345 Sun';
            [string]$escapedPattern = '+2525';
            [string]$anchor = 'ZZZ ';
            [string]$with = '\d{5}';
            [string]$paste = '${_a}==($0)== ';

            Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -Anchor $anchor `
              -With $with -Paste $paste | `
              Should -BeExactly 'In the ZZZ ==(+2525)== year: , Mourning +2525 ZZZ 12345 Sun';
          }

          It 'should: cut the last match and paste after the first anchor' {
            [string]$source = 'In the ZZZ year: +2525, Mourning +2525 ZZZ 12345 Sun';
            [string]$escapedPattern = '+2525';
            [string]$anchor = 'ZZZ ';
            [string]$with = '\d{5}';
            [string]$paste = '${_a}==($0)== ';

            Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -PatternOccurrence 'L' `
              -Anchor $anchor -With $with -Paste $paste | `
              Should -BeExactly 'In the ZZZ ==(+2525)== year: +2525, Mourning  ZZZ 12345 Sun';
          }

          It 'should: cut the first match and paste after the last escaped anchor' {
            [string]$source = 'In the ZZZ+ year: +2525, Mourning +2525 ZZZ+ 12345 Sun';
            [string]$escapedPattern = '+2525';
            [string]$escapedAnchor = 'ZZZ+ ';
            [string]$with = '\d{5}';
            [string]$paste = '${_a}==(${_w})== ';

            Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -EscapedAnchor $escapedAnchor `
              -AnchorOccurrence 'L' -With $with -Paste $paste | `
              Should -BeExactly 'In the ZZZ+ year: , Mourning +2525 ZZZ+ ==(12345)== 12345 Sun';
          }

          It 'should: cut the last match paste after the last escaped anchor' {
            [string]$source = 'In the ZZZ+ year: +2525, Mourning +2525 ZZZ+ 12345 Sun';
            [string]$escapedPattern = '+2525';
            [string]$escapedAnchor = 'ZZZ+ ';
            [string]$with = '\d{5}';
            [string]$paste = '${_a}==(${_w})== ';

            Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -PatternOccurrence 'L' `
              -EscapedAnchor $escapedAnchor -AnchorOccurrence 'L' -With $with -WithOccurrence 'L' -Paste $paste | `
              Should -BeExactly 'In the ZZZ+ year: +2525, Mourning  ZZZ+ ==(12345)== 12345 Sun';

            Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -PatternOccurrence 'L' `
              -EscapedAnchor $escapedAnchor -AnchorOccurrence 'L' -With $with -WithOccurrence '1' -Paste $paste | `
              Should -BeExactly 'In the ZZZ+ year: +2525, Mourning  ZZZ+ ==(12345)== 12345 Sun';
          }

          Context 'and: Custom Anchor captures' {
            It 'should: cut the first match and paste before the last anchor' {
              [string]$source = 'In the ZZZ[blue, rose] year: +2525, Mourning +2525 ZZZ[white, rabbit] 12345 Sun';
              [string]$escapedPattern = '+2525';
              [string]$anchor = 'ZZZ\[(?<col>\w+), (?<obj>\w+)\]';
              [string]$paste = '==(COL: ${col}, OBJ: ${obj})== ${_a}';
              [string]$expected = 'In the ZZZ[blue, rose] year: , Mourning +2525 ==(COL: white, OBJ: rabbit)== ZZZ[white, rabbit] 12345 Sun';

              Move-MatchLegacy -Source $source -EscapedPattern $escapedPattern -Anchor $anchor `
                -AnchorOccurrence 'L' -Paste $paste | Should -BeExactly $expected;
            }
          }
        }
      } # exotic formatted

      Context 'and: Start' {

      } # and: Start

      Context 'and: End' {

      } # and: End
    } # and: EscapedPattern matches [and: vanilla move]

    Context 'and: vanilla move formatted' { # Pattern, Paste

    } # and: vanilla move formatted
  } # and: EscapedPattern matches
} # Move-MatchLegacy
