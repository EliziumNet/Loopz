
Describe 'Get-UniqueCrossPairs' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;
  }

  Context 'given: 1xn array pair' {
    Context 'and: 1x1' {
      It 'should: return empty list' {
        [string[]]$first = @('A');
        [string[]]$second = @('B');

        [PSCustomObject[]]$result = Get-UniqueCrossPairs $first $second;
        $result.Count | Should -Be 1;
      }
    }

    Context 'and: 1x2' {
      Context 'and: contain common item' {
        It 'should: return single pair' {
          [string[]]$first = @('A', 'B');
          [string[]]$second = @('B');

          [PSCustomObject[]]$result = Get-UniqueCrossPairs $first $second;
          $result.Count | Should -Be 1;
        }
      }
      Context 'and: contain single common item' {
        It 'should: return 2 pairs' {
          [string[]]$first = @('A', 'B');
          [string[]]$second = @('C');

          [PSCustomObject[]]$result = Get-UniqueCrossPairs $first $second;
          $result.Count | Should -Be 2;
        }
      }
    }
  } # given: 1xn array pair

  Context 'given: a 2x2 array pair' {
    Context 'and: each array contains same items' {
      It 'should: return a list with single pair' {
        [string[]]$first = @('A', 'B');
        [string[]]$second = @('A', 'B');

        [PSCustomObject[]]$result = Get-UniqueCrossPairs $first $second;
        $result.Count | Should -Be 1;
      }
    } # and: each array contains same items

    Context 'and: each array contains single common item' {
      It 'should: return a list with 2 pairs' {
        [string[]]$first = @('A', 'B');
        [string[]]$second = @('C', 'B');

        [PSCustomObject[]]$result = Get-UniqueCrossPairs $first $second;
        $result.Count | Should -Be 3;
      }
    }

    Context 'and: each array contains no common items' {
      It 'should: return a list with 4 pairs' {
        [string[]]$first = @('A', 'B');
        [string[]]$second = @('C', 'D');

        [PSCustomObject[]]$result = Get-UniqueCrossPairs $first $second;
        $result.Count | Should -Be 4;
      }
    }
  } # given: a 2x2 array pair

  Context 'given: 2 sequences with some common elements' {
    It 'should: return unique pairs' {
      [string[]]$first = @('A', 'B', 'C');
      [string[]]$second = @('A', 'C', 'D');

      [PSCustomObject[]]$result = Get-UniqueCrossPairs $first $second;
      $result.Count | Should -Be 6;
    }
  }

  Context 'given: 2 sequences with no common elements' {
    It 'should: return unique pairs' {
      [string[]]$first = @('A', 'B', 'C', 'D');
      [string[]]$second = @('W', 'X', 'Y', 'Z');

      [PSCustomObject[]]$result = Get-UniqueCrossPairs $first $second;
      $result.Count | Should -Be 16;

      $result | ForEach-Object {
        $first | Should -Not -Contain $_.Second;
        $second | Should -Not -Contain $_.First;
      }
    }
  }

  Context 'given: 2 sequences with all common elements' {
    It 'should: return unique pairs' {
      [string[]]$first = @('A', 'B', 'C');
      [string[]]$second = @('A', 'B', 'C');

      [PSCustomObject[]]$result = Get-UniqueCrossPairs $first $second;
      $result.Count | Should -Be 3;
    }
  }

  Context 'given: 1 sequences only' {
    It 'should: return unique pairs' {
      [string[]]$first = @('A', 'B', 'C');

      [PSCustomObject[]]$result = Get-UniqueCrossPairs $first;
      $result.Count | Should -Be 3;
    }
  }
} # Get-UniqueCrossPairs
