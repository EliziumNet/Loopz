
function New-DryRunner {
  param(
    [Parameter()]
    [string]$CommandName,

    [Parameter()]
    [Hashtable]$Signals = $(Get-Signals),

    [Parameter()]
    [Scribbler]$Scribbler
  )

  [System.Management.Automation.CommandInfo]$commandInfo = Get-Command $commandName;
  [syntax]$syntax = New-Syntax -CommandName $commandName -Signals $Signals -Scribbler $Scribbler;
  [RuleController]$controller = [RuleController]::new($commandInfo);
  [PSCustomObject]$runnerInfo = @{
    CommonParamSet = $syntax.CommonParamSet;
  }
  return [DryRunner]::new($controller, $runnerInfo);
}
