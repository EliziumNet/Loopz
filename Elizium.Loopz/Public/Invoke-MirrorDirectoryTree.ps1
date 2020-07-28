
function Invoke-MirrorDirectoryTree {
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

  Write-Host "Invoke-MirrorDirectoryTree >>> SourcePath: '$SourcePath'"
  [string[]]$inclusions = @();
  $Suffixes | ForEach-Object {
    $inclusions += $_.StartsWith('*.') ? $_ : ('*.' + $_)
  }

  $sourcePathWithWildCard = $SourcePath.Contains('*') ? $SourcePath : (Join-Path -Path $SourcePath -ChildPath '*');

  Write-Host "Invoke-MirrorDirectoryTree >>> sourcePathWithWildCard: '$sourcePathWithWildCard'"

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

    Invoke-MirrorDirectoryTree -SourcePath $sourceDirectoryFullName -DestinationPath $destinationDirectory `
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



