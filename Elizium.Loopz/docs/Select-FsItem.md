---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Select-FsItem

## SYNOPSIS

A predicate function that indicates whether an item identified by the Name matches
the include/exclude filters specified.

## SYNTAX

```powershell
Select-FsItem [-Name] <String> [[-Includes] <String[]>] [[-Excludes] <String[]>] [-Case] [<CommonParameters>]
```

## DESCRIPTION

Use this utility function to help specify a Condition for Invoke-TraverseDirectory.
This function is partly required because the Include/Exclude parameters on functions
such as Get-ChildItems/Copy-Item/Get-Item etc only work on files not directories.

## EXAMPLES

### Example 1

```powershell
  [scriptblock]$filterDirectories = {
    [OutputType([boolean])]
    param(
      [System.IO.DirectoryInfo]$directoryInfo
    )
    [string[]]$directoryIncludes = @('A*');
    [string[]]$directoryExcludes = @('*_*', '*-*');

    Select-FsItem -Name $directoryInfo.Name `
      -Includes $directoryIncludes -Excludes $directoryExcludes;

    Invoke-TraverseDirectory -Path <path> -Block <block> -Condition $filterDirectories;
  }
```

Define a Condition that allows only directories beginning with A, but also excludes
any directory containing '_' or '-'.

## PARAMETERS

### -Case

Switch parameter which controls case sensitivity of inclusion/exclusion. By default
filtering is case insensitive. When The Case switch is specified, filtering is case
sensitive.

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

### -Excludes

An array containing a list of filters, each must contain a wild-card ('*'). If a
particular filter does not contain a wild-card, then it will be ignored. If the Name
matches any of the filters in the list, will cause the end result to be false.
Any match in the Excludes overrides a match in Includes, so an item
that is matched in Include, can be excluded by the Exclude.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Includes

An array containing a list of filters, each must contain a wild-card ('*'). If a
particular filter does not contain a wild-card, then it will be ignored. If Name matches
any of the filters in Includes, and are not Excluded, the result will be true.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

A string to be matched against the filters.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Boolean

## NOTES

## RELATED LINKS
