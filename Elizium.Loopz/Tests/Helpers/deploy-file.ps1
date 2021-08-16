
function script:deploy-file {
  [CmdletBinding()]
  param(
    [Parameter(ParameterSetName = 'Constituents')]
    [string]$BasePath,

    [Parameter(ParameterSetName = 'Constituents')]
    [string]$ChildPath,

    [Parameter(ParameterSetName = 'Constituents')]
    [string]$FileName,

    [Parameter(ParameterSetName = 'FullyQualified')]
    [string]$FullPath,

    [Parameter()]
    [string]$Content,

    [Parameter()]
    [DateTime]$AsOf 
  )

  [string]$deployPath, [string]$directoryPath = if ($PSCmdlet.ParameterSetName -eq 'Constituents') {
    [string]$constituentsDirectoryPath = Join-Path -Path $BasePath -ChildPath $ChildPath;

    (Join-Path $constituentsDirectoryPath -ChildPath $FileName), $constituentsDirectoryPath;
  }
  else {
    $FullPath, [System.IO.Path]::GetDirectoryName($FullPath);
  }

  if (-not(Test-Path -Path $directoryPath -PathType Container)) {
    $null = New-Item -Path $directoryPath -ItemType Container;
  }

  if (-not([string]::IsNullOrEmpty($Content))) {
    Set-Content -LiteralPath $deployPath -Value $Content;
  }
  Set-ItemProperty -LiteralPath $deployPath -Name LastWriteTime -Value $AsOf;

  return $deployPath;
}
