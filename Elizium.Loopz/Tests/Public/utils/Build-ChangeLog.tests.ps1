using module Elizium.Klassy;

Describe 'Build-ChangeLog' -Tag 'chog' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking

    [string]$script:ROOT = 'root';
    [string]$script:DIRECTORY = [ChangeLogSchema]::DIRECTORY;
    [string]$script:_rootPath = Join-Path -Path $TestDrive -ChildPath $ROOT;
  }

  Describe 'EjectConfig' {
    Context 'given: Emoji' {
      Context 'and: requested options do not exist' {
        It 'should: create new options config' {
          [PSCustomObject]$optionsInfo = [PSCustomObject]@{
            Base          = '-changelog.options';
            DirectoryName = [ChangeLogSchema]::DIRECTORY;
            GroupBy       = 'scope/type/change/break';
            Root          = $_rootPath;
          }

          [ChangeLogOptionsManager]$manager = New-ChangeLogOptionsManager -OptionsInfo $optionsInfo;
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
            Base          = '-changelog.options';
            DirectoryName = $DIRECTORY;
            GroupBy       = 'scope/type/change/break';
            Root          = $_rootPath;
          }
          [string]$directoryPath = Join-Path -Path $_rootPath -ChildPath $DIRECTORY;
          [string]$optionsFileName = 'Test-emoji-changelog.options.json';
          [string]$testPath = "./Tests/Data/changelog/$optionsFileName";

          [void]$(New-Item -ItemType 'Directory' -Path $directoryPath);
          [string]$destinationPath = Join-Path -Path $directoryPath -ChildPath $optionsFileName;
          Copy-Item -LiteralPath $testPath -Destination $destinationPath;

          [ChangeLogOptionsManager]$manager = New-ChangeLogOptionsManager -OptionsInfo $optionsInfo;
          [boolean]$withEmoji = $true;

          [PSCustomObject]$options = $manager.FindOptions('Test', $withEmoji);
          [ChangeLog]$changeLog = New-ChangeLog -Options $options;
          [string]$outputPath = Join-Path -Path $directoryPath -ChildPath 'ChangeLog.test-emojis.md';
          [string]$content = $changeLog.Build();
          $changeLog.Save($content, $outputPath);

          Test-Path -LiteralPath $outputPath | Should -BeTrue; 
        }
      }
    }
  }

  Describe 'Build-ChangeLog' {
    BeforeEach {
      $env:PesterTestDrive = $TestDrive;
      [string]$directoryPath = Join-Path -Path $TestDrive -ChildPath $([ChangeLogSchema]::DIRECTORY);
      [string]$script:_optionsFileName = $(
        Join-Path -Path $directoryPath -ChildPath 'Elizium-emoji-changelog.options.json'
      );

      [string]$script:_markdownFileName = $(
        Join-Path -Path $directoryPath -ChildPath 'ChangeLog-Elizium-emoji.md'
      );
    }

    Context 'given: Eject Emoji options' {
      Context 'and: requested options do not exist' {
        It 'should: create new options config' {
          Build-ChangeLog -Name 'Elizium' -Emoji -Eject -Test;
          Test-Path -Path $_optionsFileName | Should -BeTrue;

          Build-ChangeLog -Name 'Elizium' -Emoji -Test;
          Test-Path -Path $_markdownFileName | Should -BeTrue;
        }
      }
    }

    Context 'given: Create Emoji ChangeLog' {
      Context 'and: requested options not exist' {
        It 'should: just eject the required config' -Tag 'Current' {
          Build-ChangeLog -Name 'Elizium' -Emoji -Test;
          Test-Path -Path $_optionsFileName | Should -BeTrue;
        }
      }
    }
  }
}
