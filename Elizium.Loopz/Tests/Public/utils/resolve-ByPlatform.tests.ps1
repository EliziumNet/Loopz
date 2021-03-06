Describe 'Resolve-ByPlatform' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;

    [hashtable]$script:platforms = @{
      'windows' = 'windows-info';
      'linux'   = 'linux-info';
      'mac'     = 'mac-info';
    }
  }

  Context 'given: windows platform' {
    It 'should: resolve to the windows value' {
      Mock -ModuleName Elizium.Loopz Get-PlatformName { return 'windows' }
      [string]$expected = 'windows-info';
      $result = Resolve-ByPlatform -Hash $platforms
      $result | Should -Be $expected;
    }
  }

  Context 'given: linux platform' {
    It 'should: resolve to the linux value' {
      Mock -ModuleName Elizium.Loopz Get-PlatformName { return 'linux' }
      [string]$expected = 'linux-info';
      $result = Resolve-ByPlatform -Hash $platforms
      $result | Should -Be $expected;
    }
  }

  Context 'given: mac platform' {
    It 'should: resolve to the mac value' {
      Mock -ModuleName Elizium.Loopz Get-PlatformName { return 'mac' }
      [string]$expected = 'mac-info';
      $result = Resolve-ByPlatform -Hash $platforms
      $result | Should -Be $expected;
    }
  }

  Context 'given: undefined platform' {
    It 'should: resolve to the default value provided' {
      Mock -ModuleName Elizium.Loopz Get-PlatformName { return 'UBUNTU' }
      [string]$expected = 'default-info';

      [hashtable]$withDefault = $platforms.Clone();
      $withDefault['default'] = 'default-info';

      $result = Resolve-ByPlatform -Hash $withDefault;
      $result | Should -Be $expected;
    }
  }

  Context 'given: undefined platform' {
    It 'should: resolve to null' {
      Mock -ModuleName Elizium.Loopz Get-PlatformName { return 'UBUNTU' }
      $result = Resolve-ByPlatform -Hash $platforms
      $result | Should -BeNullOrEmpty
    }
  }
}
