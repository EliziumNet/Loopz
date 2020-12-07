---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Invoke-ForeachFsItem

## SYNOPSIS

Allows a custom defined script-block or function to be invoked for all file system objects delivered through the pipeline.

## SYNTAX

### InvokeScriptBlock (Default)

```powershell

Invoke-ForeachFsItem -pipelineItem <FileSystemInfo> [-Condition <ScriptBlock>] -Block <ScriptBlock>
[-BlockParams <Object>] [-PassThru <Hashtable>] [-Header <ScriptBlock>] [-Summary <ScriptBlock>] [-File] [-Directory] [<CommonParameters>]
```

### InvokeFunction

```powershell

Invoke-ForeachFsItem -pipelineItem <FileSystemInfo> [-Condition <ScriptBlock>] -Functee <String>
[-FuncteeParams <Hashtable>] [-PassThru <Hashtable>] [-Header <ScriptBlock>] [-Summary <ScriptBlock>] [-File] [-Directory] [<CommonParameters>]
```

## DESCRIPTION

  2 parameters sets are defined, one for invoking a named function (InvokeFunction) and
the other (InvokeScriptBlock, the default) for invoking a script-block. An optional
Summary script block can be specified which will be invoked at the end of the pipeline
batch. The user should assemble the candidate items from the file system, be they files or directories
typically using Get-ChildItem, or can be any other function that delivers file systems
items via the PowerShell pipeline. For each item in the pipeline, Invoke-ForeachFsItem will
invoke the script-block/function specified. Invoke-ForeachFsItem will deliver what ever is
returned from the script-block/function, so the result of Invoke-ForeachFsItem can be piped
to another command.

## EXAMPLES

### Example 1

Invoke a script-block to handle .txt file objects from the same directory (without -Recurse):
(NB: first parameter is of type FileInfo, -File specified on Get-ChildItem and
Invoke-ForeachFsItem. If Get-ChildItem is missing -File, then any Directory objects passed in
are filtered out by Invoke-ForeachFsItem. If -File is missing from Invoke-ForeachFsItem, then
the script-block's first parameter, must be a FileSystemInfo to handle both types)

```powershell
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
```

### Example 2

Invoke a function with additional parameters to handle directory objects from multiple directories
(with -Recurse):

```powershell
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
```

### Example 3

Invoke a script-block to handle empty .txt file objects from the same directory (without -Recurse):

```powershell
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
```

### Example 4

Invoke a script-block only for directories whose name starts with "A" from the same
directory (without -Recurse); Note the use of the LOOPZ function "Select-FsItem" in the
directory include filter:

```powershell
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
```

## PARAMETERS

### -Block

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
client's block implementation.

In addition to these fixed positional parameters, if the invoked script-block is defined
with additional parameters, then these will also be passed in. In order to achieve this,
the client has to provide excess parameters in BlockParam and these parameters must be
defined as the same type and in the same order as the additional parameters in the
script-block.

```yaml

Type: ScriptBlock
Parameter Sets: InvokeScriptBlock
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BlockParams

Optional array containing the excess parameters to pass into the script block.

```yaml

Type: Object
Parameter Sets: InvokeScriptBlock
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Condition

This is a predicate script-block, which is invoked with either a DirectoryInfo or
FileInfo object presented as a result of invoking Get-ChildItem. It provides a filtering
mechanism that is defined by the user to define which file system objects are selected
for function/script-block invocation.

```yaml

Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Directory

Switch to indicate that the invoked function/script-block (invokee) is to handle Directory
objects.

```yaml

Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -File

Switch to indicate that the invoked function/script-block (invokee) is to handle FileInfo
objects. Is mutually exclusive with the Directory switch. If neither switch is specified, then
the invokee must be able to handle both therefore the Underscore parameter it defines must
be declared as FileSystemInfo.

```yaml

Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Functee

String defining the function to be invoked. Works in a similar way to the Block parameter
for script-blocks. The Function's base signature is as follows:

* "Underscore": (See pipelineItem described in Block parameter)
* "Index": (See index described in Block parameter)
* "PassThru": (See PathThru described in Block parameter)
* "Trigger": (See trigger described in Block parameter)

```yaml

Type: String
Parameter Sets: InvokeFunction
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FuncteeParams

Optional hash-table containing the named parameters which are splatted into the Functee
function invoke. As it's a hash table, order is not significant.

```yaml

Type: Hashtable
Parameter Sets: InvokeFunction
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Header

  A script-block that is invoked at the start of the pipeline batch. The script-block is
invoked with the following positional parameters:

* PassThru: (see PassThru previously described)

  The Header can be customised with the following PassThru entries:

* 'LOOPZ.KRAYOLA-THEME': Krayola Theme generally in use
* 'LOOPZ.HEADER-BLOCK.MESSAGE': message displayed as part of the header
* 'LOOPZ.HEADER-BLOCK.CRUMB-SIGNAL': Signal Emoji displayed in header
* 'LOOPZ.HEADER.PROPERTIES': An array of Key/Value pairs of items to be displayed
* 'LOOPZ.HEADER-BLOCK.LINE': A string denoting the line to be displayed. (There are
predefined lines available to use in $LoopzUI, or a custom one can be used instead)

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru

A hash table containing miscellaneous information gathered internally throughout the
pipeline batch. This can be of use to the user, because it is the way the user can perform
bi-directional communication between the invoked custom script block and client side logic.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Summary

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

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -pipelineItem

This is the pipeline object, so should not be specified explicitly and can represent
a file object (System.IO.FileInfo) or a directory object (System.IO.DirectoryInfo).

```yaml
Type: FileSystemInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.IO.FileSystemInfo

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
