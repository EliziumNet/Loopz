
function Show-AsTable {
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
    [string]$headerSegment = $($Options.Custom.Snippets.Header);
    [string]$underlineSegment = $($Options.Custom.Snippets.Underline);

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
      $padded = $Headers[$col.Trim()];
      $krayon.Scribble("$($headerSegment)$($padded)$($inter)").End();
    }
    $krayon.Ln().Reset().End();

    # Display column underlines
    #
    $krayon.Text($indentation).End();
    foreach ($col in $selection) {
      $underline = [string]::new($Options.Chrome.Underline, $MetaData[$col].Max);
      $Krayon.Scribble("$($underlineSegment)$($underline)$($inter)").Reset().End();
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
