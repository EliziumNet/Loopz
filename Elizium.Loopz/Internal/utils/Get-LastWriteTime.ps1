
function Get-LastWriteTime {
  [OutputType([DateTime])]
  param(
    [Parameter()]
    [string]$Path
  )

  [System.IO.FileInfo]$fileInfo = Get-Item -LiteralPath $Path;
  return $fileInfo.LastWriteTime;
}
