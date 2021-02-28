
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
      Write-Debug "    --- Show-ParameterSetReport - Command: [$($_.Name)] ---";

      [syntax]$syntax = New-Syntax -CommandName $_.Name -Signals $signals -Krayon $krayon;
      [RuleController]$controller = [RuleController]::New($_);

      $null = $builder.Append($syntax.TitleStmt('Parameter Set Violations Report', $_.Name));

      [PSCustomObject]$queryInfo = [PSCustomObject]@{
        CommandInfo = $_;
        Syntax      = $syntax;
        Builder     = $builder;
      }
      $controller.ReportAll($queryInfo);

      if (-not($PSBoundParameters.ContainsKey('Builder'))) {
        Write-Debug "'$($Builder.ToString())'";
        $krayon.ScribbleLn($Builder.ToString()).End();
      }
    }
  }
}
