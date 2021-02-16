
function Show-ParameterSetReport {
  [CmdletBinding()]
  [Alias('sharp')]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string[]]$Name,

    [Parameter()]
    [System.Text.StringBuilder]$Builder = [System.Text.StringBuilder]::new()
  )

  begin {
    [Krayon]$krayon = Get-Krayon
    [hashtable]$theme = $krayon.Theme;
    [hashtable]$signals = Get-Signals;
    [System.Text.StringBuilder]$builder = [System.Text.StringBuilder]::new();
    [string]$duplicateSeparator = '.............';
  }

  process {
    if (-not($PSBoundParameters.ContainsKey('Builder'))) {
      $null = $Builder.Clear();
    }

    # Reminder: $_ is commandInfo
    # 
    if ($_ -isNot [System.Management.Automation.CommandInfo]) {
      Get-Command -Name $_ | Show-ParameterSetReport;
    }
    else {
      [syntax]$syntax = [syntax]::new($Name, $theme, $signals, $krayon);
      [string]$lnSnippet = $syntax.TableOptions.Snippets.Ln;
      [string]$punctuationSnippet = $syntax.TableOptions.Snippets.Punct;
      [rules]$rules = [rules]::New($_);

      $null = $builder.Append(
        "$($lnSnippet)" +
        "---> Parameter Set Report ..." +
        "$($lnSnippet)"
      );

      [array]$duplicates = find-DuplicateParamSets -CommandInfo $_ -Syntax $syntax;

      if ($duplicates.Count -gt 0) {
        $null = $builder.Append("$($punctuationSnippet)$($duplicateSeparator)$($lnSnippet)");

        foreach ($dup in $duplicates) {
          [string]$duplicateParamSetStmt = $syntax.DuplicateParamSetStmt(
            $dup.First, $dup.Second
          );
          $null = $builder.Append($duplicateParamSetStmt);

          [string]$firstParamSetStmt = $syntax.ParamSetStmt($_, $dup.First);
          [string]$secondParamSetStmt = $syntax.ParamSetStmt($_, $dup.Second);

          [string]$firstSyntax = $syntax.SyntaxStmt($dup.First);
          [string]$secondSyntax = $syntax.SyntaxStmt($dup.Second);

          $null = $builder.Append($(
              "$($lnSnippet)" +
              "$($firstParamSetStmt)$($lnSnippet)$($firstSyntax)$($lnSnippet)" +
              "$($lnSnippet)" +
              "$($secondParamSetStmt)$($lnSnippet)$($secondSyntax)$($lnSnippet)" +
              "$($punctuationSnippet)$($duplicateSeparator)$($lnSnippet)"
            ));

          [hashtable]$fieldMetaData, [hashtable]$headers, [hashtable]$tableContent = $(
            get-ParameterSetTableData -CommandInfo $_ -ParamSet $dup.First -Syntax $Syntax
          );

          Show-AsTable -MetaData $fieldMetaData -Headers $headers -Table $tableContent `
            -Builder $builder -Options $syntax.TableOptions -Render $syntax.RenderCell;
        }

        if (-not($PSBoundParameters.ContainsKey('Builder'))) {
          Write-Debug "'$($Builder.ToString())'";
          $krayon.ScribbleLn($Builder.ToString()).End();
        }
      }
    }
  }
}
