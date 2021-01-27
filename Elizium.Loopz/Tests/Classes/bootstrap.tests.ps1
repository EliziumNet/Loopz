
Describe 'Bootstrap' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;

    InModuleScope Elizium.Loopz {
      [hashtable]$script:_signals = Get-Signals;
      [hashtable]$script:_theme = Get-KrayolaTheme;
    }
  }

  BeforeEach {
    InModuleScope Elizium.Loopz {
      [hashtable]$exchange = @{}
      [PSCustomObject]$script:_containers = @{
        Wide  = [line]::new();
        Props = [line]::new();
      }
      
      [PSCustomObject]$options = [PSCustomObject]@{
      }
      [bootstrap]$script:_bootStrapper = [bootstrap]::new($exchange,
        $_containers, $_signals, $_theme, $options);

      [string]$script:_patternExpression = '\d{2,3}';
      [PSCustomObject]$script:_patternSpec = [PSCustomObject]@{
        Activate       = $true;
        SpecType       = 'regex';
        Name           = 'Pattern';
        Value          = $($_patternExpression, 1);
        Signal         = 'PATTERN';
        WholeSpecifier = 'p';
        Force          = 'Props';
        RegExKey       = 'LOOPZ.REMY.PATTERN-REGEX';
        OccurrenceKey  = 'LOOPZ.REMY.PATTERN-OCC';
      }
    }
  }

  Context 'given: exchange' {
    Context 'and: formatter entity' {
      It 'should: bind formatter' {
        InModuleScope Elizium.Loopz {
          [PSCustomObject]$pasteSpec = [PSCustomObject]@{
            Activate    = $true;
            SpecType    = 'formatter';
            Name        = 'Paste';
            Signal      = 'PASTE-A';
            SignalValue = '${_a}, __${name}__';
            Force       = 'Props';
            Keys = @{
              'LOOPZ.REMY.PASTE' = '${_a}, __${name}__';
            }
          }
          $_bootStrapper.Register($pasteSpec);

          [hashtable]$exchange = $_bootStrapper.Build(@());
          $exchange.ContainsKey('LOOPZ.REMY.PASTE') | Should -BeTrue;
          $_containers.Props.Line.Count | Should -Be 1;
          $_containers.Wide.Line.Count | Should -Be 0;
        }
      }

      It 'should: bind formatter' {
        InModuleScope Elizium.Loopz {
          [PSCustomObject]$dropSpec = [PSCustomObject]@{
            Activate    = $true;
            SpecType    = 'formatter';
            Name        = 'Drop';
            Signal      = 'REMY.DROP';
            SignalValue = 'clanger';
            Force       = 'Wide';
            Keys        = @{
              'LOOPZ.REMY.DROP' = 'clanger';
              'LOOPZ.REMY.MARKER' = $Loopz.Defaults.Remy.Marker;
            }
          }
          $_bootStrapper.Register($dropSpec);

          [hashtable]$exchange = $_bootStrapper.Build(@());
          $exchange.ContainsKey('LOOPZ.REMY.DROP') | Should -BeTrue;
          $exchange.ContainsKey('LOOPZ.REMY.MARKER') | Should -BeTrue;

          $_containers.Props.Line.Count | Should -Be 0;
          $_containers.Wide.Line.Count | Should -Be 1;
        }
      }
    }

    Context 'and: regex entity' {
      It 'should: bind regex' {
        InModuleScope Elizium.Loopz {
          $_bootStrapper.Register($_patternSpec);

          [hashtable]$exchange = $_bootStrapper.Build(@());
          $exchange.ContainsKey('LOOPZ.REMY.PATTERN-REGEX') | Should -BeTrue;
          $exchange.ContainsKey('LOOPZ.REMY.PATTERN-OCC') | Should -BeTrue;

          $_containers.Props.Line.Count | Should -Be 1;
          $_containers.Wide.Line.Count | Should -Be 0;
        }
      }

      Context 'and: Derived Regex' {
        It 'should: bind derived regex' -Tag 'FLAKY' {
          InModuleScope Elizium.Loopz {
            # NB: Derived Regex doesn't have to have a signal defined
            #
            [PSCustomObject]$derivedSpec = [PSCustomObject]@{
              Activate      = $true;
              SpecType      = 'regex';
              Dependency    = 'Pattern'
              Name          = 'Anchored';
              Value         = '^*{_dependency}';
              RegExKey      = 'LOOPZ.REMY.ANCHORED-REGEX';
              OccurrenceKey = 'LOOPZ.REMY.ANCHORED-OCC';
            }
            $_bootStrapper.Register($_patternSpec);
            $_bootStrapper.Register($derivedSpec);

            [hashtable]$exchange = $_bootStrapper.Build(@());
            $exchange.ContainsKey('LOOPZ.REMY.ANCHORED-REGEX') | Should -BeTrue;
            $exchange.ContainsKey('LOOPZ.REMY.ANCHORED-OCC') | Should -BeTrue;

            $_containers.Props.Line.Count | Should -Be 1;
            $_containers.Wide.Line.Count | Should -Be 0;

            [RegexEntity]$derived = $_bootStrapper.Get('Anchored');
            $derived.Regex.ToString() | Should -BeExactly "^$_patternExpression";
          }
        }
      }
    } # and: regex entity

    Context 'and: signal entity' {
      It 'should: bind signal' {
        InModuleScope Elizium.Loopz {
          [PSCustomObject]$signalSpec = [PSCustomObject]@{
            Activate    = $true;
            SpecType    = 'signal';
            Name        = 'Start';
            Value       = $true;
            Signal      = 'REMY.ANCHOR';
            SignalValue = $_signals['SWITCH-ON'].Value;
            CustomLabel = 'Start';
            Force       = 'Props';
            Keys        = @{
              'LOOPZ.REMY.ANCHOR-TYPE' = 'START';
            }
          }
          $_bootStrapper.Register($signalSpec);

          [hashtable]$exchange = $_bootStrapper.Build(@());
          $exchange.ContainsKey('LOOPZ.REMY.ANCHOR-TYPE') | Should -BeTrue;

          $_containers.Props.Line.Count | Should -Be 1;
          $_containers.Wide.Line.Count | Should -Be 0;
        }
      }

      It 'should: bind signal' -Skip -Tag 'UNDER CONSTRUCTION' {
        InModuleScope Elizium.Loopz {
          # [PSCustomObject]$cutSpec = [PSCustomObject]@{ # SignalParam?
          #   Activate    = $doCut;
          #   Signal      = 'CUT-A';
          #   SignalValue = $signals['SWITCH-ON'].Value;
          #   Force       = 'Props';
          # }
        }
      }
    } # and: signal entity

    Context 'and: simple entity' {
      It 'should: bind regex' {
        InModuleScope Elizium.Loopz {
          [PSCustomObject]$simpleSpec = [PSCustomObject]@{
            Activate = $true;
            SpecType = 'simple';
            Name     = 'Relation';
            Value    = 'before';
            Keys     = @{
              'LOOPZ.REMY.RELATION' = 'before';
            }
          }
          $_bootStrapper.Register($simpleSpec);
          [hashtable]$exchange = $_bootStrapper.Build(@());
          $exchange.ContainsKey('LOOPZ.REMY.RELATION') | Should -BeTrue;

          $_containers.Props.Line.Count | Should -Be 0;
          $_containers.Wide.Line.Count | Should -Be 0;
        }
      }
    } # and: simple entity
  }
}
