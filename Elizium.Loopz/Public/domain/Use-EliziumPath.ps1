
function Use-EliziumPath {
  <#
  .NAME
    Use-EliziumPath

  .SYNOPSIS
    Ensures that the directory referred to by the environment variable 'ELIZIUM_PATH'
  actually exists.

  .DESCRIPTION
    If the directory does not exist, the directory will be created, even if any
  intermediate sub-paths do not exist.

  .LINK
    https://eliziumnet.github.io/Loopz/
  #>
  [OutputType([string])]
  param()

  [string]$homePath = Get-EnvironmentVariable 'HOME' -Default $HOME;
  [string]$eliziumPath = (Get-EnvironmentVariable 'ELIZIUM_PATH') ?? $(
    Join-Path -Path $homePath -ChildPath '.elizium'
  );

  if (-not(Test-Path -Path $eliziumPath -PathType Container)) {
    $null = New-Item -Path $eliziumPath -ItemType Directory -WhatIf:$false;
  }

  return $eliziumPath;
}
