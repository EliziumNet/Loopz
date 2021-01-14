---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Invoke-MirrorDirectoryTree

## SYNOPSIS

Mirrors a directory tree to a new location, invoking a custom defined scriptblock
or function as it goes.

## SYNTAX

### InvokeScriptBlock (Default)

```powershell
Invoke-MirrorDirectoryTree -Path <String> -DestinationPath <String> [-DirectoryIncludes <String[]>]
 [-DirectoryExcludes <String[]>] [-FileIncludes <String[]>] [-FileExcludes <String[]>] [-Exchange <Hashtable>]
 [-Block <ScriptBlock>] [-BlockParams <Object>] [-CreateDirs] [-CopyFiles] [-Hoist] [-Header <ScriptBlock>]
 [-Summary <ScriptBlock>] [-SessionHeader <ScriptBlock>] [-SessionSummary <ScriptBlock>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### InvokeFunction

```powershell
Invoke-MirrorDirectoryTree -Path <String> -DestinationPath <String> [-DirectoryIncludes <String[]>]
 [-DirectoryExcludes <String[]>] [-FileIncludes <String[]>] [-FileExcludes <String[]>] [-Exchange <Hashtable>]
 -Functee <String> [-FuncteeParams <Hashtable>] [-CreateDirs] [-CopyFiles] [-Hoist] [-Header <ScriptBlock>]
 [-Summary <ScriptBlock>] [-SessionHeader <ScriptBlock>] [-SessionSummary <ScriptBlock>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

Copies a source directory tree to a new location applying custom functionality for each
directory. 2 parameters set are defined, one for invoking a named function (InvokeFunction) and
the other (InvokeScriptBlock, the default) for invoking a scriptblock. An optional
Summary script block can be specified which will be invoked at the end of the mirroring
batch.Copies a source directory tree to a new location applying custom functionality for each
directory. 2 parameters set are defined, one for invoking a named function (InvokeFunction) and
the other (InvokeScriptBlock, the default) for invoking a scriptblock. An optional
Summary script block can be specified which will be invoked at the end of the mirroring
batch.

## EXAMPLES

### Example 1

```powershell
  function Test-Mirror {
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
    'Format' = '---- {0} ----';
  }
  Invoke-MirrorDirectoryTree -Path './Tests/Data/fefsi' `
    -DestinationPath './Tests/Data/mirror' -CreateDirs `
    -Functee 'Test-Mirror' -FuncteeParams $parameters;
```

Invoke a named function for every directory in the source tree and mirror every
directory in the destination tree. The invoked function has an extra parameter in it's
signature, so the extra parameters must be passed in via FuncteeParams (the standard
signature being the first 4 parameters shown.)

### Example 2

```powershell
  Invoke-MirrorDirectoryTree -Path './Tests/Data/fefsi' `
    -DestinationPath './Tests/Data/mirror' -CreateDirs -CopyFiles -block {
      param(
        [System.IO.DirectoryInfo]$Underscore,
        [int]$Index,
        [hashtable]$Exchange,
        [boolean]$Trigger
      )
      ...
    };
```

Invoke a script-block for every directory in the source tree and copy all files

### Example 3

```powershell
Invoke-MirrorDirectoryTree -Path './Tests/Data/fefsi' -DestinationPath './Tests/Data/mirror' `
    -DirectoryIncludes @('A*')
```

Mirror a directory tree, including only directories beginning with A (filter A*)

Note the possible issue with this example is that any descendants named A... which are located
under an ancestor which is not named A..., will not be mirrored;

eg './Tests/Data/fefsi/Audio/mp3/A/Amorphous Androgynous', even though "Audio", "A" and
"Amorphous Androgynous" clearly match the A* filter, they will not be mirrored because
the "mp3" directory, would be filtered out.
See the following example for a resolution.

### Example 4

```powershell
  Invoke-MirrorDirectoryTree -Path './Tests/Data/fefsi' -DestinationPath './Tests/Data/mirror' `
    -DirectoryIncludes @('A*') -CreateDirs -CopyFiles -Hoist
```

Mirror a directory tree, including only directories beginning with A (filter A*) regardless of
the matching of intermediate ancestors (specifying -Hoist flag resolves the possible
issue in the previous example)

Note that the directory filter must include a wild-card, otherwise it will be ignored. So a
directory include of @('A'), is problematic, because A is not a valid directory filter so its
ignored and there are no remaining filters that are able to include any directory, so no
directory passes the filter.

### Example 5

```powershell
  Invoke-MirrorDirectoryTree -Path './Tests/Data/fefsi' -DestinationPath './Tests/Data/mirror' `
    -FileIncludes @('flac', '*.wav') -CreateDirs -CopyFiles -Hoist
```

Mirror a directory tree, including files with either .flac or .wav suffix

Note that for files, a filter may or may not contain a wild-card. If the wild-card is missing
then it is automatically treated as a file suffix; so 'flac' means '*.flac'.

### Example 6

```powershell
  [scriptblock]$summary = {
    param(
      [int]$_count,
      [int]$_skipped,
      [boolean]$_triggered,
      [hashtable]$_exchange
    )
    ...
  }

  Invoke-MirrorDirectoryTree -Path './Tests/Data/fefsi' -DestinationPath './Tests/Data/mirror' `
    -FileIncludes @('flac') -CopyFiles -Hoist -Summary $summary
```

Mirror a directory tree copying over just flac files

Note that -CreateDirs is missing which means directories will not be mirrored by default. They
are only mirrored as part of the process of copying over flac files, so in the end the
resultant mirror directory tree will contain directories that include flac files.

### Example 7

```powershell
  Invoke-MirrorDirectoryTree -Path './Tests/Data/fefsi' -DestinationPath './Tests/Data/mirror' `
  -FileIncludes @('flac') -CopyFiles -Hoist `
  -Header $LoopzHelpers.DefaultHeaderBlock -Summary $DefaultHeaderBlock.SimpleSummaryBlock `
  -SessionHeader $LoopzHelpers.DefaultHeaderBlock -SessionSummary $DefaultHeaderBlock.SimpleSummaryBlock;
```

Same as EXAMPLE 6, but using predefined Header and Summary script-blocks for Session header/summary and per directory header/summary.

## PARAMETERS

### -Block

The script block to be invoked. The script block is invoked for each directory in the
source directory tree that satisfy the specified Directory Include/Exclude filters with
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

The destination DirectoryInfo object can be accessed via the Exchange denoted by
the 'LOOPZ.MIRROR.DESTINATION' entry.

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

Optional array containing the excess parameters to pass into the script-block/function.

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

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CopyFiles

{{ Fill CopyFiles Description }}

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

### -CreateDirs

switch parameter indicates that directories should be created in the destination tree. If
not set, then Invoke-MirrorDirectoryTree turns into a function that traverses the source
directory invoking the function/script-block for matching directories.

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

### -DestinationPath

The destination Path denoting the root of the directory tree where the source tree
will be mirrored to.

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

### -DirectoryExcludes

An array containing a list of filters, each must contain a wild-card ('*'). If a
particular filter does not contain a wild-card, then it will be ignored. If the directory
matches any of the filters in the list, it will be mirrored in the destination tree.
If DirectoryIncludes contains just a single element which is the empty string, this means
that nothing is included (rather than everything being included).

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DirectoryIncludes

An array containing a list of filters, each may contain a wild-card ('*'). If a
particular filter does not contain a wild-card, then it will be treated as a file suffix.
If the file in the source tree matches any of the filters in the list, it will be mirrored
in the destination tree. If FileIncludes contains just a single element which is the empty
string, this means that nothing is included (rather than everything being included).

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Exchange

A hash table containing miscellaneous information gathered internally
throughout the pipeline batch. This can be of use to the user, because it is the way
the user can perform bi-directional communication between the invoked custom script block
and client side logic.

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

### -FileExcludes

An array containing a list of filters, each may contain a wild-card ('*'). If a
particular filter does not contain a wild-card, then it will be treated as a file suffix.
If the file in the source tree matches any of the filters in the list, it will NOT be
mirrored in the destination tree. Any match in the FileExcludes overrides a match in
FileIncludes, so a file that is matched in Include, can be excluded by the Exclude.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FileIncludes

An array containing a list of filters, each may contain a wild-card ('*'). If a
particular filter does not contain a wild-card, then it will be treated as a file suffix.
If the file in the source tree matches any of the filters in the list, it will be mirrored
in the destination tree. If FileIncludes contains just a single element which is the empty
string, this means that nothing is included (rather than everything being included).

```yaml
Type: String[]
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
* "Exchange": (See PathThru described above)
* "Trigger": (See trigger described above)

The destination DirectoryInfo object can be accessed via the Exchange denoted by
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

### -Header

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

### -Hoist

switch parameter. Without Hoist being specified, the filters can prove to be too restrictive
on matching against directories. If a directory does not match the filters then none of its
descendants will be considered to be mirrored in the destination tree. When Hoist is specified
then a descendant directory that does match the filters will be mirrored even though any of
its ancestors may not match the filters.

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

### -Path

The source Path denoting the root of the directory tree to be mirrored.

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

### -SessionHeader

A script-block that is invoked at the start of the mirroring batch. The script-block has
the same signature as the Header script block.

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

### -SessionSummary

A script-block that is invoked at the end of the mirroring batch. The script-block has
the same signature as the Summary script block.

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

### -Summary

A script-block that is invoked foreach directory that also contains child directories,
after all its descendants have been processed and serves as a sub-total for the current
directory. The script-block is invoked with the following positional parameters:

* count: the number of items processed in the mirroring batch.
* skipped: the number of items skipped in the mirroring batch. An item is skipped if
it fails the defined condition or is not of the correct type (eg if its a directory
but we have specified the -File flag).
* trigger: Flag set by the script-block/function, but should typically be used to
indicate whether any of the items processed were actively updated/written in this batch.
This helps in written idempotent operations that can be re-run without adverse
consequences.
* Exchange: (see Exchange previously described)

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

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

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
