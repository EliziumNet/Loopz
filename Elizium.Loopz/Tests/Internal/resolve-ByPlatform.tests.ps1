
Describe 'resolve-ByPlatform' -Tag 'Current' {
  BeforeAll {
    . .\Internal\get-PlatformName
    . .\Internal\resolve-ByPlatform.ps1

    [System.Collections.Hashtable]$script:platforms = @{
      'windows' = 'windows-info';
      'linux'   = 'linux-info';
      'mac'     = 'mac-info';
    }
  }

  Context 'given: windows platform' {
    It 'should: resolve to the windows value' {
      Mock get-PlatformName { return 'windows' }
      [string]$expected = 'windows-info';
      $result = resolve-ByPlatform -Hash $platforms
      $result | Should -Be $expected;
    }
  }

  Context 'given: linux platform' {
    It 'should: resolve to the linux value' {
      Mock get-PlatformName { return 'linux' }
      [string]$expected = 'linux-info';
      $result = resolve-ByPlatform -Hash $platforms
      $result | Should -Be $expected;
    }
  }

  Context 'given: mac platform' {
    It 'should: resolve to the mac value' {
      Mock get-PlatformName { return 'mac' }
      [string]$expected = 'mac-info';
      $result = resolve-ByPlatform -Hash $platforms
      $result | Should -Be $expected;
    }
  }

  Context 'given: undefined platform' {
    It 'should: resolve to the default value provided' {
      Mock get-PlatformName { return 'UBUNTU' }
      [string]$expected = 'default-info';
      $result = resolve-ByPlatform -Hash $platforms -Default 'default-info'
      $result | Should -Be $expected;
    }
  }

  Context 'given: undefined platform' {
    It 'should: resolve to null' {
      Mock get-PlatformName { return 'UBUNTU' }
      $result = resolve-ByPlatform -Hash $platforms
      $result | Should -BeNullOrEmpty
    }
  }
}
