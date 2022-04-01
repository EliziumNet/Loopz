using module Elizium.Krayola;

function Show-AsTable {
  <#
  .NAME
    Show-AsTable

  .SYNOPSIS
    Shows the provided data in a coloured table form.

  .DESCRIPTION
    Requires table meta data, headers and values and renders the content according
  to the options provided. The clint can override the default cell rendering behaviour
  by providing a render function.

  .LINK
    https://eliziumnet.github.io/Loopz/

  .PARAMETER Headers
    Hashtable instance that represents the headers displayed for the table. Maps the
  raw column title to the actual text used to display it. In practice, this is a
  space padded version of the raw title determined from the meta data.

  .PARAMETER MetaData
    Hashtable instance which maps column titles to a PSCustomObject instance that
  contains display information pertaining to that column. The object must contain

  - FieldName: the name of the column
  - Max: the size of the largest value found in the table data for that column
  - Type: the type of data represented by that column
  
  .PARAMETER Options
    The table display options (See command Get-TableDisplayOptions)

  .PARAMETER Render
    A script-block allowing client defined cell rendering logic. The Render script-block
  contains the following parameters:
  - Column: spaced padded column title, indicating which column this cell is in.
  - Value: the current value of the cell being rendered.
  - row: a PSCustomObject containing all the field values for the current row. The whole
  row is presented to the cell render function so that cross field functionality can be
  defined.
  - Options: The table display options
  - Scribbler: The Krayola scribbler instance
  - counter: the row number

  .PARAMETER Scribbler
    The Krayola scribbler instance used to manage rendering to console.

  .PARAMETER Table
    Hashtable containing the table data. Currently, the data row is indexed by the
  'Name' property and as such, the Name in in row must be unique (actually acts
  like its the primary key for the table; this will be changed in future so that
  an alternative ID field is used instead of Name.)

  .PARAMETER Title
    If provided, this will be shown as the title for this table.

  .PARAMETER TitleFormat
    A table title format string which must contain a {0} place holder for the Title
  to be inserted into.
  #>
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
  # TODO: The client should be able to define a render method on a per column basis.
  # Currently there is just a single render callback supported. And ideally, we should be
  # able to present the entire row, not just the current cell. This will enable cross
  # field functionality to be defined.
  #
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
