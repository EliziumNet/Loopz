
function test-ValidPatternArrayParam {
  [OutputType([boolean])]
  param(
    [Parameter(Mandatory)]
    [array]$Arg,

    [Parameter()]
    [switch]$AllowWildCard
  )

  [boolean]$result = $Arg -and ($Arg.Count -gt 0) -and ($Arg.Count -lt 2) -and `
    -not([string]::IsNullOrEmpty($Arg[0])) -and (($Arg.Length -eq 1) -or $Arg[1] -ne '*');

  if ($result -and $Arg.Count -gt 1 -and $Arg[1] -eq '*') {
    $result = $AllowWildCard.ToBool();
  }

  $result;
}
