
function Show-InvokeReport {
  [CmdletBinding()]
  [Alias('shire')]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string[]]$Name,

    [Parameter()]
    [string[]]$Params
  )

  begin {
    [Krayon]$krayon = Get-Krayon
    [hashtable]$theme = $krayon.Theme;
    [hashtable]$signals = Get-Signals;
    [System.Text.StringBuilder]$builder = [System.Text.StringBuilder]::new();
  }

  process {
    $null = $builder.Clear();

    if ($_ -isNot [System.Management.Automation.CommandInfo]) {
      if ($PSBoundParameters.ContainsKey('Params')) {
        Get-Command -Name $_ | Show-InvokeReport -Params $Params;
      }
      else {
        Get-Command -Name $_ | Show-InvokeReport;
      }
    }
    else {
      [syntax]$syntax = [syntax]::new($Name, $theme, $signals, $krayon);
      [string]$lnSnippet = $syntax.TableOptions.Snippets.Ln;

      $null = $builder.Append(
        "$($lnSnippet)" +
        "---> Invoke Report ..." +
        "$($lnSnippet)"
      );

      # The following rules must be applied
      #
      # - Each parameter set must have at least one unique parameter (make mandatory if possible).
      # - Unique position numbers
      # - Only 1 parameter can be ValueFromPipeline = true
      #

      # First restrict the parameter sets to those which contain where every p in Params
      # TODO: define a rules class
      #
      $candidateSets = $_.ParameterSets | Where-Object { (
          # ($_.Name -NotIn $syntax.CommonParamSet) -and
          # Intersect $Params parameter sets' parameters
          #
          ($_.Parameters.Name | Where-Object { ($Params -contains $_) }) # => too permissive
        )
      };

      # Next remove those parameter sets where any mandatory parameter in the parameter set
      # which are missing from Params
      #

      [string[]]$candidateNames = $candidateSets.Name

      Write-Host ">>> Found $($candidateSets.Count) of $($_.ParameterSets.Count) candidate parameter sets:";
      Write-Host ">>> Candidates: '$($candidateNames -join ', ')'"

      Write-Debug "'$($builder.ToString())'";
      $krayon.ScribbleLn($builder.ToString()).End();
    }
  }
}
