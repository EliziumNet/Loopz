
function New-DryRunner {
  <#
  .NAME
    New-DryRunner

  .SYNOPSIS
    Dry-Runner factory function

  .DESCRIPTION
    The Dry-Runner is used by the Show-InvokeReport command. The DryRunner can
  be used in unit-tests to ensure that expected parameters can be used to
  invoke the function without causing errors. In the unit tests, the client just needs
  to instantiate the DryRunner (using this function) then pass in an expected list
  of parameters to the Resolve method. The test case can review the result parameter
  set(s) and assert as appropriate. (Actually, a developer can also use the
  RuleController class in unit tests to check that commands do not violate the
  parameter set rules.)

  .LINK
    https://eliziumnet.github.io/Loopz/

  .PARAMETER CommandName
    The name of the command to get DryRunner instance for

  .PARAMETER Scribbler
    The Krayola scribbler instance used to manage rendering to console

  .PARAMETER Signals
    The signals hashtable collection
  #>
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
