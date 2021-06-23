using namespace System.Management.Automation;

Describe 'Syntax' -Tag 'PSTools' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;

    InModuleScope Elizium.Loopz {
      [krayon]$script:_krayon = Get-Krayon;
      [hashtable]$script:_theme = $_krayon.Theme;
      [hashtable]$script:_signals = Get-Signals;
      [string]$script:_command = 'Invoke-Command';
    }
  }

  BeforeEach {
    InModuleScope Elizium.Loopz {
      [Scribbler]$script:_scribbler = New-Scribbler -Krayon $_krayon -Test;
      [string]$script:_lnSnippet = $_scribbler.Snippets(@('Ln'));
    }    
  }

  AfterEach {
    InModuleScope Elizium.Loopz {
      $_scribbler.Flush();
    }
  }

  # !! Tests that are written for Rename-many should be re-written using another command
  #
  Describe 'ParamSetStmt' {
    Context 'given: Invoke-Command' {
      It 'should: show parameter set statements' {
        InModuleScope Elizium.Loopz {
          [syntax]$syntax = New-Syntax -CommandName $_command -Signals $_signals -Scribbler $_scribbler;
          [CommandInfo]$commandInfo = Get-Command $_command;

          foreach ($paramSet in $commandInfo.ParameterSets) {
            [string]$paramSetStmt = $(
              "$($syntax.ParamSetStmt($commandInfo, $paramSet))$($_lnSnippet)"
            );
            $_scribbler.Scribble($paramSetStmt);
          }
        }
      }
    }
  } # ParamSetStmt

  Describe 'SyntaxStmt' {
    Context 'given: Invoke-Command' {
      It 'should: show parameter set statements' {
        InModuleScope Elizium.Loopz {
          [syntax]$syntax = New-Syntax -CommandName $_command -Signals $_signals -Scribbler $_scribbler;
          [CommandInfo]$commandInfo = Get-Command $_command;

          foreach ($paramSet in $commandInfo.ParameterSets) {
            [string]$syntaxStmt = $(
              "$($syntax.SyntaxStmt($paramSet))$($_lnSnippet)$($_lnSnippet)"
            );
            $_scribbler.Scribble($syntaxStmt);
          }
        }
      }
    }

    Context 'given: parameter set with mandatory switch parameters' {
      It 'should: colour correctly' {
        InModuleScope Elizium.Loopz {
          [CommandInfo]$commandInfo = Get-Command $_command;

          if ([System.Management.Automation.CommandParameterSetInfo]$paramSet = `
            $($commandInfo.ParameterSets | Where-Object Name -eq 'MoveToStart')?[0]) {

            [syntax]$syntax = New-Syntax -CommandName $_command -Signals $_signals -Scribbler $_scribbler;
            [string]$syntaxStmt = $syntax.SyntaxStmt($paramSet);

            [string]$cyanSnippet = $_scribbler.Snippets(@('cyan'));
            [string]$redSnippet = $_scribbler.Snippets(@('red'));
            [string]$lnSnippet = $_scribbler.Snippets(@('Ln'));
            [string]$colouredMandatoryStartSwitch = "$($cyanSnippet)-$($redSnippet)Start ";

            $_scribbler.Scribble(
              "$($syntaxStmt)$($lnSnippet)"
            );
            $syntaxStmt.ToLower().contains($colouredMandatoryStartSwitch.ToLower()) | Should -BeTrue;
          }
        }
      }
    }
  }
}
