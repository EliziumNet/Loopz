
Describe 'Show-Header' {
  BeforeAll {
    InModuleScope Elizium.Loopz {
      Get-Module Elizium.Loopz | Remove-Module
      Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
        -ErrorAction 'stop' -DisableNameChecking;
    }
  }

  BeforeEach {
    InModuleScope Elizium.Loopz {
      [hashtable]$theme = $(Get-KrayolaTheme);
      [writer]$script:_writer = New-Writer($theme);
    }
  }

  Context 'given: properties' {
    BeforeAll {
      InModuleScope Elizium.Loopz {
        [line]$script:_properties = kl(@(
            $(kp('A', 'One')),
            $(kp('B', 'Two')),
            $(kp('C', 'Three', $true))
          ));
      }
    }

    Context 'and: message' {
      It 'should: display header with properties and message' {
        InModuleScope Elizium.Loopz {
          [hashtable]$passThru = @{
            'LOOPZ.HEADER-BLOCK.MESSAGE'      = 'The sound the wind makes in the pines';
            'LOOPZ.HEADER.PROPERTIES'         = $_properties;
            'LOOPZ.HEADER-BLOCK.LINE'         = $LoopzUI.TildeLine;
            'LOOPZ.WRITER'                    = $_writer;
          }
          Show-Header -Exchange $passThru;
        }
      }

      It 'should: display header with Signal crumb' {
        InModuleScope Elizium.Loopz {
          [hashtable]$signals = @{
            'CRUMB-B' = @('Crumb', '👽')
          }
          [hashtable]$passThru = @{
            'LOOPZ.SIGNALS'                   = $signals;
            'LOOPZ.HEADER-BLOCK.CRUMB-SIGNAL' = 'CRUMB-B';
            'LOOPZ.HEADER-BLOCK.MESSAGE'      = 'The sound the wind makes in the pines';
            'LOOPZ.HEADER-BLOCK.LINE'         = $LoopzUI.EqualsLine;
            'LOOPZ.WRITER'                    = $_writer;
          }
          Show-Header -Exchange $passThru;
        }
      }
    } # and: message

    Context 'and: no message' {
      It 'should: display header with properties only' {
        InModuleScope Elizium.Loopz {
          [hashtable]$passThru = @{
            'LOOPZ.HEADER.PROPERTIES' = $_properties;
            'LOOPZ.HEADER-BLOCK.LINE' = $LoopzUI.TildeLine;
            'LOOPZ.WRITER'            = $_writer;
          }

          Show-Header -Exchange $passThru;
        }
      }
    } # and: no message
  } # given: properties

  Context 'given: no properties' {
    Context 'and: small message' {
      It 'should: display header with message' {
        InModuleScope Elizium.Loopz {
          [hashtable]$passThru = @{
            'LOOPZ.HEADER-BLOCK.MESSAGE' = 'What lies in the darkness';
            'LOOPZ.HEADER-BLOCK.LINE'    = $LoopzUI.EqualsLine;
            'LOOPZ.WRITER'               = $_writer;
          }

          Show-Header -Exchange $passThru;
        }
      }

      Context 'and: multi-char open & close' {
        It 'should: display header with message' {
          InModuleScope Elizium.Loopz {
            $theme = (Get-KrayolaTheme).Clone();
            $theme['OPEN'] = '*** [';
            $theme['CLOSE'] = '] ***';

            [hashtable]$passThru = @{
              'LOOPZ.HEADER-BLOCK.MESSAGE' = 'Without chemicals he points';
              'LOOPZ.HEADER-BLOCK.LINE'    = $LoopzUI.SmallEqualsLine;
              'LOOPZ.WRITER'               = $_writer;
            }
            Show-Header -Exchange $passThru;
          }
        }
      }

      Context 'and: line with leading space' {
        It 'should: display header with message' {
          InModuleScope Elizium.Loopz {
            $withLeadingSpace = (([string]::new(".", (($_LineLength - 1) / 2))).Replace(".", " .") + " ");

            [hashtable]$passThru = @{
              'LOOPZ.HEADER-BLOCK.MESSAGE' = 'A man in a smiling bag';
              'LOOPZ.HEADER-BLOCK.LINE'    = $withLeadingSpace;
              'LOOPZ.WRITER'               = $_writer;
            }

            Show-Header -Exchange $passThru;
          }
        }
      }
    }

    Context 'and: no message' {
      It 'should: display header with crumb' {
        InModuleScope Elizium.Loopz {
          [hashtable]$signals = @{
            'TUNE' = @('Toon', '🎵')
          }
          [hashtable]$passThru = @{
            'LOOPZ.SIGNALS'                   = $signals;
            'LOOPZ.HEADER-BLOCK.CRUMB-SIGNAL' = 'TUNE';
            'LOOPZ.HEADER-BLOCK.LINE'         = $LoopzUI.EqualsLine;
            'LOOPZ.WRITER'                    = $_writer;
          }

          Show-Header -Exchange $passThru;
        }
      }

      It 'should: display header with Signal crumb' {
        InModuleScope Elizium.Loopz {
          [hashtable]$signals = @{
            'CRUMB-B' = @('Crumb', '🚀')
          }
          [hashtable]$passThru = @{
            'LOOPZ.SIGNALS'           = $signals;
            'LOOPZ.HEADER-BLOCK.LINE' = $LoopzUI.EqualsLine;
            'LOOPZ.WRITER'            = $_writer;
          }

          Show-Header -Exchange $passThru;
        }
      }
    }

    Context 'and: long message' {
      It 'should: display header with message' {
        InModuleScope Elizium.Loopz {
          [hashtable]$passThru = @{
            'LOOPZ.HEADER-BLOCK.MESSAGE' = ([string]::new('.', 4)).Replace('.', 'The owls are not what they seem ');
            'LOOPZ.HEADER-BLOCK.LINE'    = $LoopzUI.SmallEqualsLine;
            'LOOPZ.WRITER'               = $_writer;
          }

          Show-Header -Exchange $passThru;
        }
      }

      Context 'and: multi-char open & close' {
        It 'should: display header with message' {
          InModuleScope Elizium.Loopz {
            $theme = (Get-KrayolaTheme).Clone();
            $theme['OPEN'] = '*** [';
            $theme['CLOSE'] = '] ***';
            [writer]$writer = New-Writer($theme);

            [hashtable]$passThru = @{
              'LOOPZ.HEADER-BLOCK.MESSAGE' = ([string]::new('.', 4)).Replace('.', 'The monarch will be crowned ');
              'LOOPZ.HEADER-BLOCK.LINE'    = $LoopzUI.SmallEqualsLine;
              'LOOPZ.WRITER'               = $writer;
            }
            Show-Header -Exchange $passThru;
          }
        }
      }
    }
  } # given: no properties
}
