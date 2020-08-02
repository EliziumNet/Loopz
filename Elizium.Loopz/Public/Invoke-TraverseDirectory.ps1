
function Invoke-TraverseDirectory {
  [CmdletBinding()]
  [Alias('itd', 'Traverse-Directory')]
  param
  (
    [Parameter(Mandatory)]
    [ValidateScript( { Test-path -Path $_ })]
    [String]$Path,

    [Parameter()]
    [ValidateScript( { -not($_ -eq $null) })]
    [scriptblock]$Condition = (
      {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
        param([System.IO.DirectoryInfo]$directoryInfo)
        return $true;
      }
    ),

    [Parameter()]
    [System.Collections.Hashtable]$PassThru = @{},

    [Parameter()]
    [ValidateScript( { -not($_ -eq $null) })]
    [scriptblock]$SourceDirectoryBlock,

    [Parameter()]
    [scriptblock]$Summary = (
      param(
        [int]$Count,
        [int]$Skipped,
        [boolean]$Triggered,
        [System.Collections.Hashtable]$PassThru
      )
    ),

    [Parameter()]
    [switch]$Hoist
  )

  [scriptblock]$recurseTraverseDirectory = {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    param(
      [Parameter(Mandatory)]
      [System.IO.DirectoryInfo]$_directory,

      [Parameter()]
      [ValidateScript( { -not($_ -eq $null) })]
      [scriptblock]$_condition,

      [Parameter(Mandatory)]
      [ValidateScript( { -not($_ -eq $null) })]
      [System.Collections.Hashtable]$_passThru,

      [Parameter()]
      [scriptblock]$_directoryBlock,

      [Parameter()]
      [boolean]$_trigger
    )

    $index = $_passThru['LOOPZ.FOREACH-INDEX'];

    try {
      $_directoryBlock.Invoke($_directory, $index, $_passThru, $_trigger);
    }
    catch {
      Write-Error "recurseTraverseDirectory Error: ($_), for item: '$($_directory.Name)'";
    }
    finally {
      $_passThru['LOOPZ.FOREACH-INDEX']++;
    }


    [string]$fullName = $_directory.FullName;
    [System.IO.DirectoryInfo[]]$directoryInfos = Get-ChildItem -Path $fullName `
      -Directory | Where-Object { $_condition.Invoke($_) };

    [scriptblock]$adapter = $PassThru['LOOPZ.TRAVERSE-DIRECTORY.ADAPTOR'];

    if ($directoryInfos) {
      $directoryInfos | Invoke-ForeachFsItem -Directory -Block $adapter `
        -PassThru $PassThru -Condition $_condition -Summary $Summary;
    }
  } # recurseTraverseDirectory

  [scriptblock]$adapter = {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
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

    [scriptblock]$adapted = $_passThru['LOOPZ.TRAVERSE-DIRECTORY.ADAPTED'];

    Invoke-Command -ScriptBlock $adapted -ArgumentList @(
      $_underscore,
      $_passThru['LOOPZ.TRAVERSE-DIRECTORY.CONDITION'],
      $_passThru,
      $PassThru['LOOPZ.TRAVERSE-DIRECTORY.BLOCK'],
      $_trigger
    );
  } # adapter

  # Handle top level directory, before recursing through child directories
  #

  [System.IO.DirectoryInfo]$directory = Get-Item -Path $Path;

  [boolean]$itemIsDirectory = ($directory.Attributes -band
    [System.IO.FileAttributes]::Directory) -eq [System.IO.FileAttributes]::Directory;

  if ($itemIsDirectory) {
    [boolean]$trigger = $false;

    # The index of the top level directory is always 0
    #
    [int]$index = 0;

    if (-not($Hoist.ToBool())) {
      # We only want to manage the index via $PassThru when we are recursing
      #
      $PassThru['LOOPZ.FOREACH-INDEX'] = $index;
    }
    
    # This is the top level invoke
    #
    try {
      $SourceDirectoryBlock.Invoke($directory, $index, $PassThru, $trigger);
    }
    catch {
      Write-Error "Invoke-TraverseDirectory(top-level) Error: ($_), for item: '$($directory.Name)'";
    }
    finally {
      if ($Hoist.ToBool()) {
        $index++;
      }
      else {
        $PassThru['LOOPZ.FOREACH-INDEX']++;
        $index = $PassThru['LOOPZ.FOREACH-INDEX'];
      }
    }

    if ($Hoist.ToBool()) {
      # Perform non-recursive retrieval of descendant directories
      #
      [System.IO.DirectoryInfo[]]$directoryInfos = Get-ChildItem -Path $Path `
        -Directory -Recurse | Where-Object { $Condition.Invoke($_) }

      if ($directoryInfos) {
        # No need to manage the index, let Invoke-ForeachFsItem do this for us,
        # except we do need to inform Invoke-ForeachFsItem to start the index at
        # +1, because 0 is for the top level directory which has already been
        # handled.
        #
        $directoryInfos | Invoke-ForeachFsItem -Directory -Block $SourceDirectoryBlock `
          -PassThru $PassThru -StartIndex $index -Summary $Summary;
      }
    }
    else {
      # Set up the adapter. (NB, can't use splatting because we're invoking a script block
      # as opposed to a named function.)
      #
      $PassThru['LOOPZ.TRAVERSE-DIRECTORY.CONDITION'] = $Condition;
      $PassThru['LOOPZ.TRAVERSE-DIRECTORY.BLOCK'] = $SourceDirectoryBlock;
      $PassThru['LOOPZ.TRAVERSE-DIRECTORY.ADAPTED'] = $recurseTraverseDirectory;
      $PassThru['LOOPZ.TRAVERSE-DIRECTORY.ADAPTOR'] = $adapter;

      # Now perform start of recursive traversal
      #
      [System.IO.DirectoryInfo[]]$directoryInfos = Get-ChildItem -Path $Path `
        -Directory | Where-Object { $Condition.Invoke($_) }

      if ($directoryInfos) {
        $directoryInfos | Invoke-ForeachFsItem -Directory -Block $adapter `
          -PassThru $PassThru -Condition $Condition -Summary $Summary;
      }
    }

    [int]$skipped = 0;
    [boolean]$trigger = $false;
    $Summary.Invoke($index, $skipped, $trigger, $PassThru);
  }
  else {
    Write-Error "Path specified '$($Path)' is not a directory";
  }
}
