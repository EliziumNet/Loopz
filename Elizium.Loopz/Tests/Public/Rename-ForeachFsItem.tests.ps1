Describe 'Rename-ForeachFsItem' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking
  }

  Context 'given: some files' {
    It 'should: rename all' {
      Mock Move-Item {}
      [string]$sourcePath = './Tests/Data/fefsi';
      Get-ChildItem -File -Path $sourcePath -Filter '*.txt' | Rename-ForeachFsItem -File -Pattern 'data' -With 'info' -WhatIf;
    }
  }

  Context 'given: some directories' {
    It 'should: rename all' {
      Mock Move-Item {}
      [string]$sourcePath = './Tests/Data/traverse/Audio/MINIMAL/Plastikman';
      Get-ChildItem -Directory -Path $sourcePath -Filter '*e*' | Rename-ForeachFsItem -Directory -Pattern 'a' -With '@' -WhatIf;
    }
  }
}

Describe 'Fails to handle pipeline in a single pass' -Skip {
  Context 'given: pipeline variable defined as a scalar value' {
    It 'should: invoke pipeline in a single pass' {
      function invoke-first {
        param(
          [Parameter(ValueFromPipeline = $true)]
          [int]$pipelineItem
        )

        begin { Write-Host '>>> invoke-first [SCALAR] >>>'; }
        process { $pipelineItem | invoke-second }
        end { Write-Host '<<< invoke-first [SCALAR] <<<'; }
      }

      function invoke-second {
        param(
          [Parameter(ValueFromPipeline = $true)]
          [int]$pipelineItem
        )

        begin { Write-Host '>>> invoke-second [SCALAR] >>>'; }
        process { Write-Host "  [+] SECOND $($pipelineItem * 2)"; }
        end { Write-Host '<<< invoke-second [SCALAR] <<<'; }
      }
      # How to correctly 'stream' the items through in the same pipeline, instead of
      # 1 at a time, without caching the items?
      #
      1..4 | invoke-first
    }
  }

  Context 'given: pipeline variable defined as an array' {
    It 'should: invoke pipeline in a single pass' {
      function invoke-first {
        param(
          [Parameter(ValueFromPipeline = $true)]
          [int]$pipelineItem
        )

        begin { Write-Host '>>> invoke-first [ARRAY] >>>'; }
        process { $pipelineItem | invoke-second }
        end { Write-Host '<<< invoke-first [ARRAY] <<<'; }
      }

      function invoke-second {
        param(
          [Parameter(ValueFromPipeline = $true)]
          [int[]]$pipelineItem
        )

        begin { Write-Host '>>> invoke-second [ARRAY] >>>'; }
        process { Write-Host "  [+] SECOND $($pipelineItem * 2)"; }
        end { Write-Host '<<< invoke-second [ARRAY] <<<'; }
      }
      # How to correctly 'stream' the items through in the same pipeline, instead of
      # 1 at a time, without caching the items?
      #
      1..4 | invoke-first
    }
  }

  Context 'given: pipeline variable defined as a piped scalar value' {
    It 'should: invoke pipeline in a single pass' {
      function invoke-first {
        param(
          [Parameter(ValueFromPipeline = $true)]
          [int]$pipelineItem
        )

        begin { Write-Host '>>> invoke-first [PIPED-SCALAR] >>>'; }
        process { $pipelineItem }
        end { Write-Host '<<< invoke-first [PIPED-SCALAR] <<<'; }
      }

      function invoke-second {
        param(
          [Parameter(ValueFromPipeline = $true)]
          [int]$pipelineItem
        )

        begin { Write-Host '>>> invoke-second [PIPED-SCALAR] >>>'; }
        process { Write-Host "  [+] SECOND $($pipelineItem * 2)"; }
        end { Write-Host '<<< invoke-second [PIPED-SCALAR] <<<'; }
      }
      # Don't like this because invoke-second is a complicated internal function
      # that the user should not need to know about and would be cumbersome in
      # an interactive session.
      #
      1..4 | invoke-first | invoke-second
    }
  }

  Context 'given: cached pipeline variable defined as a scalar value' {
    It 'should: invoke pipeline in a single pass' -Tag 'Current' {
      function invoke-first {
        param(
          [Parameter(ValueFromPipeline = $true)]
          [int]$pipelineItem
        )
        # This method cheats, because it caches the items into a collection
        #
        begin { $coll = @(); Write-Host '>>> invoke-first [CACHED-SCALAR] >>>'; }
        process { $coll += $pipelineItem }
        end { $coll | invoke-second; Write-Host '<<< invoke-first [CACHED-SCALAR] <<<'; }
      }

      function invoke-second {
        param(
          [Parameter(ValueFromPipeline = $true)]
          [int]$pipelineItem
        )

        begin { Write-Host '>>> invoke-second [CACHED-SCALAR] >>>'; }
        process { Write-Host "  [+] SECOND $($pipelineItem * 2)"; }
        end { Write-Host '<<< invoke-second [CACHED-SCALAR] <<<'; }
      }
      1..4 | invoke-first;
    }
  }
}
