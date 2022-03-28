using module Elizium.Krayola;

function Show-InvokeReport {
  <#
  .NAME
    Show-InvokeReport

  .SYNOPSIS
    Given a list of parameters, shows which parameter set they resolve to. If they
  don't resolve to a parameter set then this is reported. If the parameters
  resolve to more than one parameter set, then all possible candidates are reported.
  This is a helper function which end users and developers alike can use to determine
  which parameter sets are in play for a given list of parameters. It was built to
  counter the un helpful message one sees when a command is invoked either with
  insufficient or an incorrect combination:

  "Parameter set cannot be resolved using the specified named parameters. One or
  more parameters issued cannot be used together or an insufficient number of
  parameters were provided.".
  
  Of course not all error scenarios can be detected, but some are which is better
  than none. This command is a substitute for actually invoking the target command.
  The target command may not be safe to invoke on an ad-hoc basis, so it's safer
  to invoke this command specifying the parameters without their values.

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

  .PARAMETER Common
    switch to indicate if the standard PowerShell Common parameters show be included

  .PARAMETER Name
    The name of the command to show invoke report for. Can be alias or full command name.

  .PARAMETER InputObject
    Item(s) from the pipeline. Can be command/alias name of the command, or command/alias
  info obtained via Get-Command.

  .PARAMETER Params
    The set of parameter names the command is invoked for. This is like invoking the
  command without specifying the values of the parameters.

  .PARAMETER Scribbler
    The Krayola scribbler instance used to manage rendering to console

  .PARAMETER Strict
    When specified, will not use Mandatory parameters check to for candidate parameter sets

  .INPUTS
    CommandInfo or command name bound to $Name.

  .EXAMPLE 1 (CommandInfo via pipeline)
  Get-Command 'Rename-Many' | Show-InvokeReport params underscore, Pattern, Anchor, With 

   
  Show invoke report for command 'Rename-Many' from its command info

  .EXAMPLE 2 (command name via pipeline)
  'Rename-Many' | Show-InvokeReport params underscore, Pattern, Anchor, With 

  Show invoke report for command 'Rename-Many' from its command info

  .EXAMPLE 3 (By Name)
  Show-InvokeReport -Name 'Rename-Many' -params underscore, Pattern, Anchor, With

  #>
  [CmdletBinding()]
  [Alias('shire')]
  param(
    [Parameter(ParameterSetName = 'ByName', Mandatory, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$Name,

    [Parameter(ParameterSetName = 'ByPipeline', Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [array[]]$InputObject,

    [Parameter(Mandatory)]
    [string[]]$Params,

    [Parameter()]
    [Scribbler]$Scribbler,

    [Parameter()]
    [switch]$Common,

    [Parameter()]
    [switch]$Strict,

    [Parameter()]
    [switch]$Test
  )

  begin {
    [Krayon]$krayon = Get-Krayon
    [hashtable]$signals = Get-Signals;

    if ($null -eq $Scribbler) {
      $Scribbler = New-Scribbler -Krayon $krayon -Test:$Test.IsPresent;
    }

    [hashtable]$shireParameters = @{
      'Params' = $Params;
      'Common' = $Common.IsPresent;
      'Test'   = $Test.IsPresent;
      'Strict' = $Strict.IsPresent;
    }

    if ($PSBoundParameters.ContainsKey('Scribbler')) {
      $shireParameters['Scribbler'] = $Scribbler;
    }      
  }

  process {
    if (($PSCmdlet.ParameterSetName -eq 'ByName') -or
      (($PSCmdlet.ParameterSetName -eq 'ByPipeline') -and ($_ -is [string]))) {

      if ($PSCmdlet.ParameterSetName -eq 'ByPipeline') {
        Get-Command -Name $_ | Show-InvokeReport @shireParameters;
      }
      else {
        Get-Command -Name $Name | Show-InvokeReport @shireParameters;
      }
    }
    elseif ($_ -is [System.Management.Automation.AliasInfo]) {
      if ($_.ResolvedCommand) {
        $_.ResolvedCommand | Show-InvokeReport @shireParameters;
      }
      else {
        Write-Error "Alias '$_' does not resolve to a command" -ErrorAction Stop;
      }
    }
    else {
      Write-Debug "    --- Show-InvokeReport - Command: [$($_.Name)] ---";

      [syntax]$syntax = New-Syntax -CommandName $_.Name -Signals $signals -Scribbler $Scribbler;
      [string]$paramSetSn = $syntax.TableOptions.Snippets.ParamSetName;
      [string]$resetSn = $syntax.TableOptions.Snippets.Reset;
      [string]$lnSn = $syntax.TableOptions.Snippets.Ln;
      [string]$punctSn = $syntax.TableOptions.Snippets.Punct;
      [string]$commandSn = $syntax.TableOptions.Snippets.Command;
      [string]$nameStmt = $syntax.QuotedNameStmt($commandSn, $_.Name);
      [string]$hiLightSn = $syntax.TableOptions.Snippets.HiLight;
      [RuleController]$controller = [RuleController]::New($_);
      [PSCustomObject]$runnerInfo = [PSCustomObject]@{
        CommonParamSet = $syntax.CommonParamSet;
      }

      [DryRunner]$runner = [DryRunner]::new($controller, $runnerInfo);
      $Scribbler.Scribble($syntax.TitleStmt('Invoke Report', $_.Name));

      [System.Management.Automation.CommandParameterSetInfo[]]$candidateSets = $Strict.IsPresent `
        ? $runner.Resolve($Params) `
        : $runner.Weak($Params);

      [string[]]$candidateNames = $candidateSets.Name
      [string]$candidateNamesCSV = $candidateNames -join ', ';
      [string]$paramsCSV = $Params -join ', ';

      [string]$structuredParamNames = $syntax.QuotedNameStmt($hiLightSn);
      [string]$unresolvedStructuredParams = $syntax.NamesRegex.Replace($paramsCSV, $structuredParamNames);

      [string]$commonInvokeFormat = $(
        $lnSn + $resetSn + '   {0}Command: ' +
        $nameStmt +
        $resetSn + ' invoked with parameters: ' +
        $unresolvedStructuredParams +
        ' {1}' + $lnSn
      );

      [string]$doubleIndent = [string]::new(' ', $syntax.TableOptions.Chrome.Indent * 2);
      [boolean]$showCommon = $Common.IsPresent;

      if ($candidateNames.Length -eq 0) {
        [string]$message = "$($resetSn)does not resolve to a parameter set and is therefore invalid.";
        $Scribbler.Scribble(
          $($commonInvokeFormat -f $(Get-FormattedSignal -Name 'INVALID' -EmojiOnly), $message)
        );
      }
      elseif ($candidateNames.Length -eq 1) {
        [string]$message = $(
          "$($lnSn)$($doubleIndent)$($punctSn)=> $($resetSn)resolves to parameter set: " +
          "$($punctSn)'$($paramSetSn)$($candidateNamesCSV)$($punctSn)'"
        );
        [string]$resolvedStructuredParams = $syntax.InvokeWithParamsStmt($candidateSets[0], $params);

        # Colour in resolved parameters
        #
        $commonInvokeFormat = $commonInvokeFormat.Replace($unresolvedStructuredParams,
          $resolvedStructuredParams);

        $Scribbler.Scribble(
          $($commonInvokeFormat -f $(Get-FormattedSignal -Name 'OK-A' -EmojiOnly), $message)
        );

        $_ | Show-ParameterSetInfo -Sets $candidateNames -Scribbler $Scribbler `
          -Common:$showCommon -Test:$Test.IsPresent;
      }
      else {
        [string]$structuredName = $syntax.QuotedNameStmt($paramSetSn);
        [string]$compoundStructuredNames = $syntax.NamesRegex.Replace($candidateNamesCSV, $structuredName);
        [string]$message = $(
          "$($lnSn)$($doubleIndent)$($punctSn)=> $($resetSn)resolves to parameter sets: " +
          "$($compoundStructuredNames)"
        );

        $Scribbler.Scribble(
          $($commonInvokeFormat -f $(Get-FormattedSignal -Name 'FAILED-A' -EmojiOnly), $message)
        );

        $_ | Show-ParameterSetInfo -Sets $candidateNames -Scribbler $Scribbler `
          -Common:$showCommon -Test:$Test.IsPresent;
      }

      if (-not($PSBoundParameters.ContainsKey('Scribbler'))) {
        $Scribbler.Flush();
      }
    }
  }
}
