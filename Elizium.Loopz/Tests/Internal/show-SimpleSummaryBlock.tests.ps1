
Describe 'show-SimpleSummaryBlock' {
  BeforeAll {
    # Get-Module Elizium.Loopz | Remove-Module
    # Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
    #   -ErrorAction 'stop' -DisableNameChecking
    #
    . .\Public\globals.ps1;
    . .\Internal\show-SimpleSummaryBlock.ps1
  }

  Context 'given: block line specified' {
    It 'should: display summary' {
      [System.Collections.Hashtable]$passThru = @{
        'LOOPZ.SUMMARY-BLOCK.LINE' = $LoopzUI.DashLine;
      }
      show-SimpleSummaryBlock -Count 999 -Skipped 0 -Triggered $false -PassThru $passThru;
    }
  }

  Context 'given: no block line specified' {
    It 'should: display summary' {
      [System.Collections.Hashtable]$passThru = @{}
      show-SimpleSummaryBlock -Count 101 -Skipped 0 -Triggered $true -PassThru $passThru;
    }
  }

  Context 'given: wide items specified' {
    It 'should: display summary with wide items' -Tag 'Current' {
      [System.Collections.Hashtable]$passThru = @{
        'LOOPZ.SUMMARY-BLOCK.LINE' = $LoopzUI.DashLine;
        'LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS' = @(@('From', '/source/'), @('To', '/destination/'));
      }
      show-SimpleSummaryBlock -Count 999 -Skipped 0 -Triggered $false -PassThru $passThru;
    }
  }

  Context 'given: summary properties specified' {
    It 'should: display summary with summary properties' -Tag 'Current' {
      [System.Collections.Hashtable]$passThru = @{
        'LOOPZ.SUMMARY-BLOCK.LINE'       = $LoopzUI.DashLine;
        'LOOPZ.SUMMARY-BLOCK.PROPERTIES' = @(@('A', 'One'), @('B', 'Two'));
      }
      show-SimpleSummaryBlock -Count 999 -Skipped 0 -Triggered $false -PassThru $passThru;
    }
  }
}
