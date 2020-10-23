using namespace System.Text.RegularExpressions;

Describe 'Move-Match' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking

    . .\Tests\Helpers\new-expr.ps1
  }

  Context 'given: Pattern' -Tag 'Match' {
    Context 'and: Pattern matches' {
      Context 'and: vanilla move' { # Pattern
        Context 'and: Anchor matches' {
          Context 'and: before' -Tag 'OK' {
            It 'should: move the first match before the first anchor' {
              [string]$source = 'Judgement Day: [06-06-2626], Judgement Day: [28-02-2727], take your pick!';
              [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
              [RegEx]$anchor = new-expr('Judgement');
              [string]$relation = 'before'

              Move-Match -Value $source -Pattern $pattern -Relation $relation -Anchor $anchor | `
                Should -BeExactly '06-06-2626Judgement Day: [], Judgement Day: [28-02-2727], take your pick!';
            }

            It 'should: move the last match before the first anchor' {
              [string]$source = 'Judgement Day: [06-06-2626], Judgement Day: [28-02-2727], take your pick!';
              [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
              [RegEx]$anchor = new-expr('Judgement');
              [string]$relation = 'before'

              Move-Match -Value $source -Pattern $pattern -PatternOccurrence 'L' `
                -Relation $relation -Anchor $anchor | `
                Should -BeExactly '28-02-2727Judgement Day: [06-06-2626], Judgement Day: [], take your pick!';
            }

            It 'should: move the 2nd match before the first anchor' {
              [string]$source = 'Judgement Day: [06-06-2626], Judgement Day: [28-02-2727], take your pick!';
              [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
              [RegEx]$anchor = new-expr('Judgement');
              [string]$relation = 'before'

              Move-Match -Value $source -Pattern $pattern -PatternOccurrence '2' `
                -Relation $relation -Anchor $anchor | `
                Should -BeExactly '28-02-2727Judgement Day: [06-06-2626], Judgement Day: [], take your pick!';
            }

            It 'should: move the first match before the last escaped anchor' {
              [string]$source = 'Judgement+ Day: [06-06-2626], Judgement+ Day: [28-02-2727], take your pick!';
              [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
              [RegEx]$escapedAnchor = new-expr([regex]::Escape('Judgement+'));
              [string]$relation = 'before'

              Move-Match -Value $source -Pattern $pattern -Relation $relation -Anchor $escapedAnchor `
                -AnchorOccurrence 'L' | `
                Should -BeExactly 'Judgement+ Day: [], 06-06-2626Judgement+ Day: [28-02-2727], take your pick!';
            }

            It 'should: move the last match before the last escaped anchor' {
              [string]$source = 'Judgement+ Day: [06-06-2626], Judgement+ Day: [28-02-2727], take your pick!';
              [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
              [RegEx]$escapedAnchor = new-expr([regex]::Escape('Judgement+'));
              [string]$relation = 'before'

              Move-Match -Value $source -Pattern $pattern -PatternOccurrence 'L' `
                -Relation $relation -Anchor $escapedAnchor  -AnchorOccurrence 'L' | `
                Should -BeExactly 'Judgement+ Day: [06-06-2626], 28-02-2727Judgement+ Day: [], take your pick!';
            }

            # Pattern:
            #
            It 'should: move the first match before the first anchor' {
              [string]$source = 'fight +fire with +fire';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire'));
              [RegEx]$anchor = new-expr('fight');
              [string]$relation = 'before'

              Move-Match -Value $source -Pattern $escapedPattern -Relation $relation -Anchor $anchor | `
                Should -BeExactly '+firefight  with +fire';
            }

            It 'should: move the last match before the first anchor' {
              [string]$source = 'fight +fire with +fire';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire'));
              [RegEx]$anchor = new-expr('fight');
              [string]$relation = 'before'

              Move-Match -Value $source -Pattern $escapedPattern -PatternOccurrence 'L' `
                -Relation $relation -Anchor $anchor | `
                Should -BeExactly '+firefight +fire with ';
            }

            It 'should: move the first match before the last anchor' {
              [string]$source = '*fight +fire with *fight +fire';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire'));
              [RegEx]$escapedAnchor = new-expr([regex]::Escape('*fight'));
              [string]$relation = 'before'

              Move-Match -Value $source -Pattern $escapedPattern `
                -Relation $relation -Anchor $escapedAnchor -AnchorOccurrence 'L' | `
                Should -BeExactly '*fight  with +fire*fight +fire';
            }

            It 'should: move the last match before the last anchor' {
              [string]$source = '*fight +fire with *fight +fire';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire'));
              [RegEx]$escapedAnchor = new-expr([regex]::Escape('*fight'));
              [string]$relation = 'before'

              Move-Match -Value $source -Pattern $escapedPattern -PatternOccurrence 'L' `
                -Relation $relation -Anchor $escapedAnchor -AnchorOccurrence 'L' | `
                Should -BeExactly '*fight +fire with +fire*fight ';
            }
          } # and: before

          Context 'and: after' {
            It 'should: move the first match after the first anchor' {
              [string]$source = 'so fight the +fire with +fire';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire'));
              [RegEx]$anchor = new-expr('fight ');
              [string]$relation = 'after'

              Move-Match -Value $source -Pattern $escapedPattern -Relation $relation -Anchor $anchor | `
                Should -BeExactly 'so fight +firethe  with +fire';
            }

            It 'should: move the last match after the first anchor' {
              [string]$source = 'so fight the +fire with +fire';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire'));
              [RegEx]$anchor = new-expr('fight ');
              [string]$relation = 'after'

              Move-Match -Value $source -Pattern $escapedPattern -PatternOccurrence 'L' `
                -Relation $relation -Anchor $anchor | `
                Should -BeExactly 'so fight +firethe +fire with ';
            }

            It 'should: move the first match after the last escaped anchor' {
              [string]$source = 'so *fight the +fire with +fire *fight';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire'));
              [RegEx]$escapedAnchor = new-expr([regex]::Escape('*fight'));
              [string]$relation = 'after'

              Move-Match -Value $source -Pattern $escapedPattern `
                -Relation $relation -Anchor $escapedAnchor -AnchorOccurrence 'L' | `
                Should -BeExactly 'so *fight the  with +fire *fight+fire';
            }

            It 'should: move the last match after the last escaped anchor' {
              [string]$source = '*fight +fire with *fight bump +fire';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire'));
              [RegEx]$escapedAnchor = new-expr([regex]::Escape('*fight'));
              [string]$relation = 'after'

              Move-Match -Value $source -Pattern $escapedPattern -PatternOccurrence 'L' `
                -Relation $relation -Anchor $escapedAnchor -AnchorOccurrence 'L' | `
                Should -BeExactly '*fight +fire with *fight+fire bump ';
            }
          } # and: after
        } # and: Anchor matches

        Context 'and: Anchor NOT match' {
          Context 'and: vanilla move before' {
            It 'should: return source unmodified' {
              [string]$source = 'fight +fire with +fire';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire'));
              [RegEx]$anchor = 'blooper';
              [string]$relation = 'before'

              Move-Match -Value $source -Pattern $escapedPattern -Relation $relation -Anchor $anchor | `
                Should -BeExactly $source;
            }
          }
        } # and: Anchor NOT match

        Context 'and: Start specified' {
          Context 'and Pattern is midway in source' {
            It 'should: Move Pattern to Start' {
              [string]$source = 'There is fire where you are going';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('fire '));

              Move-Match -Value $source -Pattern $escapedPattern -Start | `
                Should -BeExactly 'fire There is where you are going';
            }
          } # and Pattern is midway in source

          Context 'and Pattern is already at Start in source' {
            It 'should: return source unmodified' {
              [string]$source = 'There is fire where you are going';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('There'));

              Move-Match -Value $source -Pattern $escapedPattern -Start | `
                Should -BeExactly 'There is fire where you are going';
            }
          } # and Pattern is already at Start in source
        } # and: Start specified

        Context 'and: End specified' {
          Context 'and Pattern is midway in source' {
            It 'should: Move Pattern to End' {
              [string]$source = 'There is fire where you are going';
              [RegEx]$escapedPattern = new-expr(' fire');

              Move-Match -Value $source -Pattern $escapedPattern -End | `
                Should -BeExactly 'There is where you are going fire';
            }
          } # and Pattern is midway in source

          Context 'and Pattern is already at End in source' {
            It 'should: return source unmodified' {
              [string]$source = 'There is fire where you are going';
              [RegEx]$escapedPattern = new-expr(' fire');

              Move-Match -Value $source -Pattern $escapedPattern -End | `
                Should -BeExactly 'There is where you are going fire';
            }
          } # and Pattern is midway in source
        } # and: End specified
      } # and: vanilla move

      Context 'and: vanilla move formatted' { # Pattern, Paste
        Context 'and: Anchor matches' {
          It 'should: move the first match before the first anchor' {
            [string]$source = 'Judgement Day: [06-06-2626], Judgement Day: [28-02-2727], take your pick!';
            [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
            [RegEx]$anchor = new-expr('Judgement');

            Move-Match -Value $source -Pattern $pattern `
              -Anchor $anchor -Paste '==[$0]== ${_a}' | `
              Should -BeExactly '==[06-06-2626]== Judgement Day: [], Judgement Day: [28-02-2727], take your pick!';
          }

          It 'should: move the last match before the first anchor' {
            [string]$source = 'Judgement Day: [06-06-2626], Judgement Day: [28-02-2727], take your pick!';
            [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
            [RegEx]$anchor = new-expr('Judgement');

            Move-Match -Value $source -Pattern $pattern -PatternOccurrence 'L' `
              -Anchor $anchor -Paste '==[$0]== ${_a}' | `
              Should -BeExactly '==[28-02-2727]== Judgement Day: [06-06-2626], Judgement Day: [], take your pick!';
          }
        } # and: Anchor matches
      } # and: vanilla move formatted

      Context 'and: exotic' { # Pattern, With/EscapedWith/LiteralWith

        # The With tests only make sense if not using Paste, although you can use Paste with,
        # Relation, but LiteralWith is pointless, because you can just insert that text inside the
        # Paste.
        #
        Context 'and: Last With' {
          It 'should: move the first match after the first anchor' {
            [string]$source = 'Judgement Day [06-06-2626], Judgement Day [28-02-2727], Day: <Friday>';
            [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
            [RegEx]$anchor = new-expr('Judgement\s');
            [string]$relation = 'after'
            [RegEx]$With = new-expr('\d{2}-\d{2}-\d{4}');

            Move-Match -Value $source -Pattern $pattern -Relation $relation -Anchor $anchor `
              -With $With -WithOccurrence 'L' -Paste $paste | `
              Should -BeExactly 'Judgement 28-02-2727Day [], Judgement Day [28-02-2727], Day: <Friday>';
          }
        } # and: Last With

        Context 'and: EscapedWith' {
          It 'should: move the last match after the first anchor' {
            [string]$source = 'Judgement Day [06-06-2626], Judgement Day [28-02-2727], Day: <Friday>';
            [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
            [RegEx]$anchor = new-expr('Judgement Day ');
            [string]$relation = 'after'
            [RegEx]$with = new-expr('\<' + '\w+' + '\>');

            Move-Match -Value $source -Pattern $pattern -PatternOccurrence 'L' `
              -Relation $relation -Anchor $anchor -With $with | `
              Should -BeExactly 'Judgement Day <Friday>[06-06-2626], Judgement Day [], Day: <Friday>';
          }
        } # and: EscapedWith

        Context 'and: LiteralWith' {
          It 'should: cut the first match and paste after the first anchor' {
            [string]$source = 'There is where +fire your +fire is going';
            [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire') + '\s');
            [RegEx]$anchor = new-expr('is ');
            [string]$literalWith = 'ice^';
            [string]$paste = '${_a}(${_w}) ';

            Move-Match -Value $source -Pattern $escapedPattern -Anchor $anchor `
              -LiteralWith $literalWith -Paste $paste | `
              Should -BeExactly 'There is (ice^) where your +fire is going';
          }

          It 'should: cut the last match and paste With after the first anchor' {
            [string]$source = 'There is where +fire your +fire is going';
            [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire') + '\s');
            [RegEx]$anchor = new-expr('is ');
            [string]$relation = 'after'
            [string]$literalWith = 'ice^';
            [string]$paste = '${_a}(${_w}) ';

            Move-Match -Value $source -Pattern $escapedPattern -Relation $relation -Anchor $anchor `
              -LiteralWith $literalWith -Paste $paste | `
              Should -BeExactly 'There is (ice^) where your +fire is going';
          }

          It 'should: cut the last match and paste Pattern after the first anchor' {
            [string]$source = 'There is where +fire your +fire is going';
            [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire') + '\s');
            [RegEx]$anchor = new-expr('is ');
            [string]$literalWith = 'ice^';
            [string]$paste = '${_a}($0) ';

            Move-Match -Value $source -Pattern $escapedPattern -Anchor $anchor `
              -LiteralWith $literalWith -Paste $paste | `
              Should -BeExactly 'There is (+fire ) where your +fire is going';
          }

          It 'should: cut the first match and paste after the last literal anchor' {
            [string]$source = 'There is$ where +fire your +fire is$ going';
            [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire') + '\s');
            [RegEx]$literalAnchor = new-expr([regex]::Escape('is$'));
            [string]$literalWith = 'ice^';
            [string]$paste = '${_a}(${_w})';

            Move-Match -Value $source -Pattern $escapedPattern -Anchor $literalAnchor `
              -AnchorOccurrence 'L' -LiteralWith $literalWith -Paste $paste | `
              Should -BeExactly 'There is$ where your +fire is$(ice^) going';
          }

          It 'should: cut the last match paste after the last literal anchor' {
            [string]$source = 'There is$ where +fire your +fire is$ going';
            [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire') + '\s');
            [RegEx]$literalAnchor = new-expr([regex]::Escape('is$'));
            [string]$literalWith = 'ice^';
            [string]$paste = '${_a}(${_w})';

            Move-Match -Value $source -Pattern $escapedPattern -PatternOccurrence 'L' `
              -Anchor $literalAnchor -AnchorOccurrence 'L' `
              -LiteralWith $literalWith -WithOccurrence 'L' -Paste $paste | `
              Should -BeExactly 'There is$ where +fire your is$(ice^) going';
          }
        } # and: LiteralWith
      } # and: exotic

      Context 'and: exotic formatted' { # Pattern, Paste, With/EscapedWith/LiteralWith
        Context 'and: Anchor matches' {
          # It's looking like there is little point in having the With parameter, because the
          # LiteralWith functionality is provided by the Paste and the With is actually Copy.
          # But With is useful with Relation if not using Paste.
          #
          It 'should: cut the first match and paste after the first anchor' {
            [string]$source = 'In the ZZZ year: +2525, Mourning +2525 ZZZ 12345 Sun';
            [RegEx]$escapedPattern = new-expr([regex]::Escape('+2525'));
            [RegEx]$anchor = new-expr('ZZZ ');
            [RegEx]$with = new-expr('\d{5}');
            [string]$paste = '${_a}==($0)== ';

            Move-Match -Value $source -Pattern $escapedPattern -Anchor $anchor `
              -With $with -Paste $paste | `
              Should -BeExactly 'In the ZZZ ==(+2525)== year: , Mourning +2525 ZZZ 12345 Sun';
          }

          It 'should: cut the last match and paste after the first anchor' {
            [string]$source = 'In the ZZZ year: +2525, Mourning +2525 ZZZ 12345 Sun';
            [RegEx]$escapedPattern = new-expr([regex]::Escape('+2525'));
            [RegEx]$anchor = new-expr('ZZZ ');
            [RegEx]$with = new-expr('\d{5}');
            [string]$paste = '${_a}==($0)== ';

            Move-Match -Value $source -Pattern $escapedPattern -PatternOccurrence 'L' `
              -Anchor $anchor -With $with -Paste $paste | `
              Should -BeExactly 'In the ZZZ ==(+2525)== year: +2525, Mourning  ZZZ 12345 Sun';
          }

          It 'should: cut the first match and paste after the last escaped anchor' {
            [string]$source = 'In the ZZZ+ year: +2525, Mourning +2525 ZZZ+ 12345 Sun';
            [RegEx]$escapedPattern = new-expr([regex]::Escape('+2525'));
            [RegEx]$escapedAnchor = new-expr([regex]::Escape('ZZZ+ '));
            [RegEx]$with = new-expr('\d{5}');
            [string]$paste = '${_a}==(${_w})== ';

            Move-Match -Value $source -Pattern $escapedPattern -Anchor $escapedAnchor `
              -AnchorOccurrence 'L' -With $with -Paste $paste | `
              Should -BeExactly 'In the ZZZ+ year: , Mourning +2525 ZZZ+ ==(12345)== 12345 Sun';
          }

          It 'should: cut the last match paste after the last escaped anchor' {
            [string]$source = 'In the ZZZ+ year: +2525, Mourning +2525 ZZZ+ 12345 Sun';
            [RegEx]$escapedPattern = new-expr([regex]::Escape('+2525'));
            [RegEx]$escapedAnchor = new-expr([regex]::Escape('ZZZ+ '));
            [RegEx]$with = new-expr('\d{5}');
            [string]$paste = '${_a}==(${_w})== ';

            Move-Match -Value $source -Pattern $escapedPattern -PatternOccurrence 'L' `
              -Anchor $escapedAnchor -AnchorOccurrence 'L' -With $with -WithOccurrence 'L' -Paste $paste | `
              Should -BeExactly 'In the ZZZ+ year: +2525, Mourning  ZZZ+ ==(12345)== 12345 Sun';
          }

          Context 'and: Custom Anchor captures' {
            It 'should: cut the first match and paste before the last anchor' {
              [string]$source = 'In the ZZZ[blue, rose] year: +2525, Mourning +2525 ZZZ[white, rabbit] 12345 Sun';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('+2525'));
              [RegEx]$anchor = new-expr('ZZZ\[(?<col>\w+), (?<obj>\w+)\]');
              [string]$paste = '==(COL: ${col}, OBJ: ${obj})== ${_a}';
              [string]$expected = 'In the ZZZ[blue, rose] year: , Mourning +2525 ==(COL: white, OBJ: rabbit)== ZZZ[white, rabbit] 12345 Sun';

              Move-Match -Value $source -Pattern $escapedPattern -Anchor $anchor `
                -AnchorOccurrence 'L' -Paste $paste | Should -BeExactly $expected;
            }
          }
        } # and: Anchor matches
      } # and: exotic formatted
    } # and: Pattern matches

    Context 'and: No Pattern match' {
      It 'should: return source unmodified' {
        [string]$source = 'There 23-03-1984 will be fire on where you are going';
        [RegEx]$pattern = new-expr('bomb!');
        [RegEx]$anchor = new-expr('\d{2}-\d{2}-\d{4}\s');

        Move-Match -Value $source -Pattern $pattern -Relation 'before' -Anchor $anchor | `
          Should -BeExactly $source -Because "No ('$pattern') match found";
      }
    } # and: No Pattern match
  } # given: Pattern
} # Move-Match
