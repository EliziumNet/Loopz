
<#
  .NAME
    BoundEntity

  .SYNOPSIS
    Abstract Entity base class. Entities are used to tie together various pieces
  of information into a single bundle. This ensures that for a particular item
  the logic and info is centralised and handled in a consistent manner. The various
  concepts that are handled by an entity are

  * handle items that needs some kind of transformation (eg, regex need to be
  constructed via New-RegularExpression)
  * populating exchange
  * creation of signal
  * formulation and validation of formatters
  * container selection

  .DESCRIPTION
    Populates Keys into exchange.
  There are 2 types of entity, primary and related. Primary entities should have a
  boolean Activate property. This denotes whether the entity is created, actioned
  and stored in the bootstrap. Relation entities are dependent on either other
  primary or related entities. Instead of a boolean Activate property, they should
  have an Activator predicate property which is a script block that returns a boolean.
  Typically, the Activator determines it's activated state by consulting other
  entities, returning true if it is active, false otherwise. 
#>
class BoundEntity {
  [PSCustomObject]$Spec;
  [boolean]$Executed = $false;

  BoundEntity([PSCustomObject]$spec) {
    $this.Spec = $spec;
  }

  # Validation should only be performed prior to execution, not inside the constructor
  # because we want be sure we're a fully constructed object
  #
  [void] RequireAny([string[]]$fields) {
    [boolean]$found = $false;
    [int]$index = 0;

    while (-not($found) -and ($index -lt $fields.Count)) {
      [string]$current = $fields[$index];
      if ($this.Spec.psobject.properties.match($current).Count) {
        $found = $true;
      }
      $index++;

    }

    if (-not($found)) {
      [string]$csv = $fields -join ', ';

      throw [System.Management.Automation.MethodInvocationException]::new(
        "BoundEntity.RequireAny spec ['$($this.Spec.Name)'] does not contain any of: '$csv'");
    }
  }

  [void] RequireOnlyOne([string[]]$fields) {
    [string[]]$found = @()
    [int]$index = 0;

    foreach ($f in $fields) {
      [string]$current = $fields[$index];
      if ($this.Spec.psobject.properties.match($current).Count) {
        $found += $current;
      }

      $index++;
    }

    [string]$csv = $fields -join ', ';
    if ($found.Count -eq 0) {
      throw [System.Management.Automation.MethodInvocationException]::new(
        "BoundEntity.RequireOnlyOne spec ['$($this.Spec.Name)'] does not contain any of: '$csv'");
    }

    if ($found.Count -gt 1) {
      throw [System.Management.Automation.MethodInvocationException]::new(
        "BoundEntity.RequireOnlyOne spec ['$($this.Spec.Name)'] contains more than one of: '$csv'");
    }
  }

  [void] Require([string]$field) {
    if (-not($this.Spec.psobject.properties.match($field).Count)) {
      throw [System.Management.Automation.MethodInvocationException]::new(
        "BoundEntity.Require ['$($this.Spec.Name)'] is missing required field: '$field'");
    }
  }

  [void] RequireAll([string[]]$mandatory) {
    if ($mandatory.Count -gt 0) {
      foreach ($item in $mandatory) {
        $this.Require($item);
      }
    }
  }

  [void] Exec ([BootStrap]$bootstrap) {
    $this.RequireOnlyOne(@('Activate', 'Activator'));
    $this.RequireAll(@('Name', 'SpecType'));

    # Populate Keys
    #
    if ($(Get-PsObjectField -Object $this.Spec -Field 'Keys') -and ($this.Spec.Keys.Count -gt 0)) {
      $this.Spec.Keys.GetEnumerator() | ForEach-Object {
        if ($bootstrap.Exchange.ContainsKey($_.Key)) {
          throw [System.Management.Automation.MethodInvocationException]::new(
            "BoundEntity.Exec ['$($this.Spec.Name)'] Key: '$($_.Key)' already exists");
        }
        Write-Debug "BoundEntity.Exec ['$($this.Spec.Name)']; Key: '$($_.Key)', Value: '$($_.Value)'";
        $bootstrap.Exchange[$_.Key] = $_.Value;
      }
    }

    $this.Executed = $true;
  }
}

