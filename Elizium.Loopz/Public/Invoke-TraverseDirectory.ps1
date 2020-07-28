
function Invoke-TraverseDirectory {
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory)]
    [ValidateScript( { Test-path -Path $_; })]
    [String]$Path,
  
    [Parameter()]
    [String[]]$Include = @('*'),

    [Parameter()]
    [scriptblock]$Condition = (
      {
        param([System.IO.DirectoryInfo]$directoryInfo)
        return $true;
      }
    ),

    [Parameter(Mandatory)]
    [System.Collections.Hashtable]$PassThru,

    [Parameter()]
    [scriptblock]$SourceDirectoryBlock
  )
}
