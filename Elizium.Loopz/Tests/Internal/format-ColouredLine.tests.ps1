
Describe 'format-ColouredLine' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;

    InModuleScope Elizium.Loopz {
      [string]$script:LineKey = 'LOOPZ.HEADER-BLOCK.LINE';
      [string]$script:CrumbKey = 'LOOPZ.HEADER-BLOCK.CRUMB-SIGNAL';
      [string]$script:MessageKey = 'LOOPZ.HEADER-BLOCK.MESSAGE';

      function script:show-result {
        param(
          [string]$Ruler,
          [object[]]$Snippets
        )
        Write-Host "$Ruler";
        Write-InColour -TextSnippets $Snippets;
      }
    }
  }

  BeforeEach {
    InModuleScope Elizium.Loopz {
      [string]$script:_ruler = $LoopzUI.DotsLine;
      [object[]]$script:line = @();
    }
  }

  AfterEach {
    InModuleScope Elizium.Loopz {
      # Write-Host "$_ruler";
      # Write-InColour -TextSnippets $line;
      # show-result -Ruler $_ruler -Snippets $line; # @(@('First Snippet', 'red'), @('Second Snippet', 'blue'));
    }
  }

  # General note about these tests; Assertions should include the line length
  # being equal to the _ruler length (_ruler = $LoopzUI.EqualsLine)

  Context 'given: Plain Line' {
    It 'should: create coloured line without crumb or message' {
      InModuleScope Elizium.Loopz {
        [System.Collections.Hashtable]$passThru = @{
          'LOOPZ.HEADER-BLOCK.LINE' = $LoopzUI.EqualsLine;
        }

        $line = format-ColouredLine -PassThru $passThru -LineKey $LineKey -CrumbKey $CrumbKey;
        $line[0][0] | Should -BeExactly $LoopzUI.EqualsLine;
        show-result -Ruler $_ruler -Snippets $line;
      }
    }
  } # given: Plain line

  Context 'given: Message and Crumb' {
    BeforeEach {
      InModuleScope Elizium.Loopz {
        [System.Collections.Hashtable]$signals = @{
          'CRUMB-B' = @('Crumb', '🚀')
        }
        [System.Collections.Hashtable]$script:passThru = @{
          'LOOPZ.SIGNALS'                   = $signals;
          'LOOPZ.HEADER-BLOCK.CRUMB-SIGNAL' = 'CRUMB-B';
          'LOOPZ.HEADER-BLOCK.LINE'         = $LoopzUI.EqualsLine;
        }
      }
    }

    It 'should: Create coloured line' {
      InModuleScope Elizium.Loopz {
        $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = 'Children of the Damned';

        $line = format-ColouredLine -PassThru $passThru `
          -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey;
        $line[0][0] | Should -BeExactly `
          '[🚀] ===================================================================================== [ ';

        $line[1][0] | Should -BeExactly $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'];
        show-result -Ruler $_ruler -Snippets $line;
      }
    }

    Context 'and: Large message' {
      It 'should: Create coloured line with Overflowing message' {
        InModuleScope Elizium.Loopz {
          [string]$longMessage = ([string]::new('.', 3)).Replace(
            '.', 'The Number of the Beast (No Truncation) ') + '!';
          $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;

          $line = format-ColouredLine -PassThru $passThru `
            -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey;
          # Write-InColour -TextSnippets $line;

          $line[0][0] | Should -BeExactly '[🚀] ====== [ ';
          $line[1][0] | Should -BeExactly $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'];
          show-result -Ruler $_ruler -Snippets $line;
        }
      }

      Context 'and: Truncate' {
        BeforeEach {
          InModuleScope Elizium.Loopz {
            [string]$script:longMessage = ([string]::new('.', 6)).Replace('.', 'Hallowed by thy Name ') + '!';
            $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;
          }
        }

        Context 'and: Custom Ellipses' {
          It 'should: Create coloured line with Truncated message' {
            InModuleScope Elizium.Loopz {
              $line = format-ColouredLine -PassThru $passThru `
                -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate `
                -Options @{ Ellipses = ' ***' };

              $line[0][0] | Should -BeExactly '[🚀] ====== [ ';
              $line[1][0] | Should -BeExactly `
                'Hallowed by thy Name Hallowed by thy Name Hallowed by thy Name Hallowed by thy Name Hallowed by t ***';
              show-result -Ruler $_ruler -Snippets $line;
            }
          }
        } # and: Custom Ellipses

        Context 'and: Custom MinimumFlexSize' {
          It 'should: Create coloured line with Truncated message' {
            InModuleScope Elizium.Loopz {
              $line = format-ColouredLine -PassThru $passThru `
                -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate `
                -Options @{ MinimumFlexSize = 12 };

              $line[0][0] | Should -BeExactly '[🚀] ============ [ ';
              $line[1][0] | Should -BeExactly `
                'Hallowed by thy Name Hallowed by thy Name Hallowed by thy Name Hallowed by thy Name Hallowe ...';
              show-result -Ruler $_ruler -Snippets $line;
            }
          }

          It 'should: Create coloured line with Truncated message' {
            InModuleScope Elizium.Loopz {
              $line = format-ColouredLine -PassThru $passThru `
                -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate `
                -Options @{ MinimumFlexSize = 3 };

              $line[0][0] | Should -BeExactly '[🚀] === [ ';
              $line[1][0] | Should -BeExactly `
                'Hallowed by thy Name Hallowed by thy Name Hallowed by thy Name Hallowed by thy Name Hallowed by thy  ...';
              show-result -Ruler $_ruler -Snippets $line;
            }
          }
        } # and: Custom MinimumFlexSize

        Context 'and: LineKey not present' {
          It 'should: Create coloured line with Truncated message' {
            InModuleScope Elizium.Loopz {
              $passThru.Remove($LineKey);

              [string]$longMessage = ([string]::new('.', 6)).Replace('.', 'Hallowed by thy Fame ') + '!';
              $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;

              $line = format-ColouredLine -PassThru $passThru `
                -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate;

              $line[0][0] | Should -BeExactly '[🚀] ______ [ ';
              $line[1][0] | Should -BeExactly `
                'Hallowed by thy Fame Hallowed by thy Fame Hallowed by thy ...';
              show-result -Ruler $_ruler -Snippets $line;
            }
          }
        } # and: LineKey not present
      } # 'and: Truncate'
    } # and: Large message
  } # given: Message and Crumb

  Context 'given: Message Only' {
    BeforeEach {
      InModuleScope Elizium.Loopz {
        [System.Collections.Hashtable]$script:passThru = @{
          'LOOPZ.HEADER-BLOCK.LINE' = $LoopzUI.EqualsLine;
        }
      }
    }

    It 'should: Create coloured line' {
      InModuleScope Elizium.Loopz {
        $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = '22 Acacia Avenue';

        $line = format-ColouredLine -PassThru $passThru `
          -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey;

        $line[0][0] | Should -BeExactly `
          '================================================================================================ [ ';
        $line[1][0] | Should -BeExactly $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'];
        show-result -Ruler $_ruler -Snippets $line;
      }
    }

    Context 'and: Large message' {
      It 'should: Create coloured line with Overflowing message' {
        InModuleScope Elizium.Loopz {
          [string]$longMessage = ([string]::new('.', 3)).Replace(
            '.', 'Stranger in a Strange Land (No Truncation) ') + '!';

          $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;

          $line = format-ColouredLine -PassThru $passThru `
            -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey;

          $line[0][0] | Should -BeExactly '====== [ ';
          $line[1][0] | Should -BeExactly `
            'Stranger in a Strange Land (No Truncation) Stranger in a Strange Land (No Truncation) Stranger in a Strange Land (No Truncation) !';
          show-result -Ruler $_ruler -Snippets $line;
        }
      }
    } # and: Large message

    Context 'and: Truncate' {
      BeforeEach {
        InModuleScope Elizium.Loopz {
          [string]$longMessage = ([string]::new('.', 8)).Replace('.', 'Heaven Can Wait ') + '!';

          $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;
          $passThru['LOOPZ.HEADER-BLOCK.LINE'] = $LoopzUI.SmallEqualsLine;
        }
      }

      It 'should: Create coloured line with Truncated message' {
        InModuleScope Elizium.Loopz {
          $line = format-ColouredLine -PassThru $passThru `
            -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate;

          $line[0][0] | Should -BeExactly '====== [ ';
          $line[1][0] | Should -BeExactly 'Heaven Can Wait Heaven Can Wait Heaven Can Wait Heaven Can Wai ...';

          $script:_ruler = $LoopzUI.SmallDotsLine;
          show-result -Ruler $_ruler -Snippets $line;
        }
      }

      Context 'and: Custom MinimumFlexSize' {
        It 'should: Create coloured line with Truncated message' {
          InModuleScope Elizium.Loopz {
            $line = format-ColouredLine -PassThru $passThru `
              -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate `
              -Options @{ MinimumFlexSize = 3 };

            $line[0][0] | Should -BeExactly '=== [ ';
            $line[1][0] | Should -BeExactly 'Heaven Can Wait Heaven Can Wait Heaven Can Wait Heaven Can Wait H ...';

            $script:_ruler = $LoopzUI.SmallDotsLine;
            show-result -Ruler $_ruler -Snippets $line;
          }
        }

        It 'should: Create coloured line with Truncated message' {
          InModuleScope Elizium.Loopz {
            $line = format-ColouredLine -PassThru $passThru `
              -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate `
              -Options @{ MinimumFlexSize = 9 };

            $line[0][0] | Should -BeExactly '========= [ ';
            $line[1][0] | Should -BeExactly 'Heaven Can Wait Heaven Can Wait Heaven Can Wait Heaven Can  ...';

            $script:_ruler = $LoopzUI.SmallDotsLine;
            show-result -Ruler $_ruler -Snippets $line;
          }
        }
      } # and: Custom MinimumFlexSize

      Context 'and: LineKey not present' {
        It 'should: Create coloured line with Truncated message' {
          InModuleScope Elizium.Loopz {
            $passThru.Remove($LineKey);

            [string]$longMessage = ([string]::new('.', 8)).Replace('.', 'Heaven Can Bait ') + '!';
            $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;

            $line = format-ColouredLine -PassThru $passThru `
              -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate;

            $line[0][0] | Should -BeExactly '______ [ ';
            $line[1][0] | Should -BeExactly 'Heaven Can Bait Heaven Can Bait Heaven Can Bait Heaven Can Bai ...';

            $script:_ruler = $LoopzUI.SmallDotsLine;
            show-result -Ruler $_ruler -Snippets $line;
          }
        }
      }
    } # and: Truncate
  } # given: Message Only

  Context 'given: Crumb Only' {
    It 'should: Create coloured line' {
      InModuleScope Elizium.Loopz {
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
        show-result -Ruler $_ruler -Snippets $line;
      }
    }
  } # given: Crumb Only
} # format-ColouredLine
