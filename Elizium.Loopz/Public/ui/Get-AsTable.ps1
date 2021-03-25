
function Get-AsTable {
  <#
  .NAME
    Get-AsTable

  .SYNOPSIS
    Selects the table header and data from source and meta data.

  .DESCRIPTION
    The client can override the behaviour to perform custom evaluation of
  table cell values. The default will space pad the cell value and align
  according the table options (./HeaderAlign and ./ValueAlign).

  .PARAMETER Evaluate
    A script-block allowing client defined cell rendering logic. The Render script-block
  contains the following parameters:
  - Value: the current value of the cell being rendered.
  - columnData: column meta data
  - isHeader: flag to indicate if the current cell being evaluated is a header, if false
  then it is a data cell.
  - Options: The table display options

  .PARAMETER MetaData
    Hashtable instance which maps column titles to a PSCustomObject instance that
  contains display information pertaining to that column. The object must contain
  - FieldName: the name of the column
  - Max: the size of the largest value found in the table data for that column
  - Type: the type of data represented by that column

  .PARAMETER Options
    The table display options (See Get-TableDisplayOptions)

  .PARAMETER TableData
    Hashtable containing the table data.
  #>
  [OutputType([hashtable])]
  param(
    [Parameter()]
    [hashtable]$MetaData,

    [Parameter()]
    [PSCustomObject[]]$TableData,

    [Parameter()]
    [PSCustomObject]$Options,

    [Parameter()]
    [scriptblock]$Evaluate = $([scriptblock] {
        [OutputType([string])]
        param(
          [string]$value,
          [PSCustomObject]$columnData,
          [boolean]$isHeader,
          [PSCustomObject]$Options
        )
        # If the client wants to use this default, the meta data must
        # contain an int Max field denoting the max value size.
        #
        $max = $columnData.Max;

        [string]$align = $isHeader ? $Options.HeaderAlign : $Options.ValueAlign;
        return $(Get-PaddedLabel -Label $value -Width $max -Align $align);
      }
    )
  )
  # NB The table returned, uses the 'Name' as the row's key, and implies 2 things
  # 1) the table must have a Name column
  # 2) no 2 rows can have the same Name
  # This could be improved upon in the future to remove these 2 limitations
  #
  [hashtable]$headers = @{}
  $MetaData.GetEnumerator() | ForEach-Object {
    $headers[$_.Key] = $Evaluate.InvokeReturnAsIs($_.Key, $MetaData[$_.Key], $true, $Options)
  }

  [hashtable]$table = @{}
  foreach ($row in $TableData) {
    [PSCustomObject]$insert = @{}
    foreach ($field in $row.psobject.properties.name) { # .name here should not be assumed; it should be custom ID field
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
