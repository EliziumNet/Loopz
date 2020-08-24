
function get-AffirmedProduct {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
  param(
    [Alias('Underscore')]
    [System.IO.FileInfo]$FileInfo,
    [int]$Index,
    [System.Collections.Hashtable]$PassThru,
    [boolean]$Trigger
  )

  [PSCustomObject]@{ Product = $FileInfo; Affirm = $true}
}
