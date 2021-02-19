
class ParameterSetRule {
  [string]$RuleName;
  [string]$Short;
  [string]$Description;

  ParameterSetRule([string]$name) {
    $this.RuleName = $name;
  }

  # TODO: define the return type
  #
  # Violations returns violations of the rule. If no violation, then return null.
  # If there are violations, then return a single PSCustomObject which wraps:
  # - RuleName
  # - Violations as an array of free-form PSCustomObjects
  # - Reasons: array of strings identifying the contributors to the failures.
  #
  [PSCustomObject] Violation([PSCustomObject]$verifyInfo) {
    throw [System.Management.Automation.MethodInvocationException]::new(
      'Abstract method not implemented (ParameterSetRule.Violations)');
  }

  [void] ViolationStmt ([PSCustomObject[]]$violations, [PSCustomObject]$verifyInfo) {
    throw [System.Management.Automation.MethodInvocationException]::new(
      'Abstract method not implemented (ParameterSetRule.ViolationStmt)');
  }
} # ParameterSetRule

class MustContainUniqueSetOfParams : ParameterSetRule {

  MustContainUniqueSetOfParams([string]$name):base($name) {
    $this.Short = 'Unique Parameter Set';
    $this.Description =
    'Each parameter set must have at least one unique parameter. If possible, make this parameter a mandatory parameter.';
  }

  [PSCustomObject] Violation([PSCustomObject]$verifyInfo) {

    [PSCustomObject[]]$duplicates = find-DuplicateParamSets -CommandInfo $verifyInfo.CommandInfo `
      -Syntax $verifyInfo.Syntax;

    [PSCustomObject]$vo = if ($duplicates -and $duplicates.Count -gt 0) {

      [string[]]$reasons = $duplicates | ForEach-Object { $("{$($_.First.Name)/$($_.Second.Name)}"); }
      [PSCustomObject]@{
        Rule       = $this.RuleName;
        Violations = $duplicates;
        Reasons    = $reasons;
      }
    }
    else {
      $null;
    }

    return $vo;
  }

  [void] ViolationStmt ([PSCustomObject[]]$violations, [PSCustomObject]$verifyInfo) {
    # Each violation reported must have the rule name and the parameter set

    [object]$syntax = $verifyInfo.Syntax;
    [System.Text.StringBuilder]$builder = $verifyInfo.Builder;
    [PSCustomObject]$options = $syntax.TableOptions;
    [string]$lnSnippet = $options.Snippets.Ln;
    [string]$punctuationSnippet = $options.Snippets.Punct;
    [string]$duplicateSeparator = '.............';

    if ($violations -and ($violations.Count -gt 0)) {
      foreach ($duplicate in $violations) {
        [string]$duplicateParamSetStmt = $syntax.DuplicateParamSetStmt(
          $duplicate.First, $duplicate.Second
        );
        $null = $builder.Append($duplicateParamSetStmt);

        [string]$firstParamSetStmt = $syntax.ParamSetStmt($verifyInfo.CommandInfo, $duplicate.First);
        [string]$secondParamSetStmt = $syntax.ParamSetStmt($verifyInfo.CommandInfo, $duplicate.Second);

        [string]$firstSyntax = $syntax.SyntaxStmt($duplicate.First);
        [string]$secondSyntax = $syntax.SyntaxStmt($duplicate.Second);

        $null = $builder.Append($(
            "$($lnSnippet)" +
            "$($firstParamSetStmt)$($lnSnippet)$($firstSyntax)$($lnSnippet)" +
            "$($lnSnippet)" +
            "$($secondParamSetStmt)$($lnSnippet)$($secondSyntax)$($lnSnippet)" +
            "$($punctuationSnippet)$($duplicateSeparator)$($lnSnippet)"
          ));

        $verifyInfo.CommandInfo | Show-ParameterSetInfo `
          -Sets @($duplicate.First.Name) -Builder $builder `
          -Title "FIRST ('$($duplicate.First.Name)') Parameter Set Report";
      }
    }
  }
} # MustContainUniqueSetOfParams

class MustContainUniquePositions : ParameterSetRule {
  MustContainUniquePositions([string]$name):base($name) {
    $this.Short = 'Unique Positions';
    $this.Description =
    'A parameter set that contains multiple positional parameters must define unique positions for each parameter. No two positional parameters can specify the same position.';
  }

  [PSCustomObject] Violation([PSCustomObject]$verifyInfo) {

    [PSCustomObject[]]$duplicates = find-DuplicateParamPositions -CommandInfo $verifyInfo.CommandInfo `
      -Syntax $verifyInfo.Syntax;

    [PSCustomObject]$vo = if ($duplicates -and $duplicates.Count -gt 0) {

      [string[]]$reasons = $duplicates | ForEach-Object { $("{$($_.ParamSet.Name) => $($_.Params -join ', ')}"); }
      [PSCustomObject]@{
        Rule       = $this.RuleName;
        Violations = $duplicates;
        Reasons    = $reasons;
      }
    }
    else {
      $null;
    }

    return $vo;
  }

