
function Format-BooleanCellValue {
  <#
  .NAME
    Format-BooleanCellValue

  .SYNOPSIS
    Table Render callback that can be passed into Show-AsTable

  .DESCRIPTION
    For table cells containing boolean fields, this callback function will
  render the cell with alternative values other than 'true' or 'false'. Typically,
  the client would set the alternative representation of these boolean values
  (the default values are emoji values 'SWITCH-ON'/'SWITCH-OFF') in the table
  options.

  .PARAMETER TableOptions
    The PSCustomObject that contains the alternative boolean values (./Values/True
  and ./Values/False)

  .PARAMETER Value
    The original boolean value in string form.
  #>
  [OutputType([string])]
  param(
    [Parameter()]
    [string]$Value,

    [Parameter()]
    [PSCustomObject]$TableOptions
  )

  [string]$coreValue = $value.Trim() -eq 'True' `
    ? $TableOptions.Values.True : $TableOptions.Values.False;

  [string]$cellValue = Get-PaddedLabel -Label $coreValue -Width $value.Length `
    -Align $TableOptions.Align.Cell;

  return $cellValue;
}
