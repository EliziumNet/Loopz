
function Show-ParameterSetInfo {
  # by KirkMunro (https://github.com/PowerShell/PowerShell/issues/8692)
  # https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-parameter-sets?view=powershell-7.1
  #
  [CmdletBinding()]
  [Alias('ships')]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string[]]$Name,

    [Parameter(Position = 1)]
    [string[]]$Sets,

    [Parameter()]
    [Scribbler]$Scribbler,

    [Parameter()]
    [string]$Title = 'Parameter Set Info',

    [Parameter()]
    [switch]$Common,

    [Parameter()]
    [switch]$Test
  )

  begin {
    [Krayon]$krayon = Get-Krayon;
    [hashtable]$signals = Get-Signals;

    if ($null -eq $Scribbler) {
      $Scribbler = New-Scribbler -Krayon $krayon -Test:$Test.IsPresent;
    }
  }

  process {
    if ($_ -isNot [System.Management.Automation.CommandInfo]) {
      [hashtable]$shipsParameters = @{
        'Title' = $Title;
        'Common' = $Common.IsPresent;
        'Test' = $Test.IsPresent;
      }

      if ($PSBoundParameters.ContainsKey('Sets')) {
        $shipsParameters['Sets'] = $Sets;
      }

      if ($PSBoundParameters.ContainsKey('Scribbler')) {
        $shipsParameters['Scribbler'] = $Scribbler;
      }

      Get-Command -Name $_ | Show-ParameterSetInfo @shipsParameters;
    }
    else {
      Write-Debug "    --- Show-ParameterSetInfo - Command: [$($_.Name)] ---";
      [syntax]$syntax = New-Syntax -CommandName $_.Name -Signals $signals -Scribbler $Scribbler;

      [string]$commandSnippet = $syntax.TableOptions.Custom.Snippets.Command;
      [string]$resetSnippet = $syntax.TableOptions.Snippets.Reset;
      [string]$lnSnippet = $syntax.TableOptions.Snippets.Ln;
      $Scribbler.Scribble($syntax.TitleStmt($Title, $_.Name));

      if ($Common) {
        $syntax.TableOptions.Custom.IncludeCommon = $true;
      }

      # Since we're inside a process block $_ refers to a CommandInfo (the result of get-command) and
      # one property is ParameterSets.
      #
      [string]$structuredSummaryStmt = if ($_.ParameterSets.Count -gt 0) {
        [int]$total = $_.ParameterSets.Count;
        [int]$count = 0;

        foreach ($parameterSet in $_.ParameterSets) {
          [boolean]$include = (-not($PSBoundParameters.ContainsKey('Sets')) -or `
            ($PSBoundParameters.ContainsKey('Sets') -and ($Sets -contains $parameterSet.Name)))

          if ($include) {
            [hashtable]$fieldMetaData, [hashtable]$headers, [hashtable]$tableContent = $(
              get-ParameterSetTableData -CommandInfo $_ -ParamSet $parameterSet -Syntax $syntax
            );

            if (-not($($null -eq $fieldMetaData)) -and ($fieldMetaData.PSBase.Keys.Count -gt 0)) {
              [string]$structuredParamSetStmt = $syntax.ParamSetStmt($_, $parameterSet);
              [string]$structuredSyntax = $syntax.SyntaxStmt($parameterSet);

              $Scribbler.Scribble($(
                  "$($lnSnippet)" +
                  "$($structuredParamSetStmt)$($lnSnippet)$($structuredSyntax)$($lnSnippet)" +
                  "$($lnSnippet)"
                ));

              Show-AsTable -MetaData $fieldMetaData -Headers $headers -Table $tableContent `
                -Scribbler $Scribbler -Options $syntax.TableOptions -Render $syntax.RenderCell;

              $count++;
            }
            else {
              $total = 0;
            }
          }
        } # foreach
        $Scribbler.Scribble("$($lnSnippet)");

        ($total -gt 0) `
          ? "Command: $($commandSnippet)$($Name)$($resetSnippet); Showed $count of $total parameter set(s)." `
          : "Command: $($commandSnippet)$($Name)$($resetSnippet) contains no parameter sets!";
      }
      else {
        "Command: $($commandSnippet)$($Name)$($resetSnippet) contains no parameter sets!";
      }

      if (-not([string]::IsNullOrEmpty($structuredSummaryStmt))) {
        $Scribbler.Scribble(
          $("$($resetSnippet)$($structuredSummaryStmt)$($lnSnippet)$($lnSnippet)")
        );
      }

      $Scribbler.Flush();
    }
  }
}
