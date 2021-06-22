
Describe 'Get-InverseSubString' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking

    #                         01234567890123456
    [string]$script:source = 'fire walk with me';
  }

  Context 'given: StartIndex is 0 and Length is valid' {
    It 'should: return the end portion of Source' {
      Get-InverseSubString -Source $source -StartIndex 0 -Length 5 | Should -BeExactly 'walk with me';
    }
  }

  Context 'given: StartIndex occurs midway and Length is valid' {
    It 'should: return the tail and end portions of Source' {
      Get-InverseSubString -Source $source -StartIndex 5 -Length 5 | Should -BeExactly 'fire with me';
    }
  }

  Context 'given: StartIndex occurs midway, Length is valid and Split' {
    It 'should: return the tail and end portions of Source' {
      Get-InverseSubString -Source $source -StartIndex 5 -Length 5 -Split | `
        Should -BeExactly @('fire ', 'with me');
    }
  }

  Context 'given: StartIndex occurs midway and Length is a maximum' {
    It 'should: return the start portion of Source' {
      Get-InverseSubString -Source $source -StartIndex 14 -Length 3 | Should -BeExactly 'fire walk with';
    }
  }

  Context 'given: invalid StartIndex' {
    It 'should: throw' {
      { Get-InverseSubString -Source $source -StartIndex 99 -Length 3 } | Should -Throw;
    }
  }

  Context 'given: StartIndex occurs midway and Length too long' {
    It 'should: throw' {
      { Get-InverseSubString -Source $source -StartIndex 14 -Length 99 } | Should -Throw;
    }
  }

  Context 'given: marker' {
    BeforeEach {
      [char]$script:Square = 0x20DE;
    }

    Context 'and: StartIndex is 0 and Length is valid' {
      It 'should: return the end portion of Source' {
        [string]$expected = $($Square + 'walk with me');
        Get-InverseSubString -Source $source -StartIndex 0 -Length 5 -Marker $Square | `
          Should -BeExactly $expected;
      }
    }

    Context 'and: StartIndex occurs midway and Length is valid' {
      It 'should: return the tail and end portions of Source' {
        [string]$expected = $('fire ' + $Square + 'with me');
        Get-InverseSubString -Source $source -StartIndex 5 -Length 5 -Marker $Square | `
          Should -BeExactly $expected;
      }
    }

    Context 'and: StartIndex occurs midway, Length is valid and Split' {
      It 'should: return the tail and end portions of Source' {
        Get-InverseSubString -Source $source -StartIndex 5 -Length 5 -Split -Marker $Square | `
          Should -BeExactly @($('fire ' + $Square), 'with me');
      }
    }
  }
}
