
Describe 'Update-GroupRefs' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking
  }

  Context 'given: a regex capture' {             
    It 'should: return string with evaluated group cross reference' -Tag 'Ref' {
      InModuleScope Elizium.Loopz {
        . .\Tests\Helpers\new-expr.ps1
        [string]$source = 'ninas 99 red balloons 777';
        [RegEx]$patternRegEx = new-expr('(?<count>\d{2})[\w\s]+(?<triplet>\d{3})');

        [string]$null, $null, `
          [System.Text.RegularExpressions.Match]$patternMatch = Split-Match -Source $source `
          -PatternRegEx $patternRegEx;

        [Hashtable]$patternCaptures = get-Captures -MatchObject $patternMatch;

        # Note, $otherSourceWithRefs is an un-interpolated string; ie in single quotes
        #
        [string]$otherSourceWithRefs = '==(${triplet})==[${count}]==';
        [string]$updatedWithRefs = Update-GroupRefs -Source $otherSourceWithRefs -Captures $patternCaptures;
        $updatedWithRefs | Should -BeExactly '==(777)==[99]==';
      }
    }
  }
}
