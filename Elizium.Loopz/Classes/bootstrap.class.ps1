
class BoundEntity {
  [PSCustomObject]$Core;
  [boolean]$Executed = $false;

  BoundEntity([PSCustomObject]$core) {
    $this.Core = $core;
  }

  [void] Exec ([BootStrap]$bootstrap) {
    # Populate Keys
    #
    if ($this.Core.Keys -and ($this.Core.Keys.Count -gt 0)) {
      $this.Core.Keys.GetEnumerator() | ForEach-Object {
        if ($bootstrap.Exchange.ContainsKey($_.Key)) {
          throw [System.Management.Automation.MethodInvocationException]::new(
            "BoundEntity.Exec Custom Key: '$($_.Key)' already exists");
        }
        $bootstrap.Exchange[$_.Key] = $_.Value;
      }
    }

    $this.Executed = $true;
  }
}

class SimpleEntity : BoundEntity {
  SimpleEntity([PSCustomObject]$core): base($core) {
    $this.Core = $core;
  }
}

class SignalEntity : BoundEntity {
  [string]$_signalValue;

  SignalEntity([PSCustomObject]$core): base($core) {
    $this.Core = $core;
  }

  [void] Exec ([BootStrap]$bootstrap) {
    ([BoundEntity]$this).Exec($bootstrap);

    if ($this.Core.Signal -and -not([string]::IsNullOrEmpty($this.Core.Signal))) {
      # Invoke Select-SignalContainer
      #
      [hashtable]$parameters = @{
        'Containers' = $bootstrap.Containers;
        'Signals'    = $bootstrap.Signals;
        'Name'       = $this.Core.Signal;
        'Threshold'  = $bootstrap.Threshold;
      }

      if (-not([string]::IsNullOrEmpty($this._signalValue))) {
        $parameters['Value'] = $this._signalValue;
      }
      elseif (-not([string]::IsNullOrEmpty($this.Core.SignalValue))) {
        $parameters['Value'] = $this.Core.SignalValue;
      }

      if (-not([string]::IsNullOrEmpty($this.Core.CustomLabel))) {
        $parameters['CustomLabel'] = $this.Core.CustomLabel;
      }

      if (-not([string]::IsNullOrEmpty($this.Core.Format))) {
        $parameters['Format'] = $this.Core.Format;
      }

      if (-not([string]::IsNullOrEmpty($this.Core.Force))) {
        $parameters['Force'] = $this.Core.Force;
      }

      Select-SignalContainer @parameters;
    }
  }
}

<#
  .NAME
    RegexEntity

  .SYNOPSIS
    For regular expression parameters.

  .DESCRIPTION
    Used to create a regex entity. A derived regex entity can be created which references
  another regex. The derived value must reference the dependency by including the static
  place holder string '*{_dependency}'.

  eg:
  {
    Activate (mandatory)
    Name (mandatory) -> identifies the entity
    Value (optional) -> the value of the user supplied expression (including occurrence)
    Signal (optional) -> should be provided for parameters, optional for non parameters
    WholeSpecifier (mandatory) -> single letter code identifying this regex parameter.
    Force (optional) -> container selector.
    RegExKey (mandatory) -> Where the internally created [regex] object os stored in exchange.
    OccurrenceKey (mandatory) -> 'LOOPZ.REMY.PATTERN-OCC';
  }

  For derived:
  {
    Activate
    Dependency (mandatory) -> Name of required regex entity
    Name
    Value -> The pattern which should include placeholder '*{_dependency}'
    RegExKey
    OccurrenceKey
  }
#>
class RegexEntity : SignalEntity {
  [regex]$RegEx;
  [string]$Occurrence;

  RegexEntity([PSCustomObject]$core): base($core) {

  }

