
function Invoke-TraverseDirectory {
  [CmdletBinding(DefaultParameterSetName = 'InvokeScriptBlock')]
  [Alias('itd', 'Traverse-Directory')]
  param
  (
    [Parameter(ParameterSetName = 'InvokeScriptBlock', Mandatory)]
    [Parameter(ParameterSetName = 'InvokeFunction', Mandatory)]
    [ValidateScript( { Test-path -Path $_ })]
    [String]$Path,

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [ValidateScript( { -not($_ -eq $null) })]
    [scriptblock]$Condition = (
      {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
        param([System.IO.DirectoryInfo]$directoryInfo)
        return $true;
      }
    ),

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [System.Collections.Hashtable]$PassThru = @{},

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [ValidateScript( { -not($_ -eq $null) })]
    [scriptblock]$Block,

    [Parameter(ParameterSetName = 'InvokeFunction', Mandatory)]
    [ValidateScript( { -not([string]::IsNullOrEmpty($_)); })]
    [string]$Functee,

    [Parameter(ParameterSetName = 'InvokeFunction')]
    [ValidateScript( { $_.Length -gt 0; })]
    [System.Collections.Hashtable]$FuncteeParams = @{},

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [scriptblock]$Summary = (
      param(
        [int]$Count,
        [int]$Skipped,
        [boolean]$Triggered,
        [System.Collections.Hashtable]$PassThru
      )
    ),

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [switch]$Hoist
  ) # param

  # ======================================================= [recurseTraverseDirectory] ===
  #
  [scriptblock]$recurseTraverseDirectory = { # Invoked by adapter
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    param(
      [Parameter(Position = 0, Mandatory)]
      [System.IO.DirectoryInfo]$directoryInfo,

      [Parameter(Position = 1)]
      [ValidateScript( { -not($_ -eq $null) })]
      [scriptblock]$condition,

      [Parameter(Position = 2, Mandatory)]
      [ValidateScript( { -not($_ -eq $null) })]
      [System.Collections.Hashtable]$passThru,

      [Parameter(Position = 3)]
      [ValidateScript( { ($_ -is [scriptblock]) -or ($_ -is [string]) })]
      $invokee, # (scriptblock or function name; hence un-typed parameter)

      [Parameter(Position = 4)]
      [boolean]$trigger
    )

    $index = $passThru['LOOPZ.FOREACH-INDEX'];

    try {
      # This is the local invoke, for the current directory
      #
      if ($invokee -is [scriptblock]) {
        $invokee.Invoke($directoryInfo, $index, $passThru, $trigger);
      }
      else {
        [System.Collections.Hashtable]$parameters = $passThru['LOOPZ.TRAVERSE-DIRECTORY.INVOKEE.PARAMS'];

        # These are directory specific overwrites. The custom parameters
        # will still be present
        # 
        $parameters['DirectoryInfo'] = $directory;
        $parameters['Index'] = $index;
        $parameters['PassThru'] = $passThru;
        $parameters['Trigger'] = $trigger;

        & $invokee @parameters;
      }
    }
    catch {
      Write-Error "recurseTraverseDirectory Error: ($_), for item: '$($directoryInfo.Name)'";
    }
    finally {
      $passThru['LOOPZ.FOREACH-INDEX']++;
    }

    [string]$fullName = $directoryInfo.FullName;
    [System.IO.DirectoryInfo[]]$directoryInfos = Get-ChildItem -Path $fullName `
      -Directory | Where-Object { $condition.Invoke($_) };

    [scriptblock]$adapter = $PassThru['LOOPZ.TRAVERSE-DIRECTORY.ADAPTOR'];

    if ($directoryInfos) {
      # adapter is always a script block, this has nothing to do with the invokee,
      # which may be a script block or a named function(functee)
      #
      $directoryInfos | Invoke-ForeachFsItem -Directory -Block $adapter `
        -PassThru $PassThru -Condition $condition -Summary $Summary;
    }
  } # recurseTraverseDirectory

  # ======================================================================== [adapter] ===
  #
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

    $adapted.Invoke(
      $_underscore,
      $_passThru['LOOPZ.TRAVERSE-DIRECTORY.CONDITION'],
      $_passThru,
      $PassThru['LOOPZ.TRAVERSE-DIRECTORY.INVOKEE'],
      $_trigger
    );
  } # adapter

  # ======================================================= [Invoke-TraverseDirectory] ===

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

    if ('InvokeFunction' -eq $PSCmdlet.ParameterSetName) {
      # set-up custom parameters
      #
      [System.Collections.Hashtable]$parameters = $FuncteeParams;
      $parameters['Underscore'] = $directory;
      $parameters['Index'] = $index;
      $parameters['PassThru'] = $PassThru;
      $parameters['Trigger'] = $trigger;
      $PassThru['LOOPZ.TRAVERSE-DIRECTORY.INVOKEE.PARAMS'] = $parameters;
    }

    if (-not($Hoist.ToBool())) {
      # We only want to manage the index via $PassThru when we are recursing
      #
      $PassThru['LOOPZ.FOREACH-INDEX'] = $index;
    }

    # This is the top level invoke
    #
    try {
      if ('InvokeScriptBlock' -eq $PSCmdlet.ParameterSetName) {
        $Block.Invoke($directory, $index, $PassThru, $trigger);
      }
      elseif ('InvokeFunction' -eq $PSCmdlet.ParameterSetName) {
        & $Functee @parameters;
      }
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
        if ('InvokeScriptBlock' -eq $PSCmdlet.ParameterSetName) {
          $directoryInfos | Invoke-ForeachFsItem -Directory -Block $Block `
            -PassThru $PassThru -StartIndex $index -Summary $Summary;
        }
        else {
          # Invoke-ForeachFsItem now has to change to use the custom parameters
          # instead of using a fixed signature.
          # TBD: The function parameters are already prepared above for the
          # top-level invoke, we just re-use for further iterations
          #
          $directoryInfos | Invoke-ForeachFsItem -Directory -Functee $Functee `
            -FuncteeParamsKey 'LOOPZ.TRAVERSE-DIRECTORY.INVOKEE.PARAMS' -PassThru $PassThru `
            -StartIndex $index -Summary $Summary;
        }
      }
    }
    else {
      # Set up the adapter. (NB, can't use splatting because we're invoking a script block
      # as opposed to a named function.)
      #
      $PassThru['LOOPZ.TRAVERSE-DIRECTORY.CONDITION'] = $Condition;
      $PassThru['LOOPZ.TRAVERSE-DIRECTORY.ADAPTED'] = $recurseTraverseDirectory;
      $PassThru['LOOPZ.TRAVERSE-DIRECTORY.ADAPTOR'] = $adapter;

      if ('InvokeScriptBlock' -eq $PSCmdlet.ParameterSetName) {
        $PassThru['LOOPZ.TRAVERSE-DIRECTORY.INVOKEE'] = $Block;
      }
      elseif ('InvokeFunction' -eq $PSCmdlet.ParameterSetName) {
        $PassThru['LOOPZ.TRAVERSE-DIRECTORY.INVOKEE'] = $Functee;
      }

      # Now perform start of recursive traversal
      #
      [System.IO.DirectoryInfo[]]$directoryInfos = Get-ChildItem -Path $Path `
        -Directory | Where-Object { $Condition.Invoke($_) }

      if ($directoryInfos) {
        $directoryInfos | Invoke-ForeachFsItem -Directory -Block $adapter `
          -PassThru $PassThru -Condition $Condition -Summary $Summary;
      }

      [int]$skipped = 0;
      [boolean]$trigger = $false;
      $Summary.Invoke($index, $skipped, $trigger, $PassThru);
    }
  }
  else {
    Write-Error "Path specified '$($Path)' is not a directory";
  }
} # Invoke-TraverseDirectory
