using namespace System.Text.RegularExpressions;

Describe 'invoke-MoveMatchAction' {
  BeforeAll {
    . .\Public\Move-Match.ps1;
    . .\Public\Get-DeconstructedMatch.ps1;
    . .\Public\Get-InverseSubString;
    . .\Internal\invoke-MoveMatchAction.ps1;
    . .\Tests\Helpers\new-expr.ps1
  }

  Context 'given: MATCHED-ITEM AnchorType' {
    Context 'and: single Pattern match' {
      Context 'and: Relation=before' {
        Context 'and: single Anchor match' {
          It 'should: move Pattern before target' {
            [string]$source = 'We are like the dreamer';
            [RegEx]$pattern = new-expr('like ');
            [RegEx]$anchor = new-expr('dreamer');

            invoke-MoveMatchAction -Value $source -Pattern $pattern -Anchor $anchor `
              -AnchorType 'MATCHED-ITEM' -Relation 'before' | Should -BeExactly 'We are the like dreamer';
          }
        } # and: single Anchor match

        Context 'and: multiple Anchor matches' {
          It 'should: move to before the first target match' {
            [string]$source = 'We are like the dreamer, dreamer';
            [RegEx]$pattern = new-expr('like ');
            [RegEx]$anchor = new-expr('dreamer');

            invoke-MoveMatchAction -Value $source -Pattern $pattern -Anchor $anchor `
              -AnchorType 'MATCHED-ITEM' -Relation 'before' | `
              Should -BeExactly 'We are the like dreamer, dreamer';
          }
        } # and: multiple Anchor matches
      } # and: Relation=before

      Context 'and: Relation=after' {
        Context 'and: single Anchor match' {
          It 'should: move Pattern after target' {
            [string]$source = 'We are like the dreamer';
            [RegEx]$pattern = new-expr(' like');
            [RegEx]$anchor = new-expr('dreamer');

            invoke-MoveMatchAction -Value $source -Pattern $pattern -Anchor $anchor `
              -AnchorType 'MATCHED-ITEM' -Relation 'after' | Should -BeExactly 'We are the dreamer like';
          }
        } # and: single Anchor match

        Context 'and: multiple Anchor matches' {
          It 'should: move to after the first target match' {
            [string]$source = 'We are like the dreamer, dreamer';
            [RegEx]$pattern = new-expr(' like');
            [RegEx]$anchor = new-expr('dreamer');

            invoke-MoveMatchAction -Value $source -Pattern $pattern -Anchor $anchor `
              -AnchorType 'MATCHED-ITEM' -Relation 'after' | `
              Should -BeExactly 'We are the dreamer like, dreamer';
          }
        }
      } # and: Relation=after
    } # and: single Pattern match

    Context 'With' {
      It 'should: replace Pattern with With' {
        [string]$source = 'We are like the dreamer 1234';
        [RegEx]$pattern = new-expr('like ');
        [RegEx]$anchor = new-expr('dreamer');
        [RegEx]$with = new-expr('\d{4}');

        invoke-MoveMatchAction -Value $source -Pattern $pattern -Anchor $anchor `
          -AnchorType 'MATCHED-ITEM' -Relation 'before' -With $with | `
          Should -BeExactly 'We are the 1234dreamer 1234';
      }
    } # With

    Context 'LiteralWith' {
      It 'should: replace Pattern with LiteralWith' {
        [string]$source = 'We are like the dreamer';
        [RegEx]$pattern = new-expr('like ');
        [RegEx]$anchor = new-expr('dreamer');
        [string]$literalWith = 'wayward ';

        invoke-MoveMatchAction -Value $source -Pattern $pattern -Anchor $anchor `
          -AnchorType 'MATCHED-ITEM' -Relation 'before' -LiteralWith $literalWith | `
          Should -BeExactly 'We are the wayward dreamer';
      }
    } # LiteralWith

    Context 'Paste' {
      It 'should: replace Pattern with LiteralWith' {
        [string]$source = 'We are like the dreamer';
        [RegEx]$pattern = new-expr('like ');
        [RegEx]$anchor = new-expr('dreamer');
        [string]$paste = '===[${_a}]===';

        invoke-MoveMatchAction -Value $source -Pattern $pattern -Anchor $anchor `
          -AnchorType 'MATCHED-ITEM' -Paste $paste | `
          Should -BeExactly 'We are the ===[dreamer]===';
      }
    } # Paste

    Context 'Occurrence' {
      It 'should: move 2nd Pattern' {
        [string]$source = 'We are like the dreamer who like the hatter does like a hat';
        [RegEx]$pattern = new-expr('like ');
        [RegEx]$anchor = new-expr('dreamer');

        invoke-MoveMatchAction -Value $source -Pattern $pattern -PatternOccurrence '2' -Anchor $anchor `
          -AnchorType 'MATCHED-ITEM' -Relation 'before' | `
          Should -BeExactly 'We are like the like dreamer who the hatter does like a hat';
      }

      It 'should: move pattern before 2nd Anchor' {
        [string]$source = 'We are like the dreamer who like the hatter does like a hat';
        [RegEx]$pattern = new-expr('hatter ');
        [RegEx]$anchor = new-expr('like');

        invoke-MoveMatchAction -Value $source -Pattern $pattern -Anchor $anchor -AnchorOccurrence '2' `
          -AnchorType 'MATCHED-ITEM' -Relation 'before' | `
          Should -BeExactly 'We are like the dreamer who hatter like the does like a hat';
      }

      It 'should: replace pattern with last With' {
        [string]$source = 'Xmas Eve: 24-12-2020, New years day:01-01-2021, Summer Solstice: 21-06-2021';
        [RegEx]$pattern = new-expr(' Summer Solstice');
        [RegEx]$anchor = new-expr('New years');
        [RegEx]$with = new-expr(': \d{2}-\d{2}-\d{4}');

        invoke-MoveMatchAction -Value $source -Pattern $pattern -Anchor $anchor `
          -AnchorType 'MATCHED-ITEM' -Relation 'before' -With $with -WithOccurrence 'L' | `
          Should -BeExactly 'Xmas Eve: 24-12-2020, : 21-06-2021New years day:01-01-2021,: 21-06-2021';
      }
    } # Occurrence
 
    Context 'and: multiple Pattern matches' {
      Context 'and: Relation=after' {
        Context 'and: single Anchor match' {
          It 'should: move Pattern before target' {
            [string]$source = 'We like are like the dreamer';
            [RegEx]$pattern = new-expr(' like');
            [RegEx]$anchor = new-expr('are');

            invoke-MoveMatchAction -Value $source -Pattern $pattern -Anchor $anchor `
              -AnchorType 'MATCHED-ITEM' -Relation 'after' | Should -BeExactly 'We are like like the dreamer';
          }
        } # and: single Anchor match
      }
    }
  } # given: MATCHED-ITEM AnchorType

  Context 'given: START AnchorType' {
    It 'should: move Pattern to start' {
      [string]$source = 'We are like the dreamer';
      [RegEx]$pattern = new-expr('like ');

      invoke-MoveMatchAction -Value $source -Pattern $pattern `
        -AnchorType 'START' | Should -BeExactly 'like We are the dreamer';
    }
  } # given: START AnchorType

  Context 'given: END AnchorType' {
    It 'should: move Pattern to end' {
      [string]$source = 'We are like the dreamer';
      [RegEx]$pattern = new-expr(' like');

      invoke-MoveMatchAction -Value $source -Pattern $pattern `
        -AnchorType 'END' | Should -BeExactly 'We are the dreamer like';
    }
  } # given: END AnchorType

} # invoke-MoveMatchAction