  [void] ViolationStmt ([PSCustomObject[]]$violations, [PSCustomObject]$verifyInfo) {
    [object]$syntax = $verifyInfo.Syntax;
    [System.Text.StringBuilder]$builder = $verifyInfo.Builder;
    [PSCustomObject]$options = $syntax.TableOptions;
    [string]$lnSnippet = $options.Snippets.Ln;
    [string]$punctuationSnippet = $options.Snippets.Punct;
    [string]$duplicateSeparator = '.............';

    if ($violations -and ($violations.Count -gt 0)) {
      $null = $builder.Append("$($lnSnippet)");

      foreach ($duplicate in $violations) {
        [string]$duplicateParamPositionsStmt = $(
          "DUPLICATED POSITIONS: $($duplicate.ParamSet.Name), Params: [$($duplicate.Params -join ', ')]" +
          "$($lnSnippet)"
        );
        $null = $builder.Append($duplicateParamPositionsStmt);

        # [string]$firstParamSetStmt = $syntax.ParamSetStmt($verifyInfo.CommandInfo, $duplicate.First);
        # [string]$secondParamSetStmt = $syntax.ParamSetStmt($verifyInfo.CommandInfo, $duplicate.Second);

        # [string]$firstSyntax = $syntax.SyntaxStmt($duplicate.First);
        # [string]$secondSyntax = $syntax.SyntaxStmt($duplicate.Second);

        # $null = $builder.Append($(
        #     "$($lnSnippet)" +
        #     "$($firstParamSetStmt)$($lnSnippet)$($firstSyntax)$($lnSnippet)" +
        #     "$($lnSnippet)" +
        #     "$($secondParamSetStmt)$($lnSnippet)$($secondSyntax)$($lnSnippet)" +
        #     "$($punctuationSnippet)$($duplicateSeparator)$($lnSnippet)"
        #   ));

        # $verifyInfo.CommandInfo | Show-ParameterSetInfo `
        #   -Sets @($duplicate.First.Name) -Builder $builder `
        #   -Title "FIRST ('$($duplicate.First.Name)') Parameter Set Report";
      }
      $null = $builder.Append("$($lnSnippet)");
    }
  }
} # MustContainUniquePositions

class MustNotHaveMultiplePipelineParams : ParameterSetRule {
  MustNotHaveMultiplePipelineParams([string]$name):base($name) {
    $this.Short = 'Single Pipeline Param';
    $this.Description =
    'Only one parameter in a set can declare the ValueFromPipeline keyword with a value of true.';
  }

  [PSCustomObject] Violation([PSCustomObject]$verifyInfo) {

    return $null;
  }

  [void] ViolationStmt ([PSCustomObject[]]$violations, [PSCustomObject]$verifyInfo) {
    # [object]$syntax = $verifyInfo.Syntax;
    # [System.Text.StringBuilder]$builder = $verifyInfo.Builder;
    # [PSCustomObject]$options = $syntax.TableOptions;
    # [string]$lnSnippet = $options.Snippets.Ln;
    # [string]$punctuationSnippet = $options.Snippets.Punct;

    if ($violations -and ($violations.Count -gt 0)) {
      foreach ($duplicate in $violations) {

      }
    }
  }
} # MustNotHaveMultiplePipelineParams

#
# We could introduce another ParameterSet agnostic rule (ACCIDENTAL-ALL-SETS) that check that if a
# parameter contains a Parameter def without a ParameterSet definition, then it
# it also should not contain other Parameter defs that do have a ParameterSet,
# because in effect, it disables them.
# eg it should detect this scenario:
#
# [Parameter()]
# [Parameter(ParameterSetName = 'InAllSetsByAccident', Position = 777)]
# [object]$Bad
#
# Key                 Value
# ---                 -----
# InAllSetsByAccident System.Management.Automation.ParameterSetMetadata
# __AllParameterSets  System.Management.Automation.ParameterSetMetadata
#
# That is a deceptive erroneous definition
#
# defining [Parameter()], puts the parameter into '__AllParameterSets'
#

