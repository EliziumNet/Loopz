
function Show-ParameterSetReport {
  [CmdletBinding()]
  [Alias('sharp')]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string[]]$Name,

    [Parameter()]
    [Scribbler]$Scribbler,

    [Parameter()]
    [switch]$Test
  )

  begin {
    [Krayon]$krayon = Get-Krayon
    [hashtable]$signals = Get-Signals;
    if ($null -eq $Scribbler) {
      $Scribbler = New-Scribbler -Krayon $krayon -Test:$Test.IsPresent;
    }
  }

  process {
    # Reminder: $_ is commandInfo
    # 
    if ($_ -isNot [System.Management.Automation.CommandInfo]) {
      [hashtable]$sharpParameters = @{
        'Test'   = $Test.IsPresent;
      }

      if ($PSBoundParameters.ContainsKey('Scribbler')) {
        $sharpParameters['Scribbler'] = $Scribbler;
      }     

      Get-Command -Name $_ | Show-ParameterSetReport @sharpParameters;
    }
    else {
      Write-Debug "    --- Show-ParameterSetReport - Command: [$($_.Name)] ---";

      [syntax]$syntax = New-Syntax -CommandName $_.Name -Signals $signals -Scribbler $Scribbler;
      [RuleController]$controller = [RuleController]::New($_);

      $Scribbler.Scribble($syntax.TitleStmt('Parameter Set Violations Report', $_.Name));

      [PSCustomObject]$queryInfo = [PSCustomObject]@{
        CommandInfo = $_;
        Syntax      = $syntax;
        Scribbler   = $Scribbler;
      }
      $controller.ReportAll($queryInfo);

      $Scribbler.Flush();
    }
  }
}
