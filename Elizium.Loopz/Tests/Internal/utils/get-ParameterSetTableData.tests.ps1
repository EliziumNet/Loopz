using namespace System.Management.Automation;

Describe 'get-ParameterSetTableData' -Tag 'PSTools' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;
  }

  Context 'Where specified' {
    It 'should: filter table contents' {
      InModuleScope Elizium.Loopz {
        function test-TableDataWhereClause {
          param(
            [Parameter(Mandatory, ValueFromPipeline = $true, Position = 0)]
            [object]$underscore,

            [Parameter(ParameterSetName = 'Positional', Mandatory, Position = 1)]
            [object]$PosA,

            [Parameter(ParameterSetName = 'Positional', Position = 2)]
            [object]$PosB,

            [Parameter(ParameterSetName = 'Positional', Position = 3)]
            [object]$PosC,

            [Parameter(ParameterSetName = 'Positional')]
            [object]$MissingPos,

            [Parameter(ParameterSetName = 'Alternative', Mandatory, Position = 1)]
            [object]$AltA,

            [Parameter(ParameterSetName = 'Alternative', Position = 2)]
            [object]$AltB
          )
        }

        [string]$commandName = 'test-TableDataWhereClause';
        [Krayon]$krayon = Get-Krayon;
        [hashtable]$signals = Get-Signals;
        [Scribbler]$scribbler = New-Scribbler -Krayon $krayon -Test;
        [Syntax]$syntax = New-Syntax -CommandName $commandName -Signals $signals -Scribbler $scribbler;

        [CommandInfo]$commandInfo = Get-Command $commandName;
        [CommandParameterSetInfo]$positionalPsi = `
          $commandInfo.ParameterSets | Where-Object Name -eq 'Positional';

        [scriptblock]$paramIsPositional = [scriptblock] {
          [OutputType([boolean])]
          param (
            [Parameter()]
            [PSCustomObject]$row
          )
          return $row.Pos -ne 'named';
        };

        [hashtable]$fieldMetaData, [hashtable]$headers, [hashtable]$tableContent = `
          get-ParameterSetTableData -CommandInfo $commandInfo `
          -ParamSet $positionalPsi -Syntax $syntax -Where $paramIsPositional;

        $tableContent.PSBase.Count | Should -Be 4;
      }
    }
  }
}
