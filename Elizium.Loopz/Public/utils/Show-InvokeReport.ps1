
function Show-InvokeReport {
  [CmdletBinding()]
  [Alias('shire')]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string[]]$Name,

    [Parameter(Mandatory)]
    [string[]]$Params,

    [Parameter()]
    [Scribbler]$Scribbler,

    [Parameter()]
    [switch]$Common,

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
    if ($_ -isNot [System.Management.Automation.CommandInfo]) {
      [hashtable]$shireParameters = @{
        'Params' = $Params;
        'Common' = $Common.IsPresent;
        'Test'   = $Test.IsPresent;
      }

      if ($PSBoundParameters.ContainsKey('Scribbler')) {
        $shireParameters['Scribbler'] = $Scribbler;
      }      

      Get-Command -Name $_ | Show-InvokeReport @shireParameters;
    }
    else {
      Write-Debug "    --- Show-InvokeReport - Command: [$($_.Name)] ---";

      [syntax]$syntax = New-Syntax -CommandName $_.Name -Signals $signals -Scribbler $Scribbler;
      [string]$paramSetSnippet = $syntax.TableOptions.Snippets.ParamSetName;
      [string]$resetSnippet = $syntax.TableOptions.Snippets.Reset;
      [string]$lnSnippet = $syntax.TableOptions.Snippets.Ln;
      [string]$punctSnippet = $syntax.TableOptions.Snippets.Punct;
      [string]$commandSnippet = $syntax.TableOptions.Snippets.Command;
      [string]$hiLightSnippet = $syntax.TableOptions.Snippets.HiLight;
      [RuleController]$controller = [RuleController]::New($_);
      [PSCustomObject]$runnerInfo = [PSCustomObject]@{
        CommonParamSet = $syntax.CommonParamSet;
      }

      [DryRunner]$runner = [DryRunner]::new($controller, $runnerInfo);
      $Scribbler.Scribble($syntax.TitleStmt('Invoke Report', $_.Name));

      [System.Management.Automation.CommandParameterSetInfo[]]$candidateSets = $runner.Resolve($Params);

      [string[]]$candidateNames = $candidateSets.Name
      [string]$candidateNamesCSV = $candidateNames -join ', ';
      [string]$paramsCSV = $Params -join ', ';

      [string]$structuredParamNames = $syntax.QuotedNameStmt($hiLightSnippet);
      [string]$unresolvedStructuredParams = $syntax.NamesRegex.Replace($paramsCSV, $structuredParamNames);

      [string]$commonInvokeFormat = $(
        $lnSnippet + $resetSnippet + '   {0}Command: ' +
        $punctSnippet + '''' + $commandSnippet + $Name + $punctSnippet + '''' +
        $resetSnippet + ' invoked with parameters: ' +
        $unresolvedStructuredParams +
        ' {1}' + $lnSnippet
      );

      [string]$doubleIndent = [string]::new(' ', $syntax.TableOptions.Chrome.Indent * 2);
      [boolean]$showCommon = $Common.IsPresent;

      if ($candidateNames.Length -eq 0) {
        [string]$message = "$($resetSnippet)does not resolve to a parameter set and is therefore invalid.";
        $Scribbler.Scribble(
          $($commonInvokeFormat -f $(Get-FormattedSignal -Name 'INVALID' -EmojiOnly), $message)
        );
      }
      elseif ($candidateNames.Length -eq 1) {
        [string]$message = $(
          "$($lnSnippet)$($doubleIndent)$($punctSnippet)=> $($resetSnippet)resolves to parameter set: " +
          "$($punctSnippet)'$($paramSetSnippet)$($candidateNamesCSV)$($punctSnippet)'"
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
        [string]$structuredName = $syntax.QuotedNameStmt($paramSetSnippet);
        [string]$compoundStructuredNames = $syntax.NamesRegex.Replace($candidateNamesCSV, $structuredName);
        [string]$message = $(
          "$($lnSnippet)$($doubleIndent)$($punctSnippet)=> $($resetSnippet)resolves to parameter sets: " +
          "$($compoundStructuredNames)"
        );

        $Scribbler.Scribble(
          $($commonInvokeFormat -f $(Get-FormattedSignal -Name 'FAILED-A' -EmojiOnly), $message)
        );

        $_ | Show-ParameterSetInfo -Sets $candidateNames -Scribbler $Scribbler `
          -Common:$showCommon -Test:$Test.IsPresent;
      }

      $Scribbler.Flush();
    }
  }
}
