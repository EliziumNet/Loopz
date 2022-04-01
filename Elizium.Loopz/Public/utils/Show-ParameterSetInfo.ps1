using module Elizium.Krayola;

function Show-ParameterSetInfo {
  <#
  .NAME
    Show-ParameterSetInfo

  .SYNOPSIS
    Displays information for a commands parameter sets. This includes the standard
  syntax statement associated with each parameter set, but is also coloured in, to help
  readability.

  .DESCRIPTION
    If the command does not define parameter sets, then no information is displayed
  apart from a message indicating no parameter sets were found.

    One of the issues that a developer can encounter when designing parameter sets for
  a command is making sure that each parameter set includes at least 1 unique parameter
  as per recommendations. This function will greatly help in this regard. For each
  parameter set shown, the table it contains includes a 'Unique' column which shows
  whether a the parameter is unique to that parameter set. This relieves the developer
  from having to figure this out themselves.

  .LINK
    https://eliziumnet.github.io/Loopz/

  .PARAMETER Common
    switch to indicate if the standard PowerShell Common parameters should be included

  .PARAMETER Name
    The name of the command to show parameter set info report for. Can be alias or full command name.

  .PARAMETER InputObject
    Item(s) from the pipeline. Can be command/alias name of the command, or command/alias
  info obtained via Get-Command.

  .PARAMETER Scribbler
    The Krayola scribbler instance used to manage rendering to console

  .PARAMETER Sets
    A list of parameter sets the output should be restricted to. When not specified, all
  parameter sets are displayed.

  .PARAMETER Title
    The text displayed as a title. End user does not have to specify this value. It is useful
  to other client commands that invoke this one, so some context can be added to the display.

  .INPUTS
    CommandInfo or command name bound to $Name.

  .EXAMPLE 1 (Show all parameter sets, CommandInfo via pipeline)

  Get-Command 'Rename-Many' | Show-ParameterSetInfo

  .EXAMPLE 2 (Show all parameter sets with Common parameters, command name via pipeline)

  'Rename-Many' | Show-ParameterSetInfo -Common

  .EXAMPLE 3 (Show specified parameter sets, command name via pipeline)

  'Rename-Many' | Show-ParameterSetInfo -Sets MoveToAnchor, UpdateInPlace

  .EXAMPLE 4 (By Name)

  Show-ParameterSetInfo -Name 'Rename-Many' -Sets MoveToAnchor, UpdateInPlace

  #>
  [CmdletBinding()]
  [Alias('ships')]
  param(
    [Parameter(ParameterSetName = 'ByName', Mandatory, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$Name,

    [Parameter(ParameterSetName = 'ByPipeline', Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [array[]]$InputObject,

    [Parameter(Position = 1)]
    [string[]]$Sets,

    [Parameter()]
    [Scribbler]$Scribbler,

    [Parameter()]
    [string]$Title = 'Parameter Set Info',

    [Parameter()]
    [switch]$Common,

    [Parameter()]
    [switch]$Test
  )
  # inspired by Get-CommandDetails function by KirkMunro
  # (https://github.com/PowerShell/PowerShell/issues/8692)
  # https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-parameter-sets?view=powershell-7.1
  #
  begin {
    [Krayon]$krayon = Get-Krayon;
    [hashtable]$signals = Get-Signals;

    if ($null -eq $Scribbler) {
      $Scribbler = New-Scribbler -Krayon $krayon -Test:$Test.IsPresent;
    }

    [hashtable]$shipsParameters = @{
      'Title'  = $Title;
      'Common' = $Common.IsPresent;
      'Test'   = $Test.IsPresent;
    }

    if ($PSBoundParameters.ContainsKey('Sets')) {
      $shipsParameters['Sets'] = $Sets;
    }

    if ($PSBoundParameters.ContainsKey('Scribbler')) {
      $shipsParameters['Scribbler'] = $Scribbler;
    }
  }

  process {
    if (($PSCmdlet.ParameterSetName -eq 'ByName') -or
      (($PSCmdlet.ParameterSetName -eq 'ByPipeline') -and ($_ -is [string]))) {

      if ($PSCmdlet.ParameterSetName -eq 'ByPipeline') {
        Get-Command -Name $_ | Show-ParameterSetInfo @shipsParameters;
      }
      else {
        Get-Command -Name $Name | Show-ParameterSetInfo @shipsParameters;
      }
    }
    elseif ($_ -is [System.Management.Automation.AliasInfo]) {
      if ($_.ResolvedCommand) {
        $_.ResolvedCommand | Show-ParameterSetInfo @shipsParameters;
      }
      else {
        Write-Error "Alias '$_' does not resolve to a command" -ErrorAction Stop;
      }
    }
    else {
      Write-Debug "    --- Show-ParameterSetInfo - Command: [$($_.Name)] ---";
      [syntax]$syntax = New-Syntax -CommandName $_.Name -Signals $signals -Scribbler $Scribbler;

      [string]$commandSn = $syntax.TableOptions.Custom.Snippets.Command;
      [string]$resetSn = $syntax.TableOptions.Snippets.Reset;
      [string]$lnSn = $syntax.TableOptions.Snippets.Ln;
      [string]$nameStmt = $syntax.QuotedNameStmt($commandSn, $_.Name);
      $Scribbler.Scribble($syntax.TitleStmt($Title, $_.Name));

      if ($Common) {
        $syntax.TableOptions.Custom.IncludeCommon = $true;
      }

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
            [hashtable]$fieldMetaData, [hashtable]$headers, [hashtable]$tableContent = $(
              get-ParameterSetTableData -CommandInfo $_ -ParamSet $parameterSet -Syntax $syntax
            );

            if (-not($($null -eq $fieldMetaData)) -and ($fieldMetaData.PSBase.Keys.Count -gt 0)) {
              [string]$structuredParamSetStmt = $syntax.ParamSetStmt($_, $parameterSet);
              [string]$structuredSyntax = $syntax.SyntaxStmt($parameterSet);

              $Scribbler.Scribble($(
                  "$($lnSn)" +
                  "$($structuredParamSetStmt)$($lnSn)$($structuredSyntax)$($lnSn)" +
                  "$($lnSn)"
                ));

              Show-AsTable -MetaData $fieldMetaData -Headers $headers -Table $tableContent `
                -Scribbler $Scribbler -Options $syntax.TableOptions -Render $syntax.RenderCell;

              $count++;
            }
            else {
              $total = 0;
            }
          }
        } # foreach
        $Scribbler.Scribble("$($lnSn)");

        ($total -gt 0) `
          ? "Command: $($nameStmt)$($resetSn); Showed $count of $total parameter set(s)." `
          : "Command: $($nameStmt)$($resetSn) contains no parameter sets!";
      }
      else {
        "Command: $($nameStmt)$($resetSn) contains no parameter sets!";
      }

      if (-not([string]::IsNullOrEmpty($structuredSummaryStmt))) {
        $Scribbler.Scribble(
          $("$($resetSn)$($structuredSummaryStmt)$($lnSn)$($lnSn)")
        );
      }

      if (-not($PSBoundParameters.ContainsKey('Scribbler'))) {
        $Scribbler.Flush();
      }
    }
  }
}
