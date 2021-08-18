using namespace Elizium.Loopz;

Describe 'Convert-Emojis' -Tag 'emoji' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;

    InModuleScope -ModuleName Elizium.Loopz {
      [string]$script:_EliziumPath = $(Join-Path -Path $TestDrive -ChildPath 'elizium');
      [DateTime]$script:_Now = [DateTime]::new(2021, 2, 24, 15, 30, 45);
      [string]$script:emojiContentAsText = Get-Content -Path ".\Tests\Data\emojis\emoji-api.cache.json";
      [string]$script:emojiShortContentAsText = Get-Content -Path ".\Tests\Data\emojis\emoji-api.a-cache.json";
      [TimeSpan]$script:OneDaySpan = New-TimeSpan -Days 1;
      [string]$script:CodePointFormat = "&#x{0};";
    }
  }
 
  Describe 'Convert-Emojis' {
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
            Content           = $emojiContentAsText;
          }
        }
      }
    }
  
    Context 'given: all valid emojis' {
      Context 'and: a typical full document with emoji short code refs' {
        Context 'and: Overwrite' {
          It 'should: show results of conversion' {
            InModuleScope Elizium.Loopz {
              [string]$documentPath = Resolve-Path -Path "./Tests/Data/emojis/README-WITH-EMOJIS.md";

              [hashtable]$parameters = @{
                'Now'       = $_Now;
                'QuerySpan' = $OneDaySpan;
                'Test'      = $true;
                'WhatIf'    = $true;
              }
              Get-Item -Path $documentPath | Convert-Emojis @parameters;
            }
          }
        } # Overwrite

        Context 'and: OutputSuffix' {
          It 'should: show results of conversion' {
            InModuleScope Elizium.Loopz {
              [string]$documentPath = Resolve-Path -Path "./Tests/Data/emojis/README-WITH-EMOJIS.md";

              [hashtable]$parameters = @{
                'Now'          = $_Now;
                'QuerySpan'    = $OneDaySpan;
                'OutputSuffix' = 'converted';
                'Test'         = $true;
                'WhatIf'       = $true;
              }
              Get-Item -Path $documentPath | Convert-Emojis @parameters;
            }
          }
        } # Overwrite
      } # a typical full document with emoji short code refs
    }

    Context 'given: missing emojis' {
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

      Context 'and: a typical full document with emoji short code refs' {
        Context 'and: Overwrite' {
          It 'should: show failed results of conversion' {
            InModuleScope Elizium.Loopz {
              [string]$documentPath = Resolve-Path -Path "./Tests/Data/emojis/README-WITH-EMOJIS.md";

              [hashtable]$parameters = @{
                'Now'       = $_Now;
                'QuerySpan' = $OneDaySpan;
                'Test'      = $true;
                'WhatIf'    = $true;
              }
              Get-Item -Path $documentPath | Convert-Emojis @parameters;
            }
          }
        } # Overwrite
      }
    }
  } # Convert-Emojis
} # Convert-Emojis
