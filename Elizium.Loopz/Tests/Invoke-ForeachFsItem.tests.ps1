
Describe 'Invoke-ForeachFsItem' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking

    [scriptblock]$script:commonBlock = {
      param(
        [System.IO.FileInfo]$FileInfo,
        [int]$Index,
        [System.Collections.Hashtable]$PassThru,
        [boolean]$Trigger
      )
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
            [System.IO.FileInfo]$FileInfo,
            [int]$Index,
            [System.Collections.Hashtable]$PassThru,
            [boolean]$Trigger
          )
          $container.count++;
        }

        [string]$directoryPath = './Tests/Data/fefsi/csv';
        Get-ChildItem $directoryPath | Invoke-ForeachFsItem -body $block;
        $container.count | Should -Be 3;
      }
    }

    Context 'and: files piped from different directories' {
      It 'should: invoke all' {
        $container = @{
          count = 0
        }

        [scriptblock]$block = {
          param(
            [System.IO.FileInfo]$FileInfo,
            [int]$Index,
            [System.Collections.Hashtable]$PassThru,
            [boolean]$Trigger
          )
          $container.count++;
        }

        [string]$directoryPath = './Tests/Data/fefsi';
        Get-ChildItem $directoryPath -Recurse -Filter '*.txt' | Invoke-ForeachFsItem -body $block;
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
          [System.IO.FileInfo]$FileInfo,
          [int]$Index,
          [System.Collections.Hashtable]$PassThru,
          [boolean]$Trigger
        )
        $container.count++;
      }

      [scriptblock]$fileIsEmpty = {
        param(
          [System.IO.FileInfo]$FileInfo
        )
        return (0 -eq $FileInfo.Length)
      }

      [string]$directoryPath = './Tests/Data/fefsi';
      Get-ChildItem $directoryPath -Recurse -Filter '*.txt' | Invoke-ForeachFsItem `
        -body $block -condition $fileIsEmpty;
      $container.count | Should -Be 3;
    }
  } # given: condition provided

  Context 'given: Summary provided' {
    Context 'and: files piped from different directories' {
      It 'should: invoke all' {
        [scriptblock]$summary = {
          param(
            [int]$Count,
            [int]$Skipped,
            [boolean]$Triggered,
            [System.Collections.Hashtable]$PassThru = @{}
          )

          $Count | Should -Be 8;
          $Skipped | Should -Be 0;
          $Triggered | Should -BeFalse;
        }

        [string]$directoryPath = './Tests/Data/fefsi';
        Get-ChildItem $directoryPath -Recurse | Invoke-ForeachFsItem `
          -body $commonBlock -Summary $summary;
      }
    }

    Context 'and: files piped from different directories' {
      Context 'and: Block with Break' {
        It 'should: invoke all until Break occurs' {
          [scriptblock]$block = {
            param(
              [System.IO.FileInfo]$FileInfo,
              [int]$Index,
              [System.Collections.Hashtable]$PassThru,
              [boolean]$Trigger
            )

            if ($Index -eq 2) {
              return @{ Break = $true }
            }
          }

          [scriptblock]$summary = {
            param(
              [int]$Count,
              [int]$Skipped,
              [boolean]$Triggered,
              [System.Collections.Hashtable]$PassThru = @{}
            )

            $Count | Should -Be 3;
            $Skipped | Should -Be 5;
            $Triggered | Should -BeFalse;
          }

          [string]$directoryPath = './Tests/Data/fefsi';
          Get-ChildItem $directoryPath -Recurse | Invoke-ForeachFsItem `
            -body $block -Summary $summary;
        }
      } # and: Block with Break

      Context 'and: Triggered entry' {
        It 'should: invoke all' {
          [scriptblock]$block = {
            param(
              [System.IO.FileInfo]$FileInfo,
              [int]$Index,
              [System.Collections.Hashtable]$PassThru,
              [boolean]$Trigger
            )

            if ($Index -eq 2) {
              return @{ Trigger = $true }
            }
          }

          [scriptblock]$summary = {
            param(
              [int]$Count,
              [int]$Skipped,
              [boolean]$Triggered,
              [System.Collections.Hashtable]$PassThru = @{}
            )

            $Triggered | Should -BeTrue;
          }

          [string]$directoryPath = './Tests/Data/fefsi';
          Get-ChildItem $directoryPath -Recurse | Invoke-ForeachFsItem `
            -body $block -Summary $summary;
        }
      } # and: Triggered entry

      Context 'With PassThru' {
        It 'should: invoke all and properties passed through (via PassThru)' {
          [scriptblock]$block = {
            param(
              [System.IO.FileInfo]$FileInfo,
              [int]$Index,
              [System.Collections.Hashtable]$PassThru,
              [boolean]$Trigger
            )

            $PassThru['Action'] | Should -BeExactly 'Disconnect';
            $PassThru['Answer'] = 'Fourty Two';
          }

          [scriptblock]$summary = {
            param(
              [int]$Count,
              [int]$Skipped,
              [boolean]$Triggered,
              [System.Collections.Hashtable]$PassThru = @{}
            )
            $PassThru['Answer'] | Should -BeExactly 'Fourty Two';
          }

          [System.Collections.Hashtable]$passThru = @{
            'Action' = 'Disconnect'
          }

          [string]$directoryPath = './Tests/Data/fefsi';
          Get-ChildItem $directoryPath -Recurse | Invoke-ForeachFsItem `
            -body $block -Summary $summary -PassThru $passThru;
        }
      } # With PassThru
    } # and: files piped from different directories
  } # given: Summary provided

  Context 'given: invoke named function' {
    Context 'and: files piped from different directories' {
      It 'should: send objects out of the pipeline' -Tag 'Current' {
        Mock -ModuleName Elizium.Loopz invoke-Dummy -Verifiable {
          param(
            [Alias('Underscore')]
            [System.IO.FileInfo]$FileInfo,
            [int]$Index,
            [System.Collections.Hashtable]$PassThru,
            [boolean]$Trigger
          )

          [PSCustomObject]@{ Product = $FileInfo; }
        }
        [System.IO.FileInfo[]]$collection = @();
        [string]$directoryPath = './Tests/Data/fefsi';

        Get-ChildItem $directoryPath -Recurse | Invoke-ForeachFsItem -Functee 'invoke-Dummy' | ForEach-Object {
          $collection += $_;
        }

        $collection.Length | Should -Be 8;
        Assert-MockCalled invoke-Dummy -ModuleName Elizium.Loopz -Times $collection.Length;
      }
    }
  } # given: invoke named function
} # Invoke-ForeachFsItem
