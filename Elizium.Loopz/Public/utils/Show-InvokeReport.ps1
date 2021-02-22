
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

    if ($_ -isNot [System.Management.Automation.CommandInfo]) {
      Get-Command -Name $_ | Show-InvokeReport -Params $Params;
    }
    else {
      [syntax]$syntax = New-Syntax -CommandName $_.Name -Signals $signals -Krayon $krayon;
      [string]$paramSetSnippet = $syntax.TableOptions.Snippets.ParamSetName;
      [string]$resetSnippet = $syntax.TableOptions.Snippets.Reset;
      [string]$lnSnippet = $syntax.TableOptions.Snippets.Ln;
      [string]$punctSnippet = $syntax.TableOptions.Snippets.Punct;
      [string]$commandSnippet = $syntax.TableOptions.Snippets.Command;
      [string]$hiLightSnippet = $syntax.TableOptions.Snippets.HiLight;
      [rules]$rules = [rules]::New($_);
      [PSCustomObject]$informInfo = [PSCustomObject]@{
        AllCommonParamSet = $syntax.AllCommonParamSet;
      }

      [informer]$informer = [informer]::new($rules, $informInfo);
      $null = $builder.Append($syntax.TitleStmt('Invoke Report', $_.Name));

      [System.Management.Automation.CommandParameterSetInfo[]]$candidateSets = $informer.Resolve($Params);

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

      if ($candidateNames.Length -eq 0) {
        [string]$message = "$($resetSnippet)does not resolve to a parameter set and is therefore invalid.";
        $null = $Builder.Append(
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

        $null = $Builder.Append(
          $($commonInvokeFormat -f $(Get-FormattedSignal -Name 'OK-A' -EmojiOnly), $message)
        );

        $_ | Show-ParameterSetInfo -Sets $candidateNames -Builder $Builder;
      }
      else {
        [string]$structuredName = $syntax.QuotedNameStmt($paramSetSnippet);
        [string]$compoundStructuredNames = $syntax.NamesRegex.Replace($candidateNamesCSV, $structuredName);
        [string]$message = $(
          "$($lnSnippet)$($doubleIndent)$($punctSnippet)=> $($resetSnippet)resolves to parameter sets: " +
          "$($compoundStructuredNames)"
        );

        $null = $Builder.Append(
          $($commonInvokeFormat -f $(Get-FormattedSignal -Name 'FAILED-A' -EmojiOnly), $message)
        );

        $_ | Show-ParameterSetInfo -Sets $candidateNames -Builder $Builder;
      }

      if (-not($PSBoundParameters.ContainsKey('Builder'))) {
        Write-Debug "'$($Builder.ToString())'";
        $krayon.ScribbleLn($Builder.ToString()).End();
      }
    }
  }
}