<#
  .NAME
    SimpleEntity

  .SYNOPSIS
    Simple item that does not need any transformation of the value and is not
  represented by a signal.

  .DESCRIPTION
    Populates Keys into exchange. A simple entity can be used if all that is required
  is to populate an exchange entry (via Keys); this is wht the Value member is
  optional.

  * Activate (primary: mandatory) -> flag to indicate if the entity is to be created.
  * Activator (relation: mandatory) -> predicate to indicate if the entity is to be created.
  * Name (mandatory) -> identifies the entity
  * SpecType (mandatory) -> 'simple'
  * Value (optional) -> the value of the user supplied expression (including occurrence)
  * Keys (optional ) -> Collection of key/value pairs to be inserted into exchange.
#>
class SimpleEntity : BoundEntity {
  SimpleEntity([PSCustomObject]$spec): base($spec) {
    $this.Spec = $spec;
  }
}

<#
  .NAME
    SignalEntity

  .SYNOPSIS
    For signalled entities.

  .DESCRIPTION
    Manages signal related functionality. This entity manages its own internal
  signal value in addition to the client specified signal value. This is because
  derived classes such as RegexEntity may want to override the signal value, but
  we should not scribble over what ever the client has defined, so we write to
  an internal value instead.

  * Activate (primary: mandatory) -> flag to indicate if the entity is to be created.
  * Activator (relation: mandatory) -> predicate to indicate if the entity is to be created.
  * Name (mandatory) -> identifies the entity
  * SpecType (mandatory) -> 'signal'
  * Value (optional) -> the primary value for this entity (not necessarily the display value)
  * Signal (mandatory) -> name of the signal
  * SignalValue (optional) -> the display value of the signal
  * Force (optional) -> container selector.
  * Keys (optional ) -> Collection of key/value pairs to be inserted into exchange.
#>
class SignalEntity : BoundEntity {
  [string]$_signalOverrideValue;

  SignalEntity([PSCustomObject]$spec): base($spec) {
    $this.Spec = $spec;
  }

  [void] Exec ([BootStrap]$bootstrap) {
    ([BoundEntity]$this).Exec($bootstrap);
  
    if (-not([string]::IsNullOrEmpty($(Get-PsObjectField -Object $this.Spec -Field 'Signal')))) {
      # Invoke Select-SignalContainer
      #
      [hashtable]$parameters = @{
        'Containers' = $bootstrap.Containers;
        'Signals'    = $bootstrap.Signals;
        'Name'       = $this.Spec.Signal;
        'Threshold'  = $bootstrap.Threshold;
      }

      if (-not([string]::IsNullOrEmpty($this._signalOverrideValue))) {
        $parameters['Value'] = $this._signalOverrideValue;
      }
      elseif (-not([string]::IsNullOrEmpty($this.Spec.SignalValue))) {
        $parameters['Value'] = $this.Spec.SignalValue;
      }

      if (-not([string]::IsNullOrEmpty($this.Spec.CustomLabel))) {
        $parameters['CustomLabel'] = $this.Spec.CustomLabel;
      }

      if (-not([string]::IsNullOrEmpty($this.Spec.Format))) {
        $parameters['Format'] = $this.Spec.Format;
      }

      if (-not([string]::IsNullOrEmpty($this.Spec.Force))) {
        $parameters['Force'] = $this.Spec.Force;
      }

      Select-SignalContainer @parameters;
    }
  }
}

<#
  .NAME
    RegexEntity

  .SYNOPSIS
    For regular expressions.

  .DESCRIPTION
    Used to create a regex entity. The entity can represent either a parameter or an
  independent regex.
    A derived regex entity can be created which references another regex. The derived
  value must reference the dependency by including the static place holder string
  '*{_dependency}'.

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
  * Keys (optional ) -> Collection of key/value pairs to be inserted into exchange.

  For derived:
  * Activate (primary: mandatory) -> flag to indicate if the entity is to be created.
  * Activator (relation: mandatory) -> predicate to indicate if the entity is to be created.
  * Dependency (mandatory) -> Name of required regex entity
  * Name (mandatory)
  * SpecType (mandatory) -> 'regex'
  * Value -> The pattern which should include placeholder '*{_dependency}'
  * RegExKey (optional)
  * OccurrenceKey (optional)
#>
class RegexEntity : SignalEntity {
  [regex]$RegEx;
  [string]$Occurrence;

  RegexEntity([PSCustomObject]$spec): base($spec) {

  }

