
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

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [ValidateScript( { $_ -is [Array] })]
    $BlockParams = @(),

    [Parameter(ParameterSetName = 'InvokeFunction', Mandatory)]
    [ValidateScript( { -not([string]::IsNullOrEmpty($_)); })]
    [string]$Functee,

    [Parameter(ParameterSetName = 'InvokeFunction')]
    [ValidateScript( { $_.Length -gt 0; })]
    [System.Collections.Hashtable]$FuncteeParams = @{},

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [scriptblock]$Summary = ( {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
        param(
          [int]$Count,
          [int]$Skipped,
          [boolean]$Triggered,
          [System.Collections.Hashtable]$PassThru
        )
      }),

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
        $positional = @($directoryInfo, $index, $passThru, $trigger);

        if ($passThru.ContainsKey('LOOPZ.TRAVERSE.INVOKEE.PARAMS') -and
          ($passThru['LOOPZ.TRAVERSE.INVOKEE.PARAMS'] -gt 0)) {
          $passThru['LOOPZ.TRAVERSE.INVOKEE.PARAMS'] | ForEach-Object {
            $positional += $_;
          }
        }
        $invokee.Invoke($positional);
      }
      else {
        [System.Collections.Hashtable]$parameters = $passThru.ContainsKey('LOOPZ.TRAVERSE.INVOKEE.PARAMS') `
          ? $passThru['LOOPZ.TRAVERSE.INVOKEE.PARAMS'] : @{};

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

    [scriptblock]$adapter = $PassThru['LOOPZ.TRAVERSE.ADAPTOR'];

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

    [scriptblock]$adapted = $_passThru['LOOPZ.TRAVERSE.ADAPTED'];

    $adapted.Invoke(
      $_underscore,
      $_passThru['LOOPZ.TRAVERSE.CONDITION'],
      $_passThru,
      $PassThru['LOOPZ.TRAVERSE.INVOKEE'],
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
      [System.Collections.Hashtable]$parameters = $FuncteeParams.Clone();
      $parameters['Underscore'] = $directory;
      $parameters['Index'] = $index;
      $parameters['PassThru'] = $PassThru;
      $parameters['Trigger'] = $trigger;
      $PassThru['LOOPZ.TRAVERSE.INVOKEE.PARAMS'] = $parameters;
    }
    elseif ('InvokeScriptBlock' -eq $PSCmdlet.ParameterSetName) {
      $positional = @($directory, $index, $PassThru, $trigger);

      if ($BlockParams.Count -gt 0) {
        $BlockParams | Foreach-Object {
          $positional += $_;
        }
      }

      # Note, for the positional parameters, we can only pass in the additional
      # custom parameters provided by the client here via the PassThru otherwise
      # we could accidentally build up the array of positional parameters with
      # duplicated entries. This is in contrast to splatted arguments for function
      # invokes where parameter names are paired with parameter values in a
      # hashtable and naturally prevent duplicated entries. This is why we set
      # 'LOOPZ.TRAVERSE.INVOKEE.PARAMS' to $BlockParams and not $positional.
      #
      $PassThru['LOOPZ.TRAVERSE.INVOKEE.PARAMS'] = $BlockParams;
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
        $Block.Invoke($positional);
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
        [System.Collections.Hashtable]$parametersFeFsItem = @{
          'Directory'  = $true;
          'PassThru'   = $PassThru;
          'StartIndex' = $index;
          'Summary'    = $Summary;
        }

        if ('InvokeScriptBlock' -eq $PSCmdlet.ParameterSetName) {
          $parametersFeFsItem['Block'] = $Block;
          $parametersFeFsItem['BlockParams'] = $BlockParams;
        }
        else {
          $parametersFeFsItem['Functee'] = $Functee;
          $parametersFeFsItem['FuncteeParams'] = $FuncteeParams;
        }

        $directoryInfos | & 'Invoke-ForeachFsItem' @parametersFeFsItem;
      }
    }
    else {
      # Set up the adapter. (NB, can't use splatting because we're invoking a script block
      # as opposed to a named function.)
      #
      $PassThru['LOOPZ.TRAVERSE.CONDITION'] = $Condition;
      $PassThru['LOOPZ.TRAVERSE.ADAPTED'] = $recurseTraverseDirectory;
      $PassThru['LOOPZ.TRAVERSE.ADAPTOR'] = $adapter;

      if ('InvokeScriptBlock' -eq $PSCmdlet.ParameterSetName) {
        $PassThru['LOOPZ.TRAVERSE.INVOKEE'] = $Block;
      }
      elseif ('InvokeFunction' -eq $PSCmdlet.ParameterSetName) {
        $PassThru['LOOPZ.TRAVERSE.INVOKEE'] = $Functee;
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
