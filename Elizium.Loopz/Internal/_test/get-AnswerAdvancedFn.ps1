function get-AnswerAdvancedFn {

  # This function is only required because the tests using the invoke operator
  # on a string can not correctly pick up the local function name (ie defined as part
  # of the test fixture) and see its definition to be invoked.
  #
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [Parameter(Mandatory)]
    $Underscore,
  
    [Parameter(Mandatory)]
    [int]$Index,
  
    [Parameter(Mandatory)]
    [System.Collections.Hashtable]$PassThru,
  
    [Parameter(Mandatory)]
    [boolean]$Trigger
  )

  [PSCustomObject]@{ Product = "{0}: {1}" -f $Underscore, $PassThru['ANSWER'] }
}
