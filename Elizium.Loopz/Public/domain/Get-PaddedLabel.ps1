
function Get-PaddedLabel {
  <#
  .NAME
    Get-PaddedLabel

  .SYNOPSIS
    Controls and standardises the way that signals are displayed.

  .DESCRIPTION
    Pads out a string with leading or trailing spaces depending on
  alignment.

  .PARAMETER Label
    The string to be padded

  .PARAMETER Align
    Left or right alignment of the label.

  .PARAMETER Width
    Size of the field into which the label is to be placed.
  #>
  [OutputType([string])]
  param(
    [Parameter()]
    [string]$Label,

    [Parameter()]
    [string]$Align = 'right',

    [Parameter()]
    [int]$Width
  )
  [int]$length = $Label.Length;

  [string]$result = if ($length -lt $Width) {
    [string]$padding = [string]::new(' ', $($Width - $length))
    ($Align -eq 'right') ? $($padding + $Label) : $($Label + $padding);
  } else {
    $Label;
  }

  $result;
}