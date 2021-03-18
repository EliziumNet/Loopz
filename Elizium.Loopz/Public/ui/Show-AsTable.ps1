
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
    [string]$Title,

    [Parameter()]
    [string]$TitleFormat = "--- [ {0} ] ---",
  
    [Parameter()]
    [Scribbler]$Scribbler,

    [Parameter()]
    [scriptblock]$Render = $([scriptblock] {
        [OutputType([boolean])]
        param(
          [string]$column,
          [string]$Value,
          [PSCustomObject]$row,
          [PSCustomObject]$Options,
          [Scribbler]$Scribbler,
          [boolean]$counter
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
  
  $Scribbler.Scribble("$($resetSnippet)$($lnSnippet)");

  if (($MetaData.PSBase.Count -gt 0) -and ($Table.PSBase.Count -gt 0)) {
    if ($PSBoundParameters.ContainsKey('Title') -and -not([string]::IsNullOrEmpty($Title))) {
      [string]$titleSnippet = $($Options.Snippets.Title);
      [string]$titleUnderlineSnippet = $($Options.Snippets.TitleUnderline);
      [string]$adornedTitle = $TitleFormat -f $Title;
      [int]$ulLength = $Options.Chrome.TitleUnderline.Length;

      [string]$underline = $Options.Chrome.TitleUnderline * $(($adornedTitle.Length / $ulLength) + 1);

      if ($underline.Length -gt $adornedTitle.Length) {
        $underline = $underline.Substring(0, $adornedTitle.Length);
      }

      [string]$titleFragment = $(
        "$($lnSnippet)" +
        "$($indentation)$($titleSnippet)$($adornedTitle)$($resetSnippet)" +
        "$($lnSnippet)" +
        "$($indentation)$($titleUnderlineSnippet)$($underline)$($resetSnippet)" +
        "$($resetSnippet)$($lnSnippet)$($lnSnippet)"
      );
      $Scribbler.Scribble($titleFragment);
    }

    # Establish field selection
    #
    [string[]]$selection = Get-PsObjectField -Object $Options -Field 'Select';

    if (-not($selection)) {
      $selection = $Headers.PSBase.Keys;
    }

    # Display column titles
    #
    $Scribbler.Scribble($indentation);

    foreach ($col in $selection) {
      [string]$paddedValue = $Headers[$col.Trim()];
      $Scribbler.Scribble("$($headerSnippet)$($paddedValue)$($resetSnippet)$($inter)");
    }
    $Scribbler.Scribble("$($lnSnippet)$($resetSnippet)");

    # Display column underlines
    #
    $Scribbler.Scribble($indentation);
    foreach ($col in $selection) {
      $underline = [string]::new($Options.Chrome.Underline, $MetaData[$col].Max);
      $Scribbler.Scribble("$($underlineSnippet)$($underline)$($inter)$($resetSnippet)");
    }
    $Scribbler.Scribble($lnSnippet);

    # Display field values
    #
    [int]$counter = 1;
    $Table.GetEnumerator() | Sort-Object Name | ForEach-Object { # Name here should be custom ID field which should probably default to 'ID'
      $Scribbler.Scribble($indentation);

      foreach ($col in $selection) {
        if (-not($Render.InvokeReturnAsIs(
          $col, $_.Value.$col, $_.Value, $Options, $Scribbler, $counter))
        ) {
          $Scribbler.Scribble("$($resetSnippet)$($_.Value.$col)");
        }
        $Scribbler.Scribble($inter);
      }

      $Scribbler.Scribble($lnSnippet);
      $counter++;
    }
  }
}
