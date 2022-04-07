using module Elizium.Tez;

Describe 'Core Filters' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;

    InModuleScope Elizium.Loopz {
      $script:DefaultOptions = [FilterOptions]::new();
    }
  }

  Context "<Skip>, <Label>" {
    Context "Pass" {
      Context "given: Core <FilterClass> defined with <Arguments> and <Source>" {
        It "should: return filter <Result>" -TestCases @(
          # === NoFilter
  
          @{
            FilterClass = "NoFilter";
            Arguments   = @();
            Source      = "Northern Exposure";
            Result      = $true;
          }
  
          # === GlobFilter
  
          , @{
            FilterClass = "GlobFilter";
            Arguments   = @("*Northern*");
            Source      = "Northern Exposure";
            Result      = $true;
          }
  
          , @{
            FilterClass = "GlobFilter";
            Arguments   = @("!*Northern*");
            Source      = "Northern Exposure";
            Result      = $false;
          }
  
          , @{
            FilterClass = "GlobFilter";
            Arguments   = @("*Northern*");
            Source      = "foo";
            Result      = $false;
          }
  
          , @{
            FilterClass = "GlobFilter";
            Arguments   = @("!*Northern*");
            Source      = "bar";
            Result      = $true;
          }
  
          # === RegexFilter
  
          , @{
            FilterClass = "RegexFilter";
            Arguments   = @("Northern", "test");
            Source      = "Northern Exposure";
            Result      = $true;
          }
  
          , @{
            FilterClass = "RegexFilter";
            Arguments   = @("!Northern", "test");
            Source      = "Northern Exposure";
            Result      = $false;
          }
  
          , @{
            FilterClass = "RegexFilter";
            Arguments   = @("Northern", "test");
            Source      = "foo";
            Result      = $false;
          }
  
          , @{
            FilterClass = "RegexFilter";
            Arguments   = @("!Northern", "test");
            Source      = "bar";
            Result      = $true;
          }
        ) {
          InModuleScope Elizium.Loopz -Parameters @{
            Skip        = $Skip;
            Label       = $Label;
            FilterClass = $FilterClass;
            Arguments   = $Arguments;
            Source      = $Source;
            Result      = $Result;
          } {
            [PSCustomObject]$testInfo = [PSCustomObject]@{
              Skip  = (Test-Path variable:Skip) ? $Skip : $false;
              Label = (Test-Path variable:Label) ? $Label : [string]::Empty;
            }

            if ([tez]::accept($testInfo)) {
              # create the core filter
              #
              [array]$withArguments = $(@(, $script:DefaultOptions) + $Arguments);
              [array]$a = $($Arguments.Length -gt 0) ? $withArguments : @(, $script:DefaultOptions);
              [CoreFilter]$filter = New-Object $FilterClass $a;
              $filter | Should -Not -BeNullOrEmpty;
              $filter.Pass($Source) | Should -Be $Result -Because $(
                "'$FilterClass', source: '$Source', Arguments: '$($a)'"
              );
            }
          }
        }
      }
    } # Pass

    Context "UnaryFilter.Accept" {
      Context "given: Unary <FilterClass> defined with <Arguments>, <Scope>, <IsChild>, <IsLeaf>" {
        It "should: return filter <Result>" -TestCases @(
          @{
            FilterClass = "GlobFilter";
            Arguments   = @("*earth*");
            Scope       = "Current";
            IsChild     = $false;
            IsLeaf      = $true;
            Result      = $true;
          }

          , @{
            FilterClass = "GlobFilter";
            Arguments   = @("*neph*");
            Scope       = "Parent";
            IsChild     = $false;
            IsLeaf      = $true;
            Result      = $true;
          }

          , @{
            FilterClass = "GlobFilter";
            Arguments   = @("*earth*");
            Scope       = "Leaf";
            IsChild     = $false;
            IsLeaf      = $true;
            Result      = $true;
          }

          , @{
            FilterClass = "GlobFilter";
            Arguments   = @("*got*");
            Scope       = "Child";
            IsChild     = $true;
            IsLeaf      = $false;
            Result      = $true;
          }
        ) {
          InModuleScope Elizium.Loopz -Parameters @{
            Skip        = $Skip;
            Label       = $Label;
            FilterClass = $FilterClass;
            Arguments   = $Arguments;
            Scope       = $Scope;
            IsChild     = $IsChild;
            IsLeaf      = $IsLeaf;
            Result      = $Result;
          } {
            [PSCustomObject]$testInfo = [PSCustomObject]@{
              Skip  = (Test-Path variable:Skip) ? $Skip : $false;
              Label = (Test-Path variable:Label) ? $Label : [string]::Empty;
            }

            if ([tez]::accept($testInfo)) {
              # create the core filter
              #
              [FilterOptions]$filterOptions = [FilterOptions]::new($Scope);
              [array]$withArguments = $(@(, $filterOptions) + $Arguments);
              [array]$a = $($Arguments.Length -gt 0) ? $withArguments : @(, $filterOptions);
              [CoreFilter]$filter = New-Object $FilterClass $a;
  
              # create the unary driver filter
              #
              [FilterDriver]$driver = [UnaryFilter]::new($filter);
  
              # create a fake subject
              #
              [FilterSubject]$subject = [FilterSubject]::new([PSCustomObject]@{
                  ChildDepthLevel = 2;
                  IsChild         = $IsChild;
                  IsLeaf          = $IsLeaf;
                  Segments        = @("audio", "gothic", "nephilim", "earth inferno");
                  Value           = [PSCustomObject]@{
                    # argh! Possible optimisation would be to store segment indices
                    # instead of the string values.
                    #
                    Current = "earth inferno";
                    Parent  = "nephilim";
                    Child   = "gothic";
                    Leaf    = "earth inferno";
                  }
                });
  
              $driver | Should -Not -BeNullOrEmpty;
              $driver.Accept($subject) | Should -Be $Result -Because $(
                "Driver:'$DriverClass'/Filter: '$($filter)', Segments: '$($subject.Segments)'"
              );
            }
          }
        }
      }
    } # UnaryFilter.Accept

    Context "Compound.Accept" {
      Context "given: <DriverClass> <HandlerClass> defined with <FirstScope>/<SecondScope> - <FirstPattern>/<SecondPattern> - <IsChild>/IsLeaf" {
        InModuleScope Elizium.Loopz -Parameters @{
          Skip          = $Skip;
          Label         = $Label;
          DriverClass   = $DriverClass;
          HandlerClass  = $HandlerClass;
          FirstScope    = $FirstScope;
          SecondScope   = $SecondScope;
          FirstPattern  = $FirstPattern;
          SecondPattern = $SecondPattern;
          IsChild       = $IsChild;
          IsLeaf        = $IsLeaf;
          Result        = $Result;
        } {
          # NB: It should be noted that we can't simply create the compound filter in the data
          # driven test cases, because that would mean new-ing those classes, and as these
          # would be reference types defined during discovery phase, they would not be
          # available ar run stage, effectively resulting in dangling references. This means
          # we have to define all the primitive values here in the testcases, and construct
          # the instances from these primitives inside the implementation body of the test case.
          #
          It "should:" -TestCases @(
            ### --- [IsChild = false /IsLeaf = true] ---
            #
            @{
              DriverClass   = "CompoundFilter";
              HandlerClass  = "AllCompoundHandler";
              FirstScope    = [FilterScope]::Child;
              SecondScope   = [FilterScope]::Leaf;
              FirstPattern  = "min";
              SecondPattern = "sion";
              IsChild       = $false;
              IsLeaf        = $true;
              Result        = $true;
            }

            , @{
              DriverClass   = "CompoundFilter";
              HandlerClass  = "AllCompoundHandler";
              FirstScope    = [FilterScope]::Child;
              SecondScope   = [FilterScope]::Leaf;
              FirstPattern  = "---";
              SecondPattern = "---";
              IsChild       = $false;
              IsLeaf        = $true;              
              Result        = $false;
            }

            , @{
              DriverClass   = "CompoundFilter";
              HandlerClass  = "AllCompoundHandler";
              FirstScope    = [FilterScope]::Child;
              SecondScope   = [FilterScope]::Leaf;
              FirstPattern  = "---";
              SecondPattern = "sion";
              IsChild       = $false;
              IsLeaf        = $true;
              Result        = $false;
            }

            , @{
              DriverClass   = "CompoundFilter";
              HandlerClass  = "AllCompoundHandler";
              FirstScope    = [FilterScope]::Child;
              SecondScope   = [FilterScope]::Leaf;
              FirstPattern  = "min";
              SecondPattern = "---";
              IsChild       = $false;
              IsLeaf        = $true;
              Result        = $false;
            }

            # ===
            , @{
              DriverClass   = "CompoundFilter";
              HandlerClass  = "AnyCompoundHandler";
              FirstScope    = [FilterScope]::Child;
              SecondScope   = [FilterScope]::Leaf;
              FirstPattern  = "min";
              SecondPattern = "sion";
              IsChild       = $false;
              IsLeaf        = $true;
              Result        = $true;
            }

            , @{
              DriverClass   = "CompoundFilter";
              HandlerClass  = "AnyCompoundHandler";
              FirstScope    = [FilterScope]::Child;
              SecondScope   = [FilterScope]::Leaf;
              FirstPattern  = "---";
              SecondPattern = "---";
              IsChild       = $false;
              IsLeaf        = $true;
              Result        = $false;
            }

            , @{
              DriverClass   = "CompoundFilter";
              HandlerClass  = "AnyCompoundHandler";
              FirstScope    = [FilterScope]::Child;
              SecondScope   = [FilterScope]::Leaf;
              FirstPattern  = "---";
              SecondPattern = "sion";
              IsChild       = $false;
              IsLeaf        = $true;
              Result        = $true;
            }

            , @{
              DriverClass   = "CompoundFilter";
              HandlerClass  = "AnyCompoundHandler";
              FirstScope    = [FilterScope]::Child;
              SecondScope   = [FilterScope]::Leaf;
              FirstPattern  = "min";
              SecondPattern = "---";
              IsChild       = $false;
              IsLeaf        = $true;
              Result        = $true;  
            }

            ### --- [IsChild = true /IsLeaf = false] ---
            #
            , @{
              DriverClass   = "CompoundFilter";
              HandlerClass  = "AllCompoundHandler";
              FirstScope    = [FilterScope]::Child;
              SecondScope   = [FilterScope]::Leaf;
              FirstPattern  = "min";
              SecondPattern = "sion";
              IsChild       = $true;
              IsLeaf        = $false;
              Result        = $true;
            }

            , @{
              DriverClass   = "CompoundFilter";
              HandlerClass  = "AllCompoundHandler";
              FirstScope    = [FilterScope]::Child;
              SecondScope   = [FilterScope]::Leaf;
              FirstPattern  = "---";
              SecondPattern = "---";
              IsChild       = $true;
              IsLeaf        = $false;              
              Result        = $false;
            }

            , @{
              DriverClass   = "CompoundFilter";
              HandlerClass  = "AllCompoundHandler";
              FirstScope    = [FilterScope]::Child;
              SecondScope   = [FilterScope]::Leaf;
              FirstPattern  = "---";
              SecondPattern = "sion";
              IsChild       = $true;
              IsLeaf        = $false;
              Result        = $false;
            }

            , @{
              DriverClass   = "CompoundFilter";
              HandlerClass  = "AllCompoundHandler";
              FirstScope    = [FilterScope]::Child;
              SecondScope   = [FilterScope]::Leaf;
              FirstPattern  = "min";
              SecondPattern = "---";
              IsChild       = $true;
              IsLeaf        = $false;
              Result        = $false;
            }

            # ===

            , @{
              DriverClass   = "CompoundFilter";
              HandlerClass  = "AnyCompoundHandler";
              FirstScope    = [FilterScope]::Child;
              SecondScope   = [FilterScope]::Leaf;
              FirstPattern  = "min";
              SecondPattern = "sion";
              IsChild       = $true;
              IsLeaf        = $false;
              Result        = $true;
            }

            , @{
              DriverClass   = "CompoundFilter";
              HandlerClass  = "AnyCompoundHandler";
              FirstScope    = [FilterScope]::Child;
              SecondScope   = [FilterScope]::Leaf;
              FirstPattern  = "---";
              SecondPattern = "---";
              IsChild       = $true;
              IsLeaf        = $false;
              Result        = $false;
            }

            , @{
              DriverClass   = "CompoundFilter";
              HandlerClass  = "AnyCompoundHandler";
              FirstScope    = [FilterScope]::Child;
              SecondScope   = [FilterScope]::Leaf;
              FirstPattern  = "---";
              SecondPattern = "sion";
              IsChild       = $true;
              IsLeaf        = $false;
              Result        = $true;
            }

            , @{
              DriverClass   = "CompoundFilter";
              HandlerClass  = "AnyCompoundHandler";
              FirstScope    = [FilterScope]::Child;
              SecondScope   = [FilterScope]::Leaf;
              FirstPattern  = "min";
              SecondPattern = "---";
              IsChild       = $true;
              IsLeaf        = $false;
              Result        = $true;  
            }
          ) {
            [PSCustomObject]$testInfo = [PSCustomObject]@{
              Skip          = (Test-Path variable:Skip) ? $Skip : $false;
              Label         = (Test-Path variable:Label) ? $Label : [string]::Empty;
              Override      = $true;
              #
              DriverClass   = $DriverClass;
              HandlerClass  = $HandlerClass;
              FirstScope    = $FirstScope;
              SecondScope   = $SecondScope;
              FirstPattern  = $FirstPattern;
              SecondPattern = $SecondPattern;
              IsChild       = $IsChild;
              IsLeaf        = $IsLeaf;
              Result        = $Result;
            }

            if ([tez]::accept($testInfo)) {
              # NB: Only testing regex filters here to cut down the number of data driven
              # test case variables.
              #
              [hashtable]$handlerParams = @{
                $FirstScope  = $(New-Object RegexFilter $(
                    @([FilterOptions]::new($FirstScope), $FirstPattern, "first-test-regex"))
                );
                $SecondScope = $(New-Object RegexFilter $(
                    @([FilterOptions]::new($SecondScope), $SecondPattern, "second-test-regex"))
                );
              }

              [CompoundHandler]$handler = New-Object $HandlerClass $handlerParams;
              [CompoundFilter]$driver = [CompoundFilter]::new($handler);

              [FilterSubject]$subject = [FilterSubject]::new([PSCustomObject]@{
                  ChildDepthLevel = 2;
                  IsChild         = $IsChild;
                  IsLeaf          = $IsLeaf
                  Segments        = @("audio", "minimal", "fuse", "dimension intrusion");
                  Value           = [PSCustomObject]@{
                    Current = "dimension intrusion";
                    Parent  = "fuse";
                    Child   = "minimal";
                    Leaf    = "dimension intrusion";
                  }
                });

              $driver.Accept($subject) | Should -Be $Result -Because $(
                "ACCEPT: Driver:'$DriverClass'/Handler: '$($HandlerClass)', Segments: '$($subject.Segments)'"
              );
            }
          }
        }
      }
    } # Compound.Accept
  }
}
