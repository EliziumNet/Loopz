using namespace System.IO;

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

  .LINK
    https://eliziumnet.github.io/Loopz/

  .PARAMETER Block
    The script block to be invoked. The script block is invoked for each directory in the
  source directory tree that satisfy the specified Condition predicate with
  the following positional parameters:
    * underscore: the DirectoryInfo object representing the directory in the source tree
    * index: the 0 based index representing current directory in the source tree
    * Exchange object: a hash table containing miscellaneous information gathered internally
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

  .PARAMETER Condition
    This is a predicate script-block, which is invoked with a DirectoryInfo object presented
  as a result of invoking Get-ChildItem. It provides a filtering mechanism that is defined
  by the user to define which directories are selected for function/script-block invocation.

  .PARAMETER Exchange
    A hash table containing miscellaneous information gathered internally throughout the
  traversal batch. This can be of use to the user, because it is the way the user can perform
  bi-directional communication between the invoked custom script block and client side logic.

  .PARAMETER Functee
    String defining the function to be invoked. Works in a similar way to the Block parameter
  for script-blocks. The Function's base signature is as follows:
  * "Underscore": (See underscore described above)
  * "Index": (See index described above)
  * "Exchange": (See PathThru described above)
  * "Trigger": (See trigger described above)

  The destination DirectoryInfo object can be accessed via the Exchange denoted by
  the 'LOOPZ.MIRROR.DESTINATION' entry.

  .PARAMETER FuncteeParams
    Optional hash-table containing the named parameters which are splatted into the Functee
  function invoke. As it's a hash table, order is not significant.

  .PARAMETER Header
    A script-block that is invoked for each directory that also contains child directories.
  The script-block is invoked with the following positional parameters:
    * Exchange: (see Exchange previously described)

    The Header can be customised with the following Exchange entries:
    * 'LOOPZ.KRAYOLA-THEME': Krayola Theme generally in use
    * 'LOOPZ.HEADER-BLOCK.MESSAGE': message displayed as part of the header
    * 'LOOPZ.HEADER-BLOCK.CRUMB-SIGNAL': Lead text displayed in header, default: '[+] '
    * 'LOOPZ.HEADER.PROPERTIES': An array of Key/Value pairs of items to be displayed
    * 'LOOPZ.HEADER-BLOCK.LINE': A string denoting the line to be displayed. (There are
    predefined lines available to use in $LoopzUI, or a custom one can be used instead)

  .PARAMETER Hoist
    Switch parameter. Without Hoist being specified, the Condition can prove to be too restrictive
  on matching against directories. If a directory does not match the Condition then none of its
  descendants will be considered to be traversed. When Hoist is specified then a descendant directory
  that does match the Condition will be traversed even though any of its ancestors may not match the
  same Condition.

  .PARAMETER Path
    The source Path denoting the root of the directory tree to be traversed.

  .PARAMETER SessionHeader
    A script-block that is invoked at the start of the traversal batch. The script-block has
  the same signature as the Header script block.

  .PARAMETER SessionSummary
    A script-block that is invoked at the end of the traversal batch. The script-block has
  the same signature as the Summary script block.

  .PARAMETER Summary
    A script-block that is invoked foreach directory that also contains child directories,
  after all its descendants have been processed and serves as a sub-total for the current
  directory. The script-block is invoked with the following positional parameters:
    * count: the number of items processed in the mirroring batch.
    * skipped: the number of items skipped in the mirroring batch. An item is skipped if
    it fails the defined condition or is not of the correct type (eg if its a directory
    but we have specified the -File flag).
    * errors: the number of items which resulted in error. An error occurs when the function
    or the script-block has set the Error property on the invoke result.
    * trigger: Flag set by the script-block/function, but should typically be used to
    indicate whether any of the items processed were actively updated/written in this batch.
    This helps in written idempotent operations that can be re-run without adverse
    consequences.
    * Exchange: (see Exchange previously described)

  .PARAMETER Depth
    Allows the restriction of traversal by depth (aligned with the Depth parameter on Get-ChildItem).
  0 means restrict invocations to immediate children of Path, with successive increments relating
  to generations thereafter.

  .PARAMETER OnBefore
    For every directory traversed which itself has sub-directories, the scriptblock specified
  by OnBefore is invoked, before those directories are invoked. The scriptblock specified must
  be defined with the following signature:

    [scriptblock]$before = {
      param(
        [DirectoryInfo]$_directoryInfo,
        [hashtable]$_exchange
      )
      ...
    }

    The directory info specified is the directory whose child directories are about to be invoked.

  .PARAMETER OnAfter
    For every directory traversed which itself has sub-directories, the scriptblock specified
  by OnBefore is invoked, after those directories are invoked (in fact it is the same directory
  info that is passed into OnBefore). The scriptblock specified must be defined with a signature
  the same as OnBefore.

  .EXAMPLE 1
    Invoke a script-block for every directory in the source tree.

    [scriptblock]$block = {
      param(
        $underscore,
        [int]$index,
        [hashtable]$exchange,
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
      [hashtable]$Exchange,
      [boolean]$Trigger,
      [string]$Format
    )
    ...
  }
  [hashtable]$parameters = @{
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
      [hashtable]$Exchange,
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
      [hashtable]$Exchange,
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

  .EXAMPLE 5
  Same as EXAMPLE 4, but using predefined Header and Summary script-blocks for Session header/summary
  and per directory header/summary. (Test-Traverse and filterDirectories as per EXAMPLE 4)

  Invoke-TraverseDirectory -Path './Tests/Data/fefsi' -Functee 'Test-Traverse' `
    -Condition $filterDirectories -Hoist `
    -Header $LoopzHelpers.DefaultHeaderBlock -Summary $DefaultHeaderBlock.SimpleSummaryBlock `
    -SessionHeader $LoopzHelpers.DefaultHeaderBlock -SessionSummary $DefaultHeaderBlock.SimpleSummaryBlock;

  .EXAMPLE 6
    Invoke a script-block for every directory in the source tree within a depth of 2

    [scriptblock]$block = {
      param(
        $underscore,
        [int]$index,
        [hashtable]$exchange,
        [boolean]$trigger
      )
      ...
    }

    Invoke-TraverseDirectory -Path './Tests/Data/fefsi' -Block $block -Depth 2
  #>
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
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
    [hashtable]$Exchange = @{},

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
    [hashtable]$FuncteeParams = @{},

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [scriptblock]$Header = ( {
        param(
          [hashtable]$_exchange
        )
      }),

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [scriptblock]$Summary = ( {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
        param(
          [int]$_count,
          [int]$_skipped,
          [int]$_errors,
          [boolean]$_triggered,
          [hashtable]$_exchange
        )
      }),

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [scriptblock]$SessionHeader = ( {
        param(
          [hashtable]$_exchange
        )
      }),

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [scriptblock]$SessionSummary = ( {
        param(
          [int]$_count,
          [int]$_skipped,
          [int]$_errors,
          [boolean]$_trigger,
          [hashtable]$_exchange
        )
      }),

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [switch]$Hoist,

    [Parameter()]
    [ValidateScript( { $_ -ge 0 })]
    [int]$Depth,

    [Parameter()]
    [scriptblock]$OnBefore = ({
        param(
          [Parameter()]
          [DirectoryInfo]$_directoryInfo,

          [Parameter()]
          [hashtable]$_exchange
        )
      }),

    [Parameter()]
    [scriptblock]$OnAfter = ({
        param(
          [Parameter()]
          [DirectoryInfo]$_directoryInfo,

          [Parameter()]
          [hashtable]$_exchange
        )
      })
  ) # param

  function Test-DepthInRange {

    # Assuming 'traverse' is the root path
    #
    # Get-ChildItem depth/limit ----->                  0     1       2
    # controller depth -------------->         1        2     3       4
    #                             .\Tests\Data\traverse\Audio\MINIMAL\FUSE
    #
    [OutputType([boolean])]
    param(
      [hashtable]$Exchange
    )

    [boolean]$isInRange = if ($Exchange.ContainsKey('LOOPZ.TRAVERSE.LIMIT-DEPTH')) {
      [int]$limitDepth = $Exchange['LOOPZ.TRAVERSE.LIMIT-DEPTH']; # 0 based
      [int]$controllerDepth = $Exchange['LOOPZ.CONTROLLER.DEPTH']; # 1 based

      $($controllerDepth -le ($limitDepth + 2));
    }
    else {
      $true;
    }

    return $isInRange;
  }

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
      [hashtable]$exchange,

      [Parameter(Position = 3)]
      [ValidateScript( { ($_ -is [scriptblock]) -or ($_ -is [string]) })]
      $invokee, # (scriptblock or function name; hence un-typed parameter)

      [Parameter(Position = 4)]
      [boolean]$trigger
    )

    $result = $null;
    $index = $exchange['LOOPZ.FOREACH.INDEX'];

    # This is the invoke, for the current directory
    #
    if ($invokee -is [scriptblock]) {
      $positional = @($directoryInfo, $index, $exchange, $trigger);

      if ($exchange.ContainsKey('LOOPZ.TRAVERSE.INVOKEE.PARAMS') -and
        ($exchange['LOOPZ.TRAVERSE.INVOKEE.PARAMS'].Count -gt 0)) {
        $exchange['LOOPZ.TRAVERSE.INVOKEE.PARAMS'] | ForEach-Object {
          $positional += $_;
        }
      }
      $result = $invokee.InvokeReturnAsIs($positional);
    }
    else {
      [hashtable]$parameters = $exchange.ContainsKey('LOOPZ.TRAVERSE.INVOKEE.PARAMS') `
        ? $exchange['LOOPZ.TRAVERSE.INVOKEE.PARAMS'] : @{};

      # These are directory specific overwrites. The custom parameters
      # will still be present
      #
      $parameters['Underscore'] = $directoryInfo;
      $parameters['Index'] = $index;
      $parameters['Exchange'] = $exchange;
      $parameters['Trigger'] = $trigger;

      $result = & $invokee @parameters;
    }

    if (Test-DepthInRange -Exchange $Exchange) {
      [string]$fullName = $directoryInfo.FullName;
      [System.IO.DirectoryInfo[]]$directoryInfos = Get-ChildItem -Path $fullName `
        -Directory | Where-Object { $condition.InvokeReturnAsIs($_) };

      [scriptblock]$adapter = $Exchange['LOOPZ.TRAVERSE.ADAPTOR'];

      if ($directoryInfos.Count -gt 0) {
        if ($Exchange.ContainsKey("LOOPZ.TRAVERSE.ON-BEFORE")) {
          $Exchange["LOOPZ.TRAVERSE.ON-BEFORE"].Invoke($fullName, $Exchange);
        }
        # adapter is always a script block, this has nothing to do with the invokee,
        # which may be a script block or a named function(functee)
        #
        $directoryInfos | Invoke-ForeachFsItem -Directory -Block $adapter `
          -Exchange $Exchange -Condition $condition -Summary $Summary;

        if ($Exchange.ContainsKey("LOOPZ.TRAVERSE.ON-AFTER")) {
          $Exchange["LOOPZ.TRAVERSE.ON-AFTER"].Invoke($fullName, $Exchange);
        }
      }
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
      [hashtable]$_exchange,

      [Parameter(Mandatory)]
      [boolean]$_trigger
    )

    [scriptblock]$adapted = $_exchange['LOOPZ.TRAVERSE.ADAPTED'];
    $controller = $_exchange['LOOPZ.CONTROLLER'];

    try {
      $adapted.InvokeReturnAsIs(
        $_underscore,
        $_exchange['LOOPZ.TRAVERSE.CONDITION'],
        $_exchange,
        $Exchange['LOOPZ.TRAVERSE.INVOKEE'],
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

  $controller = New-Controller -Type TraverseCtrl -Exchange $Exchange `
    -Header $Header -Summary $Summary -SessionHeader $SessionHeader -SessionSummary $SessionSummary;
  $Exchange['LOOPZ.CONTROLLER'] = $controller;

  if ($PSBoundParameters.ContainsKey('Depth')) {
    $Exchange['LOOPZ.TRAVERSE.LIMIT-DEPTH'] = $Depth;
  }

  if ($PSBoundParameters.ContainsKey("OnBefore")) {
    $Exchange["LOOPZ.TRAVERSE.ON-BEFORE"] = $OnBefore;
  }

  if ($PSBoundParameters.ContainsKey("OnAfter")) {
    $Exchange["LOOPZ.TRAVERSE.ON-AFTER"] = $OnAfter;
  }

  $controller.BeginSession();

  # Handle top level directory, before recursing through child directories
  #
  [System.IO.DirectoryInfo]$directory = Get-Item -Path $Path;

  [boolean]$itemIsDirectory = ($directory.Attributes -band
    [System.IO.FileAttributes]::Directory) -eq [System.IO.FileAttributes]::Directory;

  if ($itemIsDirectory) {
    if ($Condition.InvokeReturnAsIs($directory)) {
      [boolean]$trigger = $controller.GetTrigger();

      # The index of the top level directory is always 0
      #
      [int]$index = $controller.RequestIndex();

      if ('InvokeFunction' -eq $PSCmdlet.ParameterSetName) {
        # set-up custom parameters
        #
        [hashtable]$parameters = $FuncteeParams.Clone();
        $parameters['Underscore'] = $directory;
        $parameters['Index'] = $index;
        $parameters['Exchange'] = $Exchange;
        $parameters['Trigger'] = $trigger;
        $Exchange['LOOPZ.TRAVERSE.INVOKEE.PARAMS'] = $parameters;
      }
      elseif ('InvokeScriptBlock' -eq $PSCmdlet.ParameterSetName) {
        $positional = @($directory, $index, $Exchange, $trigger);

        if ($BlockParams.Count -gt 0) {
          $BlockParams | Foreach-Object {
            $positional += $_;
          }
        }

        # Note, for the positional parameters, we can only pass in the additional
        # custom parameters provided by the client here via the Exchange otherwise
        # we could accidentally build up the array of positional parameters with
        # duplicated entries. This is in contrast to splatted arguments for function
        # invokes where parameter names are paired with parameter values in a
        # hashtable and naturally prevent duplicated entries. This is why we set
        # 'LOOPZ.TRAVERSE.INVOKEE.PARAMS' to $BlockParams and not $positional.
        #
        $Exchange['LOOPZ.TRAVERSE.INVOKEE.PARAMS'] = $BlockParams;
      }

      $result = $null;

      try {
        # No need to consider the depth here because this is the top level invoke
        # which should never be skipped because of the depth limit
        #
        if ('InvokeScriptBlock' -eq $PSCmdlet.ParameterSetName) {
          $result = $Block.InvokeReturnAsIs($positional);
        }
        elseif ('InvokeFunction' -eq $PSCmdlet.ParameterSetName) {
          $result = & $Functee @parameters;
        }
      }
      catch {
        $result = [PSCustomObject]@{
          ErrorReason = "Unhandled Error: $($_.Exception.Message)";
        }
      }
      finally {
        $controller.HandleResult($result);
      }
    }
    else {
      $controller.SkipItem();
    }

    # --- end of top level invoke ----------------------------------------------------------

    if ($Hoist.IsPresent) {
      # Perform non-recursive retrieval of descendant directories
      #
      [hashtable]$parametersGeChItem = @{
        'Path'      = $Path;
        'Directory' = $true;
        'Recurse'   = $true;
      }
      if ($PSBoundParameters.ContainsKey('Depth')) {
        $parametersGeChItem['Depth'] = $Depth;
      }

      [System.IO.DirectoryInfo[]]$directoryInfos = Get-ChildItem @parametersGeChItem | Where-Object {
        $Condition.InvokeReturnAsIs($_)
      }

      Write-Debug "  [o] Invoke-TraverseDirectory (Hoist); Count: $($directoryInfos.Count)";

      if ($directoryInfos.Count -gt 0) {
        if ($PSBoundParameters.ContainsKey("OnBefore")) {
          $OnBefore.Invoke($directory, $Exchange);
        }
        # No need to manage the index, let Invoke-ForeachFsItem do this for us,
        # except we do need to inform Invoke-ForeachFsItem to start the index at
        # +1, because 0 is for the top level directory which has already been
        # handled.
        #
        [hashtable]$parametersFeFsItem = @{
          'Directory' = $true;
          'Exchange'  = $Exchange;
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

        if ($PSBoundParameters.ContainsKey("OnAfter")) {
          $OnAfter.Invoke($directory, $Exchange);
        }
      }
    }
    else {
      # Top level descendants
      #
      # Set up the adapter. (NB, can't use splatting because we're invoking a script block
      # as opposed to a named function.)
      #
      $Exchange['LOOPZ.TRAVERSE.CONDITION'] = $Condition;
      $Exchange['LOOPZ.TRAVERSE.ADAPTED'] = $recurseTraverseDirectory;
      $Exchange['LOOPZ.TRAVERSE.ADAPTOR'] = $adapter;

      if ('InvokeScriptBlock' -eq $PSCmdlet.ParameterSetName) {
        $Exchange['LOOPZ.TRAVERSE.INVOKEE'] = $Block;
      }
      elseif ('InvokeFunction' -eq $PSCmdlet.ParameterSetName) {
        $Exchange['LOOPZ.TRAVERSE.INVOKEE'] = $Functee;
      }

      # Now perform start of recursive traversal
      #
      [System.IO.DirectoryInfo[]]$directoryInfos = Get-ChildItem -Path $Path `
        -Directory | Where-Object { $Condition.InvokeReturnAsIs($_) }

      if ($directoryInfos.Count -gt 0) {
        if ($PSBoundParameters.ContainsKey("OnBefore")) {
          $OnBefore.Invoke($directory, $Exchange);
        }
        $directoryInfos | Invoke-ForeachFsItem -Directory -Block $adapter `
          -Exchange $Exchange -Condition $Condition -Summary $Summary;

        if ($PSBoundParameters.ContainsKey("OnAfter")) {
          $OnAfter.Invoke($directory, $Exchange);
        }
      }
    }
  }
  else {
    $controller.SkipItem();
    Write-Error "Path specified '$($Path)' is not a directory";
  }

  $controller.EndSession();
} # Invoke-TraverseDirectory
