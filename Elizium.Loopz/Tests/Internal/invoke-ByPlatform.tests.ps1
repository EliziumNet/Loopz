
Describe 'invoke-ByPlatform' {
  BeforeAll {
    . .\Internal\get-PlatformName
    . .\Internal\invoke-ByPlatform.ps1

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
      Mock get-PlatformName { return 'windows' }

      [string]$expected = 'win: Name:cherry, Colour:red';
      $result = invoke-ByPlatform -Hash $platforms

      $result | Should -Be $expected;
    }
  }

  Context 'given: linux platform' {
    It 'should: invoke the linux function' {
      Mock get-PlatformName { return 'linux' }

      [string]$expected = 'linux: Name:grass, Colour:green';
      $result = invoke-ByPlatform -Hash $platforms

      $result | Should -Be $expected;
    }
  }

  Context 'given: mac platform' {
    It 'should: invoke the mac function' {
      Mock get-PlatformName { return 'mac' }

      [string]$expected = 'mac: Name:lagoon, Colour:blue';
      $result = invoke-ByPlatform -Hash $platforms

      $result | Should -Be $expected;
    }
  }
}
