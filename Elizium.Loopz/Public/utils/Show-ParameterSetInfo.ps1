
function Get-ParameterSetInfo {
  # by KirkMunro (https://github.com/PowerShell/PowerShell/issues/8692)
  # https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-parameter-sets?view=powershell-7.1
  #
  [CmdletBinding()]
  [Alias('gips')]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string[]]$Name,

    [Parameter(Position = 1)]
    [string[]]$Sets
  )

  begin {
    [Krayon]$krayon = Get-Krayon
    [hashtable]$theme = $krayon.Theme;
    [hashtable]$signals = Get-Signals;

    [scriptblock]$renderParSetCell = {
      [OutputType([boolean])]
      param(
        [string]$column,
        [string]$value,
        [PSCustomObject]$Options,
        [Krayon]$Krayon
      )
      [boolean]$result = $true;
      # https://github.com/EliziumNet/Krayola/issues/41
      # (Krayon.Scribble does not render a vanilla string)
      #
      switch -Regex ($column) {
        'Name' {
          [System.Management.Automation.CommandParameterInfo]$parameterInfo = `
            $Options.Custom.ParameterSetInfo.Parameters | Where-Object Name -eq $value.Trim();
          [string]$parameterType = $parameterInfo.ParameterType;

          [string]$nameSnippet = if ($parameterInfo.IsMandatory) {
            $Options.Custom.Snippets.Mandatory;
          }
          elseif ($parameterType -eq 'switch') {
            $Options.Custom.Snippets.Switch;
          }
          else {
            $Options.Custom.Snippets.Cell;
          }
          $krayon.Scribble("$($nameSnippet)$value").End();
        }

        'Type' {
          $krayon.Scribble("$($Options.Custom.Snippets.Type)$value").End();              
        }

        'Mandatory|PipeValue' {
          [string]$coreValue = $value.Trim() -eq 'True' ? $Options.Values.True : $Options.Values.False;
          [string]$padded = Get-PaddedLabel -Label $coreValue -Width $value.Length -Align $Options.Align.Cell;
          $krayon.Reset().Text($padded).End();
        }

        default {
          # let's not do anything here and revert to default handling
          #
          $result = $false;
        }
      }
      # https://devblogs.microsoft.com/scripting/use-the-get-command-powershell-cmdlet-to-find-parameter-set-information/
      # https://blogs.msmvps.com/jcoehoorn/blog/2017/10/02/powershell-expandproperty-vs-property/

      return $result;
    } # renderParSetCell
  }

  process {
    if ($_ -isNot [System.Management.Automation.CommandInfo]) {
      if ($PSBoundParameters.ContainsKey('Sets')) {
        Get-Command -Name $_ | Get-ParameterSetInfo -Sets $Sets;
      }
      else {
        Get-Command -Name $_ | Get-ParameterSetInfo;
      }
    }
    else {
      [syntax]$syntax = [syntax]::new($Name, $theme, $signals, $krayon.ApiFormat);

      [string]$commandSnippet = $syntax.TableOptions.Custom.Snippets.Command;
      [string]$resetSnippet = $syntax.TableOptions.Snippets.Reset;

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
            $parametersToShow = $parameterSet.Parameters | Where-Object Name -NotIn $syntax.CommonParamSet;
            $parameterGroups = $parametersToShow.where( { $_.Position -ge 0 }, 'split');
            $parameterGroups[0] = @($parameterGroups[0] | Sort-Object -Property Position);
            $parametersToShow = $parameterGroups[0] + $parameterGroups[1];

            [PSCustomObject[]]$resultSet = ($parametersToShow `
              | Select-Object -Property @( # this is a query statement
                'Name'
                @{Name = 'Type'; Expression = { $_.ParameterType.Name }; }
                @{Name = 'Mandatory'; Expression = { $_.IsMandatory } }
                @{Name = 'Pos'; Expression = { if ($_.Position -eq [int]::MinValue) { 'named' } else { $_.Position } } }
                @{Name = 'PipeValue'; Expression = { $_.ValueFromPipeline } }
                @{Name = 'PipeName'; Expression = { $_.ValueFromPipelineByPropertyName } }
                @{Name = 'Alias'; Expression = { $_.Aliases -join ',' } }
              ));

            if (-not($($null -eq $resultSet)) -and ($resultSet.Count -gt 0)) {
              [hashtable]$fieldMetaData = Get-FieldMetaData -Data $resultSet;
              $syntax.TableOptions.Custom.ParameterSetInfo = $parameterSet;

              [hashtable]$headers, [hashtable]$tableContent = Get-AsTable -MetaData $fieldMetaData `
                -TableData $resultSet -Options $syntax.TableOptions;

              [string]$structuredParamSetStmt = $syntax.ParamSetStmt($_, $parameterSet);
              [string]$structuredSyntax = $syntax.SyntaxStmt($parameterSet);

              $krayon.Ln().End();
              $krayon.ScribbleLn($structuredParamSetStmt).End();
              $krayon.ScribbleLn($structuredSyntax).End();
              $krayon.Ln().End();

              Show-AsTable -MetaData $fieldMetaData -Headers $headers -Table $tableContent `
                -Krayon $krayon -Options $syntax.TableOptions -Render $renderParSetCell;

              $count++;
            }
            else {
              $total = 0;
            }
          }
        } # foreach
        $krayon.Ln().End();

        ($total -gt 0) `
          ? "Command: $($commandSnippet)$($Name)$($resetSnippet); Showed $count of $total parameter set(s)."
        : "Command: $($commandSnippet)$($Name)$($resetSnippet) contains no parameter sets!";
      }
      else {
        "Command: $($commandSnippet)$($Name)$($resetSnippet) contains no parameter sets!";
      }

      if (-not([string]::IsNullOrEmpty($structuredSummaryStmt))) {
        $krayon.Reset().ScribbleLn($structuredSummaryStmt).Ln().End()
      }
    }
  }
}
