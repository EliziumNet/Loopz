
# NB The table returned, uses the 'Name' as the row's key, and implies 2 things
# 1) the table must have a Name column
# 2) no 2 rows can have the same Name
# This could be improved upon in the future to remove these 2 limitations
#
function Get-AsTable {
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
