
function get-PaddedLabel {
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