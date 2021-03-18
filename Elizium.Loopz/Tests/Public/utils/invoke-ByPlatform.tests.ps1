
Describe 'Invoke-ByPlatform' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;

    function invoke-winFn {
      param(
        [string]$name,
        [string]$colour
      )

      "win: Name:$name, Colour:$colour";
    }
    function invoke-linuxFn {
      param(
        [string]$name,
        [string]$colour
      )

      "linux: Name:$name, Colour:$colour";
    }

    function invoke-macFn {
      param(
        [string]$name,
        [string]$colour
      )

      "mac: Name:$name, Colour:$colour";
    }

    function invoke-defaultFn {
      param(
        [string]$name,
        [string]$colour
      )

      "def: Name:$name, Colour:$colour";
    }
  }

  Context 'given: Parameters By Position' {
    BeforeAll {
      [hashtable]$script:platformsPositional = @{
        'windows' = [PSCustomObject]@{
          FnInfo     = Get-Command -Name invoke-winFn -CommandType Function;
          Positional = @('cherry', 'red');
        };
        'linux'   = [PSCustomObject]@{
          FnInfo     = Get-Command -Name invoke-linuxFn -CommandType Function;
          Positional = @('grass', 'green');
        };
        'mac'     = [PSCustomObject]@{
          FnInfo     = Get-Command -Name invoke-macFn -CommandType Function;
          Positional = @('lagoon', 'blue');
        };
      }
    }

    Context 'and: windows platform' {
      It 'should: invoke the windows function' {
        Mock -ModuleName Elizium.Loopz Get-PlatformName { return 'windows' }

        [string]$expected = 'win: Name:cherry, Colour:red';
        $result = Invoke-ByPlatform -Hash $platformsPositional;

        $result | Should -Be $expected;
      }
    } # and: windows platform

    Context 'and: linux platform' {
      It 'should: invoke the linux function' {
        Mock -ModuleName Elizium.Loopz Get-PlatformName { return 'linux' }

        [string]$expected = 'linux: Name:grass, Colour:green';
        $result = Invoke-ByPlatform -Hash $platformsPositional;

        $result | Should -Be $expected;
      }
    } # and: linux platform

    Context 'and: mac platform' {
      It 'should: invoke the mac function' {
        Mock -ModuleName Elizium.Loopz Get-PlatformName { return 'mac' }

        [string]$expected = 'mac: Name:lagoon, Colour:blue';
        $result = Invoke-ByPlatform -Hash $platformsPositional;

        $result | Should -Be $expected;
      }
    } # and: mac platform

    Context 'and: Unknown platform and Default supplied' {
      It 'should: invoke the default function' {
        Mock -ModuleName Elizium.Loopz Get-PlatformName { return 'ubuntu' }

        [hashtable]$platformsWithDefault = $platformsPositional.Clone();
        $platformsWithDefault['default'] = [PSCustomObject]@{
          FnInfo     = Get-Command -Name invoke-defaultFn -CommandType Function;
          Positional = @('canary', 'yellow');
        }
        [string]$expected = 'def: Name:canary, Colour:yellow';
        $result = Invoke-ByPlatform -Hash $platformsWithDefault;

        $result | Should -Be $expected;
      }
    } # and: Unknown platform and Default supplied

    Context 'and: invoke function without parameters' {
      It 'should: invoke' {
        Mock -ModuleName Elizium.Loopz Get-PlatformName { return 'windows' }
        function invoke-ParamLessWinFn {
          param()
          "win: param-less";
        }
        [hashtable]$script:paramLessPositional = @{
          'windows' = [PSCustomObject]@{
            FnInfo     = Get-Command -Name invoke-ParamLessWinFn -CommandType Function;
            Positional = @();
          };
        }
        [string]$expected = 'win: param-less';
        $result = Invoke-ByPlatform -Hash $paramLessPositional;

        $result | Should -Be $expected;
      }
    }
  } # given: Parameters By Position

  Context 'given: Named Parameters' -Skip {
    BeforeAll {
      [hashtable]$script:platformsNamed = @{
        'windows' = [PSCustomObject]@{
          FnInfo     = Get-Command -Name invoke-winFn -CommandType Function;
          Named = @{ 'name' = 'cherry'; 'colour' = 'red'};
        };
        'linux'   = [PSCustomObject]@{
          FnInfo     = Get-Command -Name invoke-linuxFn -CommandType Function;
          Named = @{ 'name' = 'grass'; 'colour' = 'green'};
        };
        'mac'     = [PSCustomObject]@{
          FnInfo     = Get-Command -Name invoke-macFn -CommandType Function;
          Named = @{ 'name' = 'lagoon'; 'colour' = 'blue'};
        };
      }
    }

    Context 'and: windows platform' {
      It 'should: invoke the windows function' {
        Mock -ModuleName Elizium.Loopz Get-PlatformName { return 'windows' }

        [string]$expected = 'win: Name:cherry, Colour:red';
        $result = Invoke-ByPlatform -Hash $platformsNamed;

        $result | Should -Be $expected;
      }
    } # and: windows platform

    Context 'and: linux platform' {
      It 'should: invoke the linux function' {
        Mock -ModuleName Elizium.Loopz Get-PlatformName { return 'linux' }

        [string]$expected = 'linux: Name:grass, Colour:green';
        $result = Invoke-ByPlatform -Hash $platformsNamed;

        $result | Should -Be $expected;
      }
    } # and: linux platform

    Context 'and: mac platform' {
      It 'should: invoke the mac function' {
        Mock -ModuleName Elizium.Loopz Get-PlatformName { return 'mac' }

        [string]$expected = 'mac: Name:lagoon, Colour:blue';
        $result = Invoke-ByPlatform -Hash $platformsNamed;

        $result | Should -Be $expected;
      }
    } # and: mac platform

    Context 'and: Unknown platform and Default supplied' {
      It 'should: invoke the default function' {
        Mock -ModuleName Elizium.Loopz Get-PlatformName { return 'ubuntu' }

        [hashtable]$namedWithDefault = $platformsNamed.Clone();
        $namedWithDefault['default'] = [PSCustomObject]@{
          FnInfo     = Get-Command -Name invoke-defaultFn -CommandType Function;
          Named      = @{ 'name' = 'canary'; 'colour' = 'yellow' };
        }
        [string]$expected = 'def: Name:canary, Colour:yellow';
        $result = Invoke-ByPlatform -Hash $namedWithDefault;

        $result | Should -Be $expected;
      }
    } # and: Unknown platform and Default supplied
  } # given: Named Parameters
} # Invoke-ByPlatform
