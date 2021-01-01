
Describe 'Edit-RemoveSingleSubString' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking
  }

  Context 'given: First Only' {
    Context 'and: case sensitive' {
      It 'should: remove first occurence of <Subtract>' -TestCases @(
        @{ Subtract = 'o'; Expected = 'The quick brwn fox' }
        @{ Subtract = 'jump'; Expected = 'The quick brown fox' }
        @{ Subtract = 'The'; Expected = ' quick brown fox' }
        @{ Subtract = 'fox'; Expected = 'The quick brown ' }
        @{ Subtract = 'Fox'; Expected = 'The quick brown fox' }
      ) {
        $target = 'The quick brown fox';
        edit-RemoveSingleSubString -Target $target -Subtract $Subtract | `
          Should -BeExactly $Expected;
      }
    }

    Context 'and: case in-sensitive' {
      It 'should: remove the first substring of a different case' {
        $target = 'The quick brown fox';
        $subtract = 'O';
        $expected = 'The quick brwn fox'
        edit-RemoveSingleSubString -Target $target -Subtract $subtract -Insensitive | `
          Should -BeExactly $expected;
      }
    }
  } # given: First Only

  Context 'given: Last Only' {
    Context 'and: case sensitive' {
      It 'should: remove last occurence of <Subtract>' -TestCases @(
        @{ Subtract = 'a'; Expected = 'The naked nd the dub' }
        @{ Subtract = 'jump'; Expected = 'The naked and the dub' }
        @{ Subtract = 'The'; Expected = ' naked and the dub' }
        @{ Subtract = 'dub'; Expected = 'The naked and the ' }
        @{ Subtract = 'Dub'; Expected = 'The naked and the dub' }
      ) {
        $target = 'The naked and the dub';
        edit-RemoveSingleSubString -Target $target -Subtract $Subtract -Last | `
          Should -BeExactly $Expected;
      }
    }

    Context 'and: case in-sensitive' {
      It 'should: remove the last substring of a different case' {
        $target = 'The naked and the dead';
        $subtract = 'DEAD';
        $expected = 'The naked and the '
        edit-RemoveSingleSubString -Target $target -Subtract $subtract -Insensitive | `
          Should -BeExactly $expected;
      }
    }
  } # given: Last Only
}
