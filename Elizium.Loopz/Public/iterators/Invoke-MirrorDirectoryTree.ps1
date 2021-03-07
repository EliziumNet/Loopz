function Invoke-MirrorDirectoryTree {
  <#
  .NAME
    Invoke-MirrorDirectoryTree

  .SYNOPSIS
    Mirrors a directory tree to a new location, invoking a custom defined scriptblock
  or function as it goes.

  .DESCRIPTION
    Copies a source directory tree to a new location applying custom functionality for each
  directory. 2 parameters set are defined, one for invoking a named function (InvokeFunction) and
  the other (InvokeScriptBlock, the default) for invoking a scriptblock. An optional
  Summary script block can be specified which will be invoked at the end of the mirroring
  batch.

  .PARAMETER Block
    The script block to be invoked. The script block is invoked for each directory in the
  source directory tree that satisfy the specified Directory Include/Exclude filters with
  the following positional parameters:
    * underscore: the DirectoryInfo object representing the directory in the source tree
    * index: the 0 based index representing current directory in the source tree
    * Exchange object: a hash table containing miscellaneous information gathered internally
    throughout the mirroring batch. This can be of use to the user, because it is the way
    the user can perform bi-directional communication between the invoked custom script block
    and client side logic.
    * trigger: a boolean value, useful for state changing idempotent operations. At the end
    of the batch, the state of the trigger indicates whether any of the items were actioned.
    When the script block is invoked, the trigger should indicate if the trigger was pulled for
    any of the items so far processed in the batch. This is the responsibility of the
    client's script-block/function implementation.

  In addition to these fixed positional parameters, if the invoked scriptblock is defined
  with additional parameters, then these will also be passed in. In order to achieve this,
  the client has to provide excess parameters in BlockParams and these parameters must be
  defined as the same type and in the same order as the additional parameters in the
  script-block.

  The destination DirectoryInfo object can be accessed via the Exchange denoted by
  the 'LOOPZ.MIRROR.DESTINATION' entry.

  .PARAMETER BlockParams
    Optional array containing the excess parameters to pass into the script-block/function.

  .PARAMETER CopyFiles
    Switch parameter that indicates that files matching the specified filters should be copied

  .PARAMETER CreateDirs
    switch parameter indicates that directories should be created in the destination tree. If
  not set, then Invoke-MirrorDirectoryTree turns into a function that traverses the source
  directory invoking the function/script-block for matching directories.

  .PARAMETER DestinationPath
    The destination Path denoting the root of the directory tree where the source tree
  will be mirrored to.

  .PARAMETER DirectoryIncludes
    An array containing a list of filters, each must contain a wild-card ('*'). If a
  particular filter does not contain a wild-card, then it will be ignored. If the directory
  matches any of the filters in the list, it will be mirrored in the destination tree.
  If DirectoryIncludes contains just a single element which is the empty string, this means
  that nothing is included (rather than everything being included).

  .PARAMETER DirectoryExcludes
    An array containing a list of filters, each must contain a wild-card ('*'). If a
  particular filter does not contain a wild-card, then it will be ignored. If the directory
  matches any of the filters in the list, it will NOT be mirrored in the destination tree.
  Any match in the DirectoryExcludes overrides a match in DirectoryIncludes, so a directory
  that is matched in Include, can be excluded by the Exclude.

  .PARAMETER Exchange
    A hash table containing miscellaneous information gathered internally
  throughout the pipeline batch. This can be of use to the user, because it is the way
  the user can perform bi-directional communication between the invoked custom script block
  and client side logic.

  .PARAMETER FileExcludes
    An array containing a list of filters, each may contain a wild-card ('*'). If a
  particular filter does not contain a wild-card, then it will be treated as a file suffix.
  If the file in the source tree matches any of the filters in the list, it will NOT be
  mirrored in the destination tree. Any match in the FileExcludes overrides a match in
  FileIncludes, so a file that is matched in Include, can be excluded by the Exclude.

  .PARAMETER FileIncludes
    An array containing a list of filters, each may contain a wild-card ('*'). If a
  particular filter does not contain a wild-card, then it will be treated as a file suffix.
  If the file in the source tree matches any of the filters in the list, it will be mirrored
  in the destination tree. If FileIncludes contains just a single element which is the empty
  string, this means that nothing is included (rather than everything being included).


  .PARAMETER Functee
    String defining the function to be invoked. Works in a similar way to the Block parameter
  for script-blocks. The Function's base signature is as follows:
  * "Underscore": (See underscore described above)
  * "Index": (See index described above)
  * "Exchange": (See PathThru described above)
  * "Trigger": (See trigger described above)

  The destination DirectoryInfo object can be accessed via the Exchange denoted by
  the 'LOOPZ.MIRROR.DESTINATION' entry.

  .PARAMETER FuncteeParams
    Optional hash-table containing the named parameters which are splatted into the Functee
  function invoke. As it's a hash table, order is not significant.

  .PARAMETER Header
    A script-block that is invoked for each directory that also contains child directories.
  The script-block is invoked with the following positional parameters:
    * Exchange: (see Exchange previously described)

    The Header can be customised with the following Exchange entries:
    * 'LOOPZ.KRAYOLA-THEME': Krayola Theme generally in use
    * 'LOOPZ.HEADER-BLOCK.MESSAGE': message displayed as part of the header
    * 'LOOPZ.HEADER-BLOCK.CRUMB-SIGNAL': Lead text displayed in header, default: '[+] '
    * 'LOOPZ.HEADER.PROPERTIES': An array of Key/Value pairs of items to be displayed
    * 'LOOPZ.HEADER-BLOCK.LINE': A string denoting the line to be displayed. (There are
    predefined lines available to use in $LoopzUI, or a custom one can be used instead)

  .PARAMETER Hoist
    switch parameter. Without Hoist being specified, the filters can prove to be too restrictive
  on matching against directories. If a directory does not match the filters then none of its
  descendants will be considered to be mirrored in the destination tree. When Hoist is specified
  then a descendant directory that does match the filters will be mirrored even though any of
  its ancestors may not match the filters.

  .PARAMETER Path
    The source Path denoting the root of the directory tree to be mirrored.

  .PARAMETER SessionHeader
    A script-block that is invoked at the start of the mirroring batch. The script-block has
  the same signature as the Header script block.

  .PARAMETER SessionSummary
    A script-block that is invoked at the end of the mirroring batch. The script-block has
  the same signature as the Summary script block.

  .PARAMETER Summary
    A script-block that is invoked foreach directory that also contains child directories,
  after all its descendants have been processed and serves as a sub-total for the current
  directory. The script-block is invoked with the following positional parameters:
    * count: the number of items processed in the mirroring batch.
    * skipped: the number of items skipped in the mirroring batch. An item is skipped if
    it fails the defined condition or is not of the correct type (eg if its a directory
    but we have specified the -File flag).
    * errors: the number of items which resulted in error. An error occurs when the function
    or the script-block has set the Error property on the invoke result.
    * trigger: Flag set by the script-block/function, but should typically be used to
    indicate whether any of the items processed were actively updated/written in this batch.
    This helps in written idempotent operations that can be re-run without adverse
    consequences.
    * Exchange: (see Exchange previously described)

  .EXAMPLE 1
    Invoke a named function for every directory in the source tree and mirror every
  directory in the destination tree. The invoked function has an extra parameter in it's
  signature, so the extra parameters must be passed in via FuncteeParams (the standard
  signature being the first 4 parameters shown.)

  function Test-Mirror {
    param(
      [System.IO.DirectoryInfo]$Underscore,
      [int]$Index,
      [hashtable]$Exchange,
      [boolean]$Trigger,
      [string]$Format
    )
    ...
  }

  [hashtable]$parameters = @{
    'Format' = '---- {0} ----';
  }
  Invoke-MirrorDirectoryTree -Path './Tests/Data/fefsi' `
    -DestinationPath './Tests/Data/mirror' -CreateDirs `
    -Functee 'Test-Mirror' -FuncteeParams $parameters;

  .EXAMPLE 2
  Invoke a script-block for every directory in the source tree and copy all files

  Invoke-MirrorDirectoryTree -Path './Tests/Data/fefsi' `
    -DestinationPath './Tests/Data/mirror' -CreateDirs -CopyFiles -block {
      param(
        [System.IO.DirectoryInfo]$Underscore,
        [int]$Index,
        [hashtable]$Exchange,
        [boolean]$Trigger
      )
      ...
    };

  .EXAMPLE 3
  Mirror a directory tree, including only directories beginning with A (filter A*)

  Invoke-MirrorDirectoryTree -Path './Tests/Data/fefsi' -DestinationPath './Tests/Data/mirror' `
    -DirectoryIncludes @('A*')

  Note the possible issue with this example is that any descendants named A... which are located
  under an ancestor which is not named A..., will not be mirrored;

  eg './Tests/Data/fefsi/Audio/mp3/A/Amorphous Androgynous', even though "Audio", "A" and
  "Amorphous Androgynous" clearly match the A* filter, they will not be mirrored because
  the "mp3" directory, would be filtered out.
  See the following example for a resolution.

  .EXAMPLE 4
  Mirror a directory tree, including only directories beginning with A (filter A*) regardless of
  the matching of intermediate ancestors (specifying -Hoist flag resolves the possible
  issue in the previous example)

  Invoke-MirrorDirectoryTree -Path './Tests/Data/fefsi' -DestinationPath './Tests/Data/mirror' `
    -DirectoryIncludes @('A*') -CreateDirs -CopyFiles -Hoist

  Note that the directory filter must include a wild-card, otherwise it will be ignored. So a
  directory include of @('A'), is problematic, because A is not a valid directory filter so its
  ignored and there are no remaining filters that are able to include any directory, so no
  directory passes the filter.

  .EXAMPLE 5
  Mirror a directory tree, including files with either .flac or .wav suffix

  Invoke-MirrorDirectoryTree -Path './Tests/Data/fefsi' -DestinationPath './Tests/Data/mirror' `
    -FileIncludes @('flac', '*.wav') -CreateDirs -CopyFiles -Hoist

  Note that for files, a filter may or may not contain a wild-card. If the wild-card is missing
  then it is automatically treated as a file suffix; so 'flac' means '*.flac'.

  .EXAMPLE 6
  Mirror a directory tree copying over just flac files

  [scriptblock]$summary = {
    param(
      [int]$_count,
      [int]$_skipped,
      [boolean]$_triggered,
      [hashtable]$_exchange
    )
    ...
  }

  Invoke-MirrorDirectoryTree -Path './Tests/Data/fefsi' -DestinationPath './Tests/Data/mirror' `
    -FileIncludes @('flac') -CopyFiles -Hoist -Summary $summary

  Note that -CreateDirs is missing which means directories will not be mirrored by default. They
  are only mirrored as part of the process of copying over flac files, so in the end the
  resultant mirror directory tree will contain directories that include flac files.

  .EXAMPLE 7
  Same as EXAMPLE 6, but using predefined Header and Summary script-blocks for Session header/summary
  and per directory header/summary.

  Invoke-MirrorDirectoryTree -Path './Tests/Data/fefsi' -DestinationPath './Tests/Data/mirror' `
  -FileIncludes @('flac') -CopyFiles -Hoist `
  -Header $LoopzHelpers.DefaultHeaderBlock -Summary $DefaultHeaderBlock.SimpleSummaryBlock `
  -SessionHeader $LoopzHelpers.DefaultHeaderBlock -SessionSummary $DefaultHeaderBlock.SimpleSummaryBlock;
  #>

  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
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
    [hashtable]$Exchange = @{},

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [scriptblock]$Block = ( {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
        param(
          [System.IO.DirectoryInfo]$underscore,
          [int]$index,
          [hashtable]$exchange,
          [boolean]$trigger
        )
      } ),

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [ValidateScript( { $_ -is [Array] })]
    $BlockParams = @(),

    [Parameter(ParameterSetName = 'InvokeFunction', Mandatory)]
    [ValidateScript( { -not([string]::IsNullOrEmpty($_)); })]
    [string]$Functee,

    [Parameter(ParameterSetName = 'InvokeFunction')]
    [hashtable]$FuncteeParams = @{},

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
    [scriptblock]$Header = ( {
        param(
          [hashtable]$_exchange
        )
      }),

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [scriptblock]$Summary = ( {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
        param(
          [int]$_index,
          [int]$_skipped,
          [int]$_errors,
          [boolean]$_trigger,
          [hashtable]$_exchange
        )
      }),

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [scriptblock]$SessionHeader = ( {
        param(
          [hashtable]$_exchange
        )
      }),

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [scriptblock]$SessionSummary = ( {
        param(
          [int]$_count,
          [int]$_skipped,
          [int]$_errors,
          [boolean]$_trigger,
          [hashtable]$_exchange
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
      [hashtable]$_exchange,

      [Parameter(Mandatory)]
      [boolean]$_trigger
    )

    # Write-Host "[+] >>> doMirrorBlock: $($_underscore.Name)";

    [string]$rootSource = $_exchange['LOOPZ.MIRROR.ROOT-SOURCE'];
    [string]$rootDestination = $_exchange['LOOPZ.MIRROR.ROOT-DESTINATION'];

    $sourceDirectoryFullName = $_underscore.FullName;

    # sourceDirectoryFullName must end with directory separator
    #
    if (-not($sourceDirectoryFullName.EndsWith([System.IO.Path]::DirectorySeparatorChar))) {
      $sourceDirectoryFullName += [System.IO.Path]::DirectorySeparatorChar;
    }

    $destinationBranch = edit-RemoveSingleSubString -Target $sourceDirectoryFullName -Subtract $rootSource;

    $destinationDirectory = Join-Path -Path $rootDestination -ChildPath $destinationBranch;
    $_exchange['LOOPZ.MIRROR.BRANCH-DESTINATION'] = $destinationBranch;

    [boolean]$whatIf = $_exchange.ContainsKey('WHAT-IF') -and ($_exchange['WHAT-IF']);
    Write-Debug "[+] >>> doMirrorBlock: destinationDirectory: '$destinationDirectory'";

    if ($whatIf) {
      if (Test-Path -Path $destinationDirectory) {
        Write-Debug "    [-] (WhatIf) Get existing destination branch directory: '$destinationBranch'";
        $destinationInfo = (Get-Item -Path $destinationDirectory);
      }
      else {
        Write-Debug "    [-] (WhatIf) Creating synthetic destination branch directory: '$destinationBranch'";
        $destinationInfo = ([System.IO.DirectoryInfo]::new($destinationDirectory));
      }
    }
    else {
      if ($CreateDirs.ToBool()) {
        Write-Debug "    [-] Creating destination branch directory: '$destinationBranch'";

        $destinationInfo = (Test-Path -Path $destinationDirectory) `
          ? (Get-Item -Path $destinationDirectory) `
          : (New-Item -ItemType 'Directory' -Path $destinationDirectory);
      }
      else {
        Write-Debug "    [-] Creating destination branch directory INFO obj: '$destinationBranch'";
        $destinationInfo = New-Object -TypeName System.IO.DirectoryInfo ($destinationDirectory);
      }
    }

    if ($CopyFiles.ToBool()) {
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

      # Ensure that the destination directory exists, but only if there are
      # files to copy over which pass the include/exclude filters. This is
      # required in the case where CreateDirs has not been specified.
      #
      [array]$filesToCopy = Get-ChildItem $sourceDirectoryWithWildCard `
        -Include $adjustedFileIncludes -Exclude $adjustedFileExcludes -File;

      if ($filesToCopy) {
        if (-not($whatIf)) {
          if (-not(Test-Path -Path $destinationDirectory)) {
            New-Item -ItemType 'Directory' -Path $destinationDirectory;
          }

          Copy-Item -Path $sourceDirectoryWithWildCard `
            -Include $adjustedFileIncludes -Exclude $adjustedFileExcludes `
            -Destination $destinationDirectory;
        }
        $_exchange['LOOPZ.MIRROR.COPIED-FILES.COUNT'] = $filesToCopy.Count;

        Write-Debug "    [-] No of files copied: '$($filesToCopy.Count)'";
      }
      else {
        $_exchange.Remove('LOOPZ.MIRROR.COPIED-FILES.COUNT');
        $_exchange.Remove('LOOPZ.MIRROR.COPIED-FILES.INCLUDES');
      }
    }

    # To be consistent with Invoke-ForeachFsItem, the user function/block is invoked
    # with the source directory info. The destination for this mirror operation is
    # returned via 'LOOPZ.MIRROR.DESTINATION' within the Exchange.
    #
    $_exchange['LOOPZ.MIRROR.DESTINATION'] = $destinationInfo;

    $invokee = $_exchange['LOOPZ.MIRROR.INVOKEE'];

    if ($invokee -is [scriptblock]) {
      $positional = @($_underscore, $_index, $_exchange, $_trigger);

      if ($_exchange.ContainsKey('LOOPZ.MIRROR.INVOKEE.PARAMS')) {
        $_exchange['LOOPZ.MIRROR.INVOKEE.PARAMS'] | ForEach-Object {
          $positional += $_;
        }
      }

      $invokee.InvokeReturnAsIs($positional);
    }
    elseif ($invokee -is [string]) {
      [hashtable]$parameters = $_exchange.ContainsKey('LOOPZ.MIRROR.INVOKEE.PARAMS') `
        ? $_exchange['LOOPZ.MIRROR.INVOKEE.PARAMS'] : @{};
      $parameters['Underscore'] = $_underscore;
      $parameters['Index'] = $_index;
      $parameters['Exchange'] = $_exchange;
      $parameters['Trigger'] = $_trigger;

      & $invokee @parameters;
    }
    else {
      Write-Warning "User defined function/block not valid, not invoking.";
    }

    @{ Product = $destinationInfo }
  } #doMirrorBlock

  # ===================================================== [Invoke-MirrorDirectoryTree] ===

  [string]$resolvedSourcePath = Convert-Path $Path;
  [string]$resolvedDestinationPath = Convert-Path $DestinationPath;

  $Exchange['LOOPZ.MIRROR.ROOT-SOURCE'] = $resolvedSourcePath;
  $Exchange['LOOPZ.MIRROR.ROOT-DESTINATION'] = $resolvedDestinationPath;

  if ('InvokeScriptBlock' -eq $PSCmdlet.ParameterSetName) {
    $Exchange['LOOPZ.MIRROR.INVOKEE'] = $Block;

    if ($BlockParams.Count -gt 0) {
      $Exchange['LOOPZ.MIRROR.INVOKEE.PARAMS'] = $BlockParams;
    }
  }
  else {
    $Exchange['LOOPZ.MIRROR.INVOKEE'] = $Functee;

    if ($FuncteeParams.PSBase.Count -gt 0) {
      $Exchange['LOOPZ.MIRROR.INVOKEE.PARAMS'] = $FuncteeParams.Clone();
    }
  }

  if ($PSBoundParameters.ContainsKey('WhatIf') -and ($true -eq $PSBoundParameters['WhatIf'])) {
    $Exchange['WHAT-IF'] = $true;
  }

  if ($CopyFiles.ToBool()) {
    $Exchange['LOOPZ.MIRROR.COPIED-FILES.INCLUDES'] = $FileIncludes -join ', ';
  }

  [scriptblock]$filterDirectories = {
    [OutputType([boolean])]
    param(
      [System.IO.DirectoryInfo]$directoryInfo
    )
    Select-FsItem -Name $directoryInfo.Name `
      -Includes $DirectoryIncludes -Excludes $DirectoryExcludes;
  }

  $null = Invoke-TraverseDirectory -Path $resolvedSourcePath `
    -Block $doMirrorBlock -Exchange $Exchange -Header $Header -Summary $Summary `
    -SessionHeader $SessionHeader -SessionSummary $SessionSummary -Condition $filterDirectories -Hoist:$Hoist;
} # Invoke-MirrorDirectoryTree
