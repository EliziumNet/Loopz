
# :nazar_amulet: Elizium.Loopz

[![A B](https://img.shields.io/badge/branching-commonflow-informational?style=flat)](https://commonflow.org)
[![A B](https://img.shields.io/badge/merge-rebase-informational?style=flat)](https://git-scm.com/book/en/v2/Git-Branching-Rebasing)
[![A B](https://img.shields.io/github/license/eliziumnet/loopz)](https://github.com/eliziumnet/Loopz/blob/master/LICENSE)
[![A B](https://img.shields.io/powershellgallery/p/Elizium.Loopz)](https://www.powershellgallery.com/packages/Elizium.Loopz)

PowerShell iteration utilities with additional goodies like [Parameter Set Tools](resources/docs/parameter-set-tools.md).

## Introduction

When writing a suite of utilities/functions it can be difficult to develop them so that they behave in a consistent manner. Along with another dependent Powershell module [Elizium.Krayola](https://github.com/plastikfan/Krayola), Elizium.Loopz can be used to build PowerShell commands that are both more visually appealing and consistent particularly with regards to rendering repetitive content as a result of some kind of iteration process.

The module can be installed using the standard **install-module** command:

> PS> install-module -Name Elizium.Loopz -Scope AllUsers

### Dependencies

Requires:

* [Elizium.Krayola](https://github.com/plastikfan/Krayola)
* [Elizium.Klassy](https://github.com/plastikfan/Klassy)

which will be installed automatically if not already present.

*For best results on windows, it is recommended that the user installs and uses Microsoft's Windows Terminal, since it has better support for emojis when compared to the ageing Console app. Users can also try [TerminalBuddy](https://github.com/plastikfan/TerminalBuddy), another PowerShell module, to assist in setting up custom colour themes.*

The :scroll: ChangeLog for this project is available [here](Elizium.Loopz/CHANGELOG.md).

## The Main Commands (for end users)

| COMMAND-NAME                                              | DESCRIPTION
|-----------------------------------------------------------|------------
| [Format-Escape](Elizium.Loopz/docs/Format-Escape.md)      | Escape Regex param
| [Show-Signals](Elizium.Loopz/docs/Show-Signals.md)        | Show signals with overrides
| [Select-Patterns](Elizium.Loopz/docs/Select-Patterns.md)  | Find text inside files

## Iteration functions (for end developers)

The following table shows the list of public commands exported from the Loopz module:

| COMMAND-NAME                                                                     | DESCRIPTION
|----------------------------------------------------------------------------------|------------
| [Invoke-ForeachFsItem](Elizium.Loopz/docs/Invoke-ForeachFsItem.md)               | Invoke a function foreach file system object
| [Invoke-MirrorDirectoryTree](Elizium.Loopz/docs/Invoke-MirrorDirectoryTree.md)   | Copy a directory tree invoking a function
| [Invoke-TraverseDirectory](Elizium.Loopz/docs/Invoke-TraverseDirectory.md)       | Navigate a directory tree invoking a function
| [Show-Header](Elizium.Loopz/docs/Show-Header.md)                                 | Show iteration Header
| [Show-Summary](Elizium.Loopz/docs/Show-Summary.md)                               | Show iteration Summary
| [Write-HostFeItemDecorator](Elizium.Loopz/docs/Write-HostFeItemDecorator.md)     | Write output foreach file system object

## Parameter Set Tools

This module includes a collection of commands/classes that comprise the parameter set tools. When building new commands that use the parameter set framework, it can be difficult to build them so they don't violate the established rules, particular when the command is complex and has a large number of parameters and parameter sets. These parameter sets tools aims to fill a void and give developers some additional tools that can be used to resolved common parameter issues. The following table shows the commands in this tool set:

| COMMAND-NAME                                                              | DESCRIPTION
|---------------------------------------------------------------------------|------------
| [Show-InvokeReport](Elizium.Loopz/docs/Show-InvokeReport.md)              | [:heavy_check_mark:](resources/docs/parameter-set-tools.md/#using.show-invoke-report) Show command invoke report
| [Show-ParameterSetInfo](Elizium.Loopz/docs/Show-ParameterSetInfo.md)      | [:heavy_check_mark:](resources/docs/parameter-set-tools.md/#using.show-parameter-set-info) Show parameter set info
| [Show-ParameterSetReport](Elizium.Loopz/docs/Show-ParameterSetReport.md)  | [:heavy_check_mark:](resources/docs/parameter-set-tools.md/#using.show-parameter-set-report) Show parameter set violations

| CLASS-NAME                                                                     | DESCRIPTION
|--------------------------------------------------------------------------------|------------
| [DryRunner](resources/docs/parameter-set-tools.md/#dry-runner.class)           | Dry run a command
| [RuleController](resources/docs/parameter-set-tools.md/#rule-controller.class) | Parameter set rules
| [Syntax](resources/docs/parameter-set-tools.md/#syntax.class)                  | Command syntax

See [Parameter Set Tools](resources/docs/parameter-set-tools.md) [:pray:](#thanks)

## Supporting Utilities (for developers)

| COMMAND-NAME                                                                     | DESCRIPTION
|----------------------------------------------------------------------------------|------------
| [Edit-RemoveSingleSubString](Elizium.Loopz/docs/Edit-RemoveSingleSubString.md)   | Remove single substring
| [Format-StructuredLine](Elizium.Loopz/docs/Format-StructuredLine.md)             | Create Krayon line
| [Get-FormattedSignal](Elizium.Loopz/docs/Get-FormattedSignal.md)                 | Get formatted signal
| [Get-InverseSubstring](Elizium.Loopz/docs/Get-InverseSubString.md)               | Get inverse substring (the opposite of standard substring string method)
| [Get-IsLocked](Elizium.Loopz/docs/Get-IsLocked.md)                               | Get locked state of a command
| [Get-PaddedLabel](Elizium.Loopz/docs/Get-PaddedLabel.md)                         | Get space padded string
| [Get-PlatformName](Elizium.Loopz/docs/Get-PlatformName.md)                       | Get platform name (OS type)
| [Get-PsObjectField](Elizium.Loopz/docs/Get-PsObjectField.md)                     | Get field from PSCustomObject
| [Get-Signals](Elizium.Loopz/docs/Get-Signals.md)                                 | Get signals
| [Initialize-ShellOperant](Elizium.Loopz/docs/Initialize-ShellOperant.md)         | Init shell operation
| [Invoke-ByPlatform](Elizium.Loopz/docs/Invoke-ByPlatform.md)                     | Invoke OS specific fn
| [New-RegularExpression](Elizium.Loopz/docs/New-RegularExpression.md)             | Regex factory fn
| [Resolve-ByPlatform](Elizium.Loopz/docs/Resolve-ByPlatform.md)                   | Resolve item by OS type
| [Resolve-PatternOccurrence](Elizium.Loopz/docs/Resolve-PatternOccurrence.md)     | Regex param helper
| [Select-FsItem](Elizium.Loopz/docs/Select-FsItem.md)                             | A predicate fn used for filtering
| [Select-SignalContainer](Elizium.Loopz/docs/Select-SignalContainer.md)           | Select signal into a container
| [Split-Match](Elizium.Loopz/docs/Split-Match.md)                                 | Split regex match
| [Test-IsFileSystemSafe](Elizium.Loopz/docs/Test-IsFileSystemSafe.md)             | Test if string is FS safe
| [Update-GroupRefs](Elizium.Loopz/docs/Update-GroupRefs.md)                       | Update named group refs

| CLASS-NAME                                                                       | DESCRIPTION
|----------------------------------------------------------------------------------|------------
| [bootstrap](resources/docs/bootstrap.md)                                         | Command init helper

## General Concepts

### :sparkles: Exchange hashtable object<a name = "general.exchange"></a>

A common theme present in the main commands is the use of a Hash-table object called $Exchange.
The scenarios in which the Exchange are as follows:

* Allows calling code to send additional parameters to a Loopz command outside of its regular signature.
* Allows invoked code to return information back to calling code.

Let's elaborate the above points...

:star: First point: [Invoke-ForeachFsItem](Elizium.Loopz/docs/Invoke-ForeachFsItem.md) requires calling code to either specify a script-block or a function (collectively called the invokee). The invokee must have to conform to a signature accepting the following four common arguments:

* Underscore: the current pipeline item
* Index: an allocated numeric value indicating the sequence number in the pipeline
* Exchange: the hash-table containing additional named items, and other information gathered throughout processing
* Trigger: client controlled boolean flag that should be used to denote if update/write action was taken for a particular item in pipeline. (Relevant for state changing operations only).

When additional parameters need to be sent to the invokee, there is already a mechanism for
passing these (either with *BlockParams* or *FuncteeParams*), this approach is generally preferred.

However, there is another commonly occurring pattern which would require the use of Exchange. This pattern is the adapter pattern. If there is an existing function that needs to be integrated to be used with Invoke-ForeachFsItem, but does not match the required signature, an intermediate adapter can be implemented. Calling code can put in any additional parameters (required by the non-conformant function) into the Exchange, which are picked up by the adapter and forwarded on as required. Using the adapter this way is much preferred than using additional parameters (*BlockParams* or *FuncteeParams*), because there could be confusion as to whom these parameters are required for, the adapter or the target function/script-block. Using parameters in Exchange can be made to be much clearer because very meaningful names can be used as hash-table keys; Eg, for internal Loopz command interaction (Invoke-MirrorDirectoryTree internally invokes Invoke-TraverseDirectory and uses keys like 'LOOPZ.MIRROR.INVOKEE', which means that, that value is only of importance to Invoke-TraverseDirectory, so any other function that sees this should ignore it).

:pushpin: Note, users should use a similar namespaced style keys, for their own use, to avoid any chance of name clashes and users should not use any keys beginning with 'LOOPZ.' as these are reserved for internal Loopz operation.

:warning: Warning don't nest Invoke-ForeachFsItem calls, using the same Exchange instance. That is to say do not use a function/script-block already known to call 'Invoke-ForeachFsItem' with its own Invoke-ForeachFsItem request using the same Exchange instance. If you need to achieve this, then a new and separate Exchange instance should be created. However, recursive functions are fine, as long as it makes sense that different iterations use the same Exchange.

:star: Second point:

The *Invoke-MirrorDirectoryTree* command illustrates this well. Invoke-MirrorDirectoryTree needs to be able to present the invokee with multiple (actually, just 2) DirectoryInfo objects for each source directory encountered, one for the source directory and another for the mirrored directory. Since *Invoke-ForeachFsItem* is the command that under-pins this functionality, Invoke-MirrorDirectoryTree needs to conform to it's requirements, one of which is that a single DirectoryInfo is presented to the invokee. To get around this, it populates a new entry inside the Exchange: 'LOOPZ.MIRROR.ROOT-DESTINATION', which the invokee can now access. This same technique can be used by calling code.

### :sparkles: The Trigger

If the script-block/function (invokee) to be invoked by [Invoke-ForeachFsItem](Elizium.Loopz/docs/Invoke-ForeachFsItem.md), [Invoke-MirrorDirectoryTree](Elizium.Loopz/docs/Invoke-MirrorDirectoryTree.md) or [Invoke-TraverseDirectory](Elizium.Loopz/docs/Invoke-TraverseDirectory.md) (the compound function) is a state changing operation (such as renaming a file or a directory), it may be useful to know if the invokee actually performed the change or not, especially when a particular command is re-run. It may be that a rerun of a command results in no actual state change and it may be useful to know this after the batch has completed. (*Please don't confuse this with WhatIf behaviour. An example of not performing an action being alluded to here, is an attempt to rename a file where the new name is the same as the existing one; this could happen in a re-run*) In this scenario, the invokee must set the Trigger accordingly. If the write action was performed, then Trigger should be set (it's just a boolean value) on the PSCustomObject that it should return. The Trigger that the invokee receives as one of the fixed parameters passed to it by the compound function, reflects if any of the previous items in the pipeline set the Trigger.

If the user needs to write functionality that needs to be able to support re-runs, where the re-run should not
produce overly verbose output, because no real action was performed for some items in the pipeline, then use
of the 'LOOPZ.WH-FOREACH-DECORATOR.IF-TRIGGERED' setting in the Exchange should be made. It should be set
to true (although in reality, just the existence of the IF-TRIGGERED key, sets this option):

```powershell
  $Exchange['LOOPZ.WH-FOREACH-DECORATOR.IF-TRIGGERED'] = $true
```

:pushpin: *This indicates that for a particular item in the pipeline, no output should be written
for that item, if the invokee has not set the Trigger to true, to indicate that action has been performed*

If a Summary script-block is supplied to the compound function, then it will see if any of the pipeline items set the Trigger.

### :sparkles: Write-HostFeItemDecorator

When using a custom function/script-block (invokee) with one of the compound functions it is considered good form not to write to the host within the command being written (PSScriptAnalyzer warning *PSAvoidUsingWriteHost* comes to mind). This is so that the command can be composed into a pipeline without generating convoluted output (plus other reasons). However, it isn't against the law to write output and command line utilities are made much the richer and user friendly when they receive feedback for the operations being performed.

This is where Write-HostFeItemDecorator comes in. It allows the development of commands that don't write to the host, leaving this to be taken over by Write-HostFeItemDecorator.

The following shows an example of using a named function with [*Invoke-ForeachFsItem*](Elizium.Loopz/docs/Invoke-ForeachFsItem.md)

```powershell
  function Resize-Image {
    param(
      [System.IO.FileInfo]$Underscore,
      [int]$Index,
      [System.Collections.Hashtable]$Exchange,
      [boolean]$Trigger
    )

    [PSCustomObject]@{ Product = $FileInfo; }
  }

  [string]$directoryPath = './Data/fefsi';
  Get-ChildItem $directoryPath -Recurse -File -Filter "*.jpg" | Invoke-ForeachFsItem -Functee 'Resize-Image'
```

The function does not write any output to the host. However, it might be desirable to do so. Rather than include that logic into *Resize-Image*, it can be modified to populate the returned PSCustomObject that it already creates with additional properties (although this part is optional) and then making use of *Write-HostFeItemDecorator*.

This can be achieved by defining our end function in the Exchange under key 'LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME' and selecting *Write-HostFeItemDecorator* to be the Functee on *Invoke-ForeachFsItem*.

```powershell
  function Resize-Image {
    param(
      [System.IO.DirectoryInfo]$Underscore,
      [int]$Index,
      [System.Collections.Hashtable]$Exchange,
      [boolean]$Trigger,
    )
    ...
    $pairs = @(
      @('By', $percentage), @('Height', $height), @('Width', $width)
    );
    @{ Product = $Underscore; Pairs = $pairs; }
  }

  [Systems.Collection.Hashtable]$Exchange = @{
    'LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME' = 'Resize-Image';
  }

  [string]$directoryPath = './Data/fefsi';
  Get-ChildItem $directoryPath -Recurse -File -Filter "*.jpg" | Invoke-ForeachFsItem -Exchange $Exchange
    -Functee 'Write-HostFeItemDecorator'
```

This sets up a new calling chain, where *Invoke-ForeachFsItem* invokes the *Write-HostFeItemDecorator* function and it in turn invokes the function defined in 'LOOPZ.WH-FOREACH-DECORATOR.FUNCTION-NAME' in this case being *Resize-Image*. This technique can also be used with [*Invoke-MirrorDirectoryTree*](Elizium.Loopz/docs/Invoke-MirrorDirectoryTree.md) and [*Invoke-TraverseDirectory*](Elizium.Loopz/docs/Invoke-TraverseDirectory.md).

## Helpers

Some global definitions have been exported as global variables as an aid to using the functions in this module.

### :dart: Predefined Header script-block

```powershell
$LoopzHelpers.HeaderBlock
```

The *HeaderBlock* can be used on any compound function that that has a *Header* parameter. The Header can be customised with the following Exchange entries:

* 'LOOPZ.KRAYOLA-THEME': Krayola Theme generally in use
* 'LOOPZ.HEADER-BLOCK.MESSAGE': message displayed as part of the header
* 'LOOPZ.HEADER-BLOCK.CRUMB-SIGNAL': Lead text displayed in header, default: '[+] '
* 'LOOPZ.HEADER.PROPERTIES': An array of Key/Value pairs of items to be displayed
* 'LOOPZ.HEADER-BLOCK.LINE': A string denoting the line to be displayed. (There are
predefined lines available to use in $LoopzUI, or a custom one can be used instead)

The *HeaderBlock* will generated either a single line or multi-line Header depending on whether custom properties have been defined. When properties have been defined under key *LOOPZ.HEADER.PROPERTIES* then a multi-line Header is generated, eg:

```powershell
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The sound the wind makes in the pines // ["A" => "One", "B" => "Two", "C" => "Three"]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

If no properties have been defined then a single line Header will be generated, eg:

```powershell
[+] ============================================================= [ What lies in the darkness ] ===
```

What is displayed in the Header is driven by what is defined in the Krayola theme or items in the Exchange, so in this example

* 'CRUMB-A' (*Exchange*): 'LOOPZ.HEADER-BLOCK.CRUMB-SIGNAL'
* 'What lies in the darkness' (*Exchange*): 'LOOPZ.HEADER-BLOCK.MESSAGE'
* '[': (*Theme*): 'OPEN'
* ']': (*Theme*): 'CLOSE'

The user can specify the pre-defined Header script block or can defined their own. The signature of the Header script-block is as follows:

```powershell
  param(
    [System.Collections.Hashtable]$Exchange
  )
```

### :dart: Predefined Summary script-block

```powershell
$LoopzHelpers.SummaryBlock
```

The *SummaryBlock* can be used on any compound function that that has a *Summary* parameter. It can be customised by specifying a line string under key 'LOOPZ.SUMMARY-BLOCK.LINE'. Any string can be defined or one of the pre-defined lines (see below) can be specified.

A custom summary message may also be defined under key 'LOOPZ.SUMMARY-BLOCK.MESSAGE'; this is optional and if not specified, the word 'Summary' will be used.

A Krayola theme may be specified and as one may already have been defined for *Write-HostFeFsItem* under key 'LOOPZ.KRAYOLA-THEME', this will also be used by the Summary block.

The user can specify the pre-defined Summary script block or can defined their own. The signature of the Summary script-block is as follows:

```powershell
  param(
    [int]$Count,
    [int]$Skipped,
    [boolean]$Triggered,
    [System.Collections.Hashtable]$Exchange
  )
```

### :dart: Line definitions

To be set under key 'LOOPZ.HEADER-BLOCK.LINE' and/or 'LOOPZ.SUMMARY-BLOCK.LINE' of the Exchange as previously discussed.

```powershell
$LoopzUI.UnderscoreLine
$LoopzUI.EqualsLine
$LoopzUI.DashLine
$LoopzUI.DotsLine
$LoopzUI.LightDashLine
$LoopzUI.LightDotsLine
$LoopzUI.TildeLine
$LoopzUI.SmallUnderscoreLine
$LoopzUI.SmallEqualsLine
$LoopzUI.SmallLightDashLine
$LoopzUI.SmallDashLine
$LoopzUI.SmallDotsLine
$LoopzUI.SmallLightDotsLine
$LoopzUI.SmallTildeLine
```

### :dart: Predefined Write-HostFeFsItem decorator script-block

As the write host decorator is functionally the same used in different contents, it made sense not to force the user to keep re-defining this. Therefore, a predefined decorator is available for 3rd party use. Just pass this value as the *Block* parameter on the compound function being used.

```powershell
$LoopzHelpers.WhItemDecoratorBlock
```

### Acknowledgements<a name="thanks"></a>

:pray: I'd like to thank @KirkMunro and @JamesWTruher who wrote the original *Get-CommandDetails* function which formed the early roots of the design of *Show-ParameterSetInfo*. See [this](https://github.com/PowerShell/PowerShell/issues/8692) PowerShell issue for proposals on amending the syntax displayed from *Get-Command*.
