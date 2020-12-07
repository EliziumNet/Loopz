
Describe 'format-ColouredLine' {
  BeforeAll {
    . .\Internal\format-ColouredLine.ps1

    [string]$script:LineKey = 'LOOPZ.HEADER-BLOCK.LINE';
    [string]$script:CrumbKey = 'LOOPZ.HEADER-BLOCK.CRUMB-SIGNAL';
    [string]$script:MessageKey = 'LOOPZ.HEADER-BLOCK.MESSAGE';
  }

  BeforeEach {
    [string]$script:ruler = $LoopzUI.DotsLine;
  }

  AfterEach {
    Write-Host "$ruler";
    Write-InColour -TextSnippets $line;
  }

  # General note about these tests; Assertions should include the line length
  # being equal to the ruler length (ruler = $LoopzUI.EqualsLine)

  Context 'given: Plain Line' {
    It 'should: create coloured line without crumb or message' {
      [System.Collections.Hashtable]$passThru = @{
        'LOOPZ.HEADER-BLOCK.LINE' = $LoopzUI.EqualsLine;
      }

      $line = format-ColouredLine -PassThru $passThru -LineKey $LineKey -CrumbKey $CrumbKey;
      $line[0][0] | Should -BeExactly $LoopzUI.EqualsLine;
    }
  } # given: Plain line

  Context 'given: Message and Crumb' {
    BeforeEach {
      [System.Collections.Hashtable]$signals = @{
        'CRUMB-B' = @('Crumb', '🚀')
      }
      [System.Collections.Hashtable]$script:passThru = @{
        'LOOPZ.SIGNALS'                   = $signals;
        'LOOPZ.HEADER-BLOCK.CRUMB-SIGNAL' = 'CRUMB-B';
        'LOOPZ.HEADER-BLOCK.LINE'         = $LoopzUI.EqualsLine;
      }
    }

    It 'should: Create coloured line' {
      $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = 'Children of the Damned';

      $line = format-ColouredLine -PassThru $passThru `
        -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey;
      $line[0][0] | Should -BeExactly `
        '[🚀] ===================================================================================== [ ';

      $line[1][0] | Should -BeExactly $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'];
    }

    Context 'and: Large message' {
      It 'should: Create coloured line with Overflowing message' {
        [string]$longMessage = ([string]::new('.', 3)).Replace(
          '.', 'The Number of the Beast (No Truncation) ') + '!';
        $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;

        $line = format-ColouredLine -PassThru $passThru `
          -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey;
        # Write-InColour -TextSnippets $line;

        $line[0][0] | Should -BeExactly '[🚀] ====== [ ';
        $line[1][0] | Should -BeExactly $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'];
      }

      Context 'and: Truncate' {
        BeforeEach {
          [string]$script:longMessage = ([string]::new('.', 6)).Replace('.', 'Hallowed by thy Name ') + '!';
          $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;
        }

        Context 'and: Custom Ellipses' {
          It 'should: Create coloured line with Truncated message' {
            $line = format-ColouredLine -PassThru $passThru `
              -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate `
              -Options @{ Ellipses = ' ***' };

            $line[0][0] | Should -BeExactly '[🚀] ====== [ ';
            $line[1][0] | Should -BeExactly `
              'Hallowed by thy Name Hallowed by thy Name Hallowed by thy Name Hallowed by thy Name Hallowed by t ***';
          }
        } # and: Custom Ellipses

        Context 'and: Custom MinimumFlexSize' {
          It 'should: Create coloured line with Truncated message' {
            $line = format-ColouredLine -PassThru $passThru `
              -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate `
              -Options @{ MinimumFlexSize = 12 };

            $line[0][0] | Should -BeExactly '[🚀] ============ [ ';
            $line[1][0] | Should -BeExactly `
              'Hallowed by thy Name Hallowed by thy Name Hallowed by thy Name Hallowed by thy Name Hallowe ...';
          }

          It 'should: Create coloured line with Truncated message' {
            $line = format-ColouredLine -PassThru $passThru `
              -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate `
              -Options @{ MinimumFlexSize = 3 };

            $line[0][0] | Should -BeExactly '[🚀] === [ ';
            $line[1][0] | Should -BeExactly `
              'Hallowed by thy Name Hallowed by thy Name Hallowed by thy Name Hallowed by thy Name Hallowed by thy  ...';
          }
        } # and: Custom MinimumFlexSize

        Context 'and: LineKey not present' {
          It 'should: Create coloured line with Truncated message' {
            $passThru.Remove($LineKey);

            [string]$longMessage = ([string]::new('.', 6)).Replace('.', 'Hallowed by thy Fame ') + '!';
            $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;

            $line = format-ColouredLine -PassThru $passThru `
              -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate;

            $line[0][0] | Should -BeExactly '[🚀] ______ [ ';
            $line[1][0] | Should -BeExactly `
              'Hallowed by thy Fame Hallowed by thy Fame Hallowed by thy ...';
          }
        } # and: LineKey not present
      } # 'and: Truncate'
    } # and: Large message
  } # given: Message and Crumb

  Context 'given: Message Only' {
    BeforeEach {
      [System.Collections.Hashtable]$script:passThru = @{
        'LOOPZ.HEADER-BLOCK.LINE' = $LoopzUI.EqualsLine;
      }
    }

    It 'should: Create coloured line' {
      $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = '22 Acacia Avenue';

      $line = format-ColouredLine -PassThru $passThru `
        -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey;

      $line[0][0] | Should -BeExactly `
        '================================================================================================ [ ';
      $line[1][0] | Should -BeExactly $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'];
    }

    Context 'and: Large message' {
      It 'should: Create coloured line with Overflowing message' {
        [string]$longMessage = ([string]::new('.', 3)).Replace(
          '.', 'Stranger in a Strange Land (No Truncation) ') + '!';

        $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;

        $line = format-ColouredLine -PassThru $passThru `
          -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey;

        $line[0][0] | Should -BeExactly '====== [ ';
        $line[1][0] | Should -BeExactly `
          'Stranger in a Strange Land (No Truncation) Stranger in a Strange Land (No Truncation) Stranger in a Strange Land (No Truncation) !';
      }
    } # and: Large message

    Context 'and: Truncate' {
      BeforeEach {
        [string]$longMessage = ([string]::new('.', 8)).Replace('.', 'Heaven Can Wait ') + '!';

        $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;
        $passThru['LOOPZ.HEADER-BLOCK.LINE'] = $LoopzUI.SmallEqualsLine;
      }

      It 'should: Create coloured line with Truncated message' {
        $line = format-ColouredLine -PassThru $passThru `
          -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate;

        $line[0][0] | Should -BeExactly '====== [ ';
        $line[1][0] | Should -BeExactly 'Heaven Can Wait Heaven Can Wait Heaven Can Wait Heaven Can Wai ...';

        $script:ruler = $LoopzUI.SmallDotsLine
      }

      Context 'and: Custom MinimumFlexSize' {
        It 'should: Create coloured line with Truncated message' {
          $line = format-ColouredLine -PassThru $passThru `
            -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate `
            -Options @{ MinimumFlexSize = 3 };

          $line[0][0] | Should -BeExactly '=== [ ';
          $line[1][0] | Should -BeExactly 'Heaven Can Wait Heaven Can Wait Heaven Can Wait Heaven Can Wait H ...';

          $script:ruler = $LoopzUI.SmallDotsLine
        }

        It 'should: Create coloured line with Truncated message' {
          $line = format-ColouredLine -PassThru $passThru `
            -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate `
            -Options @{ MinimumFlexSize = 9 };

          $line[0][0] | Should -BeExactly '========= [ ';
          $line[1][0] | Should -BeExactly 'Heaven Can Wait Heaven Can Wait Heaven Can Wait Heaven Can  ...';

          $script:ruler = $LoopzUI.SmallDotsLine
        }
      } # and: Custom MinimumFlexSize

      Context 'and: LineKey not present' {
        It 'should: Create coloured line with Truncated message' {
          $passThru.Remove($LineKey);

          [string]$longMessage = ([string]::new('.', 8)).Replace('.', 'Heaven Can Bait ') + '!';
          $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;

          $line = format-ColouredLine -PassThru $passThru `
            -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate;

          $line[0][0] | Should -BeExactly '______ [ ';
          $line[1][0] | Should -BeExactly 'Heaven Can Bait Heaven Can Bait Heaven Can Bait Heaven Can Bai ...';

          $script:ruler = $LoopzUI.SmallDotsLine
        }
      }
    } # and: Truncate
  } # given: Message Only

  Context 'given: Crumb Only' {
    It 'should: Create coloured line' {
      [System.Collections.Hashtable]$signals = @{
        'CRUMB-B' = @('Crumb', '🔥')
      }
      [System.Collections.Hashtable]$passThru = @{
        'LOOPZ.SIGNALS'                   = $signals;
        'LOOPZ.HEADER-BLOCK.CRUMB-SIGNAL' = 'CRUMB-B';
        'LOOPZ.HEADER-BLOCK.LINE'         = $LoopzUI.TildeLine;
      }

      $line = format-ColouredLine -PassThru $passThru -LineKey $LineKey -CrumbKey $CrumbKey;
      $line[0][0] | Should -BeExactly `
        '[🔥] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~';
    }
  } # given: Crumb Only
} # format-ColouredLine
