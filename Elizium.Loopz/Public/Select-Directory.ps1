
function Select-Directory {
  [OutputType([boolean])]
  param(
    [Parameter(Mandatory)]
    [System.IO.DirectoryInfo]$DirectoryInfo,

    [Parameter()]
    [string[]]$Includes = @(),

    [Parameter()]
    [string[]]$Excludes = @(),

    [Parameter()]
    [switch]$Case
  )

  # Note we wrap the result inside @() array designator just in-case the where-object
  # returns just a single item in which case the array would be flattened out into
  # an individual scalar value which is what we don't want, damn you powershell for
  # doing this and making life just so much more difficult. Actually, on further
  # investigation, we don't need to wrap inside @(), because we've explicitly defined
  # the type of the includes variables to be arrays, which would preserve the type
  # even in the face of powershell annoyingly flattening the single item array. @()
  # being left in for clarity and show of intent.
  #
  [string[]]$validIncludes = @($Includes | Where-Object { $_.Contains('*') })
  [string[]]$validExcludes = @($Excludes | Where-Object { $_.Contains('*') })

  [boolean]$resolvedInclude = $validIncludes `
    ? (select-ResolvedDirectory -DirectoryInfo $DirectoryInfo -Filter $Includes -Case:$Case) `
    : $false;

  [boolean]$resolvedExclude = $validExcludes `
    ? (select-ResolvedDirectory -DirectoryInfo $DirectoryInfo -Filter $Excludes -Case:$Case) `
    : $false;

  ($resolvedInclude) -and -not($resolvedExclude)
}
