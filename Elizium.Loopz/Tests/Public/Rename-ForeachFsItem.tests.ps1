using namespace System.Management.Automation;

Describe 'Rename-ForeachFsItem' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking

    Import-Module Assert;
    [boolean]$script:whatIf = $false;
  }

  Context 'TBD' -Tag 'Current' {
    Context 'given: some files' {
      It 'should: rename all' {
        [string]$sourcePath = './Tests/Data/fefsi';
        Get-ChildItem -File -Path $sourcePath -Filter  '*.txt' | `
          Rename-ForeachFsItem -File -Pattern 'data' -With 'info' -WhatIf;
      }
    }

    Context 'given: some directories' {
      It 'should: rename all' {
        [string]$sourcePath = './Tests/Data/traverse/Audio/MINIMAL/Plastikman';
        Get-ChildItem -Directory -Path $sourcePath -Filter '*e*' | `
          Rename-ForeachFsItem -Directory -Pattern 'a' -With '@' -WhatIf;
      }
    }
  }

  Context 'given: Parameter Set' {
    [string]$script:sourcePath = './Tests/Data/fefsi';
    [string]$script:filter = 'bling.*';
    [scriptblock]$script:successCondition = ( { return $true; })

    BeforeAll {
      Mock -ModuleName Elizium.Loopz Write-ThemedPairsInColour { }
      Mock -ModuleName Elizium.Loopz Write-InColour { }
    }

    Context 'is: valid' {
      Context 'MoveRelative' {
        It 'should: not throw ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -Last -Whole -Pattern 'data.' -Target 't\d{1}\.' -With 'repl' -Except 'fake' `
              -Condition $successCondition -Relation 'before' -WhatIf:$whatIf; } `
          | Should -Not -Throw;
        }
      } # MoveRelative

      Context 'MoveToStart' {
        It 'should: not throw ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -Last -Whole -Pattern 'data.' -Start -With 'repl' -Except 'fake' -Condition $successCondition `
              -WhatIf:$whatIf; } `
          | Should -Not -Throw;
        }
      } # MoveToStart

      Context 'MoveToEnd' {
        It 'should: not throw ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -Last -Whole -Pattern 'data.' -End -With 'repl' -Except 'fake' -Condition $successCondition `
              -WhatIf:$whatIf; } `
          | Should -Not -Throw;
        }
      } # MoveToEnd

      Context 'ReplaceWith' {
        It 'should: not throw ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -Last -Whole -Pattern 'data.' -With 'info.' -Except 'fake' `
              -Condition $successCondition -WhatIf:$whatIf; } `
          | Should -Not -Throw;
        }
      } # ReplaceWith

      Context 'ReplaceFirst' {
        It 'should: not throw ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -First -Quantity 2 -Whole -Pattern 'data.' -With 'info.' -Except 'fake' `
              -Condition $successCondition -WhatIf:$whatIf; } `
          | Should -Not -Throw;
        }
      } # ReplaceFirst
    } # is: valid

    Context 'is not: valid (MoveRelative)' {
      Context 'and: "Quantity" specified' {
        It 'should: throw ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -Pattern 'data.' -Target 't\d{1}\.' -Quantity 101 -WhatIf:$whatIf;
          } | Assert-Throw -ExceptionType ([ParameterBindingException]);
        }
      } # MoveToken(MoveRelative)

      Context 'and: "First" specified' {
        # Since the default behaviour of move, is to move the token after the
        # first match of the pattern, it does not need to be specified for the move token
        # operation.
        #
        It 'should: throw ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -Pattern 'data.' -Target 't\d{1}\.' -First -WhatIf:$whatIf;
          } | Assert-Throw -ExceptionType ([ParameterBindingException]);
        }
      }
    } # is not: valid

    Context 'is not: valid (MoveToStart)' {
      Context 'and: "Relation" specified' {
        It 'should: ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -Pattern 'data.' -Start -Relation 'after' -Last -Whole -Condition $successCondition -WhatIf:$whatIf; } `
          | Assert-Throw -ExceptionType ([ParameterBindingException]);
        }
      } # and: "Relation" specified

      Context 'and: "Quantity" specified' {
        It 'should: throw ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -Pattern 'data.' -Start -Quantity 101 -WhatIf:$whatIf;
          } | Assert-Throw -ExceptionType ([ParameterBindingException]);
        }
      } # and: "Quantity" specified

      Context 'and: "End" specified' {
        It 'should: throw ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -Pattern 'data.' -Start -End -WhatIf:$whatIf;
          } | Assert-Throw -ExceptionType ([ParameterBindingException]);
        }
      } # and: "End" specified

      Context 'and: "Target" specified' {
        It 'should: throw ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -Pattern 'data.' -Start -Target 't\d{1}\.' -WhatIf:$whatIf;
          } | Assert-Throw -ExceptionType ([ParameterBindingException]);
        }
      } # and: "Target" specified
    } # is not: valid (MoveToStart)

    Context 'is not: valid (MoveToEnd)' {
      Context 'and: "Relation" specified' {
        It 'should: ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -Pattern 'data.' -End -Relation 'after' -Last -Whole -Condition $successCondition -WhatIf:$whatIf; } `
          | Assert-Throw -ExceptionType ([ParameterBindingException]);
        }
      } # and: "Relation" specified

      Context 'and: "Quantity" specified' {
        It 'should: throw ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -Pattern 'data.' -End -Quantity 101 -WhatIf:$whatIf;
          } | Assert-Throw -ExceptionType ([ParameterBindingException]);
        }
      } # and: "Quantity" specified

      Context 'and: "Start" specified' {
        It 'should: throw ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -Pattern 'data.' -Start -End -WhatIf:$whatIf;
          } | Assert-Throw -ExceptionType ([ParameterBindingException]);
        }
      } # and: "Start" specified

      Context 'and: "Target" specified' {
        It 'should: throw ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -Pattern 'data.' -End -Target 't\d{1}\.' -WhatIf:$whatIf;
          } | Assert-Throw -ExceptionType ([ParameterBindingException]);
        }
      } # and: "Target" specified
    } # is not: valid (MoveToEnd)

    Context 'is not: valid (ReplaceFirst)' {
      Context 'and: "Target" specified' {
        It 'should: ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -First -Quantity 2 -Whole -Pattern 'data.' -Target 'blah' -WhatIf:$whatIf;
          } | Assert-Throw -ExceptionType ([ParameterBindingException]);
        }
      } # and: "Target" specified

      Context 'and: "Relation" specified' {
        It 'should: ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -First -Quantity 2 -Whole -Pattern 'data.' -Relation 'after' -WhatIf:$whatIf;
          } | Assert-Throw -ExceptionType ([ParameterBindingException]);
        }
      } # and: "Relation" specified

      Context 'and: "Start" specified' {
        It 'should: ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -First -Quantity 2 -Whole -Pattern 'data.' -Start -WhatIf:$whatIf;
          } | Assert-Throw -ExceptionType ([ParameterBindingException]);
        }
      } # and: "Start" specified

      Context 'and: "End" specified' {
        It 'should: ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -First -Quantity 2 -Whole -Pattern 'data.' -End -WhatIf:$whatIf;
          } | Assert-Throw -ExceptionType ([ParameterBindingException]);
        }
      } # and: "End" specified
    } # is not: valid (ReplaceFirst)

    Context 'is not: valid; given: File & Directory specified together' {
      It 'should: throw ParameterBindingException' {
        {
          Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
            -Directory -Last -Whole -Pattern 'data.' -Target 't\d{1}\.' -WhatIf:$whatIf;
        } | Assert-Throw -ExceptionType ([ParameterBindingException]);
      }
    }
  } # given: Parameter Set
} # Rename-ForeachFsItem

