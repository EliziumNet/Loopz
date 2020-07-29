
function Invoke-TraverseDirectory {
  [CmdletBinding()]
  [Alias('itd', 'Traverse-Directory')]
  param
  (
    [Parameter(Mandatory)]
    [ValidateScript( { Test-path -Path $_; })]
    [String]$Path,
  
    [Parameter()]
    [String[]]$Include = @('*'),

    # [Parameter()]
    # [String[]]$Exclude = @('*'),

    [Parameter()]
    [ValidateScript( { -not($_ -eq $null) })]
    [scriptblock]$Condition = (
      {
        param([System.IO.DirectoryInfo]$directoryInfo)
        return $true;
      }
    ),

    [Parameter(Mandatory)]
    [ValidateScript( { -not($_ -eq $null) })]
    [System.Collections.Hashtable]$PassThru,

    [Parameter()]
    [ValidateScript( { -not($_ -eq $null) })]
    [scriptblock]$SourceDirectoryBlock
  )

  [scriptblock]$recurseTraverseDirectory = {
    param(
      [Parameter(Mandatory)]
      [System.IO.DirectoryInfo]$_directory,
  
      [Parameter()]
      [String[]]$_include,

      # [Parameter()]
      # [String[]]$Exclude = @('*'),

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

    Write-Host "===> recurseTraverseDirectory, directory: $($_directory.Name)"

    # There's something missing <HERE>

    # Sure this invoke is required? Shouldn't this be the invoke-foreachFsItem?
    #
    $_directoryBlock.Invoke($_directory, $_passThru['LOOPZ.FOREACH-INDEX'], $_passThru, $_trigger);

    [string]$fullName = $_directory.FullName;
    [string]$pathWithWildCard = Join-Path -Path $fullName -ChildPath '*';
    [System.IO.DirectoryInfo[]]$directoryInfos = Get-ChildItem -Path $pathWithWildCard `
      -Directory -Include $_include;

    [scriptblock]$adapter = $PassThru['LOOPZ.TRAVERSE-DIRECTORY.ADAPTOR'];

    if ($directoryInfos) {
      $directoryInfos | Invoke-ForeachFsItem -Directory -Block $adapter -PassThru $PassThru;
    }
  } # recurseTraverseDirectory

  [scriptblock]$adapter = {
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
    Write-Host "===> Running adapter for '$($_underscore.Name)'";
    [scriptblock]$adapted = $_passThru['LOOPZ.TRAVERSE-DIRECTORY.ADAPTED'];

    $result = Invoke-Command -ScriptBlock $adapted -ArgumentList @(
      $_underscore,
      $_passThru['LOOPZ.TRAVERSE-DIRECTORY.INCLUDE'],
      $_passThru['LOOPZ.TRAVERSE-DIRECTORY.CONDITION'],
      $_passThru,
      $PassThru['LOOPZ.TRAVERSE-DIRECTORY.BLOCK'],
      $_trigger
    );
  } # adapter

  # Handle top level directory, before recursing through child directories
  #
  Write-Host "---> Invoke-TraverseDirectory, path: $Path"

  [System.IO.DirectoryInfo]$directory = Get-Item -Path $Path;

  [boolean]$itemIsDirectory = ($directory.Attributes -band
    [System.IO.FileAttributes]::Directory) -eq [System.IO.FileAttributes]::Directory;

  if ($itemIsDirectory) {
    # The index of the top level directory is always 0
    #
    [int]$index = $PassThru['LOOPZ.FOREACH-INDEX'] = 0;
    [boolean]$trigger = $false;

    # This is the top level invoke
    #
    $SourceDirectoryBlock.Invoke($directory, $index, $PassThru, $trigger);

    # Set up the adapter. (NB, can't use splatting because we're invoking a script block
    # as opposed to a named function.)
    #
    $PassThru['LOOPZ.TRAVERSE-DIRECTORY.INCLUDE'] = $Include;
    # $PassThru['LOOPZ.TRAVERSE-DIRECTORY.EXCLUDE'] = $Exclude;
    $PassThru['LOOPZ.TRAVERSE-DIRECTORY.CONDITION'] = $Condition;
    $PassThru['LOOPZ.TRAVERSE-DIRECTORY.BLOCK'] = $SourceDirectoryBlock;
    $PassThru['LOOPZ.TRAVERSE-DIRECTORY.ADAPTED'] = $recurseTraverseDirectory;
    $PassThru['LOOPZ.TRAVERSE-DIRECTORY.ADAPTOR'] = $adapter;

  
    # Now perform start of recursive traversal
    #
    # [System.IO.DirectoryInfo[]]$directoryInfos = Get-ChildItem -Path $pathWithWildCard `
    #   -Directory -Include $DirectoryIncludes;
    # $directoryInfos | Invoke-ForeachFsItem -Directory -Block $SourceDirectoryBlock -PassThru $PassThru;
    $index = $PassThru['LOOPZ.FOREACH-INDEX']++;

    [string]$pathWithWildCard = $Path.Contains('*') ? $Path : (Join-Path -Path $Path -ChildPath '*');

    [System.IO.DirectoryInfo[]]$directoryInfos = Get-ChildItem -Path $pathWithWildCard `
      -Directory -Include $DirectoryIncludes;

    if ($directoryInfos) {
      $directoryInfos | Invoke-ForeachFsItem -Directory -Block $adapter -PassThru $PassThru;
    }
  }
  else {
    Write-Error "Path specified '$($Path)' is not a directory";
  }
}
