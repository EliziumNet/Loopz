
function Format-BooleanCellValue {
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
