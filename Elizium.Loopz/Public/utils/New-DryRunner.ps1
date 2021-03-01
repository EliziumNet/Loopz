
function New-DryRunner {
  param(
    [Parameter()]
    [string]$CommandName,

    [Parameter()]
    [Hashtable]$Signals = $(Get-Signals),

    [Parameter()]
    [Krayon]$Krayon = $(Get-KrayolaTheme)
  )

  [System.Management.Automation.CommandInfo]$commandInfo = Get-Command $commandName;
  [syntax]$syntax = New-Syntax -CommandName $commandName -Signals $Signals -Krayon $Krayon;
  [RuleController]$controller = [RuleController]::new($commandInfo);
  [PSCustomObject]$runnerInfo = @{
    AllCommonParamSet = $syntax.AllCommonParamSet;
  }
  return [DryRunner]::new($controller, $runnerInfo);
}
