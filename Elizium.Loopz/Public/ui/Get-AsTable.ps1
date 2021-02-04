
function Get-AsTable { # <= Get-RawTable
  [OutputType([hashtable])]
  param(
    [Parameter()]
    [hashtable]$MetaData,

    [Parameter()]
    [PSCustomObject[]]$TableData,

    [Parameter()]
    [PSCustomObject]$Options,

    [Parameter()]
    [scriptblock]$Evaluate = $([scriptblock] { # this is getting a bit long, we need to store this elsewhere
        [OutputType([string])]
        param(
          [string]$value,
          [PSCustomObject]$columnData,
          [boolean]$isHeader,
          [PSCustomObject]$Options
        )
        # This impl, not in use (discard it)!
        #
        # If the client wants to use this default, the meta data must
        # contain an int Max field denoting the max value size.
        #
        $max = $($columnData.Max);

        [string]$align = $isHeader ? $Options.HeaderAlign : $Options.ValueAlign;

        # TODO: we need a better way of doing this. IE evaluate based upon the field type
        # Date fields may need a way to be formatted
        #
        $result = if ($isHeader -or -not('System.Boolean' -eq $columnData.Type.ToString()) ) {
          $(Get-PaddedLabel -Label $value -Width $max -Align $align);
        }
        else {
          [string]$customFieldView = $value -eq 'True' ? '✔️' : '✖️';
          $(Get-PaddedLabel -Label $customFieldView -Width $max -Align $align);
        }

        return $result;
      })
  )

  [hashtable]$headers = @{}
  $MetaData.GetEnumerator() | ForEach-Object {
    $headers[$_.Key] = $Evaluate.InvokeReturnAsIs($_.Key, $MetaData[$_.Key], $true, $Options)
  }

  [hashtable]$table = @{}
  foreach ($row in $TableData) {
    [PSCustomObject]$insert = @{}
    foreach ($field in $row.psobject.properties.name) {
      [string]$raw = $row.$field;
      [string]$cell = $Evaluate.InvokeReturnAsIs($raw, $MetaData[$field], $false, $Options);
      $insert.$field = $cell;
    }
    # Insert table row here
    #
    $table[$row.Name] = $insert;
  }

  return $headers, $table;
}
