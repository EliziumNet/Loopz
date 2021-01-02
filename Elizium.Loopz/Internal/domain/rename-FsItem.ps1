
function rename-FsItem {
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [Parameter()]
    [System.IO.FileSystemInfo]$From,

    [Parameter()]
    [string]$To,

    [Parameter()]
    [hashtable]$Undo,

    [Parameter()]
    $Shell
  )
  [boolean]$itemIsDirectory = ($From.Attributes -band
    [System.IO.FileAttributes]::Directory) -eq [System.IO.FileAttributes]::Directory;

  [string]$destinationPath = $itemIsDirectory `
    ? (Join-Path -Path $From.Parent.FullName -ChildPath $To) `
    : (Join-Path -Path $From.Directory.FullName -ChildPath $To);

  if (-not($PSBoundParameters.ContainsKey('WhatIf') -and $PSBoundParameters['WhatIf'])) {
    try {
      [boolean]$createUndoEntry = $false;
      [boolean]$differByCaseOnly = $From.Name.ToLower() -eq $To.ToLower();

      if ($differByCaseOnly) {
        # Just doing a double move to get around the problem of not being able to rename
        # an item unless the case is different
        #
        [string]$tempName = $From.Name + "_";

        $tempDestinationPath = $itemIsDirectory `
          ? (Join-Path $From.Parent.FullName $tempName) `
          : (Join-Path $From.Directory.FullName $tempName);
  
        Move-Item -LiteralPath $From.FullName -Destination $tempDestinationPath -PassThru | `
          Move-Item -Destination $destinationPath;

        if ($PSBoundParameters.ContainsKey('Undo')) {
          $createUndoEntry = $true;
        }
      }
      else {
        Move-Item -LiteralPath $From.FullName -Destination $destinationPath;
      }

      if ($createUndoEntry) {
        # TODO: Invoke the Shell instance to formulate the correct commands
        #
      }

      $result = Get-Item -LiteralPath $destinationPath;
    }
    catch [System.IO.IOException] {
      $result = $null;
    }
  }
  else {
    $result = $To;
  }

  return $result;
} # rename-FsItem