class Rules {
  static [string]$RuleNames = @('UNIQUE-PARAM-SET', 'UNIQUE-POSITIONS', 'SINGLE-PIPELINE-PARAM');

  [string]$CommandName;
  [System.Management.Automation.CommandInfo]$CommandInfo;
  [hashtable]$Rules;

  Rules([System.Management.Automation.CommandInfo]$commandInfo) {
    $this.CommandName = $commandInfo.Name;
    $this.CommandInfo = $commandInfo;

    $this.Rules = @{
      'UNIQUE-PARAM-SET'      = [MustContainUniqueSetOfParams]::new('UNIQUE-PARAM-SET');
      'UNIQUE-POSITIONS'      = [MustContainUniquePositions]::new('UNIQUE-POSITIONS');
      'SINGLE-PIPELINE-PARAM' = [MustNotHaveMultiplePipelineParams]::new('SINGLE-PIPELINE-PARAM');
    }
  }

  [void] ViolationSummaryStmt ([hashtable]$violationsByRule, [PSCustomObject]$verifyInfo) {
    # We should compose a summary statement, that shows how many violations occurred
    # across the different rules.
    #
    [object]$syntax = $verifyInfo.Syntax;
    [System.Text.StringBuilder]$builder = $verifyInfo.Builder;
    [PSCustomObject]$options = $syntax.TableOptions;
    [string]$lnSnippet = $options.Snippets.Ln;

    $null = $builder.Append(
      "$($lnSnippet)$($global:LoopzUI.EqualsLine)" +
      "$($lnSnippet)>>> SUMMARY" +
      "$($lnSnippet)$($global:LoopzUI.EqualsLine)" +
      "$($lnSnippet)"
    );
  }

  [void] ReportAll ([PSCustomObject]$verifyInfo) {
    [hashtable]$violationsByRule = @{};
    [object]$syntax = $verifyInfo.Syntax;
    [System.Text.StringBuilder]$builder = $verifyInfo.Builder;
    [PSCustomObject]$options = $syntax.TableOptions;
    [string]$lnSnippet = $options.Snippets.Ln;
    [string]$resetSnippet = $options.Snippets.Reset;
    [string]$headingSnippet = $options.Snippets.Heading;
    [string]$headingULSnippet = $options.Snippets.HeadingUL;

    $this.Rules.Keys | Sort-Object | ForEach-Object {
      [string]$ruleNameKey = $_;
      [ParameterSetRule]$rule = $this.Rules[$ruleNameKey];

      [PSCustomObject[]]$vo = $rule.Violations($verifyInfo);
      [PSCustomObject[]]$vs = $vo.Violations;
      if ($vs -and ($vs.Count -gt 0)) {

        # Show the rule violation title
        #
        [string]$indentation = [string]::new(' ', $options.Chrome.Indent * 2);
        [string]$underline = [string]::new($options.Chrome.Underline, $($rule.Short.Length));
        [string]$ruleTitle = $(
          "$($lnSnippet)" +
          "$($indentation)$($headingSnippet)$($rule.Short)$($resetSnippet)" +
          "$($lnSnippet)" +
          "$($indentation)$($resetSnippet)$($headingULSnippet)$($underline)$($resetSnippet)" +
          "$($lnSnippet)$($lnSnippet)"
        );
        $null = $builder.Append($ruleTitle);

        # Show the violations for this rule
        #
        $violationsByRule[$ruleNameKey] = $vs;
        $rule.ViolationStmt($vs, $verifyInfo);
      }
    }

    $this.ViolationSummaryStmt($violationsByRule, $verifyInfo);
  }

  [PSCustomObject[]] VerifyAll ([PSCustomObject]$verifyInfo) {
    [PSCustomObject[]]$violations = @();

    $this.Rules.GetEnumerator() | ForEach-Object {
      [ParameterSetRule]$rule = $_.Value;

      $violations += $rule.Violations($verifyInfo);
    }

    return $violations;
  }

  [boolean] Test([object]$syntax) {
    [PSCustomObject]$verifyInfo = [PSCustomObject]@{
      CommandInfo = $this.CommandInfo;
      Syntax      = $syntax;
    }

    [PSCustomObject[]]$violations = $this.VerifyAll($verifyInfo);
    return (-not($violations) -or ($violations.Count -eq 0));
  }
} # Rules

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
} # Informer
