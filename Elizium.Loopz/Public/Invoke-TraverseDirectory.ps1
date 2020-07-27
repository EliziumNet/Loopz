
function Invoke-TraverseDirectory {
  [CmdletBinding()]
  param
  (
    [parameter(Mandatory = $true)]
    [String]$SourcePath,
  
    [parameter(Mandatory = $true)]
    [String]$DestinationPath,

    [parameter(Mandatory = $true)]
    [String]$Suffix,

    [parameter(Mandatory = $true)]
    [scriptblock]$SourceFileBlock,

    [parameter(Mandatory = $true)]
    [System.Collections.Hashtable]$PassThru,

    [parameter()]
    [scriptblock]$SourceDirectoryBlock = ( { return $true; })
  )

  # Deal with top level files
  #

  {
    Invoke-ForeachFile -Directory $sourcePath -inclusions $inclusions -body $onSourceFile -propertyBag $PassThru `
      -summary $summary -Verb;

    [string]$directoryPath = './Tests/Data/fefsi';
    Get-ChildItem $directoryPath | Invoke-ForeachFsItem -Block $block -File;
  }

  
}

function Invoke-TraverseDirectory_Legacy {
  <#
.NAME
  Invoke-TraverseDirectory
.SYNOPSIS
  Peforms a recursive traversal of the source directory tree specified. The source tree
  is mirrored in the destination and invokes the script block for all the files found
  in the source tree in the corresponding location in the destination tree.

.PARAMETER $sourcePath
  The root of the source tree to traverse. (Must exist)

.PARAMETER $destinationPath
  The root of the destination tree to traverse. (Does not need to exist prior to running)

.PARAMETER $suffix
  The file suffix in the source tree to which the script block is to be applied.

.PARAMETER $onSourceFile
  The custom script block, which contains the implementation invoked for each file with
  the suffix specified in the source tree.

.PARAMETER $PassThru
  A hashtable containing custom properties required by the script block. This property bag
  must also include properties named "ROOT-SOURCE" and "ROOT-DESTINATION" which specify
  the root paths of the source and destination file system locations respectively.

.PARAMETER $onSourceDirectory
  The custom script block, which contains the implementation invoked for each source directory.
  The $onSourceDirectory script block takes 2 parameters, $sourcePath; the source directory and
  a custom property bag $PassThru

.PARAMETER $WhatIf
  Perform a dry run of the operation.
#>
  [CmdletBinding()]
  param
  (
    [parameter(Mandatory = $true)]
    [String]$sourcePath,
  
    [parameter(Mandatory = $true)]
    [String]$destinationPath,

    [parameter(Mandatory = $true)]
    [String]$suffix,

    [parameter(Mandatory = $true)]
    [scriptblock]$onSourceFile,

    [parameter(Mandatory = $true)]
    [System.Collections.Hashtable]$PassThru,

    [parameter()]
    [scriptblock]$onSourceDirectory = ( { return $true; })
  )

  $inclusions = "*." + $suffix;
  $summary = "<SUMMARY ...>";

  Invoke-ForeachFile -Directory $sourcePath -inclusions $inclusions -body $onSourceFile -propertyBag $PassThru `
    -summary $summary -Verb;

  # Convert directory contents
  #
  [scriptblock]$doTraversal = { param($underscore, $index, $properties)

    $rootSource = $properties["ROOT-SOURCE"];
    $rootDestination = $properties["ROOT-DESTINATION"];

    $sourceDirectoryName = $underscore.Name;
    $sourceDirectoryFullName = $underscore.FullName;
    $contentsColour = "Green";

    $destinationBranch = Edit-SubtractFirst -Target $sourceDirectoryFullName -Subtract $rootSource;
    $destinationDirectory = Join-Path -Path $rootDestination  -ChildPath $destinationBranch;
    Write-PairInColour @( ("destination directory", "Yellow"), ($destinationDirectory, "Red") );

    Invoke-TraverseDirectory -source $sourceDirectoryFullName -destination $destinationDirectory `
      -suffix $suffix -onSourceFile $onSourceFile -propertyBag $PassThru -onSourceDirectory $onSourceDirectory;

    return @{ Message = "*** Convert directory contents"; Product = $sourceDirectoryName; Colour = $contentsColour };
  }

  $null = Invoke-ForeachDirectory -Directory $sourcePath -body $doTraversal -propertyBag $PassThru;

  # Invoke the source directory block
  #
  $null = $onSourceDirectory.Invoke($sourcePath, $PassThru);
}
