
function Select-FsItem {
  <#
  .NAME
    Select-FsItem

  .SYNOPSIS
    A predication function that indicates whether an item identified by the Name matches
  the include/exclude filters specified.

  .DESCRIPTION
    Use this utility function to help specify a Condition for Invoke-TraverseDirectory.
  This function is partly required because the Include/Exclude parameters on functions
  such as Get-ChildItems/Copy-Item/Get-Item etc only work on files not directories. 

  .PARAMETER Name
    A string to be matched against the filters.

  .PARAMETER Includes
      An array containing a list of filters, each must contain a wild-card ('*'). If a
  particular filter does not contain a wild-card, then it will be ignored. If Name matches
  any of the filters in Includes, and are not Excluded, the result will be true.

  .PARAMETER Excludes
    An array containing a list of filters, each must contain a wild-card ('*'). If a
  particular filter does not contain a wild-card, then it will be ignored. If the Name
  matches any of the filters in the list, will cause the end result to be false.
  Any match in the Excludes overrides a match in Includes, so an item
  that is matched in Include, can be excluded by the Exclude.

  .PARAMETER Case
    Switch parameter which controls case sensitivity of inclusion/exclusion. By default
  filtering is case insensitive. When The Case switch is specified, filtering is case
  sensitive.

  .EXAMPLE 1
    Define a Condition that allows only directories beginning with A, but also excludes
    any directory containing '_' or '-'.

    [scriptblock]$filterDirectories = {
      [OutputType([boolean])]
      param(
        [System.IO.DirectoryInfo]$directoryInfo
      )
      [string[]]$directoryIncludes = @('A*');
      [string[]]$directoryExcludes = @('*_*', '*-*');

      Select-FsItem -Name $directoryInfo.Name `
        -Includes $directoryIncludes -Excludes $directoryExcludes;

      Invoke-TraverseDirectory -Path <path> -Block <block> -Condition $filterDirectories;
    }
  #>

  [OutputType([boolean])]
  param(
    [Parameter(Mandatory)]
    [string]$Name,

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
    ? (select-ResolvedFsItem -FsItem $Name -Filter $Includes -Case:$Case) `
    : $false;

  [boolean]$resolvedExclude = $validExcludes `
    ? (select-ResolvedFsItem -FsItem $Name -Filter $Excludes -Case:$Case) `
    : $false;

  ($resolvedInclude) -and -not($resolvedExclude)
} # Select-FsItem
