
function Update-GroupRefs {
  <#
  .NAME
    Update-GroupRefs

  .SYNOPSIS
    Updates group references with their captured values.

  .DESCRIPTION
    Returns a new string that reflects the replacement of group named references. The only
  exception is $0, meaning the whole match (not required).

  .LINK
    https://eliziumnet.github.io/Loopz/

  .PARAMETER Source
    The source value containing group references. NB This MUST be an un-interpolated string,
  so if using a literal it should be in single quotes NOT double; this is to prevent the
  interpolation process from attempting to evaluate the group reference, eg ${count}.

  .PARAMETER Captures
    Hashtable mapping named group reference to group capture value.

  #>
  [OutputType([string])]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
  param(
    [Parameter()]
    [string]$Source,

    [Parameter()]
    [Hashtable]$Captures
  )

  [string]$sourceText = $Source;
  $Captures.GetEnumerator() | ForEach-Object {
    if ($_.Key -ne '0') {
      [string]$groupRef = $('${' + $_.Key + '}');
      $sourceText = $sourceText.Replace($groupRef, $_.Value);
    }
  }

  return $sourceText;
}
