
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
    [ValidateScript( { -not($_ -eq $null) ; })]
    [scriptblock]$Condition = (
      {
        param([System.IO.DirectoryInfo]$directoryInfo)
        return $true;
      }
    ),

    [Parameter(Mandatory)]
    [ValidateScript( { -not($_ -eq $null) ; })]
    [System.Collections.Hashtable]$PassThru,

    [Parameter()]
    [ValidateScript( { -not($_ -eq $null) ; })]
    [scriptblock]$SourceDirectoryBlock
  )

  # Handle top level directory, before recursing through child directories
  #
  Write-Host "---> Invoke-TraverseDirectory, path: $Path"

  [System.IO.FileSystemInfo]
  [System.IO.DirectoryInfo]$directory = Get-Item -Path $Path;

  [boolean]$itemIsDirectory = ($directory.Attributes -band
    [System.IO.FileAttributes]::Directory) -eq [System.IO.FileAttributes]::Directory;

  if ($itemIsDirectory) {
    [int]$index = $PassThru['LOOPZ.TRAVERSE-INDEX'] = 0;
    [boolean]$trigger = $false;

    $SourceDirectoryBlock.Invoke($directory, $index, $PassThru, $trigger);

    [scriptblock]$recurseTraverseDirectory = {
      param(
        [Parameter(Mandatory)]
        [System.IO.DirectoryInfo]$Directory,
  
        [Parameter()]
        [String[]]$Include,

        # [Parameter()]
        # [String[]]$Exclude = @('*'),

        [Parameter()]
        [ValidateScript( { -not($_ -eq $null) ; })]
        [scriptblock]$Condition,

        [Parameter(Mandatory)]
        [ValidateScript( { -not($_ -eq $null) ; })]
        [System.Collections.Hashtable]$PassThru,

        [Parameter()]
        [scriptblock]$DirectoryBlock
      )

      Write-Host "===> recurseTraverseDirectory, directory: $($Directory.Name)"
    }

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
        $PassThru['LOOPZ.TRAVERSE-DIRECTORY.BLOCK']
      );
    }

    # Set up the adapter
    #
    $PassThru['LOOPZ.TRAVERSE-DIRECTORY.INCLUDE'] = $Include;
    # $PassThru['LOOPZ.TRAVERSE-DIRECTORY.EXCLUDE'] = $Exclude;
    $PassThru['LOOPZ.TRAVERSE-DIRECTORY.CONDITION'] = $Condition;
    $PassThru['LOOPZ.TRAVERSE-DIRECTORY.BLOCK'] = $DirectoryBlock;
    $PassThru['LOOPZ.TRAVERSE-DIRECTORY.ADAPTED'] = $recurseTraverseDirectory;

  
    # Now perform start of recursive traversal
    #
    # [System.IO.DirectoryInfo[]]$sourceDirectoryInfos = Get-ChildItem -Path $pathWithWildCard `
    #   -Directory -Include $DirectoryIncludes;
    # $sourceDirectoryInfos | Invoke-ForeachFsItem -Directory -Block $SourceDirectoryBlock -PassThru $PassThru;

    [string]$pathWithWildCard = $Path.Contains('*') ? $Path : (Join-Path -Path $Path -ChildPath '*');

    [System.IO.DirectoryInfo[]]$sourceDirectoryInfos = Get-ChildItem -Path $pathWithWildCard `
      -Directory -Include $DirectoryIncludes;

    $sourceDirectoryInfos | Invoke-ForeachFsItem -Directory -Block $adapter -PassThru $PassThru;
  }
  else {
    Write-Error "Path specified '$($Path)' is not a directory";
  }
}
