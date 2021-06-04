using module Elizium.Klassy;

Describe 'Build-PoShLog' -Tag 'plog' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking

    [string]$script:ROOT = 'root';
    [string]$script:DIRECTORY = [PoShLogProfile]::DIRECTORY;
    [string]$script:_rootPath = Join-Path -Path $TestDrive -ChildPath $ROOT;
  }

  Describe 'EjectConfig' {
    Context 'given: Emoji' {
      Context 'and: requested options do not exist' {
        It 'should: create new options config' {
          [PSCustomObject]$optionsInfo = [PSCustomObject]@{
            Base          = '-poshlog.options';
            DirectoryName = [PoShLogProfile]::DIRECTORY;
            GroupBy       = 'scope/type/change/break';
            Root          = $_rootPath;
          }

          [PoShLogOptionsManager]$manager = New-PoShLogOptionsManager -OptionsInfo $optionsInfo;
          [boolean]$withEmoji = $true;

          [PSCustomObject]$options = $manager.FindOptions('Elizium', $withEmoji);
          $options | Should -Not -BeNullOrEmpty;
        }
      }
    }
  }

  Describe 'CreateLog' {
    Context 'given: Emoji' {
      Context 'and: options file exists' {
        It 'should: build change log' {
          [PSCustomObject]$optionsInfo = [PSCustomObject]@{
            Base          = '-poshlog.options';
            DirectoryName = $DIRECTORY;
            GroupBy       = 'scope/type/change/break';
            Root          = $_rootPath;
          }
          [string]$directoryPath = Join-Path -Path $_rootPath -ChildPath $DIRECTORY;
          [string]$optionsFileName = 'Test-emoji-poshlog.options.json';
          [string]$testPath = "./Tests/Data/changelog/$optionsFileName";

          [void]$(New-Item -ItemType 'Directory' -Path $directoryPath);
          [string]$destinationPath = Join-Path -Path $directoryPath -ChildPath $optionsFileName;
          Copy-Item -LiteralPath $testPath -Destination $destinationPath;

          [PoShLogOptionsManager]$manager = New-PoShLogOptionsManager -OptionsInfo $optionsInfo;
          [boolean]$withEmoji = $true;

          [PSCustomObject]$options = $manager.FindOptions('Test', $withEmoji);
          [PoShLog]$changeLog = New-PoShLog -Options $options;
          [string]$outputPath = Join-Path -Path $directoryPath -ChildPath 'ChangeLog.test-emojis.md';
          [string]$content = $changeLog.Build();
          $changeLog.Save($content, $outputPath);

          Test-Path -LiteralPath $outputPath | Should -BeTrue; 
        }
      }
    }
  }

  Describe 'Build-PoShLog' {
    BeforeEach {
      $env:PesterTestDrive = $TestDrive;
      [string]$directoryPath = Join-Path -Path $TestDrive -ChildPath $([PoShLogProfile]::DIRECTORY);
      [string]$script:_optionsFileName = $(
        Join-Path -Path $directoryPath -ChildPath 'Elizium-emoji-poshlog.options.json'
      );

      [string]$script:_markdownFileName = $(
        Join-Path -Path $directoryPath -ChildPath 'ChangeLog-Elizium-emoji.md'
      );
    }

    Context 'given: Eject Emoji options' {
      Context 'and: requested options do not exist' {
        It 'should: create new options config' {
          Build-PoShLog -Name 'Elizium' -Emoji -Eject -Test;
          Test-Path -Path $_optionsFileName | Should -BeTrue;

          Build-PoShLog -Name 'Elizium' -Emoji -Test;
          Test-Path -Path $_markdownFileName | Should -BeTrue;
        }
      }
    }

    Context 'given: Create Emoji ChangeLog' {
      Context 'and: requested options not exist' {
        It 'should: just eject the required config' -Tag 'Current' {
          Build-PoShLog -Name 'Elizium' -Emoji -Test;
          Test-Path -Path $_optionsFileName | Should -BeTrue;
        }
      }
    }
  }
}
