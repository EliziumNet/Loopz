Describe 'edit-MoveToken' {
  BeforeAll {
    . .\Internal\edit-MoveToken.ps1;
  }

  Context 'given: plain pattern' {
    Context 'and: Pattern match' {
      Context 'and: Target match' {
        Context 'and: move before' {
          It 'should: move the match before the target' {
            [string]$source = 'There is fire where you are going';
            [string]$pattern = 'fire ';
            [string]$target = 'are ';

            edit-MoveToken -Source $source -Pattern $pattern -Target $target -Relation 'before' | `
              Should -BeExactly 'There is where you fire are going';
          }
        } # and: move before

        Context 'and: move after' {
          It 'should: move the match after the target' {
            [string]$source = 'There is fire where you are going';
            [string]$pattern = 'fire ';
            [string]$target = 'are ';

            edit-MoveToken -Source $source -Pattern $pattern -Target $target -Relation 'after' | `
              Should -BeExactly 'There is where you are fire going';
          }
        } # and: move after

        Context 'and: replace With after' {
          It 'should: move the match after the target' {
            [string]$source = 'There is fire where you are going';
            [string]$pattern = 'fire ';
            [string]$target = 'are ';
            [string]$with = 'ice ';

            edit-MoveToken -Source $source -Pattern $pattern -Target $target -With $with -Relation 'after' | `
              Should -BeExactly 'There is where you are ice going';
          }
        }
      } # and: Target match

      Context 'and: multiple Target matches' {
        Context 'and: move before' {
          It 'should: move the match before the target' {
            [string]$source = 'There is fire where you are going you are saying?';
            [string]$pattern = 'fire ';
            [string]$target = 'are ';

            edit-MoveToken -Source $source -Pattern $pattern -Target $target -Relation 'before' | `
              Should -BeExactly 'There is where you fire are going you are saying?';
          }
        } # and: move before
      } # and: multiple Target matches

      Context 'and: Target NOT match' {
        It 'should: return source unmodified' {
          [string]$source = 'There is fire where you are going';
          [string]$pattern = 'fire ';
          [string]$target = 'spanner!';

          edit-MoveToken -Source $source -Pattern $pattern -Target $target -Relation 'before' | `
            Should -BeExactly 'There is fire where you are going';
        }
      } # and: Target NOT match

      Context 'and: Start specified' {
        Context 'and Pattern is midway in source' {
          It 'should: Move Pattern to Start' {
            [string]$source = 'There is fire where you are going';
            [string]$pattern = 'fire ';

            edit-MoveToken -Source $source -Pattern $pattern -Start | `
              Should -BeExactly 'fire There is where you are going';
          }
        } # and Pattern is midway in source

        Context 'and Pattern is already at Start in source' {
          It 'should: return source unmodified' {
            [string]$source = 'There is fire where you are going';
            [string]$pattern = 'There';

            edit-MoveToken -Source $source -Pattern $pattern -Start | `
              Should -BeExactly 'There is fire where you are going';
          }
        } # and Pattern is already at Start in source
      } # and: Start specified

      Context 'and: End specified' {
        Context 'and Pattern is midway in source' {
          It 'should: Move Pattern to End' {
            [string]$source = 'There is fire where you are going';
            [string]$pattern = ' fire';

            edit-MoveToken -Source $source -Pattern $pattern -End | `
              Should -BeExactly 'There is where you are going fire';
          }
        } # and Pattern is midway in source
      } # and: End specified
    } # and: Pattern match

    Context 'and: multiple Pattern matches' {
      Context 'and: Target match' {
        Context 'and: move before' {
          It 'should: move the match before the target' {
            [string]$source = 'There is fire where fire you are going';
            [string]$pattern = 'fire ';
            [string]$target = 'are ';

            edit-MoveToken -Source $source -Pattern $pattern -Target $target -Relation 'before' | `
              Should -BeExactly 'There is where fire you fire are going';
          }
        } # and: move before
      } # and: Target match
    }

    Context 'and: No Pattern match' {
      It 'should: return source unmodified' {
        [string]$source = 'There is fire where you are going';
        [string]$pattern = 'bomb!';
        [string]$target = 'are ';

        edit-MoveToken -Source $source -Pattern $pattern -Target $target -Relation 'before' | `
          Should -BeExactly 'There is fire where you are going' -Because "No ('$pattern') match found";
      }
    } # and: No Pattern match
  } # given: plain pattern

  Context 'given: regex pattern' {
    Context 'and: Pattern match' {
      Context 'and: Target match' {
        Context 'and: move after' {
          It 'should: move the match after the target' -Tag 'Focus' {
            [string]$source = 'There 23-03-1984 will be fire on where you are going';
            [string]$pattern = '\d{2}-\d{2}-\d{4}\s';
            [string]$target = 'on ';

            edit-MoveToken -Source $source -Pattern $pattern -Target $target -Relation 'after' | `
              Should -BeExactly 'There will be fire on \d{2}-\d{2}-\d{4}\swhere you are going';

            # ----------------------
            # Ideally, we would like the result of this test to be:
            # 'There will be fire on 23-03-1984 where you are going'
            # but for now it is:
            # 'There will be fire on \d{2}-\d{2}-\d{4}\swhere you are going'
            #                   --->|===================|<---
            #
            # This is because, the pattern is literally inserted as the text replacement as opposed
            # to it being re-parsed from the source. This is an additional feature. So this is a
            # stop-gap test until this functionality has been implemented; probably as an extra
            # parameters such as "Capture" and "Format", where the user defines:
            #
            # Capture = '(?<date>\d{2}-\d{2}-\d{4}\s)'
            # Format = 'date:${date}'
            #
            # where the capture groups specified in Capture, must be in sync with the Format
            # string; ie, the fields referenced in the Format, must be defined in the Capture
            # pattern. [Let's call this the 'Capture' parameter set]
            #
            # which actually would should result in 
            # 'There will be fire on date:23-03-1984 where you are going'
          }
        } # and: move after
      } # and: Target match

      Context 'and: Target NOT match' {
        It 'should: return source unmodified' {
          [string]$source = 'There 23-03-1984 will be fire on where you are going';
          [string]$pattern = '\d{2}-\d{2}-\d{4}\s';
          [string]$target = 'spanner!';

          edit-MoveToken -Source $source -Pattern $pattern -Target $target -Relation 'before' | `
            Should -BeExactly 'There 23-03-1984 will be fire on where you are going' -Because "No ('$target') match found";
        }
      } # and: Target NOT match
    } # and: Pattern match

    Context 'and: No Pattern match' {
      It 'should: return source unmodified' {
        [string]$source = 'There 23-03-1984 will be fire on where you are going';
        [string]$pattern = 'bomb!';
        [string]$target = '\d{2}-\d{2}-\d{4}\s';

        edit-MoveToken -Source $source -Pattern $pattern -Target $target -Relation 'before' | `
          Should -BeExactly 'There 23-03-1984 will be fire on where you are going' -Because "No ('$pattern') match found";
      }
    } # and: No Pattern match
  } # given: regex pattern

  Context 'and: Whole' {
    Context 'and: Target match' {
      Context 'and: move before' {
        It 'should: move the whole word match before the target' -Tag 'BROKEN' {
          [string]$source = 'The quick brown firefox fox fox';
          [string]$pattern = 'fox';
          [string]$target = ' quick';

          edit-MoveToken -Whole -Source $source -Pattern $pattern `
            -Target $target -Relation 'before' | Should -BeExactly 'Thefox quick brown firefox  fox';
        }
      } # and: Target match

      Context 'and: move after' {
        It 'should: move the match after the target' {
          [string]$source = 'There is fire where you are going';
          [string]$pattern = 'fire ';
          [string]$target = 'are ';

          edit-MoveToken -Source $source -Pattern $pattern -Target $target -Relation 'after' | `
            Should -BeExactly 'There is where you are fire going';
        }
      } # and: move after
    } # and: Target match
  } # and: Whole
} # edit-MoveToken
