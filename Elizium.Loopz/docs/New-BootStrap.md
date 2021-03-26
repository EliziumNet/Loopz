---
external help file: Elizium.Loopz-help.xml
Module Name: Elizium.Loopz
online version:
schema: 2.0.0
---

# New-BootStrap

## SYNOPSIS

Bootstrap factory function

## SYNTAX

```powershell
New-BootStrap [[-Exchange] <Hashtable>] [[-Containers] <PSObject>] [[-Options] <PSObject>] [<CommonParameters>]
```

## DESCRIPTION

  Creates a bootstrap instance for the client command. When a command designed to
show a lot of output and indication signals, the bootstrap can help manage this
complexity in a common way. A command may want to show the presence of user
defined parameters with Signals. By using the Boot-strapper the client can be designed
without having to implement the logic of showing indicators. All the client needs
to do is to define a 'spec' object which describes a parameter or other indicator
and then register this spec with the Boot-strapper. The Boot-strapper then creates an
'Entity' that relates to the spec.

There are 2 types of entity, primary and related. Primary entities should have a
boolean Activate property. This denotes whether the entity is created, actioned
and stored in the bootstrap. Relation entities are dependent on either other
primary or related entities. Instead of a boolean Activate property, they should
have an Activator predicate property which is a script block that returns a boolean.
Typically, the Activator determines it's activated state by consulting other
entities, returning true if it is active, false otherwise.

  Entities are used to tie together various pieces of information into a single bundle.
This ensures that for a particular item the logic and info is centralised and handled
in a consistent manner. The various concepts that are handled by an entity are:

* handle items that needs some kind of transformation (eg, regex entities need to be
constructed via New-RegularExpression)
* populating exchange
* creation of signal
* formulation and validation of formatters
* container selection

There are currently four entity types:

* 1) **SimpleEntity**: Simple item that does not need any transformation of the value and is not
represented by a signal. A simple entity can be used if all that is required
is to populate an exchange entry (via Keys); this is why the Value member is
optional.

Spec properties:

* Activate (primary: mandatory) -> flag to indicate if the entity is to be created.
* Activator (relation: mandatory) -> predicate to indicate if the entity is to be created.
* Name (mandatory) -> identifies the entity
* SpecType (mandatory) -> 'simple'
* Value (optional) -> typically the value of a parameter, but can be anything.
* Keys (optional) -> Collection of key/value pairs to be inserted into exchange.

---

* 2) **SignalEntity**: For signalled entities. (eg a parameter that is associated with a signal)

Spec properties:

* Activate (primary: mandatory) -> flag to indicate if the entity is to be created.
* Activator (relation: mandatory) -> predicate to indicate if the entity is to be created.
* Name (mandatory) -> identifies the entity
* SpecType (mandatory) -> 'signal'
* Value (optional) -> the primary value for this entity (not necessarily the display value)
* Signal (mandatory) -> name of the signal
* SignalValue (optional) -> the display value of the signal
* Force (optional) -> container selector.
* Keys (optional) -> Collection of key/value pairs to be inserted into exchange.

---

* 3) **RegexEntity**: For regular expressions. Used to create a regex entity. The entity can
represent either a parameter or an independent regex.

  A derived regex entity can be created which references another regex. The derived
value must reference the dependency by including the static place holder string
'*{_dependency}'.

Spec properties:

* Activate (primary: mandatory) -> flag to indicate if the entity is to be created.
* Activator (relation: mandatory) -> predicate to indicate if the entity is to be created.
* Name (mandatory) -> identifies the entity
* Value (optional) -> the value of the user supplied expression (including occurrence)
* Signal (optional) -> should be provided for parameters, optional for non parameters
* WholeSpecifier (optional) -> single letter code identifying this regex parameter.
* Force (optional) -> container selector.
* RegExKey (optional) -> Key identifying where the internally created [regex] object
  is stored in exchange.
* OccurrenceKey (optional) -> Key identifying where the occurrence value for this regex
  is stored in exchange.
* Keys (optional) -> Collection of key/value pairs to be inserted into exchange.

For derived:

* Activate (primary: mandatory) -> flag to indicate if the entity is to be created.
* Activator (relation: mandatory) -> predicate to indicate if the entity is to be created.
* Dependency (mandatory) -> Name of required regex entity
* Name (mandatory)
* SpecType (mandatory) -> 'regex'
* Value -> The pattern which should include placeholder '*{_dependency}'
* RegExKey (optional)
* OccurrenceKey (optional)

---

* 4) **FormatterEntity**: For formatter parameters, which formats a file or directory name.
  This is a signal entity with the addition of a validator which checks that the
value represented does not contain file system unsafe characters. Uses function
Test-IsFileSystemSafe to perform this check.

Spec properties:

* Activate (primary: mandatory) -> flag to indicate if the entity is to be created.
* Activator (relation: mandatory) -> predicate to indicate if the entity is to be created.
* Name (mandatory) -> identifies the entity
* SpecType (mandatory) -> 'formatter'
* Value (optional) -> the value of the user supplied expression (including occurrence)
* Signal (optional) -> should be provided for parameters, optional for non parameters
* WholeSpecifier (optional) -> single letter code identifying this regex parameter.
* Force (optional) -> container selector.
* Keys (optional) -> Collection of key/value pairs to be inserted into exchange.

## PARAMETERS

### -Containers

A PSCustomObject that must contain a 'Wide' property and a 'Props' property. Both of
these must be of type Krayola.Line. 'Prop's are designed to show a small item of information,
typically 5/6 characters long; multiple props would typically easily fit on a single line
in the console. Wide items, are those which when show take up a lot of screen space, eg
showing a file's full path is often a 'wide' item, so it would be best to present it on
its own line.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Exchange

The exchange instance to populate.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Options

Not mandatory. Currently, only specifies a 'Whole' property. The 'Whole' property is a
string containing multiple individual characters each one maps to a regex parameter and
indicates if that regex pattern should be applied as a whole; ie it is wrapped up in
the word boundary token '\b' to indicate that it should match on whole word basis only.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### BootStrap

A new BootStrap instance to help initialise a client command.

## NOTES

## RELATED LINKS
