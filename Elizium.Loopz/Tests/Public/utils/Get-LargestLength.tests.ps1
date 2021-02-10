
Describe 'Get-LargestLength' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;
  }

  Context 'given: empty array' {
    It 'should: return 0' {
      Get-LargestLength @() | Should -Be 0;
    }
  }

  Context 'given: single string item array' {
    It 'should: return 1' {
      Get-LargestLength @('greetings') | Should -Be 9;
    }
  }

  Context 'given: multi-item string array' {
    It 'should: return largest length' {
      Get-LargestLength @('who', 'watches', 'the', 'watchers') | Should -Be 8;
    }
  }

  Context 'given: multi-item string array with empty strings' {
    It 'should: return 0' {
      Get-LargestLength @('', '', '', '') | Should -Be 0;
    }
  }

  Context 'given: an array of integers' {
    It 'should: return 0' -Skip {
      
      [PScustomObject]$arr = @(
        @{ Name = 'fred'; Size = 1; Girl = $false }
        @{ Name = 'kerry'; Size = 2; Girl = $true }
        @{ Name = 'julie'; Size = 3; Girl = $true }
      )

      Write-Host ">>> Names: '$($arr.Name)', Max: $(Get-LargestLength $arr.Name)";
      Write-Host ">>> Sizes: '$($arr.Size)', Max: $(Get-LargestLength $arr.Size)";
      Write-Host ">>> Girls: '$($arr.Girl)', Max: $(Get-LargestLength $arr.Girl)";

      $field = 'Girl'
      Write-Host "!!! SEX: '$($arr.Girl + 'sex')'"
      Write-Host "!!! SEX: '$($arr.$field + 'sex')'"

      $s = @('one', 'two');
      $r = $s + 'three';

      Write-Host ">>> SAFE: $r";
      $b = $($true, $false);
      $r = $b + 'three';
      Write-Host ">>> UNSAFE: $r";
    }
  }

  Context 'command syntax: regex parameter parsing' {
    It 'blah' {
      
    }
  }
}
