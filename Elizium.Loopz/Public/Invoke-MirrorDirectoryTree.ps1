function Invoke-MirrorDirectoryTree {
  [CmdletBinding(SupportsShouldProcess)]
  [Alias('imdt', 'Mirror-Directory')]
  param
  (
    [Parameter(Mandatory)]
    [ValidateScript( { Test-path -Path $_; })]
    [String]$Path,

    [Parameter(Mandatory)]
    [String]$DestinationPath,

    # The include/exclude parameters are collections of filters (can contain a *).
    # If an entry does not include a *, it is treated as a suffix for files
    # and ignored for directories.
    #
    [Parameter()]
    [String[]]$DirectoryIncludes = @('*'),

    [Parameter()]
    [String[]]$DirectoryExcludes = @(),

    [Parameter()]
    [String[]]$FileIncludes = @('*'),

    [Parameter()]
    [String[]]$FileExcludes = @(),

    [Parameter()]
    [System.Collections.Hashtable]$PassThru = @{},

    [Parameter()]
    [scriptblock]$DirectoryBlock = ( {} ),

    [Parameter()]
    [switch]$CreateDirs,

    [Parameter()]
    [switch]$CopyFiles,

    [Parameter()]
    [switch]$Hoist
  )

  [scriptblock]$doMirrorBlock = {
    param(
      [Parameter(Mandatory)]
      [System.IO.DirectoryInfo]$_underscore,

      [Parameter(Mandatory)]
      [int]$_index,

      [Parameter(Mandatory)]
      [System.Collections.Hashtable]$_passThru,

      [Parameter(Mandatory)]
      [boolean]$_trigger
    )

    # Write-Host "[+] >>> doMirrorBlock: $($_underscore.Name)";

    [string]$rootSource = $_passThru['LOOPZ.MIRROR.ROOT-SOURCE'];
    [string]$rootDestination = $_passThru['LOOPZ.MIRROR.ROOT-DESTINATION'];

    $sourceDirectoryFullName = $_underscore.FullName;

    # sourceDirectoryFullName must end with directory separator
    #
    if (-not($sourceDirectoryFullName.EndsWith([System.IO.Path]::DirectorySeparatorChar))) {
      $sourceDirectoryFullName += [System.IO.Path]::DirectorySeparatorChar;
    }

    $destinationBranch = remove-SingleSubString -Target $sourceDirectoryFullName -Subtract $rootSource;
    $destinationDirectory = Join-Path -Path $rootDestination -ChildPath $destinationBranch;

    [boolean]$whatIf = $_passThru.ContainsKey('LOOPZ.MIRROR.WHAT-IF') -and ($_passThru['LOOPZ.MIRROR.WHAT-IF']);
    Write-Debug "[+] >>> doMirrorBlock: destinationDirectory: '$destinationDirectory'";
  
    if ($CreateDirs.ToBool()) {
      Write-Debug "    [-] Creating destination branch directory: '$destinationBranch'";

      $destinationInfo = (Test-Path -Path $destinationDirectory) `
        ? (Get-Item -Path $destinationDirectory) `
        : (New-Item -ItemType 'Directory' -Path $destinationDirectory -WhatIf:$whatIf);
    }
    else {
      Write-Debug "    [-] Creating destination branch directory INFO obj: '$destinationBranch'";
      $destinationInfo = New-Object -TypeName System.IO.DirectoryInfo ($destinationDirectory);
    }

    if ($CopyFiles.ToBool() -and $CreateDirs.ToBool()) {
      Write-Debug "    [-] Creating files for branch directory: '$destinationBranch'";

      # To use the include/exclude parameters on Copy-Item, the Path specified
      # must end in /*. We only need to add the star though because we added the /
      # previously.
      #
      [string]$sourceDirectoryWithWildCard = $sourceDirectoryFullName + '*';

      Copy-Item -Path $sourceDirectoryWithWildCard -Include $FileIncludes -Exclude $FileExcludes `
        -Destination $destinationDirectory -WhatIf:$whatIf;
    }

    $_passThru['LOOPZ.MIRROR.DESTINATION'] = $destinationInfo;
    [scriptblock]$directoryBlock = $_passThru['LOOPZ.MIRROR.DIRECTORY-BLOCK'];

    try {
      $directoryBlock.Invoke($_underscore, $_index, $_passThru, $_trigger);
    }
    catch {
      Write-Error "function invoke error doMirrorBlock: error ($_) occurred for '$destinationBranch'";
    }

    @{ Product = $destinationInfo }
  } #doMirrorBlock

  [scriptblock]$summary = {
    param(
      [Parameter(Mandatory)]
      [System.Collections.Hashtable]$_passThru
    )
  }

  [string]$resolvedSourcePath = Convert-Path $Path;
  [string]$resolvedDestinationPath = Convert-Path $DestinationPath;

  $PassThru['LOOPZ.MIRROR.ROOT-SOURCE'] = $resolvedSourcePath;
  $PassThru['LOOPZ.MIRROR.ROOT-DESTINATION'] = $resolvedDestinationPath;
  $PassThru['LOOPZ.MIRROR.DIRECTORY-BLOCK'] = $DirectoryBlock;

  if ($PSBoundParameters.ContainsKey('WhatIf')) {
    $PassThru['LOOPZ.MIRROR.WHAT-IF'] = $true;
  }

  [scriptblock]$filterDirectories = {
    [OutputType([boolean])]
    param(
      [System.IO.DirectoryInfo]$directoryInfo
    )
    Select-Directory -DirectoryInfo $directoryInfo `
      -Includes $DirectoryIncludes -Excludes $DirectoryExcludes;
  }

  Invoke-TraverseDirectory -Path $resolvedSourcePath `
    -SourceDirectoryBlock $doMirrorBlock -PassThru $PassThru -Summary $summary `
    -Condition $filterDirectories -Hoist:$Hoist;
} # Invoke-MirrorDirectoryTree
