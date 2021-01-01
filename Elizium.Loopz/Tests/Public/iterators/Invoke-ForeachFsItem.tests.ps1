
Describe 'Invoke-ForeachFsItem' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking

    [scriptblock]$script:commonBlock = {
      param(
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
        [System.IO.FileInfo]$FileInfo,
        [int]$Index,
        [hashtable]$Exchange,
        [boolean]$Trigger
      )

      @{ Product = $FileInfo; }
    }
  }

  Context 'given: condition NOT provided' {
    Context 'and: files piped from same directory' {
      It 'should: invoke all' {
        $container = @{
          count = 0
        }

        [scriptblock]$block = {
          param(
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
            [System.IO.FileInfo]$FileInfo,
            [int]$Index,
            [hashtable]$Exchange,
            [boolean]$Trigger
          )
          $container.count++;
        }

        [string]$directoryPath = './Tests/Data/fefsi/csv';
        Get-ChildItem $directoryPath -File | Invoke-ForeachFsItem -Block $block;
        $container.count | Should -Be 3;
      }
    }

    Context 'and: files piped from same directory' {
      It 'should: contain correct count value in Exchange' {
        $container = @{
          count = 0
        }

        [scriptblock]$block = {
          param(
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
            [System.IO.FileInfo]$FileInfo,
            [int]$Index,
            [hashtable]$Exchange,
            [boolean]$Trigger
          )
          $container.count++;
        }

        [string]$directoryPath = './Tests/Data/fefsi/csv';
        [hashtable]$verifiedCountPassThru = @{}
        Get-ChildItem $directoryPath -File | Invoke-ForeachFsItem -Block $block -Exchange $verifiedCountPassThru;
        $container.count | Should -Be 3;
        $verifiedCountPassThru['LOOPZ.FOREACH.COUNT'] | Should -Be 3;
      }
    }

    Context 'and: no files found' {
      It 'should: contain 0 count value in Exchange' {
        $container = @{
          count = 0
        }

        [scriptblock]$block = {
          param(
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
            [System.IO.FileInfo]$FileInfo,
            [int]$Index,
            [hashtable]$Exchange,
            [boolean]$Trigger
          )
          $container.count++;
        }

        [string]$directoryPath = './Tests/Data/fefsi/csv';
        [hashtable]$verifiedCountPassThru = @{}
        Get-ChildItem $directoryPath -File -Filter '*.blob' | Invoke-ForeachFsItem -Block $block -Exchange $verifiedCountPassThru;
        $container.count | Should -Be 0;
        $verifiedCountPassThru['LOOPZ.FOREACH.COUNT'] | Should -Be 0;
      }
    }

    Context 'and: files piped from different directories' {
      It 'should: invoke all' {
        $container = @{
          count = 0
        }

        [scriptblock]$block = {
          param(
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
            [System.IO.FileInfo]$FileInfo,
            [int]$Index,
            [hashtable]$Exchange,
            [boolean]$Trigger
          )
          $container.count++;
        }

        [string]$directoryPath = './Tests/Data/fefsi';
        Get-ChildItem $directoryPath -Recurse -Filter '*.txt' -File | Invoke-ForeachFsItem -Block $block;
        $container.count | Should -Be 4;
      }
    }
  } # given: condition NOT provided

  Context 'given: condition provided' {
    It 'should: invoke only when condition is satisfied' {
      $container = @{
        count = 0
      }

      [scriptblock]$block = {
        param(
          [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
          [System.IO.FileInfo]$FileInfo,
          [int]$Index,
          [hashtable]$Exchange,
          [boolean]$Trigger
        )
        $container.count++;

        @{ Product = $FileInfo; }
      }

      [scriptblock]$fileIsEmpty = {
        param(
          [System.IO.FileInfo]$FileInfo
        )
        return (0 -eq $FileInfo.Length)
      }

      [string]$directoryPath = './Tests/Data/fefsi';
      Get-ChildItem $directoryPath -Recurse -Filter '*.txt' -File | Invoke-ForeachFsItem `
        -Block $block -condition $fileIsEmpty;
      $container.count | Should -Be 3;
    }
  } # given: condition provided

  Context 'given: Summary provided' {
    Context 'and: files piped from different directories' {
      It 'should: invoke all' {
        [scriptblock]$summary = {
          [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
          param(
            [int]$Count,
            [int]$Skipped,
            [boolean]$Triggered,
            [hashtable]$Exchange = @{}
          )

          $Count | Should -Be 8;
          $Skipped | Should -Be 0;
          $Triggered | Should -BeFalse;
        }

        [string]$directoryPath = './Tests/Data/fefsi';
        Get-ChildItem $directoryPath -Recurse -File | Invoke-ForeachFsItem `
          -Block $commonBlock -Summary $summary;
      }
    }

    Context 'and: files piped from different directories' {
      Context 'and: Block with Break' {
        It 'should: invoke all until Break occurs' {
          [scriptblock]$block = {
            [OutputType([PSCustomObject])]
            param(
              [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
              [System.IO.FileInfo]$FileInfo,
              [int]$Index,
              [hashtable]$Exchange,
              [boolean]$Trigger
            )

            if ($Index -eq 2) {
              @{ Product = $FileInfo; Break = $true }
            }
            else {
              @{ Product = $FileInfo; }
            }
          }

          [scriptblock]$summary = {
            param(
              [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
              [int]$Count,
              [int]$Skipped,
              [boolean]$Triggered,
              [hashtable]$Exchange = @{}
            )

            $Count | Should -Be 3;
            $Skipped | Should -Be 5;
            $Triggered | Should -BeFalse;
          }

          [string]$directoryPath = './Tests/Data/fefsi';
          Get-ChildItem $directoryPath -Recurse -File | Invoke-ForeachFsItem `
            -Block $block -Summary $summary;
        }
      } # and: Block with Break

      Context 'and: Triggered entry' {
        It 'should: invoke all' {
          [scriptblock]$block = {
            param(
              [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
              [System.IO.FileInfo]$FileInfo,
              [int]$Index,
              [hashtable]$Exchange,
              [boolean]$Trigger
            )

            if ($Index -eq 2) {
              return @{ Trigger = $true }
            }
          }

          [scriptblock]$summary = {
            param(
              [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
              [int]$Count,
              [int]$Skipped,
              [boolean]$Triggered,
              [hashtable]$Exchange = @{}
            )

            $Triggered | Should -BeTrue;
          }

          [string]$directoryPath = './Tests/Data/fefsi';
          Get-ChildItem $directoryPath -Recurse -File | Invoke-ForeachFsItem `
            -Block $block -Summary $summary;
        }
      } # and: Triggered entry

      Context 'With Exchange' {
        It 'should: invoke all and properties passed through (via Exchange)' {
          [scriptblock]$block = {
            param(
              [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
              [System.IO.FileInfo]$FileInfo,
              [int]$Index,
              [hashtable]$Exchange,
              [boolean]$Trigger
            )

            $Exchange['Action'] | Should -BeExactly 'Disconnect';
            $Exchange['Answer'] = 'Fourty Two';
          }

          [scriptblock]$summary = {
            param(
              [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
              [int]$Count,
              [int]$Skipped,
              [boolean]$Triggered,
              [hashtable]$Exchange = @{}
            )
            $Exchange['Answer'] | Should -BeExactly 'Fourty Two';
          }

          [hashtable]$exchange = @{
            'Action' = 'Disconnect'
          }

          [string]$directoryPath = './Tests/Data/fefsi';
          Get-ChildItem $directoryPath -Recurse -File | Invoke-ForeachFsItem `
            -Block $block -Summary $summary -Exchange $exchange;
        }
      } # With Exchange
    } # and: files piped from different directories
  } # given: Summary provided

  Context 'given: invoke named function' {
    Context 'and: files piped from different directories' {
      It 'should: send objects out of the pipeline' {
        function global:invoke-Dummy {
          [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
          [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
          param(
            [Alias('Underscore')]
            [System.IO.FileInfo]$FileInfo,
            [int]$Index,
            [hashtable]$Exchange,
            [boolean]$Trigger
          )
          Write-Warning "These aren't the droids you're looking for, ..., move along, move along!";

          [PSCustomObject]@{ Product = $FileInfo; }
        }

        Mock -ModuleName Elizium.Loopz invoke-Dummy -Verifiable {
          param(
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
            [Alias('Underscore')]
            [System.IO.FileInfo]$FileInfo,
            [int]$Index,
            [hashtable]$Exchange,
            [boolean]$Trigger
          )

          @{ Product = $FileInfo; }
        }
        [System.IO.FileInfo[]]$collection = @();
        [string]$directoryPath = './Tests/Data/fefsi';

        Get-ChildItem $directoryPath -Recurse -File | Invoke-ForeachFsItem -Functee 'invoke-Dummy' | ForEach-Object {
          $collection += $_;
        }

        $collection.Length | Should -Be 8;
        Assert-MockCalled invoke-Dummy -ModuleName Elizium.Loopz -Times $collection.Length;
      }
    }
  } # given: invoke named function

  Context 'given: invoke named function with additional param(s)' {
    Context 'and: files piped from different directories' {
      It 'should: send objects out of the pipeline' {

        function global:Test-FileResult {
          [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
          param(
            [Parameter(Mandatory)]
            [System.IO.FileInfo]$Underscore,

            [Parameter(Mandatory)]
            [int]$Index,

            [Parameter(Mandatory)]
            [hashtable]$Exchange,

            [Parameter(Mandatory)]
            [boolean]$Trigger,

            [Parameter(Mandatory)]
            [string]$Format
          )

          [string]$result = $Format -f ($Underscore.Name);
          Write-Debug "Custom function; Test-FileResult: '$result'";
          @{ Product = $Underscore }
        }

        Mock -ModuleName Elizium.Loopz Test-FileResult -Verifiable {
          param(
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
            [System.IO.FileInfo]$Underscore,
            [int]$Index,
            [hashtable]$Exchange,
            [boolean]$Trigger,
            [string]$Format
          )
          [string]$result = $Format -f ($Underscore.Name);
          Write-Debug "Mocked Custom function; Test-FileResult: '$result'";
          @{ Product = $Underscore; }
        }
        [System.IO.FileInfo[]]$collection = @();
        [string]$directoryPath = './Tests/Data/fefsi';

        [hashtable]$parameters = @{
          'Format' = '*** [{0}] ***'
        }

        Get-ChildItem $directoryPath -Recurse -File | Invoke-ForeachFsItem -Functee 'Test-FileResult' `
          -FuncteeParams $parameters | ForEach-Object {
          $collection += $_;
        }

        $collection.Length | Should -Be 8;
        Assert-MockCalled Test-FileResult -ModuleName Elizium.Loopz -Times $collection.Length;
      }
    }
  } # given: invoke named function with additional param(s)

  Context 'given: File flag specified' {
    Context 'and: files piped from same directory' {
      It 'should: invoke all' {
        $container = @{
          count = 0
        }

        [scriptblock]$block = {
          param(
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
            [System.IO.FileInfo]$FileInfo,
            [int]$Index,
            [hashtable]$Exchange,
            [boolean]$Trigger
          )
          $container.count++;

          @{ Product = $FileInfo }
        }

        [string]$directoryPath = './Tests/Data/fefsi/csv';
        Get-ChildItem $directoryPath | Invoke-ForeachFsItem -Block $block -File;
        $container.count | Should -Be 3;
      }
    } # and: files piped from same directory

    Context 'and: files and directories piped from same directory' {
      It 'should: invoke all' {
        $container = @{
          count = 0
        }

        [scriptblock]$block = {
          param(
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
            [System.IO.FileInfo]$FileInfo,
            [int]$Index,
            [hashtable]$Exchange,
            [boolean]$Trigger
          )
          $container.count++;

          @{ Product = $FileInfo }
        }

        [string]$directoryPath = './Tests/Data/fefsi';
        Get-ChildItem $directoryPath | Invoke-ForeachFsItem -Block $block -File;
        $container.count | Should -Be 5;
      }
    } # and: files piped from same directory
  } # given: File flag specified

  Context 'given: Directory flag specified' {
    Context 'and: single directory piped' {
      It 'should: invoke all' {
        $container = @{
          count = 0
        }

        [scriptblock]$block = {
          param(
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
            [System.IO.DirectoryInfo]$DirInfo,
            [int]$Index,
            [hashtable]$Exchange,
            [boolean]$Trigger
          )
          $container.count++;

          @{ Product = $DirInfo }
        }

        [string]$directoryPath = './Tests/Data/fefsi';
        Get-ChildItem $directoryPath | Invoke-ForeachFsItem -Block $block -Directory;
        $container.count | Should -Be 1;
      }
    } # and: single directory piped
  } # given: Directory flag specified

  Context 'given: scriptblock with additional custom parameters' {
    It 'should: invoke scriptblock with additional parameters' {
      $container = @{
        count = 0
      }

      [scriptblock]$block = {
        param(
          [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
          [System.IO.DirectoryInfo]$DirInfo,
          [int]$Index,
          [hashtable]$Exchange,
          [boolean]$Trigger,
          [string]$Format
        )
        $container.count++;
        [string]$result = $Format -f ($DirInfo.Name);
        Write-Debug "*** Custom block: '$result'";
        @{ Product = $DirInfo }
      }

      [string]$directoryPath = './Tests/Data/fefsi';
      $parameters = , @("!!! {0} !!!");
      Get-ChildItem $directoryPath | Invoke-ForeachFsItem `
        -Block $block -BlockParams $parameters -Directory;
      $container.count | Should -Be 1;
    }
  }
} # Invoke-ForeachFsItem