  [void] Exec ([BootStrap]$bootstrap) {
    if ($this.Core.Dependency -and -not([string]::IsNullOrEmpty($this.Core.Dependency))) {
      if ([string]::IsNullOrEmpty($this.Core.Value)) {
        throw [System.Management.Automation.MethodInvocationException]::new(
          "RegexEntity.Exec '$($this.Core.Name)', Value is undefined");
      }

      [BoundEntity]$bound = $bootstrap.Get($this.Core.Dependency);

      if ($bound -is [RegexEntity]) {
        [RegexEntity]$dependency = [RegexEntity]$bound;

        if (-not($dependency.Executed)) {
          $dependency.Exec($bootstrap);
        }

        $this.Core.Value = $this.Core.Value.Replace(
          '*{_dependency}', $dependency.RegEx.ToString());
      }
      else {
        throw [System.Management.Automation.MethodInvocationException]::new(
          "RegexEntity.Exec '$($this.Core.Name)', Dependency: '$($bound._param.Name)' is not a RegEx");
      }
    }

    # Create the expression & occurrence
    #
    [string]$expression, $this.Occurrence = Resolve-PatternOccurrence $this.Core.Value;
    $this._signalValue = $expression;

    ([SignalEntity]$this).Exec($bootstrap);

    # Create the regex
    #
    $this.RegEx = New-RegularExpression -Expression $expression `
      -WholeWord:$($bootstrap.Options.Whole -and -not([string]::IsNullOrEmpty($bootstrap.Options.Whole)) `
        -and ($bootstrap.Options.Whole -in @('*', $this.Core.WholeSpecifier)));

    # Populate Keys
    #
    if ($(Get-PsObjectField -Object $this.Core -Field 'RegExKey')) {
      if ($bootstrap.Exchange.ContainsKey($this.Core.RegExKey)) {
        throw [System.Management.Automation.MethodInvocationException]::new(
          "RegexEntity.Exec RegEx Key: '$($this.Core.RegExKey)' already exists");
      }
      $bootstrap.Exchange[$this.Core.RegExKey] = $this.RegEx;
    }

    if ($(Get-PsObjectField -Object $this.Core -Field 'OccurrenceKey')) {
      if ($bootstrap.Exchange.ContainsKey($this.Core.OccurrenceKey)) {
        throw [System.Management.Automation.MethodInvocationException]::new(
          "RegexEntity.Exec Occurrence Key: '$($this.Core.OccurrenceKey)' already exists");
      }
      $bootstrap.Exchange[$this.Core.OccurrenceKey] = $this.Occurrence;
    }
  }
}

class FormatterEntity : SignalEntity {
  FormatterEntity([PSCustomObject]$core): base($core) {

  }

  [void] Exec ([BootStrap]$bootstrap) {
    ([SignalEntity]$this).Exec($bootstrap);

    if (-not(Test-IsFileSystemSafe -Value $this.Core.Value)) {
      throw [System.Management.Automation.MethodInvocationException]::new(
        "'$($this.Core.Name)' parameter ('$($this.Core.Value)') contains unsafe characters");
    }
  }
}

class UtilityEntity : SignalEntity {
  UtilityEntity([PSCustomObject]$core): base($core) {

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

      'utility' {
        [UtilityEntity]::new($spec);
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

      if ($this.Containers.Wide.Line.Length -gt 0) {
        $this.Exchange['LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS'] = $this.Containers.Wide;
      }

      if ($this.Containers.Props.Line.Length -gt 0) {
        $this.Exchange['LOOPZ.SUMMARY.PROPERTIES'] = $this.Containers.Props;
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

              # TODO: Is it safe to pass in the relations here?
              # (Its probably ok as long as no changes are made to the collection)
              #
              if ($activator.InvokeReturnAsIs($this._entities, $this._relations)) {
                [BoundEntity]$relatedEntity = $this.Create($relatedSpec);
                $this._relations[$relatedEntity.Core.Name] = $relatedEntity;

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
    if ($entity.Core.Activate) {
      if ($this._entities.ContainsKey($entity.Core.Name)) {
        throw [System.Management.Automation.MethodInvocationException]::new(
          "BootStrap._bind: Item with id: '$($entity.Core.Name)' already exists.");
      }

      $this._entities[$entity.Core.Name] = $entity;
    }
  }
}
