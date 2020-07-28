
function Invoke-TraverseDirectory {
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory)]
    [ValidateScript( { Test-path -Path $_; })]
    [String]$SourcePath,
  
    [Parameter(Mandatory)]
    [String]$DestinationPath,

    [Parameter()]
    [String[]]$Suffixes = @('*'),

    [Parameter()]
    [String[]]$DirectoryIncludes = @('*'),

    [Parameter(Mandatory)]
    [System.Collections.Hashtable]$PassThru,

    [Parameter(Mandatory)]
    [scriptblock]$SourceFileBlock,

    [Parameter()]
    [scriptblock]$SourceDirectoryBlock = ( { return $true; })
  )

  Write-Host "Invoke-TraverseDirectory >>> SourcePath: '$SourcePath'"
  [string[]]$inclusions = @();
  $Suffixes | ForEach-Object {
    $inclusions += $_.StartsWith('*.') ? $_ : ('*.' + $_)
  }

  $sourcePathWithWildCard = $SourcePath.Contains('*') ? $SourcePath : (Join-Path -Path $SourcePath -ChildPath '*');

  Write-Host "Invoke-TraverseDirectory >>> sourcePathWithWildCard: '$sourcePathWithWildCard'"

  # Invoke the source directory block for this directory
  #
  # $SourceDirectoryBlock.Invoke($sourcePath, $PassThru);

  # Finally traverse this directory's child directories
  #
  [System.IO.DirectoryInfo[]]$sourceDirectoryInfos = Get-ChildItem -Path $sourcePathWithWildCard `
    -Directory -Include $DirectoryIncludes;
  $sourceDirectoryInfos | Invoke-ForeachFsItem -Directory -Block $SourceDirectoryBlock -PassThru $PassThru;
  
  # Deal with top level files for this directory
  # WARNING: you can't use wild card with LiteralPath
  #
  [System.IO.FileInfo[]]$sourceFileInfos = Get-ChildItem -Path $sourcePathWithWildCard `
    -File -Include $inclusions;
  $sourceFileInfos | Invoke-ForeachFsItem -File -Block $SourceFileBlock -PassThru $PassThru;
  
  # Convert directory contents
  #
  [scriptblock]$doTraversal = { param(
      $_underscore,
      $_index,
      $_passThru,
      $_trigger
    )

    # Argh, this looks like mirror directory not traverse. Big blunder here.
    #

    # BUG: Make sure that ROOT-SOURCE ends with /* so that include/exclude works
    # Why the F is rootSource an array of objects instead of a string?
    $rootSource = $_passThru['ROOT-SOURCE'];
    $rootDestination = $_passThru['ROOT-DESTINATION'];

    $sourceDirectoryFullName = $_underscore.FullName;
    $contentsColour = "Green";

    # sourceDirectoryFullName must end with directory separator
    #
    if (-not($sourceDirectoryFullName.EndsWith([System.IO.Path]::DirectorySeparatorChar))) {
      $sourceDirectoryFullName += [System.IO.Path]::DirectorySeparatorChar;
    }

    $destinationBranch = remove-SingleSubString -Target $sourceDirectoryFullName -Subtract $rootSource;
    $destinationDirectory = Join-Path -Path $rootDestination  -ChildPath $destinationBranch;
    # Write-Host "@@@ sourceDirectoryFullName: $sourceDirectoryFullName"
    # Write-Host "--- Subtracting ROOT-SOURCE: '$rootSource' from '$sourceDirectoryFullName'";
    # Write-Host "+++ destination directory: $destinationDirectory"
    # Write-PairInColour @( ("destination directory", "Yellow"), ($destinationDirectory, "Red") );

    Invoke-TraverseDirectory -SourcePath $sourceDirectoryFullName -DestinationPath $destinationDirectory `
      -Suffixes $inclusions -DirectoryIncludes $DirectoryIncludes -PassThru $_passThru `
      -SourceFileBlock $SourceFileBlock -SourceDirectoryBlock $SourceDirectoryBlock;

    return @{ Message = "*** Convert directory contents";
      Product = $_underscore; Colour = $contentsColour 
    };

    # Finally traverse this directory's child directories
    #
    # [System.IO.DirectoryInfo[]]$sourceDirectoryInfos = Get-ChildItem -Path $sourcePathWithWildCard `
    #   -Directory -Include $DirectoryIncludes;
    $sourceDirectoryInfos | Invoke-ForeachFsItem -Directory -Block $doTraversal -PassThru $PassThru;
  } # doTraversal
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
    [parameter(Mandatory)]
    [String]$sourcePath,
  
    [parameter(Mandatory)]
    [String]$destinationPath,

    [parameter(Mandatory)]
    [String]$suffix,

    [parameter(Mandatory)]
    [scriptblock]$onSourceFile,

    [parameter(Mandatory)]
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
