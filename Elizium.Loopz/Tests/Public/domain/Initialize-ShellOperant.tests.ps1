using module '../../../Output/Elizium.Loopz/Elizium.Loopz.psd1';

Describe 'Initialize-ShellOperant' {
  # Ideally we'd use data driven test cases, but because we need to use TestDrive
  # which is not accessible during discovery time when the TestCase template parameters
  # are populated, we can't. Instead we have to manually define each test case and the
  # problem is made worse by our need to mock out Get-EnvironmentVariable which needs
  # the full path including TestDrive. Due to these restrictions these tests are
  # really way more verbose than they ought to be.
  #

  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force; ;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;

    [string]$script:_HomePath = $(Join-Path -Path $TestDrive -ChildPath 'home');
    [string]$script:_EliziumPath = $(Join-Path -Path $_HomePath -ChildPath 'elizium');
    [string]$script:_ShortCodeSegment = 'remy';
    [string]$script:_SubRootSegment = 'sub-root';
    [string]$script:_UndoDisabledName = 'UNDO_DISABLED';
    [string]$script:_UndoDisabledValue = [string]::Empty;

    $null = New-Item -Path $_EliziumPath -ItemType Directory;

    Mock -ModuleName Elizium.Loopz Use-EliziumPath {
      param()
      return $_EliziumPath;
    }

    Mock -ModuleName Elizium.Loopz Get-EnvironmentVariable {
      param(
        [Parameter()][string]$Variable,
        [Parameter()][string]$Default
      )
      # Each test must set _UndoDisabledValue accordingly
      #
      return $_UndoDisabledValue;
    }

    function script:Invoke-CoreTest {
      [CmdletBinding()]
      param(
        [Parameter(Mandatory)]
        [PSCustomObject]$Options,

        [Parameter()]
        [string[]]$Segments,

        [Parameter()]
        [switch]$ShouldCreateOp
      )

      [object]$operant = Initialize-ShellOperant -Options $Options;
      ($null -ne $operant) | Should -Be $($ShouldCreateOp.IsPresent);

      [string]$directoryPath = [System.IO.Path]::GetDirectoryName($operant.Shell.FullPath);

      if ($ShouldCreateOp) {
        Test-Path -Path $directoryPath -PathType Container | Should -BeTrue;
      }

      # We check the segments as an alternative to checking the whole path, because
      # doing so would not be platform independent, owing to the directory separator
      # char.
      #
      if ($PSBoundParameters.ContainsKey("Segments")) {
        $Segments | ForEach-Object {
          $directoryPath.Contains($_) | Should -BeTrue -Because "Path does not contain segment: '$_'";
        }
      }
    }
  }

  Context 'given: UNDO_DISABLED is NOT defined' {
    Context 'and: Options.SubRoot is defined' {
      It 'should: create path' {
        [PSCustomObject]$options = [PSCustomObject]@{
          SubRoot       = $_SubRootSegment;
          OperantName   = 'UndoRename';
          Shell         = 'PoShShell';
          BaseFilename  = 'undo-rename';
          DisabledEnVar = $script:_UndoDisabledName;
        }
        $script:_UndoDisabledValue = [string]::Empty;

        Invoke-CoreTest -Options $options -Segments @($_SubRootSegment) -ShouldCreateOp;
      }
    } # Options.SubRoot is defined

    Context 'and: Options.ShortCode is defined' {
      It 'should: create path' {
        [PSCustomObject]$options = [PSCustomObject]@{
          ShortCode     = $_ShortCodeSegment;
          OperantName   = 'UndoRename';
          Shell         = 'PoShShell';
          BaseFilename  = 'undo-rename';
          DisabledEnVar = $script:_UndoDisabledName;
        }
        $script:_UndoDisabledValue = [string]::Empty;

        Invoke-CoreTest -Options $options -Segments @($_ShortCodeSegment) -ShouldCreateOp;
      }
    } # Options.ShortCode is defined

    Context 'and: Options.SubRoot/ShortCode and are BOTH  defined' {
      It 'should: create path' {
        [PSCustomObject]$options = [PSCustomObject]@{
          SubRoot       = $_SubRootSegment;
          ShortCode     = $_ShortCodeSegment;
          OperantName   = 'UndoRename';
          Shell         = 'PoShShell';
          BaseFilename  = 'undo-rename';
          DisabledEnVar = $script:_UndoDisabledName;
        }
        $script:_UndoDisabledValue = [string]::Empty;

        Invoke-CoreTest -Options $options -Segments @(
          $_SubRootSegment, $_ShortCodeSegment) -ShouldCreateOp;
      }
    } # Options.SubRoot is defined

  } # UNDO_DISABLED is NOT defined

  Context 'given: UNDO_DISABLED is defined' {
    Context 'and: UNDO_DISABLED is true' {
      It 'should: create path' {
        [PSCustomObject]$options = [PSCustomObject]@{
          SubRoot       = $_SubRootSegment;
          ShortCode     = $_ShortCodeSegment;
          OperantName   = 'UndoRename';
          Shell         = 'PoShShell';
          BaseFilename  = 'undo-rename';
          DisabledEnVar = $script:_UndoDisabledName;
        }
        $script:_UndoDisabledValue = "true";

        Invoke-CoreTest -Options $options;
      }
    } # UNDO_DISABLED is true

    Context 'and: UNDO_DISABLED is false' {
      Context 'and: Options.ShortCode is defined' {
        It 'should: create path' {
          [PSCustomObject]$options = [PSCustomObject]@{
            ShortCode     = $_ShortCodeSegment;
            OperantName   = 'UndoRename';
            Shell         = 'PoShShell';
            BaseFilename  = 'undo-rename';
            DisabledEnVar = $script:_UndoDisabledName;
          }
          $script:_UndoDisabledValue = "false";

          Invoke-CoreTest -Options $options -Segments @($_ShortCodeSegment) -ShouldCreateOp;
        }
      } # Options.SubRoot is defined

    } # UNDO_DISABLED is false

    Context 'and: UNDO_DISABLED is mal-defined' {
      Context 'and: Options.SubRoot is defined' {
        It 'should: default to enabled and still create path' {
          [PSCustomObject]$options = [PSCustomObject]@{
            SubRoot       = $_SubRootSegment;
            OperantName   = 'UndoRename';
            Shell         = 'PoShShell';
            BaseFilename  = 'undo-rename';
            DisabledEnVar = $script:_UndoDisabledName;
          }
          $script:_UndoDisabledValue = "foo-bar";

          Invoke-CoreTest -Options $options -Segments @($_SubRootSegment) -ShouldCreateOp;
        }
      } # Options.SubRoot is defined
    }
  } # UNDO_DISABLED is defined
} # Initialize-ShellOperant
