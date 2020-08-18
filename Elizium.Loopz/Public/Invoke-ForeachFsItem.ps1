
function Invoke-ForeachFsItem {
  <#
  .NAME
    Invoke-ForeachFsItem

  .SYNOPSIS
    Allows a custom defined scriptblock or function to be invoked for all file system
  objects delivered through the pipeline.

  .DESCRIPTION
    2 parameters sets are defined, one for invoking a named function (InvokeFunction) and
  the other (InvokeScriptBlock, the default) for invoking a script-block. An optional
  Summary script block can be specified which will be invoked at the end of the pipeline
  batch. The user should assemble the candidate items from the file system, be they files or
  directories typically using Get-ChildItem, or can be any other function that delivers
  file systems items via the PowerShell pipeline. For each item in the pipeline,
  Invoke-ForeachFsItem will invoke the script-block/function specified. Invoke-ForeachFsItem
  will deliver what ever is returned from the script-block/function, so the result of
  Invoke-ForeachFsItem can be piped to another command.

  .PARAMETER pipelineItem
    This is the pipeline object, so should not be specified explicitly and can represent
  a file object (System.IO.FileInfo) or a directory object (System.IO.DirectoryInfo).

  .PARAMETER Condition
    This is a predicate scriptblock, which is invoked with either a DirectoryInfo or
  FileInfo object presented as a result of invoking Get-ChildItem. It provides a filtering
  mechanism that is defined by the user to define which file system objects are selected
  for function/scriptblock invocation.

  .PARAMETER Block
    The script block to be invoked. The script block is invoked for each item in the
  pipeline that satisfy the Condition with the following positional parameters:
    * pipelineItem: the item from the pipeline
    * index: the 0 based index representing current pipeline item
    * PassThru: a hash table containing miscellaneous information gathered internally
  throughout the pipeline batch. This can be of use to the user, because it is the way
  the user can perform bi-directional communication between the invoked custom script block
  and client side logic.
    * trigger: a boolean value, useful for state changing idempotent operations. At the end
  of the batch, the state of the trigger indicates whether any of the items were actioned.
  When the script block is invoked, the trigger should indicate if the trigger was pulled for
  any of the items so far processed in the pipeline. This is the responsibility of the
  client's block implementation. The trigger is only of use for state changing operations
  and can be ignored otherwise.
  
  In addition to these fixed positional parameters, if the invoked scriptblock is defined
  with additional parameters, then these will also be passed in. In order to achieve this,
  the client has to provide excess parameters in BlockParam and these parameters must be
  defined as the same type and in the same order as the additional parameters in the
  scriptblock.

  .PARAMETER BlockParams
    Optional array containing the excess parameters to pass into the script block.

  .PARAMETER Functee
    String defining the function to be invoked. Works in a similar way to the Block parameter
  for script-blocks. The Function's base signature is as follows:
    "Underscore": (See pipelineItem described above)
    "Index": (See index described above)
    "PassThru": (See PathThru described above)
    "Trigger": (See trigger described above)

  .PARAMETER FuncteeParams
    Optional hash-table containing the named parameters which are splatted into the Functee
  function invoke. As it's a hash table, order is not significant.

  .PARAMETER PassThru
    A hash table containing miscellaneous information gathered internally throughout the
  pipeline batch. This can be of use to the user, because it is the way the user can perform
  bi-directional communication between the invoked custom script block and client side logic.

  .PARAMETER Summary
    A script-block that is invoked at the end of the pipeline batch. The script-block is
  invoked with the following positional parameters:
    * count: the number of items processed in the pipeline batch.
    * skipped: the number of items skipped in the pipeline batch. An item is skipped if
    it fails the defined condition or is not of the correct type (eg if its a directory
    but we have specified the -File flag). Also note that, if the script-block/function
    sets the Break flag causing further iteration to stop, then those subsequent items
    in the pipeline which have not been processed are not reflected in the skip count.
    * trigger: Flag set by the script-block/function, but should typically be used to
    indicate whether any of the items processed were actively updated/written in this batch.
    This helps in written idempotent operations that can be re-run without adverse
    consequences.
    * PassThru: (see PassThru previously described)

  .PARAMETER File
    Switch to indicate that the invoked function/script-block (invokee) is to handle FileInfo
  objects. Is mutually exclusive with the Directory switch. If neither switch is specified, then
  the invokee must be able to handle both therefore the Underscore parameter it defines must
  be declared as FileSystemInfo.

  .PARAMETER Directory
    Switch to indicate that the invoked function/script-block (invokee) is to handle Directory
  objects.

  .PARAMETER StartIndex
    Some calling functions interact with Invoke-ForeachFsItem in a way that may require that
  there is external control of the starting index. For example, Invoke-TraverseDirectory
  (which invokes Invoke-ForeachFsItem) handles the root Directory separately from its descendants
  and to ensure that the allocated indices are correct, the starting index should be set to 1,
  because the root Directory has already been allocated index 0, outside of the ForeachFsItem
  batch.
    Normal use of ForeachFsItem does not require StartIndex to be specified.

  .EXAMPLE 1
  Invoke a script-block to handle .txt file objects from the same directory (without -Recurse):
  (NB: first parameter is of type FileInfo, -File specified on Get-ChildItem and
  Invoke-ForeachFsItem. If Get-ChildItem is missing -File, then any Directory objects passed in
  are filtered out by Invoke-ForeachFsItem. If -File is missing from Invoke-ForeachFsItem, then
  the script-block's first parameter, must be a FileSystemInfo to handle both types)

    [scriptblock]$block = {
      param(
        [System.IO.FileInfo]$FileInfo,
        [int]$Index,
        [System.Collections.Hashtable]$PassThru,
        [boolean]$Trigger
      )
      ...
    }

    Get-ChildItem './Tests/Data/fefsi' -Recurse -Filter '*.txt' -File | `
      Invoke-ForeachFsItem -File -Block $block;

  .EXAMPLE 2
  Invoke a function with additional parameters to handle directory objects from multiple directories
  (with -Recurse):

  function invoke-Target {
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
    'Format'
  }
  Get-ChildItem './Tests/Data/fefsi' -Recurse -Directory | `
    Invoke-ForeachFsItem -Directory -Functee 'invoke-Target' -FuncteeParams $parameters

  .EXAMPLE 3
  Invoke a script-block to handle empty .txt file objects from the same directory (without -Recurse):
    [scriptblock]$block = {
      param(
        [System.IO.FileInfo]$FileInfo,
        [int]$Index,
        [System.Collections.Hashtable]$PassThru,
        [boolean]$Trigger
      )
      ...
    }

    [scriptblock]$fileIsEmpty = {
      param(
        [System.IO.FileInfo]$FileInfo
      )
      return (0 -eq $FileInfo.Length)
    }

    Get-ChildItem './Tests/Data/fefsi' -Recurse -Filter '*.txt' -File | Invoke-ForeachFsItem `
      -Block $block -File -condition $fileIsEmpty;

  .EXAMPLE 4
  Invoke a script-block only for directories whose name starts with "A" from the same
  directory (without -Recurse); Note the use of the LOOPZ function "Select-FsItem" in the
  directory include filter:

    [scriptblock]$block = {
      param(
        [System.IO.FileInfo]$FileInfo,
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
    Select-FsItem -Name $directoryInfo.Name -Includes 'A*';
  }

    Get-ChildItem './Tests/Data/fefsi' -Directory | Invoke-ForeachFsItem `
      -Block $block -Directory -DirectoryIncludes $filterDirectories;
  #>
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
  [CmdletBinding(DefaultParameterSetName = 'InvokeScriptBlock')]
  param(
    [Parameter(ParameterSetName = 'InvokeScriptBlock', Mandatory, ValueFromPipeline = $true)]
    [Parameter(ParameterSetName = 'InvokeFunction', Mandatory, ValueFromPipeline = $true)]
    [System.IO.FileSystemInfo]$pipelineItem,

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [scriptblock]$Condition = ( { return $true; }),

    [Parameter(ParameterSetName = 'InvokeScriptBlock', Mandatory)]
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
    [System.Collections.Hashtable]$PassThru = @{},

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [scriptblock]$Summary = ( {
        param(
          [int]$count,
          [int]$skipped,
          [boolean]$trigger,
          [System.Collections.Hashtable]$passThru
        )
      }),

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [ValidateScript( { -not($PSBoundParameters.ContainsKey('Directory')) })]
    [switch]$File,

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [ValidateScript( { -not($PSBoundParameters.ContainsKey('File')) })]
    [switch]$Directory,

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [int]$StartIndex = 0
  ) # param

  begin {
    [boolean]$manageIndex = -not($PassThru.ContainsKey('LOOPZ.FOREACH.INDEX'));
    [int]$index = $manageIndex ? $StartIndex : $PassThru['LOOPZ.FOREACH.INDEX'];
    [int]$skipped = 0;
    [boolean]$broken = $false;
    [boolean]$trigger = $PassThru.ContainsKey('LOOPZ.FOREACH.TRIGGER');
  }

  process {
    [boolean]$itemIsDirectory = ($pipelineItem.Attributes -band
      [System.IO.FileAttributes]::Directory) -eq [System.IO.FileAttributes]::Directory;

    [boolean]$acceptAll = -not($File.ToBool()) -and -not($Directory.ToBool());

    if (-not($broken)) {
      if ( $acceptAll -or ($Directory.ToBool() -and $itemIsDirectory) -or
        ($File.ToBool() -and -not($itemIsDirectory)) ) {
        if ($Condition.Invoke($pipelineItem)) {
          $result = $null;

          try {
            if ('InvokeScriptBlock' -eq $PSCmdlet.ParameterSetName) {
              $positional = @($pipelineItem, $index, $PassThru, $trigger);

              if ($BlockParams.Length -gt 0) {
                $BlockParams | ForEach-Object {
                  $positional += $_;
                }
              }

              $result = Invoke-Command -ScriptBlock $Block -ArgumentList $positional;
            }
            elseif ('InvokeFunction' -eq $PSCmdlet.ParameterSetName) {
              [System.Collections.Hashtable]$parameters = $FuncteeParams.Clone();

              $parameters['Underscore'] = $pipelineItem;
              $parameters['Index'] = $index;
              $parameters['PassThru'] = $PassThru;
              $parameters['Trigger'] = $trigger;

              $result = & $Functee @parameters;
            }
          }
          catch {
            Write-Error "Foreach Error: ($_), for item: '$($pipelineItem.Name)'";
          }
          finally {
            if ($manageIndex) {
              $index++;
            }
            else {
              $index = $PassThru['LOOPZ.FOREACH.INDEX'];
            }

            if ($result) {
              if ($result.psobject.properties.match('Trigger') -and $result.Trigger) {
                $PassThru['LOOPZ.FOREACH.TRIGGER'] = $true;
                $trigger = $true;
              }

              if ($result.psobject.properties.match('Break') -and $result.Break) {
                $broken = $true;
              }

              if ($result.psobject.properties.match('Product') -and $result.Product) {
                $result.Product;
              }
            }
          }
        }
        else {
          # IDEA! We could allow the user to provide an extra script block which we
          # invoke for skipped items and set a string containing the reason why it was
          # skipped.
          $null = $skipped++;
        }
      }
      else {
        $null = $skipped++;
      }
    }
    else {
      $null = $skipped++;
    }
  }

  end {
    $PassThru['LOOPZ.FOREACH.TRIGGER'] = $trigger;
    if ($manageIndex) {
      $Summary.Invoke($index, $skipped, $trigger, $PassThru);
    }
  }
} # Invoke-ForeachFsItem
