
function Show-ParameterSetReport {
  <#
  .NAME
    Show-ParameterSetReport

  .SYNOPSIS
    Shows a reporting indicating problems with a command's parameter sets.

  .DESCRIPTION
    If no errors were found with any the parameter sets for this command, then
  the result is simply a message indicating no problems found. If the user wants
  to just get the parameter set info for a command, then they can use command
  Show-ParameterSetInfo instead.

    Parameter set violations are defined as rules. The following rules are defined:
  - 'Non Unique Parameter Set': Each parameter set must have at least one unique
  parameter. If possible, make this parameter a mandatory parameter.
  - 'Non Unique Positions': A parameter set that contains multiple positional
  parameters must define unique positions for each parameter. No two positional
  parameters can specify the same position.
  - 'Multiple Claims to Pipeline item': Only one parameter in a set can declare the
  ValueFromPipeline keyword with a value of true.
  - 'In All Parameter Sets By Accident': Defining a parameter with multiple
  'Parameter Blocks', some with and some without a parameter set, is invalid.

  .LINK
    https://eliziumnet.github.io/Loopz/

  .PARAMETER Name
    The name of the command to show parameter set report for. Can be alias or full command name.

  .PARAMETER InputObject
    Item(s) from the pipeline. Can be command/alias name of the command, or command/alias
  info obtained via Get-Command.

  .PARAMETER Scribbler
    The Krayola scribbler instance used to manage rendering to console

  .INPUTS
    CommandInfo or command name bound to $Name.

  .EXAMPLE 1 (CommandInfo via pipeline)
  Get Command Rename-Many | Show-ParameterSetReport

  .EXAMPLE 2 (command name via pipeline)
  'Rename-Many' | Show-ParameterSetReport

  .EXAMPLE 3 (By Name)
  Show-ParameterSetReport -Name 'Rename-Many'

  #>
  [CmdletBinding()]
  [Alias('sharp')]
  param(
    [Parameter(ParameterSetName = 'ByName', Mandatory, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$Name,

    [Parameter(ParameterSetName = 'ByPipeline', Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [array[]]$InputObject,

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

    [hashtable]$sharpParameters = @{
      'Test' = $Test.IsPresent;
    }

    if ($PSBoundParameters.ContainsKey('Scribbler')) {
      $sharpParameters['Scribbler'] = $Scribbler;
    }
  }

  process {
    # Reminder: $_ is commandInfo
    #
    if (($PSCmdlet.ParameterSetName -eq 'ByName') -or
      (($PSCmdlet.ParameterSetName -eq 'ByPipeline') -and ($_ -is [string]))) {

      if ($PSCmdlet.ParameterSetName -eq 'ByPipeline') {
        Get-Command -Name $_ | Show-ParameterSetReport @sharpParameters;
      }
      else {
        Get-Command -Name $Name | Show-ParameterSetReport @sharpParameters;
      }
    }
    elseif ($_ -is [System.Management.Automation.AliasInfo]) {
      if ($_.ResolvedCommand) {
        $_.ResolvedCommand | Show-ParameterSetReport @sharpParameters;
      }
      else {
        Write-Error "Alias '$_' does not resolve to a command" -ErrorAction Stop;
      }
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

      if (-not($PSBoundParameters.ContainsKey('Scribbler'))) {
        $Scribbler.Flush();
      }
    }
  }
}
