
function New-DryRunner {
  param(
    [Parameter()]
    [string]$CommandName,

    [Parameter()]
    [Hashtable]$Signals = $(Get-Signals),

    [Parameter()]
    [Krayon]$Krayon = $(Get-Krayon)
  )

  [System.Management.Automation.CommandInfo]$commandInfo = Get-Command $commandName;
  [syntax]$syntax = New-Syntax -CommandName $commandName -Signals $Signals -Krayon $Krayon;
  [RuleController]$controller = [RuleController]::new($commandInfo);
  [PSCustomObject]$runnerInfo = @{
    CommonParamSet = $syntax.CommonParamSet;
  }
  return [DryRunner]::new($controller, $runnerInfo);
}
