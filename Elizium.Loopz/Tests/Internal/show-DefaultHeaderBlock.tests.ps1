
Describe 'show-DefaultHeaderBlock' {
  BeforeAll {
    # Get-Module Elizium.Loopz | Remove-Module
    # Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
    #   -ErrorAction 'stop' -DisableNameChecking
    #
    . .\Public\globals.ps1;
    . .\Internal\show-DefaultHeaderBlock.ps1
    . .\Internal\format-ColouredLine.ps1
  }

  Context 'given: properties' {
    [string[][]]$script:properties = @(
      @('A', 'One'), @('B', 'Two'), @('C', 'Three')
    );

    Context 'and: message' {
      It 'should: display header with properties and message' {
        [System.Collections.Hashtable]$passThru = @{
          'LOOPZ.HEADER-BLOCK.MESSAGE' = 'The sound the wind makes in the pines';
          'LOOPZ.HEADER.PROPERTIES'    = $properties;
          'LOOPZ.HEADER-BLOCK.LINE'    = $LoopzUI.TildeLine;
        }

        show-DefaultHeaderBlock($passThru);
      }

      It 'should: display header with Signal crumb' {
        [System.Collections.Hashtable]$signals = @{
          'CRUMB-B' = @('Crumb', '🚀')
        }
        [System.Collections.Hashtable]$passThru = @{
          'LOOPZ.SIGNALS'              = $signals;
          'LOOPZ.HEADER-BLOCK.MESSAGE' = 'The sound the wind makes in the pines';
          'LOOPZ.HEADER-BLOCK.LINE'    = $LoopzUI.EqualsLine;
        }

        show-DefaultHeaderBlock($passThru);
      }
    } # and: message

    Context 'and: no message' {
      It 'should: display header with properties only' {
        [System.Collections.Hashtable]$passThru = @{
          'LOOPZ.HEADER.PROPERTIES' = $properties;
          'LOOPZ.HEADER-BLOCK.LINE' = $LoopzUI.TildeLine;
        }

        show-DefaultHeaderBlock($passThru);
      }
    } # and: no message
  } # given: properties

  Context 'given: no properties' {
    Context 'and: small message' {
      It 'should: display header with message' {
        [System.Collections.Hashtable]$passThru = @{
          'LOOPZ.HEADER-BLOCK.MESSAGE' = 'What lies in the darkness';
          'LOOPZ.HEADER-BLOCK.LINE'    = $LoopzUI.EqualsLine;
        }

        show-DefaultHeaderBlock($passThru);
      }

      Context 'and: multi-char open & close' {
        It 'should: display header with message' {
          $theme = (Get-KrayolaTheme).Clone();
          $theme['OPEN'] = '*** [';
          $theme['CLOSE'] = '] ***';

          [System.Collections.Hashtable]$passThru = @{
            'LOOPZ.HEADER-BLOCK.MESSAGE' = 'Without chemicals he points';
            'LOOPZ.HEADER-BLOCK.LINE'    = $LoopzUI.SmallEqualsLine;
          }
          $passThru['LOOPZ.KRAYOLA-THEME'] = $theme;
          show-DefaultHeaderBlock($passThru);
        }
      }

      Context 'and: line with leading space' {
        It 'should: display header with message' {
          $withLeadingSpace = ((New-Object String(".", (($_LineLength - 1) / 2))).Replace(".", " .") + " ");

          [System.Collections.Hashtable]$passThru = @{
            'LOOPZ.HEADER-BLOCK.MESSAGE' = 'A man in a smiling bag';
            'LOOPZ.HEADER-BLOCK.LINE'    = $withLeadingSpace;
          }

          show-DefaultHeaderBlock($passThru);
        }
      }
    }

    Context 'and: no message' {
      It 'should: display header with crumb' {
        [System.Collections.Hashtable]$signals = @{
          'TUNE' = @('Toon', '🎵')
        }
        [System.Collections.Hashtable]$passThru = @{
          'LOOPZ.SIGNALS'                   = $signals;
          'LOOPZ.HEADER-BLOCK.CRUMB-SIGNAL' = 'TUNE';
          'LOOPZ.HEADER-BLOCK.LINE'         = $LoopzUI.EqualsLine;
        }

        show-DefaultHeaderBlock($passThru);
      }

      It 'should: display header with Signal crumb' {
        [System.Collections.Hashtable]$signals = @{
          'CRUMB-B' = @('Crumb', '🚀')
        }
        [System.Collections.Hashtable]$passThru = @{
          'LOOPZ.SIGNALS'           = $signals;
          'LOOPZ.HEADER-BLOCK.LINE' = $LoopzUI.EqualsLine;
        }

        show-DefaultHeaderBlock($passThru);
      }
    }

    Context 'and: long message' {
      It 'should: display header with message' {
        [System.Collections.Hashtable]$passThru = @{
          'LOOPZ.HEADER-BLOCK.MESSAGE' = (New-Object String('.', 4)).Replace('.', 'The owls are not what they seem ');
          'LOOPZ.HEADER-BLOCK.LINE'    = $LoopzUI.SmallEqualsLine;
        }

        show-DefaultHeaderBlock($passThru);
      }

      Context 'and: multi-char open & close' {
        It 'should: display header with message' {
          $theme = (Get-KrayolaTheme).Clone();
          $theme['OPEN'] = '*** [';
          $theme['CLOSE'] = '] ***';

          [System.Collections.Hashtable]$passThru = @{
            'LOOPZ.HEADER-BLOCK.MESSAGE' = (New-Object String('.', 4)).Replace('.', 'The monarch will be crowned ');
            'LOOPZ.HEADER-BLOCK.LINE'    = $LoopzUI.SmallEqualsLine;
          }
          $passThru['LOOPZ.KRAYOLA-THEME'] = $theme;
          show-DefaultHeaderBlock($passThru)
        }
      }
    }
  } # given: no properties
} # show-DefaultHeaderBlock
