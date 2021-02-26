
function Show-AsTable {
  # TODO: The client should be able to define a render method on a per column basis.
  # Currently there is just a single render callback supported. And ideally, we should be
  # able to present the entire row, not just the current cell. This will enable cross
  # field functionality to be defined.
  #
  param(
    [Parameter()]
    [hashtable]$MetaData,

    [Parameter()]
    [hashtable]$Headers,

    [Parameter()]
    [hashtable]$Table,

    [Parameter()]
    [System.Text.StringBuilder]$Builder,

    [Parameter()]
    [scriptblock]$Render = $([scriptblock] {
        [OutputType([boolean])]
        param(
          [string]$column,
          [string]$Value,
          [PSCustomObject]$row,
          [PSCustomObject]$Options,
          [System.Text.StringBuilder]$Builder
        )
        return $false;
      }),

    [Parameter()]
    [PSCustomObject]$Options
  )
  [string]$indentation = [string]::new(' ', $Options.Chrome.Indent);
  [string]$inter = [string]::new(' ', $Options.Chrome.Inter);
  [string]$headerSnippet = $($Options.Custom.Snippets.Header);
  [string]$underlineSnippet = $($Options.Custom.Snippets.Underline);
  [string]$resetSnippet = $($Options.Snippets.Reset);
  [string]$lnSnippet = $($Options.Snippets.Ln);
  
  $null = $Builder.Append("$($resetSnippet)$($lnSnippet)");

  if (($MetaData.Keys.Count -gt 0) -and ($Table.Keys.Count -gt 0)) {
    # Establish field selection
    #
    [string[]]$selection = Get-PsObjectField -Object $Options -Field 'Select';

    if (-not($selection)) {
      $selection = $Headers.Keys;
    }

    # Display column titles
    #
    $null = $Builder.Append($indentation);

    foreach ($col in $selection) {
      [string]$paddedValue = $Headers[$col.Trim()];
      $null = $Builder.Append("$($headerSnippet)$($paddedValue)$($resetSnippet)$($inter)");
    }
    $null = $Builder.Append("$($lnSnippet)$($resetSnippet)");

    # Display column underlines
    #
    $null = $Builder.Append($indentation);
    foreach ($col in $selection) {
      $underline = [string]::new($Options.Chrome.Underline, $MetaData[$col].Max);
      $null = $Builder.Append("$($underlineSnippet)$($underline)$($inter)").Append(
        $resetSnippet);
    }
    $null = $Builder.Append($lnSnippet);

    # Display field values
    #
    $Table.GetEnumerator() | Sort-Object Name | ForEach-Object {
      $null = $Builder.Append($indentation);

      foreach ($col in $selection) {
        if (-not($Render.InvokeReturnAsIs($col, $_.Value.$col, $_.Value, $Options, $Builder))) {
          $null = $Builder.Append("$($resetSnippet)$($_.Value.$col)");
        }
        $null = $Builder.Append($inter);
      }

      $null = $Builder.Append($lnSnippet);
    }
  }
}
