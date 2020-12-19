
Describe 'show-SimpleSummaryBlock' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking
  }

  Context 'given: block line specified' {
    It 'should: display summary' {
      InModuleScope Elizium.Loopz {
        [hashtable]$passThru = @{
          'LOOPZ.SUMMARY-BLOCK.LINE' = $LoopzUI.DashLine;
        }
        show-SimpleSummaryBlock -Count 999 -Skipped 0 -Triggered $false -PassThru $passThru;
      }
    }
  }

  Context 'given: no block line specified' {
    It 'should: display summary' {
      InModuleScope Elizium.Loopz {
        [hashtable]$passThru = @{}
        show-SimpleSummaryBlock -Count 101 -Skipped 0 -Triggered $true -PassThru $passThru;
      }
    }
  }

  Context 'given: wide items specified' {
    It 'should: display summary with wide items' {
      InModuleScope Elizium.Loopz {
        [hashtable]$passThru = @{
          'LOOPZ.SUMMARY-BLOCK.LINE'       = $LoopzUI.DashLine;
          'LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS' = @(@('From', '/source/'), @('To', '/destination/'));
        }
        show-SimpleSummaryBlock -Count 999 -Skipped 0 -Triggered $false -PassThru $passThru;
      }
    }

    It 'should: display summary with wide items grouped together' {
      InModuleScope Elizium.Loopz {
        [hashtable]$passThru = @{
          'LOOPZ.SUMMARY-BLOCK.LINE'             = $LoopzUI.DashLine;
          'LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS'       = @(@('From', '/source/'), @('To', '/destination/'));
          'LOOPZ.SUMMARY-BLOCK.GROUP-WIDE-ITEMS' = $true
        }
        show-SimpleSummaryBlock -Count 999 -Skipped 0 -Triggered $false -PassThru $passThru;
      }
    }
  }

  Context 'given: summary properties specified' {
    It 'should: display summary with summary properties' {
      InModuleScope Elizium.Loopz {
        [hashtable]$passThru = @{
          'LOOPZ.SUMMARY-BLOCK.LINE'       = $LoopzUI.DashLine;
          'LOOPZ.SUMMARY-BLOCK.PROPERTIES' = @(@('A', 'One'), @('B', 'Two'));
        }
        show-SimpleSummaryBlock -Count 999 -Skipped 0 -Triggered $false -PassThru $passThru;
      }
    }
  }
}
