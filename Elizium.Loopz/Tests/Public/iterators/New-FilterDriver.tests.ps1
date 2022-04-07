Describe 'New-FilterDriver' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;

  }

  InModuleScope Elizium.Loopz {
    Context "Unary Driver" {
      Context "given: <parameters>" {
        It "create Filter with Core Of type <CoreClass>" -TestCases @(
          @{
            CoreClass  = "GlobFilter";
            Parameters = @{
              "cl"        = $true;
              "ChildLike" = "*foo*";
            }
          }

          , @{
            CoreClass  = "RegexFilter";
            Parameters = @{
              "cm"           = $true;
              "ChildPattern" = "bar";
            }
          }

          , @{
            CoreClass  = "GlobFilter";
            Parameters = @{
              "ll"       = $true;
              "LeafLike" = "*foo*";
            }
          }

          , @{
            CoreClass  = "RegexFilter";
            Parameters = @{
              "lm"          = $true;
              "LeafPattern" = "bar";
            }
          }
        ) {
          $driver = New-FilterDriver -Parameters $Parameters;
          $driver | Should -Not -BeNullOrEmpty;
          $driver | Should -BeOfType $([UnaryFilter]);
          $driver.Core.GetType() | Should -Be $CoreClass;
        }
      }
    } # Unary Driver
  
    Context "Compound Driver" {
      Context "given: <parameters>" {
        It "create Filter with Core Of type <ChildClass> and <LeafClass>" -TestCases @(
          @{
            ChildClass = "GlobFilter";
            LeafClass  = "RegexFilter";
            Parameters = @{
              "cl_lm"       = $true;
              "ChildLike"   = "*foo*";
              "LeafPattern" = "bar";
              "op"          = "Any";
            }
          }

          , @{
            ChildClass = "GlobFilter";
            LeafClass  = "GlobFilter";
            Parameters = @{
              "cl_ll"     = $true;
              "ChildLike" = "*foo*";
              "LeafLike"  = "*zoo*";
              "op"        = "Any";
            }
          }

          , @{
            ChildClass = "RegexFilter";
            LeafClass  = "RegexFilter";
            Parameters = @{
              "cm_lm"        = $true;
              "ChildPattern" = "bar";
              "LeafPattern"  = "baz";
              "op"           = "Any";
            }
          }

          @{
            ChildClass = "RegexFilter";
            LeafClass  = "GlobFilter";
            Parameters = @{
              "cm_ll"        = $true;
              "ChildPattern" = "bar";
              "LeafLike"     = "*zoo*";
              "op"           = "Any";
            }
          }

          # HandlerOp = "All"
          , @{
            ChildClass = "GlobFilter";
            LeafClass  = "RegexFilter";
            Parameters = @{
              "cl_lm"       = $true;
              "ChildLike"   = "*foo*";
              "LeafPattern" = "bar";
              "op"          = "All";
            }
          }
        ) {
          $driver = New-FilterDriver -Parameters $Parameters;
          $driver | Should -Not -BeNullOrEmpty;
          $driver | Should -BeOfType $([CompoundFilter]);
          $driver.Handler.Filters | Should -Not -BeNullOrEmpty;

          $driver.Handler.Filters[$([FilterScope]::Child)].GetType() | Should -Be $ChildClass;
          $driver.Handler.Filters[$([FilterScope]::Leaf)].GetType() | Should -Be $LeafClass;
        }
      }
    } # Compound Driver

    Context "given: no filtering parameters present" {
      It "should: return NoFilter" {
        [hashtable]$parameters = @{}
        $driver = New-FilterDriver -Parameters $parameters;
        $driver | Should -Not -BeNullOrEmpty;
        $driver | Should -BeOfType $([UnaryFilter]);
        $driver.Core | Should -BeOfType $([NoFilter]);
      }
    } # No Filter
  }
}
