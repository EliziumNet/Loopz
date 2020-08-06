---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Invoke-TraverseDirectory

## SYNOPSIS

Traverses a directory tree invoking a custom defined script-block or named function
as it goes.

## SYNTAX

### InvokeScriptBlock (Default)

```powershell
Invoke-TraverseDirectory -Path <String> [-Condition <ScriptBlock>] [-PassThru <Hashtable>]
 [-Block <ScriptBlock>] [-BlockParams <Object>] [-Summary <ScriptBlock>] [-Hoist] [<CommonParameters>]
```

### InvokeFunction

```powershell
Invoke-TraverseDirectory -Path <String> [-Condition <ScriptBlock>] [-PassThru <Hashtable>] -Functee <String>
 [-FuncteeParams <Hashtable>] [-Summary <ScriptBlock>] [-Hoist] [<CommonParameters>]
```

## DESCRIPTION

Navigates a directory tree applying custom functionality for each directory. A Condition
script-block can be applied for conditional functionality. 2 parameters set are defined, one
for invoking a named function (InvokeFunction) and the other (InvokeScriptBlock, the default)
for invoking a script-block. An optional Summary script block can be specified which will be
invoked at the end of the traversal batch.

## EXAMPLES

### Example 1

Invoke a script-block for every directory in the source tree.

```powershell
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
```

### Example 2

Invoke a named function with extra parameters for every directory in the source tree.

```powershell
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
```

### Example 3

Invoke a named function, including only directories beginning with A (filter A*)

```powershell
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
```

Note the possible issue with this example is that any descendants named A... which are located
under an ancestor which is not named A..., will not be processed by the provided function

### Example 4

Mirror a directory tree, including only directories beginning with A (filter A*) regardless of
the matching of intermediate ancestors (specifying -Hoist flag resolves the possible
issue in the previous example)

```powershell
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
```

Note that the directory filter must include a wild-card, otherwise it will be ignored. So a
directory include of @('A'), is problematic, because A is not a valid directory filter so its
ignored and there are no remaining filters that are able to include any directory, so no
directory passes the filter.

## PARAMETERS

### -Block

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

In addition to these fixed positional parameters, if the invoked script-block is defined
with additional parameters, then these will also be passed in. In order to achieve this,
the client has to provide excess parameters in BlockParams and these parameters must be
defined as the same type and in the same order as the additional parameters in the
script-block.

```yaml
Type: ScriptBlock
Parameter Sets: InvokeScriptBlock
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BlockParams

Optional array containing the excess parameters to pass into the script-block.

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

This is a predicate scriptblock, which is invoked with a DirectoryInfo object presented
as a result of invoking Get-ChildItem. It provides a filtering mechanism that is defined
by the user to define which directories are selected for function/scriptblock invocation.

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

### -Functee

String defining the function to be invoked. Works in a similar way to the Block parameter
for script-blocks. The Function's base signature is as follows:

* "Underscore": (See underscore described above)
* "Index": (See index described above)
* "PassThru": (See PathThru described above)
* "Trigger": (See trigger described above)

The destination DirectoryInfo object can be accessed via the PassThru denoted by
the 'LOOPZ.MIRROR.DESTINATION' entry.

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

### -Hoist

Switch parameter. Without Hoist being specified, the Condition can prove to be too restrictive
on matching against directories. If a directory does not match the Condition then none of its
descendants will be considered to be traversed. When Hoist is specified then a descendant directory
that does match the Condition will be traversed even though any of its ancestors may not match the
same Condition.

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

### -PassThru

A hash table containing miscellaneous information gathered internally throughout the
traversal batch. This can be of use to the user, because it is the way the user can perform
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

### -Path

The source Path denoting the root of the directory tree to be traversed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Summary

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