  [void] Exec ([BootStrap]$bootstrap) {
    if (-not([string]::IsNullOrEmpty($(Get-PsObjectField -Object $this.Spec -Field 'Dependency')))) {
      if ([string]::IsNullOrEmpty($this.Spec.Value)) {
        throw [System.Management.Automation.MethodInvocationException]::new(
          "RegexEntity.Exec '$($this.Spec.Name)', Value is undefined");
      }

      [BoundEntity]$bound = $bootstrap.Get($this.Spec.Dependency);

      if ($bound -is [RegexEntity]) {
        [RegexEntity]$dependency = [RegexEntity]$bound;

        if (-not($dependency.Executed)) {
          $dependency.Exec($bootstrap);
        }

        $this.Spec.Value = $this.Spec.Value.Replace(
          '*{_dependency}', $dependency.RegEx.ToString());
      }
      else {
        throw [System.Management.Automation.MethodInvocationException]::new(
          "RegexEntity.Exec '$($this.Spec.Name)', Dependency: '$($bound._param.Name)' is not a RegEx");
      }
    }

    # Create the expression & occurrence
    #
    [string]$expression, $this.Occurrence = Resolve-PatternOccurrence $this.Spec.Value;
    $this._signalOverrideValue = $expression;

    ([SignalEntity]$this).Exec($bootstrap);

    # Create the regex
    #
    [string]$specifier = Get-PsObjectField -Object $this.Spec -Field 'WholeSpecifier';
    [boolean]$whole = [string]::IsNullOrEmpty($specifier) ? $false : `
    $($bootstrap.Options.Whole -and -not([string]::IsNullOrEmpty($bootstrap.Options.Whole)) `
        -and ($bootstrap.Options.Whole -in @('*', $specifier)));

    $this.RegEx = New-RegularExpression -Expression $expression -WholeWord:$whole;

    # Populate Keys
    #
    if ($(Get-PsObjectField -Object $this.Spec -Field 'RegExKey')) {
      if ($bootstrap.Exchange.ContainsKey($this.Spec.RegExKey)) {
        throw [System.Management.Automation.MethodInvocationException]::new(
          "RegexEntity.Exec ['$($this.Spec.Name)'] RegEx Key: '$($this.Spec.RegExKey)' already exists");
      }
      $bootstrap.Exchange[$this.Spec.RegExKey] = $this.RegEx;
    }

    if ($(Get-PsObjectField -Object $this.Spec -Field 'OccurrenceKey')) {
      if ($bootstrap.Exchange.ContainsKey($this.Spec.OccurrenceKey)) {
        throw [System.Management.Automation.MethodInvocationException]::new(
          "RegexEntity.Exec ['$($this.Spec.Name)'] Occurrence Key: '$($this.Spec.OccurrenceKey)' already exists");
      }
      $bootstrap.Exchange[$this.Spec.OccurrenceKey] = $this.Occurrence;
    }
  }
}

<#
  .NAME
    FormatterEntity

  .SYNOPSIS
    For formatter parameters

  .DESCRIPTION
    This is a signal entity with the addition of a validator which check

  * Activate (primary: mandatory) -> flag to indicate if the entity is to be created.
  * Activator (relation: mandatory) -> predicate to indicate if the entity is to be created.
  * Name (mandatory) -> identifies the entity
  * SpecType (mandatory) -> 'formatter'
  * Value (optional) -> the value of the user supplied expression (including occurrence)
  * Signal (optional) -> should be provided for parameters, optional for non parameters
  * WholeSpecifier (optional) -> single letter code identifying this regex parameter.
  * Force (optional) -> container selector.
  * Keys (optional ) -> Collection of key/value pairs to be inserted into exchange.
#>
class FormatterEntity : SignalEntity {
  FormatterEntity([PSCustomObject]$spec): base($spec) {

  }

  [void] Exec ([BootStrap]$bootstrap) {
    ([SignalEntity]$this).Exec($bootstrap);

    if (-not(Test-IsFileSystemSafe -Value $this.Spec.Value)) {
      throw [System.Management.Automation.MethodInvocationException]::new(
        "'$($this.Spec.Name)' parameter ('$($this.Spec.Value)') contains unsafe characters");
    }
  }
}

class BootStrap {

  [hashtable]$Exchange;
  [PSCustomObject]$Containers;
  [hashtable]$Signals;
  [int]$Threshold = 6;
  [PSCustomObject]$Options;
  [hashtable]$Theme;
  [hashtable]$_entities;
  [hashtable]$_relations;
  [boolean]$_built = $false;

