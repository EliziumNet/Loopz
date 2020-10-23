using namespace System.Management.Automation;

Describe 'Rename-ForeachFsItem' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking

    Import-Module Assert;
    [boolean]$script:whatIf = $false;
    [string]$script:directoryPath = './Tests/Data/fefsi/';

    Mock -ModuleName Elizium.Loopz rename-FsItem {
      param(
        [System.IO.FileSystemInfo]$From,
        [string]$To,
        [System.Collections.Hashtable]$Undo,
        $Shell,
        [switch]$WhatIf
      )
      # This mock result works only because the actual returned FileSystemInfo returned
      # does not drive any control logic.
      #
      return $From;
    }
  }

  # TODO: all the patterns must be updated to include the option occurrence value
  # Get rid of First/Last, this is now part of the Pattern definitions

  Context 'given: MoveRelative' {
    Context 'and: TargetType is Anchor' {
      Context 'and Relation is Before' {
        Context 'and: Source matches Pattern' {
          Context 'and: Source matches Anchor' {
            It 'should: do rename; move Pattern match before target' {
              Get-ChildItem -File -Path $directoryPath | Rename-ForeachFsItem -File `
                -Pattern 'data.' -Anchor 'loopz' -Relation 'before' -WhatIf;
            }
          } # and: Source matches Anchor

          Context 'and: Whole Pattern' {
            It 'should: do rename; move Pattern match before target' {
              Get-ChildItem -File -Path $directoryPath | Rename-ForeachFsItem -File `
                -Pattern 'data' -Anchor 'loopz' -Relation 'before' -Whole p -WhatIf;
            }
          }

          Context 'and: Source does not match Anchor' {
            It 'should: NOT do rename' {
              Get-ChildItem -File -Path $directoryPath | Rename-ForeachFsItem -File `
                -Pattern 'data.' -Anchor 'blooper' -Relation 'before' -WhatIf;
            }
          }
        } # and: Source matches Pattern
      } # and Relation is Before

      Context 'and Relation is After' {
        Context 'and: Source matches Pattern' {
          Context 'and: Source matches Anchor' {
            It 'should: do rename; move Pattern match after target' {
              Get-ChildItem -File -Path $directoryPath | Rename-ForeachFsItem -File `
                -Pattern 'loopz.' -Anchor 'data.' -Relation 'after' -WhatIf;
            }

            Context 'and: Whole Anchor' {
              It 'should: do rename; move Pattern match after target' {
                Get-ChildItem -File -Path $directoryPath | Rename-ForeachFsItem -File `
                  -Pattern 'loopz.' -Anchor 'data' -Relation 'after' -Whole a -WhatIf;
              }
            }
          } # and: Source matches Anchor

          # Context 'and: Source matches Anchor which needs escape' {
          #   # use Literal t (eg, `+^$.,-?()[]{}` are all allowed in win-fs, but are regex characters that needs escape)
          #   It 'should: ' {
          #     Write-Host "NOT-IMPLEMENTED YET"
          #   }
          # }

          Context 'and: Source does not match Anchor' {
            It 'should: NOT do rename' {
              Get-ChildItem -File -Path $directoryPath | Rename-ForeachFsItem -File `
                -Pattern 'loopz.' -Anchor 'blooper' -Relation 'after' -WhatIf;
            }
          }
        } # and: Source matches Pattern
      } # and Relation is After
    } # and: TargetType is Anchor
  } # given: MoveRelative

  Context 'given: MoveToStart' {
    Context 'and: Source matches Pattern in middle' {
      It 'should: do rename; move Pattern match to start' {
        Get-ChildItem -Path $directoryPath -Filter '*.txt' | Rename-ForeachFsItem -File `
          -Pattern 'data.' -Start -WhatIf;
      }
    } # and: Source matches Pattern in middle

    Context 'and: Source matches Pattern already at start' {
      It 'should: NOT do rename' {
        Get-ChildItem -Path $directoryPath -Filter '*.txt' | Rename-ForeachFsItem -File `
          -Pattern 'loopz.' -Start -WhatIf;
      }
    } # and: Source matches Pattern in middle
  } # given: MoveToStart

  Context 'given: MoveToEnd' {
    Context 'and: Source matches Pattern in middle' {
      It 'should: do rename; move Pattern match to end' {
        Get-ChildItem -Path $directoryPath -File | Rename-ForeachFsItem -File `
          -Pattern '.data' -End -WhatIf;
      }
    }

    Context 'and: Source matches Pattern already at end' {
      It 'should: NOT do rename' {
        Get-ChildItem -Path $directoryPath | Rename-ForeachFsItem -File `
          -Pattern 't1' -End -WhatIf;
      }
    } # and: Source matches Pattern in middle
  } # given: MoveToEnd

  Context 'given: ReplaceWith' {
    Context 'and: Source matches Pattern' {
      Context 'and: With is non-regex static text' {
        Context 'and: First Only' {
          It 'should: do rename; replace First Pattern for With text' {
            Get-ChildItem -Path $directoryPath | Rename-ForeachFsItem -File `
              -Pattern 'a', f -With '@' -WhatIf;
          }
        } # and: First Only

        Context 'and: replace 3rd match' {
          It 'should: do rename; replace 3rd Occurrence for With text' {
            Get-ChildItem -Path $directoryPath | Rename-ForeachFsItem -File `
              -Quantity 2 -Pattern 'o', 6 -With '0' -WhatIf;
          }
        } # and: First 2 Only

        Context 'and: Last Only' {
          It 'should: do rename; replace Last Pattern for With text' {
            Get-ChildItem -Path $directoryPath | Rename-ForeachFsItem -File `
              -Pattern 'a', l -LiteralWith '@' -WhatIf;
          }
        } # and: Last Only
      }

      Context 'and: With is regex' {
        Context 'and: Whole With' {
          It 'should: do rename; replace First Pattern for With text' {
            Get-ChildItem -Path $directoryPath | Rename-ForeachFsItem -File `
              -Pattern 'a', f -With 't\d' -Whole w -WhatIf;
          }
        }
      }

      Context 'and: With contains static text that needs escape' {
        Context 'and: First Only' {
          It 'should: do rename; replace First Pattern for With text' {
            Write-Host "should: do rename; replace First Pattern for With text: NOT-IMPLEMENTED YET"
          }
        }
      }

      Context 'and: Except' {
        Context 'and: Source matches Pattern' {
          It 'should: do rename; replace Last Pattern for With text' {
            Get-ChildItem -Path $directoryPath | Rename-ForeachFsItem -File `
              -Pattern 'loopz' -Except 'data' -With 'h00pz' -WhatIf;
          }
        }
      } # and: Except

      Context 'and: Source denotes Directories' {
        It 'should: do rename; replace First Pattern for With text' {
          [string]$plastikmanPath = './Tests/Data/traverse/Audio/MINIMAL/Plastikman';

          Get-ChildItem -Path $plastikmanPath | Rename-ForeachFsItem -Directory `
            -Pattern 'e' -With '3' -WhatIf;
        }
      }
    } # and: Source matches Pattern
  } # given: ReplaceWith

  Context 'given: Parameter Set' -Skip -Tag 'Reason: parameter sets need to be re-defined' {
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
              -Last -Whole p -Pattern 'data.' -Anchor 't\d{1}\.' -With 'repl' -Except 'fake' `
              -Condition $successCondition -Relation 'before' -WhatIf:$whatIf; } `
          | Should -Not -Throw;
        }
      } # MoveRelative

      Context 'MoveToStart' {
        It 'should: not throw ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -Last -Whole p -Pattern 'data.' -Start -With 'repl' -Except 'fake' -Condition $successCondition `
              -WhatIf:$whatIf; } `
          | Should -Not -Throw;
        }
      } # MoveToStart

      Context 'MoveToEnd' {
        It 'should: not throw ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -Last -Whole p -Pattern 'data.' -End -With 'repl' -Except 'fake' -Condition $successCondition `
              -WhatIf:$whatIf; } `
          | Should -Not -Throw;
        }
      } # MoveToEnd

      Context 'ReplaceWith' {
        It 'should: not throw ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -Last -Whole p -Pattern 'data.' -With 'info.' -Except 'fake' `
              -Condition $successCondition -WhatIf:$whatIf; } `
          | Should -Not -Throw;
        }
      } # ReplaceWith

      Context 'ReplaceFirst' {
        It 'should: not throw ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -First -Quantity 2 -Whole p -Pattern 'data.' -With 'info.' -Except 'fake' `
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
              -Pattern 'data.' -Anchor 't\d{1}\.' -Quantity 101 -WhatIf:$whatIf;
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
              -Pattern 'data.' -Anchor 't\d{1}\.' -First -WhatIf:$whatIf;
          } | Assert-Throw -ExceptionType ([ParameterBindingException]);
        }
      }
    } # is not: valid

    Context 'is not: valid (MoveToStart)' {
      Context 'and: "Relation" specified' {
        It 'should: ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -Pattern 'data.' -Start -Relation 'after' -Last -Whole p -Condition $successCondition -WhatIf:$whatIf; } `
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

      Context 'and: "Anchor" specified' {
        It 'should: throw ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -Pattern 'data.' -Start -Anchor 't\d{1}\.' -WhatIf:$whatIf;
          } | Assert-Throw -ExceptionType ([ParameterBindingException]);
        }
      } # and: "Anchor" specified
    } # is not: valid (MoveToStart)

    Context 'is not: valid (MoveToEnd)' {
      Context 'and: "Relation" specified' {
        It 'should: ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -Pattern 'data.' -End -Relation 'after' -Last -Whole p -Condition $successCondition -WhatIf:$whatIf; } `
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

      Context 'and: "Anchor" specified' {
        It 'should: throw ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -Pattern 'data.' -End -Anchor 't\d{1}\.' -WhatIf:$whatIf;
          } | Assert-Throw -ExceptionType ([ParameterBindingException]);
        }
      } # and: "Anchor" specified
    } # is not: valid (MoveToEnd)

    Context 'is not: valid (ReplaceFirst)' {
      Context 'and: "Anchor" specified' {
        It 'should: ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -First -Quantity 2 -Whole p -Pattern 'data.' -Anchor 'blah' -WhatIf:$whatIf;
          } | Assert-Throw -ExceptionType ([ParameterBindingException]);
        }
      } # and: "Anchor" specified

      Context 'and: "Relation" specified' {
        It 'should: ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -First -Quantity 2 -Whole p -Pattern 'data.' -Relation 'after' -WhatIf:$whatIf;
          } | Assert-Throw -ExceptionType ([ParameterBindingException]);
        }
      } # and: "Relation" specified

      Context 'and: "Start" specified' {
        It 'should: ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -First -Quantity 2 -Whole p -Pattern 'data.' -Start -WhatIf:$whatIf;
          } | Assert-Throw -ExceptionType ([ParameterBindingException]);
        }
      } # and: "Start" specified

      Context 'and: "End" specified' {
        It 'should: ParameterBindingException' {
          {
            Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
              -First -Quantity 2 -Whole p -Pattern 'data.' -End -WhatIf:$whatIf;
          } | Assert-Throw -ExceptionType ([ParameterBindingException]);
        }
      } # and: "End" specified
    } # is not: valid (ReplaceFirst)

    Context 'is not: valid; given: File & Directory specified together' {
      It 'should: throw ParameterBindingException' {
        {
          Get-ChildItem -File -Path $sourcePath -Filter $filter | Rename-ForeachFsItem -File `
            -Directory -Last -Whole p -Pattern 'data.' -Anchor 't\d{1}\.' -WhatIf:$whatIf;
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
      }
      else {
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
