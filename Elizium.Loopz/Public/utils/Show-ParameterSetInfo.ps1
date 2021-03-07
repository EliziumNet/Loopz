
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
    [System.Text.StringBuilder]$Builder = [System.Text.StringBuilder]::new(),

    [Parameter()]
    [string]$Title = 'Parameter Set Info'
  )

  begin {
    [Krayon]$krayon = Get-Krayon;
    [hashtable]$signals = Get-Signals;
  }

  process {
    if (-not($PSBoundParameters.ContainsKey('Builder'))) {
      $null = $Builder.Clear();
    }

    if ($_ -isNot [System.Management.Automation.CommandInfo]) {
      if ($PSBoundParameters.ContainsKey('Sets')) {
        Get-Command -Name $_ | Show-ParameterSetInfo -Sets $Sets;
      }
      else {
        Get-Command -Name $_ | Show-ParameterSetInfo;
      }
    }
    else {
      Write-Debug "    --- Show-ParameterSetInfo - Command: [$($_.Name)] ---";
      [syntax]$syntax = New-Syntax -CommandName $_.Name -Signals $signals -Krayon $krayon;

      [string]$commandSnippet = $syntax.TableOptions.Custom.Snippets.Command;
      [string]$resetSnippet = $syntax.TableOptions.Snippets.Reset;
      [string]$lnSnippet = $syntax.TableOptions.Snippets.Ln;
      $null = $builder.Append($syntax.TitleStmt($Title, $_.Name));

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
            # TODO: we need to fnd out what the unique parameters are for each set.
            # We could add an extra boolean column to the table which indicates
            # if it is unique.
            #
            [hashtable]$fieldMetaData, [hashtable]$headers, [hashtable]$tableContent = $(
              get-ParameterSetTableData -CommandInfo $_ -ParamSet $parameterSet -Syntax $syntax
            );

            if (-not($($null -eq $fieldMetaData)) -and ($fieldMetaData.PSBase.Keys.Count -gt 0)) {
              [string]$structuredParamSetStmt = $syntax.ParamSetStmt($_, $parameterSet);
              [string]$structuredSyntax = $syntax.SyntaxStmt($parameterSet);

              $null = $Builder.Append($(
                  "$($lnSnippet)" +
                  "$($structuredParamSetStmt)$($lnSnippet)$($structuredSyntax)$($lnSnippet)" +
                  "$($lnSnippet)"
                ));

              Show-AsTable -MetaData $fieldMetaData -Headers $headers -Table $tableContent `
                -Builder $Builder -Options $syntax.TableOptions -Render $syntax.RenderCell;

              $count++;
            }
            else {
              $total = 0;
            }
          }
        } # foreach
        $null = $Builder.Append("$($lnSnippet)");

        ($total -gt 0) `
          ? "Command: $($commandSnippet)$($Name)$($resetSnippet); Showed $count of $total parameter set(s)." `
          : "Command: $($commandSnippet)$($Name)$($resetSnippet) contains no parameter sets!";
      }
      else {
        "Command: $($commandSnippet)$($Name)$($resetSnippet) contains no parameter sets!";
      }

      if (-not([string]::IsNullOrEmpty($structuredSummaryStmt))) {
        $null = $Builder.Append(
          $("$($resetSnippet)$($structuredSummaryStmt)$($lnSnippet)$($lnSnippet)")
        );
      }

      if (-not($PSBoundParameters.ContainsKey('Builder'))) {
        Write-Debug "'$($Builder.ToString())'";
        $krayon.ScribbleLn($Builder.ToString()).End();
      }
    }
  }
}
