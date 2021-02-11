
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
    [Krayon]$Krayon,

    [Parameter()]
    [scriptblock]$Render = $([scriptblock] {
        [OutputType([boolean])]
        param(
          [string]$column,
          [string]$value,
          [PSCustomObject]$Options,
          [Krayon]$krayon
        )
        $krayon.Reset().Text($value);
        return $true;
      }),

    [Parameter()]
    [PSCustomObject]$Options
  )
  # TODO: this needs to be refactored to use the string builder. We should construct all the
  # construct all the structure string in advance and invoke the string builder all in one go
  # rather than the current implementation which performs adhoc invokes on krayon. When this is
  # complete, then should be a single krayon invoke with the contents ofg the string builder.
  #
  $krayon.Reset().Ln().End();

  if (($MetaData.Count -gt 0) -and ($Table.Count -gt 0)) {
    #
    [string]$indentation = [string]::new(' ', $Options.Chrome.Indent);
    [string]$inter = [string]::new(' ', $Options.Chrome.Inter);
    [string]$headerSnippet = $($Options.Custom.Snippets.Header);
    [string]$underlineSnippet = $($Options.Custom.Snippets.Underline);
    [string]$resetSnippet = $($Options.Snippets.Reset);

    # Establish field selection
    #
    [string[]]$selection = Get-PsObjectField -Object $Options -Field 'Select';

    if (-not($selection)) {
      $selection = $Headers.Keys;
    }

    # Display column titles
    #
    $krayon.Text($indentation).End();
    foreach ($col in $selection) {
      [string]$paddedValue = $Headers[$col.Trim()];
      $krayon.Scribble("$($headerSnippet)$($paddedValue)$($resetSnippet)$($inter)").End();
    }
    $krayon.Ln().Reset().End();

    # Display column underlines
    #
    $krayon.Text($indentation).End();
    foreach ($col in $selection) {
      $underline = [string]::new($Options.Chrome.Underline, $MetaData[$col].Max);
      $Krayon.Scribble("$($underlineSnippet)$($underline)$($inter)").Reset().End();
    }
    $krayon.Ln().End();

    # Display field values
    #
    $Table.GetEnumerator() | Sort-Object Name | ForEach-Object {
      $krayon.Text($indentation).End();

      foreach ($col in $selection) {
        if (-not($Render.InvokeReturnAsIs($col, $_.Value.$col, $Options, $Krayon))) {
          $krayon.Reset().Text($_.Value.$col).End();
        }
        $krayon.Text($inter).End();
      }

      $krayon.Ln().End();
    }
  }
}

function Show-AsTableLegacy {
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
    [Krayon]$Krayon,

    [Parameter()]
    [scriptblock]$Render = $([scriptblock] {
        [OutputType([boolean])]
        param(
          [string]$column,
          [string]$value,
          [PSCustomObject]$Options,
          [Krayon]$krayon
        )
        $krayon.Reset().Text($value);
        return $true;
      }),

    [Parameter()]
    [PSCustomObject]$Options
  )
  $krayon.Reset().Ln().End();

  if (($MetaData.Count -gt 0) -and ($Table.Count -gt 0)) {
    #
    [string]$indentation = [string]::new(' ', $Options.Chrome.Indent);
    [string]$inter = [string]::new(' ', $Options.Chrome.Inter);
    [string]$headerSnippet = $($Options.Custom.Snippets.Header);
    [string]$underlineSnippet = $($Options.Custom.Snippets.Underline);
    [string]$resetSnippet = $($Options.Snippets.Reset);

    # Establish field selection
    #
    [string[]]$selection = Get-PsObjectField -Object $Options -Field 'Select';

    if (-not($selection)) {
      $selection = $Headers.Keys;
    }

    # Display column titles
    #
    $krayon.Text($indentation).End();
    foreach ($col in $selection) {
      [string]$paddedValue = $Headers[$col.Trim()];
      $krayon.Scribble("$($headerSnippet)$($paddedValue)$($resetSnippet)$($inter)").End();
    }
    $krayon.Ln().Reset().End();

    # Display column underlines
    #
    $krayon.Text($indentation).End();
    foreach ($col in $selection) {
      $underline = [string]::new($Options.Chrome.Underline, $MetaData[$col].Max);
      $Krayon.Scribble("$($underlineSnippet)$($underline)$($inter)").Reset().End();
    }
    $krayon.Ln().End();

    # Display field values
    #
    $Table.GetEnumerator() | Sort-Object Name | ForEach-Object {
      $krayon.Text($indentation).End();

      foreach ($col in $selection) {
        if (-not($Render.InvokeReturnAsIs($col, $_.Value.$col, $Options, $Krayon))) {
          $krayon.Reset().Text($_.Value.$col).End();
        }
        $krayon.Text($inter).End();
      }

      $krayon.Ln().End();
    }
  }
}
