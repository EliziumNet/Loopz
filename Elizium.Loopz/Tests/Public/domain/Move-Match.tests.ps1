using namespace System.Text.RegularExpressions;

Describe 'Move-Match' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking

    . .\Tests\Helpers\new-expr.ps1
  }

  Context 'given: Pattern' {
    Context 'and: Pattern matches' {
      Context 'and: vanilla move' { # Pattern
        Context 'and: Anchor matches' {
          Context 'and: before' {
            It 'should: move the first match before the first anchor' {
              [string]$source = 'Judgement Day: [06-06-2626], Judgement Day: [28-02-2727], take your pick!';
              [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
              [RegEx]$anchor = new-expr('Judgement');
              [string]$relation = 'before'

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $pattern -Relation $relation -Anchor $anchor;
              $moveResult.Payload | Should -BeExactly '06-06-2626Judgement Day: [], Judgement Day: [28-02-2727], take your pick!';
            }

            It 'should: move the last match before the first anchor' {
              [string]$source = 'Judgement Day: [06-06-2626], Judgement Day: [28-02-2727], take your pick!';
              [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
              [RegEx]$anchor = new-expr('Judgement');
              [string]$relation = 'before'

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $pattern -PatternOccurrence 'L' `
                -Relation $relation -Anchor $anchor;
              $moveResult.Payload | Should -BeExactly '28-02-2727Judgement Day: [06-06-2626], Judgement Day: [], take your pick!';
            }

            It 'should: move the 2nd match before the first anchor' {
              [string]$source = 'Judgement Day: [06-06-2626], Judgement Day: [28-02-2727], take your pick!';
              [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
              [RegEx]$anchor = new-expr('Judgement');
              [string]$relation = 'before'

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $pattern -PatternOccurrence '2' `
                -Relation $relation -Anchor $anchor;
              $moveResult.Payload | Should -BeExactly '28-02-2727Judgement Day: [06-06-2626], Judgement Day: [], take your pick!';
            }

            It 'should: move the first match before the last escaped anchor' {
              [string]$source = 'Judgement+ Day: [06-06-2626], Judgement+ Day: [28-02-2727], take your pick!';
              [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
              [RegEx]$escapedAnchor = new-expr([regex]::Escape('Judgement+'));
              [string]$relation = 'before'

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $pattern -Relation $relation -Anchor $escapedAnchor `
                -AnchorOccurrence 'L';
              $moveResult.Payload | Should -BeExactly 'Judgement+ Day: [], 06-06-2626Judgement+ Day: [28-02-2727], take your pick!';
            }

            It 'should: move the last match before the last escaped anchor' {
              [string]$source = 'Judgement+ Day: [06-06-2626], Judgement+ Day: [28-02-2727], take your pick!';
              [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
              [RegEx]$escapedAnchor = new-expr([regex]::Escape('Judgement+'));
              [string]$relation = 'before'

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $pattern -PatternOccurrence 'L' `
                -Relation $relation -Anchor $escapedAnchor  -AnchorOccurrence 'L';
              $moveResult.Payload | Should -BeExactly 'Judgement+ Day: [06-06-2626], 28-02-2727Judgement+ Day: [], take your pick!';
            }

            # Pattern:
            #
            It 'should: move the first match before the first anchor' {
              [string]$source = 'fight +fire with +fire';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire'));
              [RegEx]$anchor = new-expr('fight');
              [string]$relation = 'before'

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -Relation $relation -Anchor $anchor;
              $moveResult.Payload | Should -BeExactly '+firefight  with +fire';
            }

            It 'should: move the last match before the first anchor' {
              [string]$source = 'fight +fire with +fire';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire'));
              [RegEx]$anchor = new-expr('fight');
              [string]$relation = 'before'

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -PatternOccurrence 'L' `
                -Relation $relation -Anchor $anchor;
              $moveResult.Payload | Should -BeExactly '+firefight +fire with ';
            }

            It 'should: move the first match before the last anchor' {
              [string]$source = '*fight +fire with *fight +fire';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire'));
              [RegEx]$escapedAnchor = new-expr([regex]::Escape('*fight'));
              [string]$relation = 'before'

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern `
                -Relation $relation -Anchor $escapedAnchor -AnchorOccurrence 'L';
              $moveResult.Payload | Should -BeExactly '*fight  with +fire*fight +fire';
            }

            It 'should: move the last match before the last anchor' {
              [string]$source = '*fight +fire with *fight +fire';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire'));
              [RegEx]$escapedAnchor = new-expr([regex]::Escape('*fight'));
              [string]$relation = 'before'

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -PatternOccurrence 'L' `
                -Relation $relation -Anchor $escapedAnchor -AnchorOccurrence 'L';
              $moveResult.Payload | Should -BeExactly '*fight +fire with +fire*fight ';
            }

            Context 'and: Drop' {
              It 'should: move the first match before the first anchor' {
                [string]$source = 'fight +fire with +fire';
                [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire'));
                [RegEx]$anchor = new-expr('fight');
                [string]$relation = 'before'
                [string]$expectedPayload = '+firefight ^ with +fire';

                [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern `
                  -Relation $relation -Anchor $anchor -Drop '^';

                $moveResult.Payload | Should -BeExactly $expectedPayload;
              }

              It 'should: move the last match before the last escaped anchor' {
                [string]$source = 'Judgement+ Day: [06-06-2626], Judgement+ Day: [28-02-2727], take your pick!';
                [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
                [RegEx]$escapedAnchor = new-expr([regex]::Escape('Judgement+'));
                [string]$relation = 'before';
                [string]$expectedPayload = 'Judgement+ Day: [06-06-2626], 28-02-2727Judgement+ Day: [^], take your pick!';

                [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $pattern `
                  -PatternOccurrence 'L' `
                  -Relation $relation -Anchor $escapedAnchor  -AnchorOccurrence 'L' -Drop '^';

                $moveResult.Payload | Should -BeExactly $expectedPayload;
              }
            }
          } # and: before

          Context 'and: after' {
            It 'should: move the first match after the first anchor' {
              [string]$source = 'so fight the +fire with +fire';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire'));
              [RegEx]$anchor = new-expr('fight ');
              [string]$relation = 'after'

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -Relation $relation -Anchor $anchor;
              $moveResult.Payload | Should -BeExactly 'so fight +firethe  with +fire';
            }

            It 'should: move the last match after the first anchor' {
              [string]$source = 'so fight the +fire with +fire';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire'));
              [RegEx]$anchor = new-expr('fight ');
              [string]$relation = 'after'

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -PatternOccurrence 'L' `
                -Relation $relation -Anchor $anchor;
              $moveResult.Payload | Should -BeExactly 'so fight +firethe +fire with ';
            }

            It 'should: move the first match after the last escaped anchor' {
              [string]$source = 'so *fight the +fire with +fire *fight';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire'));
              [RegEx]$escapedAnchor = new-expr([regex]::Escape('*fight'));
              [string]$relation = 'after'

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern `
                -Relation $relation -Anchor $escapedAnchor -AnchorOccurrence 'L';
              $moveResult.Payload | Should -BeExactly 'so *fight the  with +fire *fight+fire';
            }

            It 'should: move the last match after the last escaped anchor' {
              [string]$source = '*fight +fire with *fight bump +fire';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire'));
              [RegEx]$escapedAnchor = new-expr([regex]::Escape('*fight'));
              [string]$relation = 'after'

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -PatternOccurrence 'L' `
                -Relation $relation -Anchor $escapedAnchor -AnchorOccurrence 'L';
              $moveResult.Payload | Should -BeExactly '*fight +fire with *fight+fire bump ';
            }

            Context 'and: Drop' {
              It 'should: move the first match after the first anchor' {
                [string]$source = 'so fight the +fire with +fire';
                [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire'));
                [RegEx]$anchor = new-expr('fight ');
                [string]$relation = 'after'

                [string]$expectedPayload = 'so fight +firethe ^ with +fire';
                [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern `
                  -Relation $relation -Anchor $anchor -Drop '^';

                $moveResult.Payload | Should -BeExactly $expectedPayload;
              }
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

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern `
                -Relation $relation -Anchor $anchor;
              $moveResult.Payload | Should -BeExactly $source;

              $moveResult.FailedReason.Contains('Anchor') | Should -BeTrue;
            }
          }
        } # and: Anchor NOT match

        Context 'and: Start specified' {
          Context 'and Pattern is midway in source' {
            It 'should: Move Pattern to Start' {
              [string]$source = 'There is fire where you are going';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('fire '));

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -Start;
              $moveResult.Payload | Should -BeExactly 'fire There is where you are going';
            }
          } # and Pattern is midway in source

          Context 'and Pattern is already at Start in source' {
            It 'should: return source unmodified' {
              [string]$source = 'There is fire where you are going';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('There'));

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -Start;
              $moveResult.Payload | Should -BeExactly $source;
            }
          } # and Pattern is already at Start in source

          Context 'and: with Paste' {
            It 'should: Move Pattern to Start' {
              [string]$source = 'There is fire where you are going';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('fire '));

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -Paste '==[$0]== ' -Start;
              $moveResult.Payload | Should -BeExactly '==[fire ]== There is where you are going';
            }
          }

          Context 'and: with Paste containing Pattern named group references' {
            It 'should: Move Pattern to Start' {
              [string]$source = 'In the day of 29-03-2525.';
              [RegEx]$escapedPattern = new-expr('\s(?<d>\d{2})-(?<m>\d{2})-(?<y>\d{4})');

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern `
                -Paste 'Americanised: ${m}-${d}-${y} ' -Start;
              $moveResult.Payload | Should -BeExactly 'Americanised: 03-29-2525 In the day of.';
            }

            Context 'and: Drop' {
              It 'should: Move Pattern to Start and Drop Captures' {
                [string]$source = 'In the day of 29-03-2525.';
                [RegEx]$escapedPattern = new-expr('\s(?<d>\d{2})-(?<m>\d{2})-(?<y>\d{4})');

                [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern `
                  -Paste 'Americanised: ${m}-${d}-${y} ' -Start -Drop ' iso:(${y}_${m}_${d})';
                $moveResult.Payload | Should -BeExactly 'Americanised: 03-29-2525 In the day of iso:(2525_03_29).';
              }

              It 'should: Move Pattern to Start and Drop Copy' {
                [string]$source = 'In the day of 29-03-2525.';
                [RegEx]$escapedPattern = new-expr('\s(?<d>\d{2})-(?<m>\d{2})-(?<y>\d{4})');

                [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern `
                  -Paste 'Americanised: ${m}-${d}-${y} ' -Start -Drop ' [${_c}]' -Copy '^[\w]+';

                $moveResult.Payload | Should -BeExactly 'Americanised: 03-29-2525 In the day of [In].';
              }

              It 'should: Move Pattern to Start and Drop Copy' {
                [string]$source = 'In the day of 29-03-2525.';
                [RegEx]$escapedPattern = new-expr('\s(?<d>\d{2})-(?<m>\d{2})-(?<y>\d{4})');

                [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern `
                  -Paste 'Americanised: ${m}-${d}-${y} ' -Start -Drop ' [${first}, ${second}]' `
                  -Copy '^(?<first>[\w]+)\s(?<second>[\w]+)';

                $moveResult.Payload | Should -BeExactly 'Americanised: 03-29-2525 In the day of [In, the].';
              }
            }
          }
        } # and: Start specified

        Context 'and: End specified' {
          Context 'and Pattern is midway in source' {
            It 'should: Move Pattern to End' {
              [string]$source = 'There is fire where you are going';
              [RegEx]$escapedPattern = new-expr(' fire');

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -End;
              $moveResult.Payload | Should -BeExactly 'There is where you are going fire';
            }
          } # and Pattern is midway in source

          Context 'and Pattern is already at End in source' {
            It 'should: return source unmodified' {
              [string]$source = 'There is fire where you are going';
              [RegEx]$escapedPattern = new-expr('going');

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -End;
              $moveResult.Payload | Should -BeExactly $source;
            }
          } # and Pattern is midway in source

          Context 'and: with Paste containing Pattern named group references' {
            It 'should: Move Pattern to End' {
              [string]$source = 'In the day of 29-03-2525, Justice will reign.';
              [RegEx]$escapedPattern = new-expr('\s(?<d>\d{2})-(?<m>\d{2})-(?<y>\d{4})');

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -Paste 'Americanised: ${m}-${d}-${y}.' -End;
              $moveResult.Payload | Should -BeExactly 'In the day of, Justice will reign.Americanised: 03-29-2525.';
            }
          }
        } # and: End specified
      } # and: vanilla move

      Context 'and: Hybrid Anchor' {
        Context 'and: Anchor does match Pattern' {
          Context 'and: Hybrid Anchor' {
            Context 'and: Start specified' {
              It 'should: ignore Start and move to Anchor' {
                [string]$source = 'the !@£$%^ frayed ends of sanity';
                [RegEx]$pattern = new-expr('(?<gibberish>[^\w\s]+)\s');
                [RegEx]$anchor = new-expr('sanity');
                [string]$relation = 'before';
                [string]$paste = '${gibberish} ${_a}';
                [string]$expectedPayload = 'the frayed ends of !@£$%^ sanity';

                [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $pattern `
                  -Relation $relation -Anchor $anchor -Start -Paste $paste;

                $moveResult.Payload | Should -BeExactly $expectedPayload;
              }
            }

            Context 'and: End specified' {
              It 'should: ignore End and move to Anchor' {
                [string]$source = 'the !@£$%^ frayed ends of sanity';
                [RegEx]$pattern = new-expr('(?<gibberish>[^\w\s]+)\s');
                [RegEx]$anchor = new-expr('sanity');
                [string]$relation = 'before';
                [string]$paste = '${gibberish} ${_a}';
                [string]$expectedPayload = 'the frayed ends of !@£$%^ sanity';

                [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $pattern `
                  -Relation $relation -Anchor $anchor -End -Paste $paste;

                $moveResult.Payload | Should -BeExactly $expectedPayload;
              }
            }
          }
        }

        Context 'and: Anchor does NOT match Pattern' {
          Context 'and: Start specified' {
            It 'should: move to start' {
              [string]$source = 'the !@£$%^ frayed ends of sanity';
              [RegEx]$anchor = new-expr('blooper');
              [string]$relation = 'before';
              [RegEx]$pattern = new-expr('(?<gibberish>[^\w\s]+)\s');
              [string]$paste = '${gibberish} ';
              [string]$expectedPayload = '!@£$%^ the frayed ends of sanity';

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $pattern `
                -Relation $relation -Anchor $anchor -Start -Paste $paste;

              $moveResult.Payload | Should -BeExactly $expectedPayload;
            }
          }

          Context 'and: End specified' {
            It 'should: move to end' {
              [string]$source = 'the !@£$%^ frayed ends of sanity';
              [RegEx]$anchor = new-expr('blooper');
              [string]$relation = 'before';
              [RegEx]$pattern = new-expr('(?<gibberish>[^\w\s]+)\s');
              [string]$paste = '${gibberish} ';
              [string]$expectedPayload = '!@£$%^ the frayed ends of sanity';

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $pattern `
                -Relation $relation -Anchor $anchor -Start -Paste $paste;

              $moveResult.Payload | Should -BeExactly $expectedPayload;
            }
          }
        }
      } # and: Hybrid Anchor

      Context 'and: vanilla move formatted' { # Pattern, Paste
        Context 'and: Anchor matches' {
          It 'should: move the first match before the first anchor' {
            [string]$source = 'Judgement Day: [06-06-2626], Judgement Day: [28-02-2727], take your pick!';
            [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
            [RegEx]$anchor = new-expr('Judgement');

            [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $pattern `
              -Anchor $anchor -Paste '==[$0]== ${_a}';
            $moveResult.Payload | Should -BeExactly '==[06-06-2626]== Judgement Day: [], Judgement Day: [28-02-2727], take your pick!';
          }

          It 'should: move the last match before the first anchor' {
            [string]$source = 'Judgement Day: [06-06-2626], Judgement Day: [28-02-2727], take your pick!';
            [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
            [RegEx]$anchor = new-expr('Judgement');

            [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $pattern -PatternOccurrence 'L' `
              -Anchor $anchor -Paste '==[$0]== ${_a}';
            $moveResult.Payload | Should -BeExactly '==[28-02-2727]== Judgement Day: [06-06-2626], Judgement Day: [], take your pick!';
          }
        } # and: Anchor matches
      } # and: vanilla move formatted

      Context 'and: exotic' { # Pattern, Copy/EscapedWith/With

        # The Copy tests only make sense if not using Paste, although you can use Paste with,
        # Relation, but With is pointless, because you can just insert that text inside the
        # Paste.
        #
        Context 'and: Last Copy' {
          It 'should: move the first match after the first anchor' {
            [string]$source = 'Judgement Day [06-06-2626], Judgement Day [28-02-2727], Day: <Friday>';
            [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
            [RegEx]$anchor = new-expr('Judgement\s');
            [string]$relation = 'after'
            [RegEx]$copy = new-expr('\d{2}-\d{2}-\d{4}');

            [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $pattern -Relation $relation -Anchor $anchor `
              -Copy $copy -CopyOccurrence 'L';
            $moveResult.Payload | Should -BeExactly 'Judgement 28-02-2727Day [], Judgement Day [28-02-2727], Day: <Friday>';
          }
        } # and: Last Copy

        Context 'and: EscapedWith' {
          It 'should: move the last match after the first anchor' {
            [string]$source = 'Judgement Day [06-06-2626], Judgement Day [28-02-2727], Day: <Friday>';
            [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
            [RegEx]$anchor = new-expr('Judgement Day ');
            [string]$relation = 'after'
            [RegEx]$copy = new-expr('\<' + '\w+' + '\>');

            [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $pattern -PatternOccurrence 'L' `
              -Relation $relation -Anchor $anchor -Copy $copy;
            $moveResult.Payload | Should -BeExactly 'Judgement Day <Friday>[06-06-2626], Judgement Day [], Day: <Friday>';
          }
        } # and: EscapedWith

        Context 'and: With' {
          It 'should: cut the first match and paste after the first anchor' {
            [string]$source = 'There is where +fire your +fire is going';
            [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire') + '\s');
            [RegEx]$anchor = new-expr('is ');
            [string]$with = 'ice^';
            [string]$paste = '${_a}(${_c}) ';

            [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -Anchor $anchor `
              -With $with -Paste $paste;
            $moveResult.Payload | Should -BeExactly 'There is (ice^) where your +fire is going';
          }

          It 'should: cut the last match and paste Copy after the first anchor' {
            [string]$source = 'There is where +fire your +fire is going';
            [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire') + '\s');
            [RegEx]$anchor = new-expr('is ');
            [string]$relation = 'after'
            [string]$with = 'ice^';
            [string]$paste = '${_a}(${_c}) ';

            [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -Relation $relation -Anchor $anchor `
              -With $with -Paste $paste;
            $moveResult.Payload | Should -BeExactly 'There is (ice^) where your +fire is going';
          }

          It 'should: cut the last match and paste Pattern after the first anchor' {
            [string]$source = 'There is where +fire your +fire is going';
            [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire') + '\s');
            [RegEx]$anchor = new-expr('is ');
            [string]$with = 'ice^';
            [string]$paste = '${_a}($0) ';

            [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -Anchor $anchor `
              -With $with -Paste $paste;
            $moveResult.Payload | Should -BeExactly 'There is (+fire ) where your +fire is going';
          }

          It 'should: cut the first match and paste after the last literal anchor' {
            [string]$source = 'There is$ where +fire your +fire is$ going';
            [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire') + '\s');
            [RegEx]$literalAnchor = new-expr([regex]::Escape('is$'));
            [string]$with = 'ice^';
            [string]$paste = '${_a}(${_c})';

            [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -Anchor $literalAnchor `
              -AnchorOccurrence 'L' -With $with -Paste $paste;
            $moveResult.Payload | Should -BeExactly 'There is$ where your +fire is$(ice^) going';
          }

          It 'should: cut the last match paste after the last literal anchor' {
            [string]$source = 'There is$ where +fire your +fire is$ going';
            [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire') + '\s');
            [RegEx]$literalAnchor = new-expr([regex]::Escape('is$'));
            [string]$with = 'ice^';
            [string]$paste = '${_a}(${_c})';

            [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -PatternOccurrence 'L' `
              -Anchor $literalAnchor -AnchorOccurrence 'L' `
              -With $with -CopyOccurrence 'L' -Paste $paste;
            $moveResult.Payload | Should -BeExactly 'There is$ where +fire your is$(ice^) going';
          }

          Context 'and: Drop' {
            It 'should: cut the first match and paste after the first anchor' {
              [string]$source = 'There is where +fire your +fire is going';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('+fire') + '\s');
              [RegEx]$anchor = new-expr('is ');
              [string]$with = 'ice^';
              [string]$paste = '${_a}(${_c}) ';
              [string]$expectedPayload = 'There is (ice^) where @your +fire is going'

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -Anchor $anchor `
                -With $with -Paste $paste -Drop '@';

              $moveResult.Payload | Should -BeExactly $expectedPayload;
            }
          }
        } # and: With

        Context 'and: Copy does NOT match' {
          It 'should: move the last match after the first anchor' {
            [string]$source = 'Judgement Day [06-06-2626], Judgement Day [28-02-2727], Day: <Friday>';
            [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
            [RegEx]$anchor = new-expr('Judgement Day ');
            [string]$relation = 'after'
            [RegEx]$copy = new-expr('blooper');

            [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $pattern -PatternOccurrence 'L' `
              -Relation $relation -Anchor $anchor -Copy $copy;

            $moveResult.Payload | Should -BeExactly $source;
            $moveResult.Success | Should -BeFalse;
            $moveResult.FailedReason.Contains('Copy') | Should -BeTrue;
          }
        } # and: Copy does NOT match
      } # and: exotic

      Context 'and: exotic formatted' { # Pattern, Paste, Copy/EscapedWith/With
        Context 'and: Anchor matches' {
          # It's looking like there is little point in having the Copy parameter, because the
          # With functionality is provided by the Paste and the Copy is actually Copy.
          # But Copy is useful with Relation if not using Paste.
          #
          It 'should: cut the first match and paste after the first anchor' {
            [string]$source = 'In the ZZZ year: +2525, Mourning +2525 ZZZ 12345 Sun';
            [RegEx]$escapedPattern = new-expr([regex]::Escape('+2525'));
            [RegEx]$anchor = new-expr('ZZZ ');
            [RegEx]$copy = new-expr('\d{5}');
            [string]$paste = '${_a}==($0)== ';

            [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -Anchor $anchor `
              -Copy $copy -Paste $paste;
            $moveResult.Payload | Should -BeExactly 'In the ZZZ ==(+2525)== year: , Mourning +2525 ZZZ 12345 Sun';
          }

          It 'should: cut the last match and paste after the first anchor' {
            [string]$source = 'In the ZZZ year: +2525, Mourning +2525 ZZZ 12345 Sun';
            [RegEx]$escapedPattern = new-expr([regex]::Escape('+2525'));
            [RegEx]$anchor = new-expr('ZZZ ');
            [RegEx]$copy = new-expr('\d{5}');
            [string]$paste = '${_a}==($0)== ';

            [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -PatternOccurrence 'L' `
              -Anchor $anchor -Copy $copy -Paste $paste;
            $moveResult.Payload | Should -BeExactly 'In the ZZZ ==(+2525)== year: +2525, Mourning  ZZZ 12345 Sun';
          }

          It 'should: cut the first match and paste after the last escaped anchor' {
            [string]$source = 'In the ZZZ+ year: +2525, Mourning +2525 ZZZ+ 12345 Sun';
            [RegEx]$escapedPattern = new-expr([regex]::Escape('+2525'));
            [RegEx]$escapedAnchor = new-expr([regex]::Escape('ZZZ+ '));
            [RegEx]$copy = new-expr('\d{5}');
            [string]$paste = '${_a}==(${_c})== ';

            [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -Anchor $escapedAnchor `
              -AnchorOccurrence 'L' -Copy $copy -Paste $paste;
            $moveResult.Payload | Should -BeExactly 'In the ZZZ+ year: , Mourning +2525 ZZZ+ ==(12345)== 12345 Sun';
          }

          It 'should: cut the last match paste after the last escaped anchor' {
            [string]$source = 'In the ZZZ+ year: +2525, Mourning +2525 ZZZ+ 12345 Sun';
            [RegEx]$escapedPattern = new-expr([regex]::Escape('+2525'));
            [RegEx]$escapedAnchor = new-expr([regex]::Escape('ZZZ+ '));
            [RegEx]$copy = new-expr('\d{5}');
            [string]$paste = '${_a}==(${_c})== ';

            [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -PatternOccurrence 'L' `
              -Anchor $escapedAnchor -AnchorOccurrence 'L' -Copy $copy -CopyOccurrence 'L' -Paste $paste;
            $moveResult.Payload | Should -BeExactly 'In the ZZZ+ year: +2525, Mourning  ZZZ+ ==(12345)== 12345 Sun';
          }

          Context 'and: Custom Anchor captures' {
            It 'should: cut the first match and paste before the last anchor' {
              [string]$source = 'In the ZZZ[blue, rose] year: +2525, Mourning +2525 ZZZ[white, rabbit] 12345 Sun';
              [RegEx]$escapedPattern = new-expr([regex]::Escape('+2525'));
              [RegEx]$anchor = new-expr('ZZZ\[(?<col>\w+), (?<obj>\w+)\]');
              [string]$paste = '==(COL: ${col}, OBJ: ${obj})== ${_a}';
              [string]$expected = 'In the ZZZ[blue, rose] year: , Mourning +2525 ==(COL: white, OBJ: rabbit)== ZZZ[white, rabbit] 12345 Sun';

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $escapedPattern -Anchor $anchor `
                -AnchorOccurrence 'L' -Paste $paste;
              $moveResult.Payload | Should -BeExactly $expected;
            }
          }

          Context 'and: Pattern defines named captures' {
            It 'should: rename accessing Pattern defined capture' {
              [string]$source = '21-04-2000, Party like its 31-12-1999, target: today is 24-09-2020';
              [RegEx]$pattern = new-expr('(?<day>\d{2})-(?<mon>\d{2})-(?<year>\d{4})');
              [RegEx]$anchor = new-expr('target:')

              [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $pattern -Anchor $anchor `
                -Paste ' Americanised ${_a} ${mon}-${day}-${year}' -Relation 'after';
              $moveResult.Payload | Should -BeExactly ', Party like its 31-12-1999,  Americanised target: 04-21-2000 today is 24-09-2020';
            }

            Context 'and: Drop' {
              It 'should: rename accessing Pattern defined capture' {
                [string]$source = '21-04-2000, Party like its 31-12-1999, target: today is 24-09-2020';
                [RegEx]$pattern = new-expr('(?<day>\d{2})-(?<mon>\d{2})-(?<year>\d{4})');
                [RegEx]$anchor = new-expr('target:');
                [string]$expectedPayload = '^, Party like its 31-12-1999,  Americanised target: 04-21-2000 today is 24-09-2020';

                [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $pattern -Anchor $anchor `
                  -Paste ' Americanised ${_a} ${mon}-${day}-${year}' -Relation 'after' -Drop '^';

                $moveResult.Payload | Should -BeExactly $expectedPayload;
              }
            }
          }
        } # and: Anchor matches

        Context 'and: Anchor does NOT match' {
          It 'should: move the last match after the first anchor' {
            [string]$source = 'Judgement Day [06-06-2626], Judgement Day [28-02-2727], Day: <Friday>';
            [RegEx]$pattern = new-expr('\d{2}-\d{2}-\d{4}');
            [RegEx]$anchor = new-expr('blooper');
            [string]$relation = 'after'
            [RegEx]$copy = new-expr('\d{2}-\d{2}-\d{4}');

            [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $pattern `
              -Relation $relation -Anchor $anchor -Copy $copy;

            $moveResult.Payload | Should -BeExactly $source;
            $moveResult.Success | Should -BeFalse;
            $moveResult.FailedReason.Contains('Anchor') | Should -BeTrue;
          }
        } # and: Anchor does NOT match
      } # and: exotic formatted
    } # and: Pattern matches

    Context 'and: No Pattern match' {
      It 'should: return source unmodified' {
        [string]$source = 'There 23-03-1984 will be fire on where you are going';
        [RegEx]$pattern = new-expr('bomb!');
        [RegEx]$anchor = new-expr('\d{2}-\d{2}-\d{4}\s');

        [PSCustomObject]$moveResult = Move-Match -Value $source -Pattern $pattern -Relation 'before' -Anchor $anchor;

        $moveResult.Payload | Should -BeExactly $source -Because "No ('$pattern') match found";
        $moveResult.Success | Should -BeFalse;
        $moveResult.FailedReason.Contains('Pattern') | Should -BeTrue;
      }
    } # and: No Pattern match
  } # given: Pattern
} # Move-Match
