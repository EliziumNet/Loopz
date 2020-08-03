function Invoke-MirrorDirectoryTree {
  [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'InvokeScriptBlock')]
  [Alias('imdt', 'Mirror-Directory')]
  param
  (
    [Parameter(Mandatory, ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(Mandatory, ParameterSetName = 'InvokeFunction')]
    [ValidateScript( { Test-path -Path $_; })]
    [String]$Path,

    [Parameter(Mandatory, ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(Mandatory, ParameterSetName = 'InvokeFunction')]
    [String]$DestinationPath,

    # The include/exclude parameters are collections of filters (can contain a *).
    # If an entry does not include a *, it is treated as a suffix for files
    # and ignored for directories.
    #
    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [String[]]$DirectoryIncludes = @('*'),

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [String[]]$DirectoryExcludes = @(),

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [String[]]$FileIncludes = @('*'),

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [String[]]$FileExcludes = @(),

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [System.Collections.Hashtable]$PassThru = @{},

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [scriptblock]$Block = ( {
        param(
          [System.IO.DirectoryInfo]$underscore,
          [int]$index,
          [System.Collections.Hashtable]$passThru,
          [boolean]$trigger
        )
      } ),

    [Parameter(ParameterSetName = 'InvokeFunction', Mandatory)]
    [ValidateScript( { -not([string]::IsNullOrEmpty($_)); })]
    [string]$Functee,

    [Parameter(ParameterSetName = 'InvokeFunction')]
    [ValidateScript( { $_.Length -gt 0; })]
    [System.Collections.Hashtable]$FuncteeParams = @{},

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [switch]$CreateDirs,

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [switch]$CopyFiles,

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [switch]$Hoist,

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [scriptblock]$Summary = ( {
        param(
          [int]$index,
          [int]$skipped,
          [boolean]$trigger,
          [System.Collections.Hashtable]$_passThru
        )
      })
  ) # param

  # ================================================================== [doMirrorBlock] ===
  #
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

      [string[]]$adjustedFileIncludes = $FileIncludes | ForEach-Object {
        $_.Contains('*') ? $_ : "*.$_".Replace('..', '.');
      }

      [string[]]$adjustedFileExcludes = $FileExcludes | ForEach-Object {
        $_.Contains('*') ? $_ : "*.$_".Replace('..', '.');
      }

      Copy-Item -Path $sourceDirectoryWithWildCard `
        -Include $adjustedFileIncludes -Exclude $adjustedFileExcludes `
        -Destination $destinationDirectory -WhatIf:$whatIf;
    }

    # To be consistent with Invoke-ForeachFsItem, the user function/block is invoked
    # with the source directory info. The destination for this mirror operation is
    # returned via 'LOOPZ.MIRROR.DESTINATION' within the PassThru.
    # 
    $_passThru['LOOPZ.MIRROR.DESTINATION'] = $destinationInfo;

    $invokee = $_passThru['LOOPZ.MIRROR.INVOKEE'];

    try {
      if ($invokee -is [scriptblock]) {
        $invokee.Invoke($_underscore, $_index, $_passThru, $_trigger);
      }
      elseif ($invokee -is [string]) {
        [System.Collections.Hashtable]$parameters = $_passThru['LOOPZ.MIRROR.INVOKEE.PARAMS'];
        $parameters['Underscore'] = $_underscore;
        $parameters['Index'] = $_index;
        $parameters['PassThru'] = $_passThru;
        $parameters['Trigger'] = $_trigger;
        $parameters;

        & $invokee @parameters;
      }
      else {
        Write-Warning "User defined function/block not valid, not invoking.";
      }
    }
    catch {
      Write-Error "function invoke error doMirrorBlock: error ($_) occurred for '$destinationBranch'";
    }

    # [scriptblock]$directoryBlock = $_passThru['LOOPZ.MIRROR.INVOKEE'];

    # try {
    #   $directoryBlock.Invoke($_underscore, $_index, $_passThru, $_trigger);
    # }
    # catch {
    #   Write-Error "function invoke error doMirrorBlock: error ($_) occurred for '$destinationBranch'";
    # }

    @{ Product = $destinationInfo }
  } #doMirrorBlock

  # ===================================================== [Invoke-MirrorDirectoryTree] ===

  [string]$resolvedSourcePath = Convert-Path $Path;
  [string]$resolvedDestinationPath = Convert-Path $DestinationPath;

  $PassThru['LOOPZ.MIRROR.ROOT-SOURCE'] = $resolvedSourcePath;
  $PassThru['LOOPZ.MIRROR.ROOT-DESTINATION'] = $resolvedDestinationPath;

  if ('InvokeScriptBlock' -eq $PSCmdlet.ParameterSetName) {
    $PassThru['LOOPZ.MIRROR.INVOKEE'] = $Block;
  }
  else {
    $PassThru['LOOPZ.MIRROR.INVOKEE'] = $Functee;
    $PassThru['LOOPZ.MIRROR.INVOKEE.PARAMS'] = $FuncteeParams;
  }

  if ($PSBoundParameters.ContainsKey('WhatIf') -and ($true -eq $PSBoundParameters['WhatIf'])) {
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
    -Block $doMirrorBlock -PassThru $PassThru -Summary $Summary `
    -Condition $filterDirectories -Hoist:$Hoist;

  # [System.Collections.Hashtable]$parametersTraverse = @{
  #   'Path'      = $resolvedSourcePath;
  #   'PassThru'  = $PassThru;
  #   'Summary'   = $Summary;
  #   'Condition' = $filterDirectories;
  # }

  # if ($Hoist.ToBool()) {
  #   $parametersTraverse['Hoist'] = $true;
  # }

  # if ('InvokeScriptBlock' -eq $PSCmdlet.ParameterSetName) {
  #   $parametersTraverse['Block'] = $doMirrorBlock;
  # }
  # else {
  #   $parametersTraverse['Functee'] = $Functee;
  #   $parametersTraverse['FuncteeParams'] = $FuncteeParams;
  # }

  # & 'Invoke-TraverseDirectory' @parametersTraverse;
} # Invoke-MirrorDirectoryTree
