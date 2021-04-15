
# :nazar_amulet: Elizium.Loopz bootstrap

When a command designed to show a lot of output and indication signals, the bootstrap class
can be used to help manage this complexity in a common way. A command may want to show the
presence of user defined parameters with Signals. By using the *Bootstrap* the client command can
be designed without having to implement the logic of showing indicators. All the client needs
to do is to define a 'spec' object which describes a parameter or other indicator
and then register this spec with the *Bootstrap*, which then creates an
'Entity' that relates to the spec.

There are 2 types of entity, **Primary** and **Related**. Primary entities should have a
boolean *Activate* property. This denotes whether the entity is created, actioned
and stored in the *Bootstrap*. Related entities are dependent on either other
Primary or Related entities. Instead of a boolean *Activate* property, they should
have an *Activator* predicate property which is a script block that returns a boolean.
Typically, the *Activator* determines it's activated state by consulting other
entities, returning $true if it is active, $false otherwise.

Entities are used to tie together various pieces of information into a single bundle.
This ensures that for a particular item the logic and info is centralised and handled
in a consistent manner. The various concepts that are handled by an entity are:

* handle items that needs some kind of transformation (eg, regex entities need to be
constructed via New-RegularExpression)
* populating *Exchange*
* creation of *Signal*
* formulation and validation of formatters
* container selection

There are currently four entity types (which can be *Primary* or *Related*):

:sparkles: *SimpleEntity*

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

:gem: *SimpleEntity* example:

```powershell
  [PSCustomObject]$relationSpec = [PSCustomObject]@{
    Activate = $PSBoundParameters.ContainsKey('Relation') -and `
      -not([string]::IsNullOrEmpty($Relation));
    Name     = 'Relation';
    SpecType = 'simple';
    Value    = $Relation;
    Keys     = @{
      'LOOPZ.REMY.RELATION' = $Relation;
    }
  }
  $bootStrap.Register($relationSpec);
```

---

:sparkles: *SignalEntity*

* 2) **SignalEntity**: For signalled entities. (eg a parameter that is associated with a *Signal*)

Spec properties:

* Activate (primary: mandatory) -> flag to indicate if the entity is to be created.
* Activator (relation: mandatory) -> predicate to indicate if the entity is to be created.
* Name (mandatory) -> identifies the entity
* SpecType (mandatory) -> 'signal'
* Value (optional) -> the primary value for this entity (not necessarily the display value)
* Signal (mandatory) -> name of the *Signal*
* SignalValue (optional) -> the display value of the *Signal*
* Force (optional) -> container selector.
* Keys (optional) -> Collection of key/value pairs to be inserted into exchange.

:gem: *SignalEntity* example:

```powershell
  [PSCustomObject]$startSpec = [PSCustomObject]@{
    Activate    = $PSBoundParameters.ContainsKey('Start') -and $Start;
    Name        = 'Start';
    SpecType    = 'signal';
    Value       = $true;
    Signal      = 'REMY.ANCHOR';
    CustomLabel = 'Start';
    Force       = 'Props';
    SignalValue = $signals['SWITCH-ON'].Value;
    Keys        = @{
      'LOOPZ.REMY.ACTION'      = 'Move-Match';
      'LOOPZ.REMY.ANCHOR-TYPE' = 'START';
    };
  }
  $bootStrap.Register($startSpec);
```

---

:sparkles: *RegexEntity*

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

:gem: *RegexEntity* example:

```powershell
  [PSCustomObject]$patternSpec = [PSCustomObject]@{
    Activate       = $PSBoundParameters.ContainsKey('Pattern') -and `
      -not([string]::IsNullOrEmpty($Pattern));
    SpecType       = 'regex';
    Name           = 'Pattern';
    Value          = $Pattern;
    Signal         = 'PATTERN';
    WholeSpecifier = 'p';
    RegExKey       = 'LOOPZ.REMY.PATTERN-REGEX';
    OccurrenceKey  = 'LOOPZ.REMY.PATTERN-OCC';
  }
  $bootStrap.Register($patternSpec);
```

:gem: Derived *RegexEntity* example:

```powershell
  [PSCustomObject]@{
    Activate      = $true;
    Name          = 'Anchored';
    SpecType      = 'regex';
    Value         = $("^*{_dependency}");
    Dependency    = 'Pattern';
    RegExKey      = 'LOOPZ.REMY.ANCHORED-REGEX';
    OccurrenceKey = 'LOOPZ.REMY.ANCHORED-OCC';
  }
  $bootStrap.Register($anchoredSpec);
```

---

:sparkles: *FormatterEntity*

* 4) **FormatterEntity**: For formatter parameters, which formats an output value.
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

:gem: Derived *FormatterEntity* example:

```powershell
  [PSCustomObject]$withSpec = [PSCustomObject]@{
    Activate    = $PSBoundParameters.ContainsKey('With') -and `
      -not([string]::IsNullOrEmpty($With));
    SpecType    = 'formatter';
    Name        = 'With';
    Value       = $With;
    Signal      = 'WITH';
    SignalValue = $With;
    Keys        = @{
      'LOOPZ.REMY.WITH' = $With;
    }
  }
  $bootStrap.Register($withSpec);
```

---

:gem: Related entity example:

```powershell
  [PSCustomObject]$isMoveSpec = [PSCustomObject]@{
    Activator = [scriptblock] {
      [OutputType([boolean])]
      param(
        [hashtable]$Entities,
        [hashtable]$Relations
      )

      [boolean]$result = $Entities.ContainsKey('Anchor') -or `
        $Entities.ContainsKey('Start') -or $Entities.ContainsKey('End') -or `
        $Entities.ContainsKey('AnchorStart') -or $Entities.ContainsKey('AnchorEnd');

      return $result;
    }
    Name      = 'IsMove';
    SpecType  = 'simple';
  }
```

This *IsMove* spec, creates an entity that is dependent on the presence of other entities. *Related* entities are not *Register*ed in the same way as we have seen for *Primary* entities. Instead, when we *build* the *Bootstrap* (see following), we specify the list of related entities, specified by name. The *Bootstrap*, performs registration of the *Related* entities as part of the *build*.

:gem: *Bootstrap* **build** example:

```powershell
  $null = $bootStrap.Build(@($isMoveSpec));
```

:pushpin: The *Build* method, returns the *Exchange* instance, but can be discarded as done in this example, by assigning to $null. This is highly recommended if calling from a function to prevent accidental leakage into the console, that is if we don't have need for the returned instance.

This builds the *Bootstrap* with the example *IsMove* Related entity from the previous example.

:pushpin: if there are no related entities, then pass in an empty array into *Build*. The *Bootstrap*, must be built regardless of the presence of related entities.

Once the *Bootstrap* is built, we can subsequently query it with either *Contains* or *Get* methods.

:gem: *Bootstrap* **Bootstrap.Contains** example:

```powershell
  if ($bootStrap.Contains('IsMove')) {
    ...
  }
```

:gem: *Bootstrap* **Bootstrap.Get** example:

```powershell
  [RegexEntity]$patternEntity = $bootStrap.Get('Pattern');
```
