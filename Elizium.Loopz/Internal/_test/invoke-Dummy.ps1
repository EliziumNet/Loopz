
# WTF, this should be a helper file in Tests/Helpers, but putting this function there and trying to
# dynamically invoke the function with the & operator from invoke-ForachFile doesnt find the
# function definition, regardless of wether its sourced inside BeforeEach, or defined inline or
# any other work-around. The only temporary shit solution, is to include the test helper function
# inside the module implementation, which fucks me off to high fucking heaven.
#
function invoke-Dummy {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
  param(
    [Alias('Underscore')]
    [System.IO.FileInfo]$FileInfo,
    [int]$Index,
    [System.Collections.Hashtable]$PassThru,
    [boolean]$Trigger
  )
  Write-Warning "These aren't the droids you're looking for, ..., move along, move along!";

  [PSCustomObject]@{ Product = $FileInfo; }
}
