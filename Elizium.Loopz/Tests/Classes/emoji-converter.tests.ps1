using namespace Elizium.Loopz;

# Warning about Mocks and classes. MUST re-created the session in-between runs
# See: https://pester.dev/docs/usage/mocking
#
Describe 'emoji converter' -Tag 'emoji' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;

    InModuleScope -ModuleName Elizium.Loopz {
      [string]$script:_EliziumPath = $(Join-Path -Path $TestDrive -ChildPath 'elizium');
      [DateTime]$script:_Now = [DateTime]::new(2021, 2, 24, 15, 30, 45);
      [DateTime]$script:_Legacy = [DateTime]::new(2020, 3, 18, 21, 15, 08);
      [string]$script:emojiContentAsText = Get-Content -Path ".\Tests\Data\emojis\emoji-api.cache.json";
      [string]$script:emojiShortContentAsText = Get-Content -Path ".\Tests\Data\emojis\emoji-api.a-cache.json";
      [TimeSpan]$script:OneDaySpan = New-TimeSpan -Days 1;
      [TimeSpan]$script:TwoHourSpan = New-TimeSpan -Hours 2;
      [DateTime]$script:TwoHoursAgo = $_Now - $TwoHourSpan;
      [string]$script:CodePointFormat = "&#x{0};";

      . .\Tests\Helpers\deploy-file.ps1
    }
  }

  BeforeEach {
    InModuleScope -ModuleName Elizium.Loopz {
      Mock -ModuleName Elizium.Loopz Get-EnvironmentVariable {
        return $_EliziumPath;
      }

      Mock -ModuleName Elizium.Loopz Invoke-EmojiApiRequest {
        [CmdletBinding()]
        param(
          [Parameter(Mandatory)]
          [Uri]$Uri,

          [Parameter()]
          [hashtable]$Headers
        )

        return [PSCustomObject]@{
          StatusCode        = 200;
          StatusDescription = 'OK';
          Headers           = @{}
          Content           = $emojiShortContentAsText;
        }
      }
    }
  }

  Describe 'JsonGopherCache' {
    Describe 'Init' {
      Context 'given: no cache file' {
        It 'should: initialise with no entries ok' {
          InModuleScope Elizium.Loopz {
            [JsonGopherCache]$cache = [JsonGopherCache]::new($_Now);
            $cache.Init();

            $cache.HashContent.PSBase.Count | Should -Be 0;
          }
        }
      }

      Context 'given: cache file present' {
        It 'should: initialise ok' {
          InModuleScope Elizium.Loopz {
            [string]$subPath = $(Join-Path -Path 'cache' -ChildPath 'emojis');
            [string]$fileName = 'emoji-api.store.json';
            [string]$fullPath = $(
              Join-Path -Path $_EliziumPath -ChildPath $subPath -AdditionalChildPath $fileName
            );
            $null = deploy-file -FullPath $fullPath -Content $emojiContentAsText -AsOf $_Now;

            [JsonGopherCache]$cache = [JsonGopherCache]::new($_Now);
            $cache.Init();
            
            $cache.HashContent.PSBase.Count | Should -BeGreaterThan 0;
          }
        }
      }
    } # Init

    Describe 'Save' {
      Context 'given: no cache file' {
        It 'should: write new content' {
          InModuleScope Elizium.Loopz {
            [JsonGopherCache]$cache = [JsonGopherCache]::new($_Now);
            $cache.Init();

            $cache.DatedFile.Exists() | Should -BeFalse;
            $cache.HashContent.PSBase.Count | Should -Be 0;
            $cache.Save($emojiContentAsText);
            $cache.HashContent.PSBase.Count | Should -BeGreaterThan 0;
          }
        }
      } # no cache file

      Context 'given: cache file present' {
        It 'should: overwrite old content' {
          InModuleScope Elizium.Loopz {
            [string]$subPath = $(Join-Path -Path 'cache' -ChildPath 'emojis');
            [string]$fileName = 'emoji-api.store.json';
            [string]$oldContent = Get-Content -Path .\Tests\Data\emojis\emoji-api.a-cache.json;
            [string]$fullPath = $(
              Join-Path -Path $_EliziumPath -ChildPath $subPath -AdditionalChildPath $fileName
            );
            $null = deploy-file -FullPath $fullPath -Content $oldContent -AsOf $_Legacy;

            [JsonGopherCache]$cache = [JsonGopherCache]::new($_Now);
            $cache.Init();

            $cache.DatedFile.Exists() | Should -BeTrue;
            $cache.HashContent.PSBase.Count | Should -BeGreaterThan 0;
            [int]$oldContentCount = $cache.HashContent.PSBase.Count;
            $cache.Save($emojiContentAsText);
            $cache.HashContent.PSBase.Count | Should -BeGreaterThan $oldContentCount;
          }
        }
      } # cache file present
    } # Save
  } # JsonGopherCache

  Describe 'GitHubEmojiApi' {
    Describe 'IsLastQueryStale' {
      Context 'given: no last query time file' {
        It 'should: return $true' {
          InModuleScope Elizium.Loopz {
            [GitHubEmojiApi]$service = [GitHubEmojiApi]::new($_Now);
            $service.Init();
            [TimeSpan]$querySpan = New-TimeSpan -Days 1;
            
            $service.IsLastQueryStale($querySpan) | Should -BeTrue;
          }
        }
      } # no last query time file

      Context 'given: last query time file stale' {
        It 'should: return $true' {
          InModuleScope Elizium.Loopz {
            [string]$subPath = 'github-emoji-api';
            [string]$fileName = [EmojiApi]::FileName;

            [string]$fullPath = $(
              Join-Path -Path $_EliziumPath -ChildPath $subPath -AdditionalChildPath $fileName
            );
            $null = deploy-file -FullPath $fullPath -Content 'pluto' -AsOf $_Legacy;

            [GitHubEmojiApi]$service = [GitHubEmojiApi]::new($_Now);
            $service.Init();

            $service.IsLastQueryStale($OneDaySpan) | Should -BeTrue;
          }
        }
      }

      Context 'given: last query time file within recent window' {
        It 'should: return $false' {
          InModuleScope Elizium.Loopz {
            [string]$subPath = 'github-emoji-api';
            [string]$fileName = [EmojiApi]::FileName;

            [string]$fullPath = $(
              Join-Path -Path $_EliziumPath -ChildPath $subPath -AdditionalChildPath $fileName
            );
            $null = deploy-file -FullPath $fullPath -Content 'asteroids' -AsOf $TwoHoursAgo;

            [GitHubEmojiApi]$service = [GitHubEmojiApi]::new($_Now);
            $service.Init();

            $service.IsLastQueryStale($OneDaySpan) | Should -BeFalse;
          }
        }
      }
    } # IsLastQueryStale
  } # GitHubEmojiApi

  Describe 'MarkDownEmojiConverter' {
    BeforeAll {
      InModuleScope -ModuleName Elizium.Loopz {
        [string]$script:_Pattern = ":(?<name>\w{2, 40}):";
      }
    }

    BeforeEach {
      InModuleScope -ModuleName Elizium.Loopz {
        Mock -ModuleName Elizium.Loopz Invoke-EmojiApiRequest {
          [CmdletBinding()]
          param(
            [Parameter(Mandatory)]
            [Uri]$Uri,

            [Parameter()]
            [hashtable]$Headers
          )

          return [PSCustomObject]@{
            StatusCode        = 200;
            StatusDescription = 'OK';
            Headers           = @{}
            Content           = $emojiContentAsText;
          }
        }
      }
    }

    Describe 'As' {
      Context 'given: <Emoji>' {
        It 'should: return the converted representation of the emoji as <Expected>' -TestCases @(
          @{ Emoji = 'arrow_heading_up'; Expected = '&#x2934;'; },
          @{ Emoji = 'arrow_right'; Expected = '&#x27a1;'; },
          @{ Emoji = 'anger'; Expected = '&#x1f4a2;'; },
          @{ Emoji = 'bar_chart'; Expected = '&#x1f4ca;'; },
          @{ Emoji = 'books'; Expected = '&#x1f4da;'; },
          @{ Emoji = 'clipboard'; Expected = '&#x1f4cb;'; },
          @{ Emoji = 'dart'; Expected = '&#x1f3af;'; },
          @{ Emoji = 'fireworks'; Expected = '&#x1f386;'; },
          @{ Emoji = 'gift'; Expected = '&#x1f381;'; },
          @{ Emoji = 'heavy_check_mark'; Expected = '&#x2714;'; },
          @{ Emoji = 'hibiscus'; Expected = '&#x1f33a;'; },
          @{ Emoji = 'hotsprings'; Expected = '&#x2668;'; },
          @{ Emoji = 'jigsaw'; Expected = '&#x1f9e9;'; },
          @{ Emoji = 'lock'; Expected = '&#x1f512;'; },
          @{ Emoji = 'nazar_amulet'; Expected = '&#x1f9ff;'; },
          @{ Emoji = 'package'; Expected = '&#x1f4e6;'; },
          @{ Emoji = 'postbox'; Expected = '&#x1f4ee;'; },
          @{ Emoji = 'pray'; Expected = '&#x1f64f;'; },
          @{ Emoji = 'pushpin'; Expected = '&#x1f4cc;'; },
          @{ Emoji = 'radioactive'; Expected = '&#x2622;'; },
          @{ Emoji = 'rainbow'; Expected = '&#x1f308;'; },
          @{ Emoji = 'recycle'; Expected = '&#x267b;'; },
          @{ Emoji = 'ribbon'; Expected = '&#x1f380;'; },
          @{ Emoji = 'scroll'; Expected = '&#x1f4dc;'; },
          @{ Emoji = 'smiley'; Expected = '&#x1f603;'; },
          @{ Emoji = 'star'; Expected = '&#x2b50;'; },
          @{ Emoji = 'sparkles'; Expected = '&#x2728;'; },
          @{ Emoji = 'toolbox'; Expected = '&#x1f9f0;'; },
          @{ Emoji = 'thumbsup'; Expected = '&#x1f44d;'; },
          @{ Emoji = 'warning'; Expected = '&#x26a0;'; },
          @{ Emoji = 'x'; Expected = '&#x274c;'; },

          @{ Emoji = 'tiddly_winks'; Expected = ''; }
        ) {
          InModuleScope Elizium.Loopz -Parameters @{ Emoji = $Emoji; Expected = $Expected; } {
            [MarkDownEmojiConverter]$converter = New-EmojiConverter -Now $_Now -QuerySpan $OneDaySpan;
            $converter.Init();

            $converter.As($Emoji) | Should -Be $Expected;
          }
        }
      }
    }

    Describe 'Convert (Short Code To Code Point)' {
      Context 'given: a typical full document with emoji short code refs' {
        It 'should: convert all to Code Points' {
          InModuleScope Elizium.Loopz {
            [MarkDownEmojiConverter]$converter = New-EmojiConverter -Now $_Now -QuerySpan $OneDaySpan;
            $converter.Init();
            
            [string]$documentPath = Resolve-Path -Path "./Tests/Data/emojis/README-WITH-EMOJIS.md";
            [string[]]$document = $converter.Read($documentPath);
            [PSCustomObject]$result = $converter.Convert($document);

            $result.MissingConversions.PSBase.Count | Should -Be 0;
            $result.TotalMissingCount | Should -Be 0;
            $result.SourceLineCount | Should -Be $result.ConversionLineCount `
              -Because 'Line count should be the same';
          }
        }
      }

      Context 'given: empty document' {
        It 'should: handle gracefully' {
          InModuleScope Elizium.Loopz {
            [MarkDownEmojiConverter]$converter = New-EmojiConverter -Now $_Now -QuerySpan $OneDaySpan;
            $converter.Init();

            [string[]]$document = @();
            [PSCustomObject]$result = $converter.Convert($document);
            $result.MissingConversions.PSBase.Count | Should -Be 0;
            $result.TotalMissingCount | Should -Be 0;
          }
        } 
      }

      Context 'and: line with emoji mapped to range of code points' {
        It 'should: pick first in range for conversion' {
          InModuleScope Elizium.Loopz {
            [MarkDownEmojiConverter]$converter = New-EmojiConverter -Now $_Now -QuerySpan $OneDaySpan;
            $converter.Init();

            [string[]]$document = @(
              "# :ascension_island: Elizium.Loopz",
              ""
              "This module includes a collection of commands"
            );
            [string]$ascensionConversion = $($CodePointFormat -f '1f1e6');
            [PSCustomObject]$result = $converter.Convert($document);
            $result.MissingConversions.PSBase.Count | Should -Be 0;
            $result.Document[0].contains($ascensionConversion) | Should -BeTrue;
          }
        }
      }

      Context 'given: Missing Conversion(s)' {
        Context 'and: line with a single missing conversion' {
          It 'should: report in MissingConversions' {
            InModuleScope Elizium.Loopz {
              [MarkDownEmojiConverter]$converter = New-EmojiConverter -Now $_Now -QuerySpan $OneDaySpan;
              $converter.Init();

              [string[]]$document = @(
                "# :blooper: Elizium.Loopz",
                ""
                "This module includes a collection of commands"
              );

              [PSCustomObject]$result = $converter.Convert($document);
              $result.MissingConversions.PSBase.Count | Should -Be 1;
              $result.MissingConversions[1] -contains 'blooper' | Should -BeTrue;
              $result.TotalMissingCount | Should -Be 1;
            }
          }
        }

        Context 'and: line with multiple missing conversions' {
          It 'should: report in MissingConversions' {
            InModuleScope Elizium.Loopz {
              [MarkDownEmojiConverter]$converter = New-EmojiConverter -Now $_Now -QuerySpan $OneDaySpan;
              $converter.Init();

              [string[]]$document = @(
                "This module includes a collection of commands"
                "",
                "# :blooper: Elizium.Loopz :clanger:"
              );

              [PSCustomObject]$result = $converter.Convert($document);
              $result.MissingConversions.PSBase.Count | Should -Be 1;
              $result.MissingConversions[3] -contains 'blooper' | Should -BeTrue;
              $result.MissingConversions[3] -contains 'clanger' | Should -BeTrue;
              $result.TotalMissingCount | Should -Be 2;
            }
          }
        }

        Context 'and: line with multiple missing conversions of the same emoji' {
          It 'should: report in MissingConversions' {
            InModuleScope Elizium.Loopz {
              [MarkDownEmojiConverter]$converter = New-EmojiConverter -Now $_Now -QuerySpan $OneDaySpan;
              $converter.Init();

              [string[]]$document = @(
                "This module includes a collection of commands"
                "",
                "# :blooper: Elizium.Loopz :blooper:"
              );

              [PSCustomObject]$result = $converter.Convert($document);
              $result.MissingConversions.PSBase.Count | Should -Be 1;
              $result.MissingConversions[3] -contains 'blooper' | Should -BeTrue;
              $result.TotalMissingCount | Should -Be 2;
            }
          }
        }

        Context 'and: fault on same line as valid conversion ' {
          It 'should: report in MissingConversions and convert' {
            InModuleScope Elizium.Loopz {
              [MarkDownEmojiConverter]$converter = New-EmojiConverter -Now $_Now -QuerySpan $OneDaySpan;
              $converter.Init();

              [string[]]$document = @(
                "This module includes a collection of commands"
                "",
                "# :blooper: Elizium.Loopz :sparkles:"
              );
              [string]$sparklesConversion = $($CodePointFormat -f '2728');

              [PSCustomObject]$result = $converter.Convert($document);
              $result.MissingConversions.PSBase.Count | Should -Be 1;
              $result.MissingConversions[3] -contains 'blooper' | Should -BeTrue;
              $result.Document[2].contains($sparklesConversion) | Should -BeTrue;
            }
          }
        }
      } # Missing Conversion(s)
    } # Convert (Short Code To Code Point)
  } # MarkDownEmojiConverter
} # emoji converter