  BootStrap([hashtable]$exchange, [PSCustomObject]$containers, [hashtable]$signals,
    [hashtable]$theme, [PSCustomObject]$options) {

    $this.Exchange = $exchange;
    $this.Containers = $containers;
    $this.Signals = $signals;
    $this.Theme = $theme;
    $this.Options = $options;
    $this._entities = [ordered]@{};
    $this._relations = [ordered]@{};

    $this.Exchange['LOOPZ.KRAYON'] = New-Krayon -Theme $this.Theme;
    $this.Exchange['LOOPZ.SIGNALS'] = $signals;
  }

  [BoundEntity] Create([PSCustomObject]$spec) {
    [BoundEntity]$instance = switch ($spec.SpecType) {
      'formatter' {
        [FormatterEntity]::new($spec);
      }

      'regex' {
        [RegexEntity]::new($spec);
      }

      'signal' {
        [SignalEntity]::new($spec);
      }

      'simple' {
        [SimpleEntity]::new($spec);
      }

      default {
        throw [System.Management.Automation.MethodInvocationException]::new(
          "BootStrap.Create: Invalid SpecType: '$($spec.SpecType)'.");        
      }
    }

    return $instance;
  }

  [void] Register([PSCustomObject]$spec) {
    $this._bind($this.Create($spec));
  }

  [hashtable] Build([array]$relations) {

    if (-not($this._built)) {
      if ($this._entities.Count -gt 0) {
        $this._entities.GetEnumerator() | ForEach-Object {
          if (-not($_.Value.Executed)) {
            $_.Value.Exec($this);
          }
        }
      }

      if ($relations.Count -gt 0) {
        foreach ($relatedSpec in $relations) {
          if ($relatedSpec -is [PSCustomObject]) {
            [scriptblock]$activator = Get-PsObjectField -Object $relatedSpec -Field 'Activator';

            if ($activator) {

              if ($this._entities.ContainsKey($relatedSpec.Name)) {
                throw [System.Management.Automation.MethodInvocationException]::new(
                  "BootStrap.Build: Relation: '$($relatedSpec.Name)' already exists as primary entity.");
              }

              if ($this._relations.ContainsKey($relatedSpec.Name)) {
                throw [System.Management.Automation.MethodInvocationException]::new(
                  "BootStrap.Build: Relation: '$($relatedSpec.Name)' already exists as relation.");
              }

              # Assumption: client makes no changes are made to the _relations collection
              # as it is currently being iterated. Any structural modifications to the
              # collection are likely to result in unexpected results and/or errors.
              #
              if ($activator.InvokeReturnAsIs($this._entities, $this._relations)) {
                [BoundEntity]$relatedEntity = $this.Create($relatedSpec);
                $this._relations[$relatedEntity.Spec.Name] = $relatedEntity;

                $relatedEntity.Exec($this);
              }
            }
            else {
              throw [System.Management.Automation.MethodInvocationException]::new(
                "BootStrap.Build: Relation: '$($relatedSpec.Name)' does not contain valid Activator.");
            }
          }
        }
      }

      if ($this.Containers.Wide.Line.Length -gt 0) {
        $this.Exchange['LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS'] = $this.Containers.Wide;
      }

      if ($this.Containers.Props.Line.Length -gt 0) {
        $this.Exchange['LOOPZ.SUMMARY.PROPERTIES'] = $this.Containers.Props;
      }

      $this._built = $true;
    }

    return $this.Exchange;
  }

  [PSCustomObject] Get ([string]$name) {
    [PSCustomObject]$result = if ($this._entities.ContainsKey($name)) {
      $this._entities[$name];
    }
    elseif ($this._relations.ContainsKey($name)) {
      $this._relations[$name];
    }
    else {
      $null;
    }

    return $result;
  }

  [boolean] Contains ([string]$name) {
    return ($null -ne $this.Get($name));
  }

  [void] _bind([BoundEntity]$entity) {
    if ($entity.Spec.Activate) {
      if ($this._entities.ContainsKey($entity.Spec.Name)) {
        throw [System.Management.Automation.MethodInvocationException]::new(
          "BootStrap._bind: Item with id: '$($entity.Spec.Name)' already exists.");
      }

      $this._entities[$entity.Spec.Name] = $entity;
    }
  }
}
