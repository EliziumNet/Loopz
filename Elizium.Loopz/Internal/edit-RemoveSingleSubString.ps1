
function edit-RemoveSingleSubString {
  <#
.NAME
  edit-RemoveSingleSubString

.SYNOPSIS
  Removes a sub-string from the target string provided.

.DESCRIPTION
  Either the first or the last occurrence of a single can be removed depending on
  whether the Last flag has been set.

.PARAMETER Target
  The string from which the subtraction is to occur.

.PARAMETER Subtract
  The sub string to subtract from the Target.

.PARAMETER Insensitive
  Flag to indicate if the search is case sensitive or not. By default, search is case
  sensitive.

.PARAMETER Last
  Flag to indicate whether the last occurrence of a sub string is to be removed from the
  Target.
#>
  [CmdletBinding(DefaultParameterSetName = 'Single')]
  [OutputType([string])]
  param
  (
    [Parameter(ParameterSetName = 'Single')]
    [String]$Target,

    [Parameter(ParameterSetName = 'Single')]
    [String]$Subtract,

    [Parameter(ParameterSetName = 'Single')]
    [switch]$Insensitive,

    [Parameter(ParameterSetName = 'Single')]
    [Parameter(ParameterSetName = 'LastOnly')]
    [switch]$Last
  )

  [StringComparison]$comparison = $Insensitive.ToBool() ? `
    [StringComparison]::OrdinalIgnoreCase : [StringComparison]::Ordinal;

  $result = $Target;

  # https://docs.microsoft.com/en-us/dotnet/standard/base-types/best-practices-strings
  #
  if (($Subtract.Length -gt 0) -and ($Target.Contains($Subtract, $comparison))) {
    $slen = $Subtract.Length;

    $foundAt = $Last.ToBool() ? $Target.LastIndexOf($Subtract, $comparison) : `
      $Target.IndexOf($Subtract, $comparison);

    if ($foundAt -eq 0) {
      $result = $Target.Substring($slen);
    }
    elseif ($foundAt -gt 0) {
      $result = $Target.Substring(0, $foundAt);
      $result += $Target.Substring($foundAt + $slen);
    }
  }

  $result;
}
