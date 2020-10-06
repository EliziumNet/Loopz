Describe 'invoke-MoveTextAction' {
  BeforeAll {
    . .\Internal\edit-MoveToken.ps1;
    . .\Internal\invoke-MoveTextAction.ps1;
  }

  Context 'given: MATCHED-ITEM TargetType' {
    Context 'and: single Pattern match' {
      Context 'and: Relation=before' {
        Context 'and: single Target match' {
          It 'should: move Pattern before target' {
            [string]$source = 'We are like the dreamer';
            [string]$pattern = 'like ';
            [string]$target = 'dreamer';

            invoke-MoveTextAction -Value $source -Pattern $pattern -Target $target `
              -TargetType 'MATCHED-ITEM' -Relation 'before' | Should -BeExactly 'We are the like dreamer';
          }
        } # and: single Target match

        Context 'and: multiple Target matches' {
          It 'should: move to before the first target match' {
            [string]$source = 'We are like the dreamer, dreamer';
            [string]$pattern = 'like ';
            [string]$target = 'dreamer';

            invoke-MoveTextAction -Value $source -Pattern $pattern -Target $target `
              -TargetType 'MATCHED-ITEM' -Relation 'before' | `
              Should -BeExactly 'We are the like dreamer, dreamer';
          }
        } # and: multiple Target matches
      } # and: Relation=before

      Context 'and: Relation=after' {
        Context 'and: single Target match' {
          It 'should: move Pattern after target' {
            [string]$source = 'We are like the dreamer';
            [string]$pattern = ' like';
            [string]$target = 'dreamer';

            invoke-MoveTextAction -Value $source -Pattern $pattern -Target $target `
              -TargetType 'MATCHED-ITEM' -Relation 'after' | Should -BeExactly 'We are the dreamer like';
          }
        } # and: single Target match

        Context 'and: multiple Target matches' {
          It 'should: move to after the first target match' {
            [string]$source = 'We are like the dreamer, dreamer';
            [string]$pattern = ' like';
            [string]$target = 'dreamer';

            invoke-MoveTextAction -Value $source -Pattern $pattern -Target $target `
              -TargetType 'MATCHED-ITEM' -Relation 'after' | `
              Should -BeExactly 'We are the dreamer like, dreamer';
          }
        }
      } # and: Relation=after
    } # and: single Pattern match

    Context 'and: single Pattern Literal match' {
      Context 'and: single Target match' {
        It 'should: move Pattern after target' -Tag 'BROKEN?' -Skip {
          [string]$source = '[] date is [???]';
          [string]$pattern = '???';
          [string]$target = '[';

          invoke-MoveTextAction -Value $source -Pattern $pattern -Target $target `
            -TargetType 'MATCHED-ITEM' -Relation 'after' -Literal p, t | Should -BeExactly '[???] date is []';
        }
      } # and: single Target match
    }

    Context 'and: multiple Pattern matches' {
      Context 'and: Relation=after' {
        Context 'and: single Target match' {
          It 'should: move Pattern before target' {
            [string]$source = 'We like are like the dreamer';
            [string]$pattern = ' like';
            [string]$target = 'are';

            invoke-MoveTextAction -Value $source -Pattern $pattern -Target $target `
              -TargetType 'MATCHED-ITEM' -Relation 'after' | Should -BeExactly 'We are like like the dreamer';
          }
        } # and: single Target match
      }
    }
  } # given: MATCHED-ITEM TargetType

  Context 'given: START TargetType' {
    It 'should: move Pattern to start' {
      [string]$source = 'We are like the dreamer';
      [string]$pattern = 'like ';

      invoke-MoveTextAction -Value $source -Pattern $pattern `
        -TargetType 'START' | Should -BeExactly 'like We are the dreamer';
    }
  } # given: START TargetType

  Context 'given: END TargetType' {
    It 'should: move Pattern to end' {
      [string]$source = 'We are like the dreamer';
      [string]$pattern = ' like';

      invoke-MoveTextAction -Value $source -Pattern $pattern `
        -TargetType 'END' | Should -BeExactly 'We are the dreamer like';
    }
  } # given: END TargetType
} # invoke-MoveTextAction
