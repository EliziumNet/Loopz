Describe 'Show-Summary' {
  BeforeAll {
    InModuleScope Elizium.Loopz {
      Get-Module Elizium.Loopz | Remove-Module
      Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
        -ErrorAction 'stop' -DisableNameChecking
    }
  }

  BeforeEach {
    InModuleScope Elizium.Loopz {
      [hashtable]$theme = $(Get-KrayolaTheme);
      [Krayon]$script:_krayon = New-Krayon($theme);
    }
  }

  Context 'given: block line specified' {
    It 'should: display summary' {
      InModuleScope Elizium.Loopz {
        [hashtable]$exchange = @{
          'LOOPZ.SUMMARY-BLOCK.LINE' = $LoopzUI.DashLine;
          'LOOP.KRAYON'              = $_krayon;
        }
        Show-Summary -Count 999 -Skipped 0 -Triggered $false -Exchange $exchange;
      }
    }
  }

  Context 'given: no block line specified' {
    It 'should: display summary' {
      InModuleScope Elizium.Loopz {
        [hashtable]$exchange = @{
          'LOOP.KRAYON' = $_krayon;
        }
        Show-Summary -Count 101 -Skipped 0 -Triggered $true -Exchange $exchange;
      }
    }
  }

  Context 'given: wide items specified' {
    It 'should: display summary with wide items' {
      InModuleScope Elizium.Loopz {
        [line]$wideItems = $(kl($(kp('From', '/source/')), $(kp('To', '/destination/'))));
        [hashtable]$exchange = @{
          'LOOPZ.SUMMARY-BLOCK.LINE'       = $LoopzUI.DashLine;
          'LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS' = $wideItems;
          'LOOP.KRAYON'                    = $_krayon;
        }
        Show-Summary -Count 999 -Skipped 0 -Triggered $false -Exchange $exchange;
      }
    }

    It 'should: display summary with wide items grouped together' {
      InModuleScope Elizium.Loopz {
        [line]$wideItems = $(kl($(kp('From', '/source/')), $(kp('To', '/destination/'))));
        [hashtable]$exchange = @{
          'LOOPZ.SUMMARY-BLOCK.LINE'             = $LoopzUI.DashLine;
          'LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS'       = $wideItems;
          'LOOPZ.SUMMARY-BLOCK.GROUP-WIDE-ITEMS' = $true;
          'LOOP.KRAYON'                          = $_krayon;
        }
        Show-Summary -Count 999 -Skipped 0 -Triggered $false -Exchange $exchange;
      }
    }
  }

  Context 'given: summary properties specified' {
    It 'should: display summary with summary properties' {
      InModuleScope Elizium.Loopz {
        [line]$wideItems = $(kl($(kp('A', 'one')), $(kp('B', 'two'))));
        [hashtable]$exchange = @{
          'LOOPZ.SUMMARY-BLOCK.LINE'       = $LoopzUI.DashLine;
          'LOOPZ.SUMMARY.PROPERTIES' = $wideItems;
          'LOOP.KRAYON'                    = $_krayon;
        }
        Show-Summary -Count 999 -Skipped 0 -Triggered $false -Exchange $exchange;
      }
    }
  }
}