Describe 'RegEx comprehension' -Skip {
  Context 'Literal ([regex]::Escape("pattern"))' {
    It 'Literal' {
      [string]$source = 'hello=-=world';
      [string]$pattern = [regex]::Escape('=*=');

      [boolean]$result = $source -match $pattern;
      Write-Host ">>> Literal match result: $result";
    }

    It 'Capture' {
      [string]$source = 'date:29-jul-2008';
      [string]$pattern = '(\-)(?<cap>\w{3})(\-)';

      [boolean]$result = $source -match $pattern;
      Write-Host ">>> Literal match result: $result";

      if ($result) {
        $captured = $matches[0];
        Write-Host ">>> Captured: $captured";
        $cap = $matches['cap'];
        Write-Host ">>> <cap>: $cap";

        # How do we get the capture group name?
        # We need the following expression:
        # just look for (?<group>
        #
        $captureGroupPattern = '\(\?\<(?<groupName>\w+)\>'

        if ($pattern -match $captureGroupPattern) {
          $groupName = $matches['groupName'];
          Write-Host ">>> Capture Group: $groupName";
        }
      }      
    }

    It 'Reinsert Capture groups' {
      # How do we move 'Zorg' to moniker: -->
      # [moniker:"Zorg"]Greeting earthlings, my name is Zorg and I eat humans
      [string]$source = '[moniker:"Zorg"]Greeting earthlings, my name is  and I eat humans, code:1234';
      [string]$pattern = 'Zorg';
      [string]$capturedPattern = '(?<name>{0})' -f $pattern;

      [string]$captureGroupPattern = '\(\?\<(?<groupName>\w+)\>'

      if ($capturedPattern -match $captureGroupPattern) {
        [string]$groupName = $matches['groupName'];

        if ($source -match $capturedPattern) {
          # Let's not cheat and find out dynamically what the capture group name is:
          #
          $capturedZorg = $matches[$groupName]

          Write-Host "@@@ Captured name: '$capturedZorg'"

          [string]$patternRemovedFromSource = $source -replace $capturedPattern, '';
          [string]$target = ':"'

          Write-Host "Pattern removed from source: '$patternRemovedFromSource'";

          [string]$with = $target + $capturedZorg;
          $inserted = $patternRemovedFromSource -replace "$target", $with
 
          Write-Host ">>> INSERTED: '$inserted'";
        }
        else {
          Write-Host "!!! FAILED to capture Zorg";
        }
      } else {
        Write-Host "!!! FAILED to find the group name"
      }
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
    It 'should: invoke pipeline in a single pass' {
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
} # Rename-ForeachFsItem
