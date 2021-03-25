---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# Register-CommandSignals

## SYNOPSIS

A client can use this function to register which signals it uses
with the signal registry. When the user uses the Show-Signals command,
they can see which signals a command uses and therefore see the impact
of defining a custom signal.

## SYNTAX

```powershell
Register-CommandSignals [-Alias] <String> [-UsedSet] <String[]> [[-Signals] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION

Stores the list of signals used for a command in the signal registry.
It is recommended that the client defines an alias for their command then
registers signals against this more concise alias, rather the the full
command name. This will reduce the chance of an overflow in the console,
if too many commands are registered. It is advised that clients invoke
this for all commands that use signals in the module initialisation code.
This will mean that when a module is imported, the command's signals are
registered and will show up in the table displayed by 'Show-Signals'.

## PARAMETERS

### -Alias

The name of the command's alias, to register the signals under.

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

### -Signals

The signals hashtable collection, to validate the UsedSet against;
should be left to the default.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UsedSet

The set of signals that the specified command uses.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
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
