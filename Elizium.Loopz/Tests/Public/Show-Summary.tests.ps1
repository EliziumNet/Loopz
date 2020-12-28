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
      [writer]$script:_writer = New-Writer($theme);
    }
  }

  Context 'given: block line specified' {
    It 'should: display summary' {
      InModuleScope Elizium.Loopz {
        [hashtable]$passThru = @{
          'LOOPZ.SUMMARY-BLOCK.LINE' = $LoopzUI.DashLine;
        }
        Show-Summary -Count 999 -Skipped 0 -Triggered $false -PassThru $passThru -Writer $_writer;
      }
    }
  }

  Context 'given: no block line specified' {
    It 'should: display summary' {
      InModuleScope Elizium.Loopz {
        [hashtable]$passThru = @{}
        Show-Summary -Count 101 -Skipped 0 -Triggered $true -PassThru $passThru -Writer $_writer;
      }
    }
  }

  Context 'given: wide items specified' {
    It 'should: display summary with wide items' {
      InModuleScope Elizium.Loopz {
        [line]$wideItems = $(kl($(kp('From', '/source/')), $(kp('To', '/destination/'))));
        [hashtable]$passThru = @{
          'LOOPZ.SUMMARY-BLOCK.LINE'       = $LoopzUI.DashLine;
          'LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS' = $wideItems;
        }
        Show-Summary -Count 999 -Skipped 0 -Triggered $false -PassThru $passThru -Writer $_writer;
      }
    }

    It 'should: display summary with wide items grouped together' {
      InModuleScope Elizium.Loopz {
        [line]$wideItems = $(kl($(kp('From', '/source/')), $(kp('To', '/destination/'))));
        [hashtable]$passThru = @{
          'LOOPZ.SUMMARY-BLOCK.LINE'             = $LoopzUI.DashLine;
          'LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS'       = $wideItems;
          'LOOPZ.SUMMARY-BLOCK.GROUP-WIDE-ITEMS' = $true
        }
        Show-Summary -Count 999 -Skipped 0 -Triggered $false -PassThru $passThru -Writer $_writer;
      }
    }
  }

  Context 'given: summary properties specified' {
    It 'should: display summary with summary properties' {
      InModuleScope Elizium.Loopz {
        [line]$wideItems = $(kl($(kp('A', 'one')), $(kp('B', 'two'))));
        [hashtable]$passThru = @{
          'LOOPZ.SUMMARY-BLOCK.LINE'       = $LoopzUI.DashLine;
          'LOOPZ.SUMMARY-BLOCK.PROPERTIES' = $wideItems;;
        }
        Show-Summary -Count 999 -Skipped 0 -Triggered $false -PassThru $passThru -Writer $_writer;
      }
    }
  }
}
