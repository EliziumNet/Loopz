---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Build-PoShLog

## SYNOPSIS

Create a change log for the current repo

## SYNTAX

### CreateLog (Default)

```powershell
Build-PoShLog [[-Name] <String>] [[-From] <String>] [[-Until] <String>] [-PassThru] [-Emoji]
 [<CommonParameters>]
```

### CreateLogUnreleased

```powershell
Build-PoShLog [[-Name] <String>] [-Unreleased] [-Emoji] [<CommonParameters>]
```

### EjectConfig

```powershell
Build-PoShLog [[-Name] <String>] [-Eject] [-Emoji] [<CommonParameters>]
```

## DESCRIPTION

  Before running, the user needs to eject a config (json), then modify it for the repo's
needs. There are a few pre-defined configs from which to choose, that customises the
appearance of the generated change log. Most of the options are cosmetic with a few
that define the structure. Also, the user can keep the default regular expressions (which
conform to keep-a-changelog). One of the properties of a good change log are that
commits should be grouped together based upon change type/scope/commit-type/breaking
  changes. This change log implementation performs groupings based on all of these
categories. The quality of the generated changelog depends heavily on the quality of
the commit messages in the repo.

  However, one of the reasons for this implementation is in recognition of the fact that
a repo may not have commits with messages that are in accordance with keep-a-changelog.
If a repo's commits can be easily represented by alternative regular expression(s),
then the user can update the options file with these additional patterns. More than 1
pattern can be specified, but the more restrictive patterns should be specified first.

  Also, a repo can have many un-squashed commits, which is generally not advised, but
again, in recognition of this state of a repo, there is a squash facility built into
the change log. That is not to say that the commits in the repo are squashed, rather
they are squashed just in the change log by a provided regular expression. In the options
config, there is a "SquashBy" setting under "Selection" and the default specifies an
"issue" number so that commits with the same issue number are grouped into a single entry
in the change log. By default, these squashed entries are marked out so they are easily
identified by the user and can be changed accordingly.

  The user can if they want, just use the generated output as is. However, this is not
the intention behind this command. Generating output, is just the first step in creating
a useful change log meaning extra curation is required of the user to ensure the items
marked as Squashed for example, are cleaned up (the end user is probably not interested
in whether an item is squashed or not).

  An alternative way to change the appearance of the change log is the use of emojis
which can really help in identifying items generated in the log and the nature of
that change. The user is welcome to change the emojis used by updating the options
file.

  The user also needs to decide how the grouping of commits is to be performed. This is
controlled by the "GroupBy" setting. The default is "scope/type/change/break". This
GroupBy can have any combination of these 4 values and the path doesn't even have to
have all of those values. Eg, the user could if they wanted specify just 'scope' and in this
scenario, all commits are just grouped by the scope and nothing else. Each leg of the
GroupBy path, eg 'scope' is assigned a heading type. So for the default of
"scope/type/change/break", scope appears as a H3 heading, type as a H4, change as a
H5 and break as a H6. No more than four segments can be defined and will result in
an error. It is recommended that the user tries all the defaults with/without
emojis to see which one best suits their needs and to try alternative values given
for the "GroupBy" value to see how entries are organised.

  If the repo is a large one, the user probably doesn't want every single commit to appear
as its own entry in the commit log. This will make for a correspondingly large commit log. It is
recommended that the user specifies some exclusion criteria in the excludes regular
expressions (there are none by default).

To see a detailed explanation of the options config, the user should consult
[Build ChangeLog](Elizium.Loopz/docs/build-changelog.md).

## EXAMPLES

### Example 1

```powershell
Build-PoShLog -name 'Alpha' -Eject -Emoji
```

Eject 'Alpha' emojis options config into the repo under \<root\>/loopz/
as "Alpha-emoji-changelog.options.json"

### Example 2

```powershell
Build-PoShLog -name 'Zen' -Eject
```

Eject 'Zen' options config without emojis into the repo under \<root\>/loopz/
as "Zen-changelog.options.json"

### Example 3

```powershell
Build-PoShLog -name 'Zen'
```

Build a change log using the pre-defined Zen config without emojis.

### Example 4

```powershell
Build-PoShLog -name 'foo'
```

Build a change log using a custom 'foo' config. If the 'foo' config does not exist
a default config is used. The user needs to update the config and re-run.

#### Example 5

Build a change log that contains for commits in releases within a specified range.

```powershell
Build-PoShLog -name 'Zen' -From '1.0.0 -Until '3.0.0'
```

#### Example 6

Build a change log that contains unreleased commits only.

```powershell
Build-PoShLog -name 'Zen' -Unreleased
```

## PARAMETERS

### -Eject

switch to indicate a config should be ejected for use. A change log is not generated
when a config is ejected as it is assumed the user needs to make adjustments to the
ejected options config file.

```yaml
Type: SwitchParameter
Parameter Sets: EjectConfig
Aliases: j

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Emoji

switch to control whether an emoji based config is ejected. When generating a change
log, indicates that the emoji version of the config should be used.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: e

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -From

Is a Tag value. Commits that come after the date associated with this tag are selected.
If specified, overrides the From value in the options config under "Tags.From" setting.

```yaml
Type: String
Parameter Sets: CreateLog
Aliases: f

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

The name of the config to use. The current list of predefined configs are 'Alpha',
'Elizium' and 'Zen' (more may be added in future). However, the user can specify a
custom name, in which case a custom default options file will be generated under that
name. In this case, the user MUST update its contents as it is not complete. It should
be noted that the name is just a logical identifier. A file name is generated from
this logical name. As configs are repo specific, they are created inside the repo and
should be committed into source control.

```yaml
Type: String
Parameter Sets: (All)
Aliases: n

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru

switch to indicate that the generated markdown content is to be sent through the pipeline
instead of being saved to a file.

```yaml
Type: SwitchParameter
Parameter Sets: CreateLog
Aliases: p

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Unreleased

switch to indicate the build log should only contain entries that represent commits
that have not yet been released, ie changes that are coming in the next release.

```yaml
Type: SwitchParameter
Parameter Sets: CreateLogUnreleased
Aliases: ur

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Until

Is a Tag value. Commits that come before the date associated with this tag are selected.
If specified, overrides the Until value in the options config under "Tags.Until" setting.

```yaml
Type: String
Parameter Sets: CreateLog
Aliases: u

Required: False
Position: 3
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

If PassThru is present, markdown content redirected to the pipeline.

## NOTES

## RELATED LINKS

[Build PoShLog](Elizium.Loopz/docs/build-poshlog.md)

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
