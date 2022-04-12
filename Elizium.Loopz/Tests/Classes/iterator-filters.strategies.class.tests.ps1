using module Elizium.Tez;
using namespace System.IO;

Describe 'Filter Strategy' -Tag "Filter" {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;

    InModuleScope Elizium.Loopz {
      $global:_Paths = @{
        "ROOT"      = [Path]::Join("Tests", "Data", "traverse", "Audio");
        "MINIMAL"   = [Path]::Join("Tests", "Data", "traverse", "Audio", "MINIMAL");
        "FUSE"      = [Path]::Join("Tests", "Data", "traverse", "Audio", "MINIMAL", "FUSE");
        "DIMENSION" = [Path]::Join("Tests", "Data", "traverse", "Audio", "MINIMAL", "FUSE",
          "Dimension Intrusion");
      }
    }
  }

  <# LOOPZ.CONTROLLER.DEPTH
  for: "Tests/Data/traverse/Audio":

  DEPTH (Audio): '1'
  DEPTH (GOTHIC): '2'
  DEPTH (Fields Of The Nephilim): '3'
  DEPTH (Earth Inferno): '4'
  DEPTH (Mourning Sun): '4'
  DEPTH (The Nephilim): '4'
  DEPTH (MINIMAL): '2'
  DEPTH (FUSE): '3'
  DEPTH (Dimension Intrusion): '4'
  DEPTH (Train Trac): '4'
  DEPTH (Plastikman): '3'
  DEPTH (Arkives): '4'
  DEPTH (Consumed): '4'
  DEPTH (EX): '4'
  DEPTH (Musik): '4'
  DEPTH (Sheet One): '4'
  DEPTH (Richie Hawtin): '3'
  DEPTH (From My Mind To Yours): '4'
  #>

  Context "<Skip>, <Label>" {
    Context "LeafGenerationStrategy.Preview" {
      Context "given: <DriverClass> <HandlerClass> defined with <FirstScope>/<SecondScope> - <FirstPattern>/<SecondPattern> - <Path>" {
        InModuleScope Elizium.Loopz -Parameters @{
          Skip          = $Skip;
          Label         = $Label;
          DriverClass   = $DriverClass;
          HandlerClass  = $HandlerClass;
          FirstScope    = $FirstScope;
          SecondScope   = $SecondScope;
          FirstPattern  = $FirstPattern;
          SecondPattern = $SecondPattern;
          Path          = $Path;
          Result        = $Result;
        } {
          # NB: no tests here yet for PreferChildScope=$false or PreviewLeafNodes=$false
          #
          It "should:" -TestCases @(
            ### --- [IsChild = false /IsLeaf = false] ---
            #
            @{
              DriverClass   = "CompoundFilter";
              HandlerClass  = "AllCompoundHandler";
              FirstScope    = [FilterScope]::Child;
              SecondScope   = [FilterScope]::Leaf;
              FirstPattern  = "min";
              SecondPattern = "sion";
              Path          = "FUSE";
              Result        = $true;
            }

            ### --- [IsChild = false /IsLeaf = true] ---
            #
            , @{
              DriverClass   = "CompoundFilter";
              HandlerClass  = "AllCompoundHandler";
              FirstScope    = [FilterScope]::Child;
              SecondScope   = [FilterScope]::Leaf;
              FirstPattern  = "min";
              SecondPattern = "sion";
              Path          = "DIMENSION";
              Result        = $true;
            }

            ### --- [IsChild = true /IsLeaf = false] ---
            #
            , @{
              DriverClass   = "CompoundFilter";
              HandlerClass  = "AllCompoundHandler";
              FirstScope    = [FilterScope]::Child;
              SecondScope   = [FilterScope]::Leaf;
              FirstPattern  = "---";
              SecondPattern = "sion";
              Path          = "MINIMAL";
              Result        = $false;
            }

            , @{
              Label         = "Spot";
              DriverClass   = "CompoundFilter";
              HandlerClass  = "AllCompoundHandler";
              FirstScope    = [FilterScope]::Child;
              SecondScope   = [FilterScope]::Leaf;
              FirstPattern  = "MIN";
              SecondPattern = "sion";
              Path          = "MINIMAL";
              Result        = $true;
            }
          ) {
            [PSCustomObject]$testInfo = [PSCustomObject]@{
              Skip     = (Test-Path variable:Skip) ? $Skip : $false;
              Label    = (Test-Path variable:Label) ? $Label : [string]::Empty;
              Override = $true;
              #
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
              [LeafGenerationStrategy]$strategy = [LeafGenerationStrategy]::new($driver);

              [hashtable]$exchange = @{
                "LOOPZ.FILTER.ROOT-PATH" = $(Resolve-Path -LiteralPath $global:_Paths["ROOT"])
              }

              [FilterNode]$node = $strategy.GetDirectoryNode([PSCustomObject] @{
                  DirectoryInfo = Get-Item -Path $global:_Paths[$Path];
                  Exchange      = $exchange;
                });

              $strategy.Preview($node) | Should -Be $Result -Because $(
                "PREVIEW: Driver:'$DriverClass'/Handler: '$($HandlerClass)'"
              );
            }
          }
        }
      }
    } # LeafGenerationStrategy.Preview
  }
}
