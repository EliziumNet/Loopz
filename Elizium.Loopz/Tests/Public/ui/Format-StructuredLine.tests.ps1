
Describe 'Format-StructuredLine' {
  # InModuleScope doesn't work well with 'Data driven tests' using TestCases/Foreach
  # so tests have been manually coded even though it looks like they're a prime
  # case to use with TestCases/Foreach.
  #
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;

    InModuleScope Elizium.Loopz {
      [string]$script:LineKey = 'LOOPZ.HEADER-BLOCK.LINE';
      [string]$script:CrumbKey = 'LOOPZ.HEADER-BLOCK.CRUMB-SIGNAL';
      [string]$script:MessageKey = 'LOOPZ.HEADER-BLOCK.MESSAGE';
      [hashtable]$script:_theme = $(Get-KrayolaTheme);
      function script:show-result {
        param(
          [string]$Ruler,
          [string]$StructuredLine
        )
        Write-Host "$Ruler";
        $_krayon.ScribbleLn($StructuredLine);
      }
    }
  }

  BeforeEach {
    InModuleScope Elizium.Loopz {
      [string]$script:_ruler = $LoopzUI.DotsLine;
      [string]$script:_structuredLine = [string]::Empty;
      [Krayon]$script:_krayon = New-Krayon($_theme);
    }
  }

  # General note about these tests; Assertions should include the line length
  # being equal to the _ruler length (_ruler = $LoopzUI.EqualsLine)

  Context 'given: Plain Line' {
    It 'should: create coloured line without crumb or message' {
      InModuleScope Elizium.Loopz {
        [hashtable]$exchange = @{
          'LOOPZ.HEADER-BLOCK.LINE' = $LoopzUI.EqualsLine;
        }

        $_structuredLine = Format-StructuredLine -Exchange $exchange `
          -LineKey $LineKey -CrumbKey $CrumbKey -Krayon $_krayon;

        show-result -Ruler $_ruler -StructuredLine $_structuredLine;
      }
    }
  } # given: Plain line

  Context 'given: Message and Crumb' {
    BeforeEach {
      InModuleScope Elizium.Loopz {
        [hashtable]$signals = @{
          'CRUMB-B' = kp(@('Crumb', '🚀'))
        }
        [hashtable]$script:exchange = @{
          'LOOPZ.SIGNALS'                   = $signals;
          'LOOPZ.HEADER-BLOCK.CRUMB-SIGNAL' = 'CRUMB-B';
          'LOOPZ.HEADER-BLOCK.LINE'         = $LoopzUI.EqualsLine;
        }
      }
    }

    It 'should: Create coloured line' {
      InModuleScope Elizium.Loopz {
        $exchange['LOOPZ.HEADER-BLOCK.MESSAGE'] = 'Children of the Damned';

        $_structuredLine = Format-StructuredLine -Exchange $exchange `
          -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Krayon $_krayon;

        show-result -Ruler $_ruler -StructuredLine $_structuredLine;
        [string]$expected = '&[ThemeColour,meta][🚀] ===================================================================================== [ ' + `
          '&[ThemeColour,message]Children of the Damned&[ThemeColour,meta] ] ===';
        $_structuredLine | Should -BeExactly $expected;
      }
    }

    Context 'and: Large message' {
      It 'should: Create coloured line with Overflowing message' {
        InModuleScope Elizium.Loopz {
          [string]$longMessage = ([string]::new('.', 3)).Replace(
            '.', 'The Number of the Beast (No Truncation) ') + '!';
          $exchange['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;

          $_structuredLine = Format-StructuredLine -Exchange $exchange `
            -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Krayon $_krayon;
      
          show-result -Ruler $_ruler -StructuredLine $_structuredLine;
          [string]$expected = '&[ThemeColour,meta][🚀] ====== [ ' + `
            '&[ThemeColour,message]The Number of the Beast (No Truncation) The Number of the Beast (No Truncation) The Number of the Beast (No Truncation) !&[ThemeColour,meta]' + `
            ' ] ===';
          $_structuredLine | Should -BeExactly $expected;
        }
      }

      Context 'and: Truncate' {
        BeforeEach {
          InModuleScope Elizium.Loopz {
            [string]$script:longMessage = ([string]::new('.', 6)).Replace('.', 'Hallowed by thy Name ') + '!';
            $exchange['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;
          }
        }

        Context 'and: Custom Ellipses' {
          It 'should: Create coloured line with Truncated message' {
            InModuleScope Elizium.Loopz {
              $_structuredLine = Format-StructuredLine -Exchange $exchange `
                -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate `
                -Options @{ Ellipses = ' ***' } -Krayon $_krayon;

              show-result -Ruler $_ruler -StructuredLine $_structuredLine;
              [string]$expected = '&[ThemeColour,meta][🚀] ====== [ ' + `
                '&[ThemeColour,message]Hallowed by thy Name Hallowed by thy Name Hallowed by thy Name Hallowed by thy Name Hallowed by t ***&[ThemeColour,meta]' + `
                ' ] ===';
              $_structuredLine | Should -BeExactly $expected;
            }
          }
        } # and: Custom Ellipses

        Context 'and: Custom MinimumFlexSize' {
          It 'should: Create coloured line with Truncated message' {
            InModuleScope Elizium.Loopz {
              $_structuredLine = Format-StructuredLine -Exchange $exchange `
                -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate `
                -Options @{ MinimumFlexSize = 12 } -Krayon $_krayon;

              show-result -Ruler $_ruler -StructuredLine $_structuredLine;
              [string]$expected = '&[ThemeColour,meta][🚀] ============ [ ' + `
                '&[ThemeColour,message]Hallowed by thy Name Hallowed by thy Name Hallowed by thy Name Hallowed by thy Name Hallowe ...&[ThemeColour,meta]' + `
                ' ] ===';
              $_structuredLine | Should -BeExactly $expected;
            }
          }

          It 'should: Create coloured line with Truncated message' {
            InModuleScope Elizium.Loopz {
              $_structuredLine = Format-StructuredLine -Exchange $exchange `
                -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate `
                -Options @{ MinimumFlexSize = 3 } -Krayon $_krayon;

              show-result -Ruler $_ruler -StructuredLine $_structuredLine;
              [string]$expected = '&[ThemeColour,meta][🚀] === [ ' + `
                '&[ThemeColour,message]Hallowed by thy Name Hallowed by thy Name Hallowed by thy Name Hallowed by thy Name Hallowed by thy  ...&[ThemeColour,meta]' + `
                ' ] ===';
              $_structuredLine | Should -BeExactly $expected;
            }
          }
        } # and: Custom MinimumFlexSize

        Context 'and: LineKey not present' {
          It 'should: Create coloured line with Truncated message' {
            InModuleScope Elizium.Loopz {
              $exchange.Remove($LineKey);

              [string]$longMessage = ([string]::new('.', 6)).Replace('.', 'Hallowed by thy Fame ') + '!';
              $exchange['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;

              $_structuredLine = Format-StructuredLine -Exchange $exchange `
                -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate -Krayon $_krayon;

              show-result -Ruler $_ruler -StructuredLine $_structuredLine;
              [string]$expected = '&[ThemeColour,meta][🚀] ______ [ ' `
                + '&[ThemeColour,message]Hallowed by thy Fame Hallowed by thy Fame Hallowed by thy ...&[ThemeColour,meta]' + `
                ' ] ___';
              $_structuredLine | Should -BeExactly $expected;
            }
          }
        } # and: LineKey not present
      } # 'and: Truncate'
    } # and: Large message
  } # given: Message and Crumb

  Context 'given: Message Only' {
    BeforeEach {
      InModuleScope Elizium.Loopz {
        [hashtable]$script:exchange = @{
          'LOOPZ.HEADER-BLOCK.LINE' = $LoopzUI.EqualsLine;
        }
      }
    }

    It 'should: Create coloured line' {
      InModuleScope Elizium.Loopz {
        $exchange['LOOPZ.HEADER-BLOCK.MESSAGE'] = '22 Acacia Avenue';

        $_structuredLine = Format-StructuredLine -Exchange $exchange `
          -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Krayon $_krayon;

        show-result -Ruler $_ruler -StructuredLine $_structuredLine;
        [string]$expected = '&[ThemeColour,meta]================================================================================================ [ ' + `
          '&[ThemeColour,message]22 Acacia Avenue&[ThemeColour,meta] ] ===';
        $_structuredLine | Should -BeExactly $expected;
      }
    }

    Context 'and: Large message' {
      It 'should: Create coloured line with Overflowing message' {
        InModuleScope Elizium.Loopz {
          [string]$longMessage = ([string]::new('.', 3)).Replace(
            '.', 'Stranger in a Strange Land (No Truncation) ') + '!';

          $exchange['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;

          $_structuredLine = Format-StructuredLine -Exchange $exchange `
            -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Krayon $_krayon;

          show-result -Ruler $_ruler -StructuredLine $_structuredLine;
          [string]$expected = '&[ThemeColour,meta]====== [ ' + `
            '&[ThemeColour,message]Stranger in a Strange Land (No Truncation) Stranger in a Strange Land (No Truncation) Stranger in a Strange Land (No Truncation) !&[ThemeColour,meta]' + `
            ' ] ===';

          $_structuredLine | Should -BeExactly $expected;
        }
      }
    } # and: Large message

    Context 'and: Truncate' {
      BeforeEach {
        InModuleScope Elizium.Loopz {
          [string]$longMessage = ([string]::new('.', 8)).Replace('.', 'Heaven Can Wait ') + '!';

          $exchange['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;
          $exchange['LOOPZ.HEADER-BLOCK.LINE'] = $LoopzUI.SmallEqualsLine;
        }
      }

      It 'should: Create coloured line with Truncated message' {
        InModuleScope Elizium.Loopz {
          $_structuredLine = Format-StructuredLine -Exchange $exchange `
            -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate -Krayon $_krayon;

          $script:_ruler = $LoopzUI.SmallDotsLine;
          show-result -Ruler $_ruler -StructuredLine $_structuredLine;
          [string]$expected = '&[ThemeColour,meta]====== [ ' + `
            '&[ThemeColour,message]Heaven Can Wait Heaven Can Wait Heaven Can Wait Heaven Can Wai ...&[ThemeColour,meta]' + `
            ' ] ===';
          $_structuredLine | Should -BeExactly $expected;
        }
      }

      Context 'and: Custom MinimumFlexSize' {
        It 'should: Create coloured line with Truncated message' {
          InModuleScope Elizium.Loopz {
            $_structuredLine = Format-StructuredLine -Exchange $exchange `
              -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate `
              -Options @{ MinimumFlexSize = 3 } -Krayon $_krayon;

            $script:_ruler = $LoopzUI.SmallDotsLine;
            show-result -Ruler $_ruler -StructuredLine $_structuredLine;
            [string]$expected = '&[ThemeColour,meta]=== [ ' + `
              '&[ThemeColour,message]Heaven Can Wait Heaven Can Wait Heaven Can Wait Heaven Can Wait H ...&[ThemeColour,meta]' + `
              ' ] ===';
            $_structuredLine | Should -BeExactly $expected;
          }
        }

        It 'should: Create coloured line with Truncated message' {
          InModuleScope Elizium.Loopz {
            $_structuredLine = Format-StructuredLine -Exchange $exchange `
              -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate `
              -Options @{ MinimumFlexSize = 9 } -Krayon $_krayon;

            $script:_ruler = $LoopzUI.SmallDotsLine;
            show-result -Ruler $_ruler -StructuredLine $_structuredLine;
            [string]$expected = '&[ThemeColour,meta]========= [ ' + `
              '&[ThemeColour,message]Heaven Can Wait Heaven Can Wait Heaven Can Wait Heaven Can  ...&[ThemeColour,meta]' + `
              ' ] ===';
            $_structuredLine | Should -BeExactly $expected;
          }
        }
      } # and: Custom MinimumFlexSize

      Context 'and: LineKey not present' {
        It 'should: Create coloured line with Truncated message' {
          InModuleScope Elizium.Loopz {
            $exchange.Remove($LineKey);

            [string]$longMessage = ([string]::new('.', 8)).Replace('.', 'Heaven Can Bait ') + '!';
            $exchange['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;

            $_structuredLine = Format-StructuredLine -Exchange $exchange `
              -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate -Krayon $_krayon;

            $script:_ruler = $LoopzUI.SmallDotsLine;
            show-result -Ruler $_ruler -StructuredLine $_structuredLine;
            [string]$expected = '&[ThemeColour,meta]______ [ ' + `
              '&[ThemeColour,message]Heaven Can Bait Heaven Can Bait Heaven Can Bait Heaven Can Bai ...&[ThemeColour,meta]' + `
              ' ] ___';
            $_structuredLine | Should -BeExactly $expected;
          }
        }
      }
    } # and: Truncate
  } # given: Message Only

  Context 'given: Crumb Only' {
    It 'should: Create coloured line' {
      InModuleScope Elizium.Loopz {
        [hashtable]$signals = @{
          'CRUMB-B' = kp(@('Crumb', '🔥'))
        }
        [hashtable]$exchange = @{
          'LOOPZ.SIGNALS'                   = $signals;
          'LOOPZ.HEADER-BLOCK.CRUMB-SIGNAL' = 'CRUMB-B';
          'LOOPZ.HEADER-BLOCK.LINE'         = $LoopzUI.TildeLine;
        }

        $_structuredLine = Format-StructuredLine -Exchange $exchange `
          -LineKey $LineKey -CrumbKey $CrumbKey -Krayon $_krayon;

        show-result -Ruler $_ruler -StructuredLine $_structuredLine;
        [string]$expected = '&[ThemeColour,meta][🔥] ' + `
          '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
        $_structuredLine | Should -BeExactly $expected;
      }
    }
  } # given: Crumb Only
} # Format-StructuredLine
