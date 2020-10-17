
function Get-InverseSubString {
  param(
    [Parameter(Position = 0, Mandatory)]
    [string]$Source,

    [Parameter()]
    [ValidateScript( { $_ -lt $Source.Length })]
    [int]$StartIndex = 0,

    [Parameter()]
    [ValidateScript( { $_ -le ($Source.Length - $StartIndex ) })]
    [int]$Length = 0,

    [Parameter()]
    [switch]$Split
  )

  $result = if ($StartIndex -eq 0) {
    $Source.SubString($Length);
  }
  else {
    [string]$head = $Source.SubString(0, $StartIndex);
    [string]$tail = $Source.SubString($StartIndex + $Length);
    ($Split.ToBool()) ? ($head, $tail) : ($head + $tail);
  }
  $result;
}
