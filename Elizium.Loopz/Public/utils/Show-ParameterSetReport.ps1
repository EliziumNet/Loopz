
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
    [hashtable]$signals = Get-Signals;
    # [string]$duplicateSeparator = '.............';
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
      [syntax]$syntax = New-Syntax -CommandName $_.Name -Signals $signals -Krayon $krayon;
      # [string]$lnSnippet = $syntax.TableOptions.Snippets.Ln;
      # [string]$punctuationSnippet = $syntax.TableOptions.Snippets.Punct;
      [rules]$rules = [rules]::New($_);

      $null = $builder.Append($syntax.TitleStmt('Parameter Set Report'));

      [PSCustomObject]$verifyInfo = [PSCustomObject]@{
        # Argh, we shouldn't need to pass in command info here, because rules get it in ctor
        #
        CommandInfo = $_;
        Syntax      = $syntax;
        Builder     = $builder;
      }
      $rules.ReportAll($verifyInfo);

      if (-not($PSBoundParameters.ContainsKey('Builder'))) {
        Write-Debug "'$($Builder.ToString())'";
        $krayon.ScribbleLn($Builder.ToString()).End();
      }
    }
  }
}
