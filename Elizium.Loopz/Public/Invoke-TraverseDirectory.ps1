
function Invoke-TraverseDirectory {
  <#
  .NAME
    Invoke-TraverseDirectory

  .SYNOPSIS
    Traverses a directory tree invoking a custom defined script-block or named function
  as it goes.

  .DESCRIPTION
    Navigates a directory tree applying custom functionality for each directory. A Condition
  script-block can be applied for conditional functionality. 2 parameters set are defined, one
  for invoking a named function (InvokeFunction) and the other (InvokeScriptBlock, the default)
  for invoking a scriptblock. An optional Summary script block can be specified which will be
  invoked at the end of the traversal batch.

  .PARAMETER Path
    The source Path denoting the root of the directory tree to be traversed.

  .PARAMETER Condition
    This is a predicate scriptblock, which is invoked with a DirectoryInfo object presented
  as a result of invoking Get-ChildItem. It provides a filtering mechanism that is defined
  by the user to define which directories are selected for function/scriptblock invocation.

  .PARAMETER PassThru
    A hash table containing miscellaneous information gathered internally throughout the
  traversal batch. This can be of use to the user, because it is the way the user can perform
  bi-directional communication between the invoked custom script block and client side logic.

  .PARAMETER Block
    The script block to be invoked. The script block is invoked for each directory in the
  source directory tree that satisfy the specified Condition predicate with
  the following positional parameters:
    * underscore: the DirectoryInfo object representing the directory in the source tree
    * index: the 0 based index representing current directory in the source tree
    * PassThru object: a hash table containing miscellaneous information gathered internally
    throughout the mirroring batch. This can be of use to the user, because it is the way
    the user can perform bi-directional communication between the invoked custom script block
    and client side logic.
    * trigger: a boolean value, useful for state changing idempotent operations. At the end
    of the batch, the state of the trigger indicates whether any of the items were actioned.
    When the script block is invoked, the trigger should indicate if the trigger was pulled for
    any of the items so far processed in the batch. This is the responsibility of the
    client's script-block/function implementation.

  In addition to these fixed positional parameters, if the invoked scriptblock is defined
  with additional parameters, then these will also be passed in. In order to achieve this,
  the client has to provide excess parameters in BlockParams and these parameters must be
  defined as the same type and in the same order as the additional parameters in the
  script-block.

  .PARAMETER BlockParams
    Optional array containing the excess parameters to pass into the script-block.

  .PARAMETER Functee
    String defining the function to be invoked. Works in a similar way to the Block parameter
  for script-blocks. The Function's base signature is as follows:
    "Underscore": (See underscore described above)
    "Index": (See index described above)
    "PassThru": (See PathThru described above)
    "Trigger": (See trigger described above)

  The destination DirectoryInfo object can be accessed via the PassThru denoted by
  the 'LOOPZ.MIRROR.DESTINATION' entry.

  .PARAMETER FuncteeParams
    Optional hash-table containing the named parameters which are splatted into the Functee
  function invoke. As it's a hash table, order is not significant.

  .PARAMETER Header
    A script-block that is invoked at the start of the mirroring batch. The script-block is
  invoked with the following positional parameters:
    * PassThru: (see PassThru previously described)

    The Header can be customised with the following PassThru entries:
    - 'LOOPZ.KRAYOLA-THEME': Krayola Theme generally in use
    - 'LOOPZ.HEADER-BLOCK.MESSAGE': message displayed as part of the header
    - 'LOOPZ.HEADER-BLOCK.CRUMB': Lead text displayed in header, default: '[+] '
    - 'LOOPZ.HEADER.PROPERTIES': An array of Key/Value pairs of items to be displayed
    - 'LOOPZ.HEADER-BLOCK.LINE': A string denoting the line to be displayed. (There are
    predefined lines available to use in $LoopzUI, or a custom one can be used instead)

  .PARAMETER Summary
    A script-block that is invoked at the end of the traversal batch. The script-block is
  invoked with the following positional parameters:
    * count: the number of items processed in the mirroring batch.
    * skipped: the number of items skipped in the mirroring batch. An item is skipped if
    it fails the defined condition or is not of the correct type (eg if its a directory
    but we have specified the -File flag).
    * trigger: Flag set by the script-block/function, but should typically be used to
    indicate whether any of the items processed were actively updated/written in this batch.
    This helps in written idempotent operations that can be re-run without adverse
    consequences.
    * PassThru: (see PassThru previously described)

  .PARAMETER Hoist
    Switch parameter. Without Hoist being specified, the Condition can prove to be too restrictive
  on matching against directories. If a directory does not match the Condition then none of its
  descendants will be considered to be traversed. When Hoist is specified then a descendant directory
  that does match the Condition will be traversed even though any of its ancestors may not match the
  same Condition.

  .EXAMPLE 1
    Invoke a script-block for every directory in the source tree.

    [scriptblock]$block = {
      param(
        $underscore,
        [int]$index,
        [System.Collections.Hashtable]$passThru,
        [boolean]$trigger
      )
      ...
    }

  Invoke-TraverseDirectory -Path './Tests/Data/fefsi' -Block $block

  .EXAMPLE 2
    Invoke a named function with extra parameters for every directory in the source tree.

  function Test-Traverse {
    param(
      [System.IO.DirectoryInfo]$Underscore,
      [int]$Index,
      [System.Collections.Hashtable]$PassThru,
      [boolean]$Trigger,
      [string]$Format
    )
    ...
  }
  [System.Collections.Hashtable]$parameters = @{
    'Format' = "=== {0} ===";
  }

  Invoke-TraverseDirectory -Path './Tests/Data/fefsi' `
    -Functee 'Test-Traverse' -FuncteeParams $parameters;

  .EXAMPLE 3
  Invoke a named function, including only directories beginning with A (filter A*)

  function Test-Traverse {
    param(
      [System.IO.DirectoryInfo]$Underscore,
      [int]$Index,
      [System.Collections.Hashtable]$PassThru,
      [boolean]$Trigger
    )
    ...
  }

  [scriptblock]$filterDirectories = {
    [OutputType([boolean])]
    param(
      [System.IO.DirectoryInfo]$directoryInfo
    )

    Select-FsItem -Name $directoryInfo.Name -Includes @('A*');
  }

  Invoke-TraverseDirectory -Path './Tests/Data/fefsi' -Functee 'Test-Traverse' `
    -Condition $filterDirectories;

  Note the possible issue with this example is that any descendants named A... which are located
  under an ancestor which is not named A..., will not be processed by the provided function

  .EXAMPLE 4
  Mirror a directory tree, including only directories beginning with A (filter A*) regardless of
  the matching of intermediate ancestors (specifying -Hoist flag resolves the possible
  issue in the previous example)

  function Test-Traverse {
    param(
      [System.IO.DirectoryInfo]$Underscore,
      [int]$Index,
      [System.Collections.Hashtable]$PassThru,
      [boolean]$Trigger
    )
    ...
  }

  [scriptblock]$filterDirectories = {
    [OutputType([boolean])]
    param(
      [System.IO.DirectoryInfo]$directoryInfo
    )

    Select-FsItem -Name $directoryInfo.Name -Includes @('A*');
  }

  Invoke-TraverseDirectory -Path './Tests/Data/fefsi' -Functee 'Test-Traverse' `
    -Condition $filterDirectories -Hoist;

  Note that the directory filter must include a wild-card, otherwise it will be ignored. So a
  directory include of @('A'), is problematic, because A is not a valid directory filter so its
  ignored and there are no remaining filters that are able to include any directory, so no
  directory passes the filter.

  #>
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
    [System.Collections.Hashtable]$FuncteeParams = @{},

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [scriptblock]$Header = ( {
        param(
          [System.Collections.Hashtable]$_passThru
        )
      }),

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [scriptblock]$Summary = ( {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
        param(
          [int]$_count,
          [int]$_skipped,
          [boolean]$_triggered,
          [System.Collections.Hashtable]$_passThru
        )
      }),

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [scriptblock]$SessionHeader = ( {
        param(
          [System.Collections.Hashtable]$_passThru
        )
      }),

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [scriptblock]$SessionSummary = ( {
        param(
          [int]$_count,
          [int]$_skipped,
          [boolean]$_trigger,
          [System.Collections.Hashtable]$_passThru
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

    $result = $null;
    $index = $passThru['LOOPZ.FOREACH.INDEX'];

    # This is the invoke, for the current directory
    #
    if ($invokee -is [scriptblock]) {
      $positional = @($directoryInfo, $index, $passThru, $trigger);

      if ($passThru.ContainsKey('LOOPZ.TRAVERSE.INVOKEE.PARAMS') -and
        ($passThru['LOOPZ.TRAVERSE.INVOKEE.PARAMS'].Count -gt 0)) {
        $passThru['LOOPZ.TRAVERSE.INVOKEE.PARAMS'] | ForEach-Object {
          $positional += $_;
        }
      }
      $result = $invokee.Invoke($positional);
    }
    else {
      [System.Collections.Hashtable]$parameters = $passThru.ContainsKey('LOOPZ.TRAVERSE.INVOKEE.PARAMS') `
        ? $passThru['LOOPZ.TRAVERSE.INVOKEE.PARAMS'] : @{};

      # These are directory specific overwrites. The custom parameters
      # will still be present
      #
      $parameters['Underscore'] = $directoryInfo;
      $parameters['Index'] = $index;
      $parameters['PassThru'] = $passThru;
      $parameters['Trigger'] = $trigger;

      $result = & $invokee @parameters;
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

    return $result;
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
    $controller = $_passThru['LOOPZ.CONTROLLER'];

    try {
      $adapted.Invoke(
        $_underscore,
        $_passThru['LOOPZ.TRAVERSE.CONDITION'],
        $_passThru,
        $PassThru['LOOPZ.TRAVERSE.INVOKEE'],
        $_trigger
      );
    }
    catch [System.Management.Automation.MethodInvocationException] {
      $controller.ErrorItem();
      # This is a mystery exception, that has no effect on processing the batch:
      #
      # Exception calling ".ctor" with "2" argument(s): "Count cannot be less than zero.
      #
      # Resolve-Error
      # Write-Error "Problem with: '$_underscore'" -ErrorAction Stop;
    }
    catch {
      $controller.ErrorItem();
      Write-Error "[!] Error: $($_.Exception.Message)" -ErrorAction Continue;

      throw;
    }
  } # adapter

  # ======================================================= [Invoke-TraverseDirectory] ===

  $controller = New-Controller -Type TraverseCtrl -PassThru $PassThru `
    -Header $Header -Summary $Summary -SessionHeader $SessionHeader -SessionSummary $SessionSummary;
  $PassThru['LOOPZ.CONTROLLER'] = $controller;

  $controller.StartSession();

  # Handle top level directory, before recursing through child directories
  #
  [System.IO.DirectoryInfo]$directory = Get-Item -Path $Path;

  [boolean]$itemIsDirectory = ($directory.Attributes -band
    [System.IO.FileAttributes]::Directory) -eq [System.IO.FileAttributes]::Directory;

  if ($itemIsDirectory) {
    if ($Condition.Invoke($directory)) {
      [boolean]$trigger = $controller.GetTrigger();

      # The index of the top level directory is always 0
      #
      [int]$index = $controller.RequestIndex();

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

      $result = $null;

      # This is the top level invoke
      #
      try {
        if ('InvokeScriptBlock' -eq $PSCmdlet.ParameterSetName) {
          $result = $Block.Invoke($positional);
        }
        elseif ('InvokeFunction' -eq $PSCmdlet.ParameterSetName) {
          $result = & $Functee @parameters;
        }
      }
      catch {
        $controller.IncrementError();
      }
      finally {
        $controller.HandleResult($result);
      }
    }
    else {
      $controller.SkipItem();
    }

    # --- end of top level invoke ----------------------------------------------------------

    if ($Hoist.ToBool()) {
      # Perform non-recursive retrieval of descendant directories
      #
      [System.IO.DirectoryInfo[]]$directoryInfos = Get-ChildItem -Path $Path `
        -Directory -Recurse | Where-Object { $Condition.Invoke($_) }

      Write-Debug "  [o] Invoke-TraverseDirectory (Hoist); Count: $($directoryInfos.Count)";

      if ($directoryInfos) {
        # No need to manage the index, let Invoke-ForeachFsItem do this for us,
        # except we do need to inform Invoke-ForeachFsItem to start the index at
        # +1, because 0 is for the top level directory which has already been
        # handled.
        #
        [System.Collections.Hashtable]$parametersFeFsItem = @{
          'Directory' = $true;
          'PassThru'  = $PassThru;
          'Summary'   = $Summary;
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
      # Top level descendants
      #
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
    }
  }
  else {
    $controller.SkipItem();
    Write-Error "Path specified '$($Path)' is not a directory";
  }

  $controller.EndSession();
} # Invoke-TraverseDirectory
