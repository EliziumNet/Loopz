
class ParameterSetRule {
  [string]$RuleName;
  [string]$Short;
  [string]$Description;

  ParameterSetRule([string]$name) {
    $this.RuleName = $name;
  }

  # TODO: define the return type
  #
  Verify([System.Management.Automation.CommandInfo]$commandInfo) {
    throw [System.Management.Automation.MethodInvocationException]::new(
      'Abstract method not implemented (ParameterSetRule.Verify)');
  }

  # TODO: define the return type
  #
  Query([System.Management.Automation.CommandInfo]$commandInfo) {
    throw [System.Management.Automation.MethodInvocationException]::new(
      'Abstract method not implemented (ParameterSetRule.Query)');
  }
}

class MustContainUniqueParameters : ParameterSetRule {

  MustContainUniqueParameters([string]$name):base($name) {
    $this.Short = 'Unique Parameters';
    $this.Description =
    'Each parameter set must have at least one unique parameter. If possible, make this parameter a mandatory parameter.';
  }

  Verify([System.Management.Automation.CommandInfo]$commandInfo) {
  }
}

class MustContainUniquePositions : ParameterSetRule {
  MustContainUniquePositions([string]$name):base($name) {
    $this.Short = 'Unique Positions';
    $this.Description =
    'A parameter set that contains multiple positional parameters must define unique positions for each parameter. No two positional parameters can specify the same position.';
  }
}

class MustNotHaveMultiplePipelineParams : ParameterSetRule {
  MustNotHaveMultiplePipelineParams([string]$name):base($name) {
    $this.Short = 'Single Pipeline Param';
    $this.Description =
    'Only one parameter in a set can declare the ValueFromPipeline keyword with a value of true.';
  }
}

class Rules {
  static [string]$RuleNames = @('UNIQUE-PARAMS', 'UNIQUE-POSITIONS', 'SINGLE-PIPELINE-PARAM');

  [string]$CommandName;
  [System.Management.Automation.CommandInfo]$CommandInfo;
  [hashtable]$Rules;

  Rules([System.Management.Automation.CommandInfo]$commandInfo) {
    $this.CommandName = $commandInfo.Name;
    $this.CommandInfo = $commandInfo;

    $this.Rules = @{
      'UNIQUE-PARAMS'         = [MustContainUniqueParameters]::new('UNIQUE-PARAMS');
      'UNIQUE-POSITIONS'      = [MustContainUniquePositions]::new('UNIQUE-POSITIONS');
      'SINGLE-PIPELINE-PARAM' = [MustNotHaveMultiplePipelineParams]::new('SINGLE-PIPELINE-PARAM');
    }
  }

  VerifyAll() {

  }
}

class Informer {
  [Rules]$Rules;
  [System.Management.Automation.CommandInfo]$CommandInfo;
  [PSCustomObject]$InformInfo;

  Informer([Rules]$rules, [PSCustomObject]$informInfo) {
    $this.Rules = $rules;
    $this.CommandInfo = $rules.CommandInfo;
    $this.InformInfo = $informInfo;
  }

  [System.Management.Automation.CommandParameterSetInfo[]] Resolve([string[]]$params) {
    [System.Management.Automation.CommandParameterSetInfo[]]$candidateSets = `
      $this.CommandInfo.ParameterSets | Where-Object {
      $(
        (Test-Intersect $_.Parameters.Name $params) -and
        (Test-ContainsAll $params ($_.Parameters | Where-Object { $_.IsMandatory }).Name)
      )
    };
    return $candidateSets;
  } # Resolve
}
