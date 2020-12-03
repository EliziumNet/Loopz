
Describe 'Invoke-ByPlatform' -Skip {
  BeforeAll {

    # . .\Public\Get-PlatformName
    # . .\Public\Invoke-ByPlatform.ps1

    # Test skipped until Invoke-ByPlatform changed to invoke the function via get-command
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;

    function invoke-winfn {
      param(
        [string]$name,
        [string]$colour
      )

      "win: Name:$name, Colour:$colour";
    }
    function invoke-linuxfn {
      param(
        [string]$name,
        [string]$colour
      )

      "linux: Name:$name, Colour:$colour";
    }

    function invoke-macfn {
      param(
        [string]$name,
        [string]$colour
      )

      "mac: Name:$name, Colour:$colour";
    }

    [System.Collections.Hashtable]$script:platforms = @{
      'windows' = @{ FunctionName = 'invoke-winfn'; FunctionParameters = @{ 'name' = 'cherry'; 'colour' = 'red' } };
      'linux'   = @{ FunctionName = 'invoke-linuxfn'; FunctionParameters = @{ 'name' = 'grass'; 'colour' = 'green' } };
      'mac'     = @{ FunctionName = 'invoke-macfn'; FunctionParameters = @{ 'name' = 'lagoon'; 'colour' = 'blue' } };
    }
  }

  Context 'given: windows platform' {
    It 'should: invoke the windows function' {
      Mock Get-PlatformName { return 'windows' }

      [string]$expected = 'win: Name:cherry, Colour:red';
      $result = Invoke-ByPlatform -Hash $platforms

      $result | Should -Be $expected;
    }
  }

  Context 'given: linux platform' {
    It 'should: invoke the linux function' {
      Mock Get-PlatformName { return 'linux' }

      [string]$expected = 'linux: Name:grass, Colour:green';
      $result = Invoke-ByPlatform -Hash $platforms

      $result | Should -Be $expected;
    }
  }

  Context 'given: mac platform' {
    It 'should: invoke the mac function' {
      Mock Get-PlatformName { return 'mac' }

      [string]$expected = 'mac: Name:lagoon, Colour:blue';
      $result = Invoke-ByPlatform -Hash $platforms

      $result | Should -Be $expected;
    }
  }
}
