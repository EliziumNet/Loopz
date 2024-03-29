---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Convert-Emojis

## SYNOPSIS

Converts emojis defined as short codes inside markdown files into their correspond code points.

## SYNTAX

```powershell
Convert-Emojis [-InputObject] <FileInfo[]> [[-OutputSuffix] <String>] [[-QuerySpan] <TimeSpan>]
 [[-Now] <DateTime>] [-Test] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The need for command as a result of the fact that external documentation platforms, in particular
gitbook, do not currently support the presence of emoji references inside markdown files. Currently,
emojis can  only be correctly rendered if the emoji is represented via its code point representation.
A user may have a large amount of markdown in multiple projects and converting these all by hand would
be onerous and impractical. This command will automatically convert all emoji short code references
into their HTML compliant code point representation; eg, the smiley emoji in short code form ___\:smiley \:___
is converted to ___\&#x1f603;___ The command takes files from the pipeline performs the conversion and depending
on supplied parameters, will either overwrite the original file or write to a new one. The user can
feed multiple items via the pipeline and they will all be processed in a batch.

Emoji code point definitions are acquired via the github emoji api, so only github defined emojis
are currently supported. Some emojis have multiple code points defined for them and are defined as
a range of values by the github api, eg ascension_island is defined as range: 1f1e6-1f1e8, so in
this case, the first item in the range is taken to be the value: 1f1e6.

WhatIf is supported and when enabled, the files are converted but not saved. This allows the user
to see if all the emojis contained within are converted successfully as an errors are reported during
the run.

## EXAMPLES

### Example 1

```powershell
Get-Item -Path ./README.md | Convert-Emojis
```

Convert a single and over the original

### Example 2

```powershell
Get-Item -Path ./README.md | Convert-Emojis -OutputSuffix out
```

Convert a single and create a new corresponding file with 'out' suffix (README-out.md)

### Example 3

```powershell
Get-ChildItem ./*.md | Convert-Emojis -OutputSuffix out
```

Convert a collection of markdown files with out suffix

### Example 4

```powershell
Get-ChildItem ./*.md | Convert-Emojis -WhatIf
```

Convert a collection of markdown files without saving

## PARAMETERS

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

### -InputObject

The current pipeline item representing a file. Any command that can deliver FileInfo items can be
used, eg Get-Item for a single item or Get-ChildItem for a collection.

```yaml
Type: FileInfo[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Now

(Required for testing purposes only)

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputSuffix

The suffix appended to the original filename. When specified, the new file generated by the conversion
process is written with this suffix. When omitted, the original file is over-written.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -QuerySpan

Defines a period of time during which successive calls to the github api can not be made. The emoji
list does not change very often, so the result is cached and is referred to on successive invocations
to avoid un-necessary api calls. The default value is 7 days, which means (assuming the cache has not
been deleted) that no 2 queries inside the space of a week are issued to the github api.

```yaml
Type: TimeSpan
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Test

(Required for testing purposes only)

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

### -WhatIf

Shows what would happen if the cmdlet runs.

Documents are converted, but not saved. This allows the user to preview the conversion process before saving to file.

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

### System.IO.FileInfo[]

Files whose content should have emoji short code references converted to HTML code points.

## OUTPUTS

### System.Object

## NOTES

Uses the github emoji api. The json response is cached locally to prevent excessive calls to the api on slowly changing data.

## RELATED LINKS

[Elizium.Loopz](https://github.com/EliziumNet/Loopz)
