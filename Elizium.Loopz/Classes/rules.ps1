
class ParameterSetRule {
  [string]$RuleName;
  [string]$Short;
  [string]$Description;

  ParameterSetRule([string]$name) {
    $this.RuleName = $name;
  }

  [PSCustomObject] Query([PSCustomObject]$verifyInfo) {
    throw [System.Management.Automation.MethodInvocationException]::new(
      'Abstract method not implemented (ParameterSetRule.Violations)');
  }

  [void] ViolationStmt([PSCustomObject[]]$pods, [PSCustomObject]$verifyInfo) {
    throw [System.Management.Automation.MethodInvocationException]::new(
      'Abstract method not implemented (ParameterSetRule.ViolationStmt)');
  }
} # ParameterSetRule

class MustContainUniqueSetOfParams : ParameterSetRule {

  MustContainUniqueSetOfParams([string]$name):base($name) {
    $this.Short = 'Non Unique Parameter Set';
    $this.Description =
    'Each parameter set must have at least one unique parameter. If possible, make this parameter a mandatory parameter.';
  }

  [PSCustomObject] Query([PSCustomObject]$verifyInfo) {
    [object]$syntax = $verifyInfo.Syntax;
    [PSCustomObject[]]$pods = find-DuplicateParamSets -CommandInfo $verifyInfo.CommandInfo `
      -Syntax $syntax;

    [string]$paramSetNameSnippet = $syntax.TableOptions.Snippets.ParamSetName;
    [string]$resetSnippet = $syntax.TableOptions.Snippets.Reset;

    [PSCustomObject]$vo = if ($pods -and $pods.Count -gt 0) {

      [string[]]$reasons = $pods | ForEach-Object {
        $(
          "{$($paramSetNameSnippet)$($_.First.Name)$($resetSnippet)/" +
          "$($paramSetNameSnippet)$($_.Second.Name)$($resetSnippet)}"
        );
      }
      [PSCustomObject]@{
        Rule       = $this.RuleName;
        Violations = $pods;
        Reasons    = $reasons;
      }
    }
    else {
      $null;
    }

    return $vo;
  }

  [void] ViolationStmt([PSCustomObject[]]$pods, [PSCustomObject]$verifyInfo) {
    # Each violation reported must have the rule name and the parameter set

    [object]$syntax = $verifyInfo.Syntax;
    [System.Text.StringBuilder]$builder = $verifyInfo.Builder;
    [PSCustomObject]$options = $syntax.TableOptions;
    [string]$lnSnippet = $options.Snippets.Ln;
    [string]$resetSnippet = $options.Snippets.Reset;
    [string]$punctuationSnippet = $options.Snippets.Punct;
    [string]$duplicateSeparator = '.............';

    if ($pods -and ($pods.Count -gt 0)) {
      foreach ($seed in $pods) {
        [string]$duplicateParamSetStmt = $syntax.DuplicateParamSetStmt(
          $seed.First, $seed.Second
        );
        $null = $builder.Append($duplicateParamSetStmt);

        [string]$firstParamSetStmt = $syntax.ParamSetStmt($verifyInfo.CommandInfo, $seed.First);
        [string]$secondParamSetStmt = $syntax.ParamSetStmt($verifyInfo.CommandInfo, $seed.Second);

        [string]$firstSyntax = $syntax.SyntaxStmt($seed.First);
        [string]$secondSyntax = $syntax.SyntaxStmt($seed.Second);

        $null = $builder.Append($(
            "$($lnSnippet)" +
            "$($firstParamSetStmt)$($lnSnippet)$($firstSyntax)$($lnSnippet)" +
            "$($lnSnippet)" +
            "$($secondParamSetStmt)$($lnSnippet)$($secondSyntax)$($lnSnippet)" +
            "$($punctuationSnippet)$($duplicateSeparator)$($lnSnippet)"
          ));

        [string]$subTitle = $syntax.QuotedNameStmt(
          $syntax.TableOptions.Snippets.ParamSetName,
          $seed.First.Name, '('
        );

        $verifyInfo.CommandInfo | Show-ParameterSetInfo `
          -Sets @($seed.First.Name) -Builder $builder `
          -Title $(
          "FIRST $($subTitle)$($resetSnippet) Parameter Set Report"
        );
      }
    }
  }
} # MustContainUniqueSetOfParams

class MustContainUniquePositions : ParameterSetRule {
  MustContainUniquePositions([string]$name):base($name) {
    $this.Short = 'Non Unique Positions';
    $this.Description =
    'A parameter set that contains multiple positional parameters must define unique positions for each parameter. No two positional parameters can specify the same position.';
  }

  [PSCustomObject] Query([PSCustomObject]$verifyInfo) {
    [object]$syntax = $verifyInfo.Syntax;
    [PSCustomObject[]]$pods = find-DuplicateParamPositions -CommandInfo $verifyInfo.CommandInfo `
      -Syntax $syntax;

    [string]$paramSetNameSnippet = $syntax.TableOptions.Snippets.ParamSetName;
    [string]$resetSnippet = $syntax.TableOptions.Snippets.Reset;

    [PSCustomObject]$vo = if ($pods -and $pods.Count -gt 0) {

      [string[]]$reasons = $pods | ForEach-Object {
        [string]$resolvedParamStmt = $syntax.ResolvedParamStmt($_.Params, $_.ParamSet);
        $("{$($paramSetNameSnippet)$($_.ParamSet.Name)$($resetSnippet) => $resolvedParamStmt$($resetSnippet)}");
      }
      [PSCustomObject]@{
        Rule       = $this.RuleName;
        Violations = $pods;
        Reasons    = $reasons;
      }
    }
    else {
      $null;
    }

    return $vo;
  }

  [void] ViolationStmt([PSCustomObject[]]$pods, [PSCustomObject]$verifyInfo) {
    [object]$syntax = $verifyInfo.Syntax;
    [System.Text.StringBuilder]$builder = $verifyInfo.Builder;
    [PSCustomObject]$options = $syntax.TableOptions;
    [string]$lnSnippet = $options.Snippets.Ln;
    if ($pods -and ($pods.Count -gt 0)) {
      foreach ($seed in $pods) {
        [string]$duplicateParamPositionsStmt = $(
          "$($syntax.ParamsDuplicatePosStmt($seed))" +
          "$($lnSnippet)$($lnSnippet)"
        );

        $null = $builder.Append($duplicateParamPositionsStmt);
      }
    }
  }
} # MustContainUniquePositions

class MustNotHaveMultiplePipelineParams : ParameterSetRule {
  MustNotHaveMultiplePipelineParams([string]$name):base($name) {
    $this.Short = 'Multiple Claims to Pipeline item';
    $this.Description =
    'Only one parameter in a set can declare the ValueFromPipeline keyword with a value of true.';
  }

  [PSCustomObject] Query([PSCustomObject]$verifyInfo) {
    [object]$syntax = $verifyInfo.Syntax;
    [PSCustomObject[]]$pods = find-MultipleValueFromPipeline -CommandInfo $verifyInfo.CommandInfo `
      -Syntax $syntax;

    [string]$paramSetNameSnippet = $syntax.TableOptions.Snippets.ParamSetName;
    [string]$resetSnippet = $syntax.TableOptions.Snippets.Reset;

    [PSCustomObject]$vo = if ($pods -and $pods.Count -gt 0) {

      [string[]]$reasons = $pods | ForEach-Object {
        [string]$resolvedParamStmt = $syntax.ResolvedParamStmt($_.Params, $_.ParamSet);
        $(
          "{$($paramSetNameSnippet)$($_.ParamSet.Name)$($resetSnippet) => $resolvedParamStmt$($resetSnippet)}"
        );
      }
      [PSCustomObject]@{
        Rule       = $this.RuleName;
        Violations = $pods;
        Reasons    = $reasons;
      }
    }
    else {
      $null;
    }

    return $vo;
  }

  [void] ViolationStmt([PSCustomObject[]]$pods, [PSCustomObject]$verifyInfo) {
    [object]$syntax = $verifyInfo.Syntax;
    [System.Text.StringBuilder]$builder = $verifyInfo.Builder;
    [PSCustomObject]$options = $syntax.TableOptions;
    [string]$lnSnippet = $options.Snippets.Ln;
    if ($pods -and ($pods.Count -gt 0)) {
      foreach ($seed in $pods) {
        [string]$multipleClaimsStmt = $(
          "$($syntax.MultiplePipelineItemClaimStmt($seed))" +
          "$($lnSnippet)$($lnSnippet)"
        );

        $null = $builder.Append($multipleClaimsStmt);
      }
    }
  }
} # MustNotHaveMultiplePipelineParams

class MustNotBeInAllParameterSetsByAccident : ParameterSetRule {
  MustNotBeInAllParameterSetsByAccident([string]$name):base($name) {
    $this.Short = 'In All Parameter Sets By Accident';
    $this.Description =
    'Defining a parameter with multiple "Parameter Blocks", where some with and some without a parameter set, is invalid.';
  }

  [PSCustomObject] Query([PSCustomObject]$verifyInfo) {
    [object]$syntax = $verifyInfo.Syntax;
    [PSCustomObject[]]$pods = find-InAllParameterSetsByAccident -CommandInfo $verifyInfo.CommandInfo `
      -Syntax $syntax;

    [string]$paramSetNameSnippet = $syntax.TableOptions.Snippets.ParamSetName;
    [string]$resetSnippet = $syntax.TableOptions.Snippets.Reset;
    [string]$commaSnippet = $syntax.TableOptions.Snippets.Comma;

    [PSCustomObject]$vo = if ($pods -and $pods.Count -gt 0) {

      [string[]]$reasons = $pods | ForEach-Object {
        [string[]]$otherParamSetNames = $_.Others | ForEach-Object { "$($paramSetNameSnippet)$($_.Name)" };
        [string]$resolvedParam = $syntax.ResolvedParamStmt(@($_.Param), $_.ParamSet);
        $(
          "{$($resetSnippet)$($resolvedParam)$($resetSnippet) of " +
          "$($paramSetNameSnippet)$($_.ParamSet.Name)" +
          "$($resetSnippet) => $($otherParamSetNames -join $commaSnippet)$($resetSnippet)}"
        );
      }
      [PSCustomObject]@{
        Rule       = $this.RuleName;
        Violations = $pods;
        Reasons    = $reasons;
      }
    }
    else {
      $null;
    }

    return $vo;
  }

  [void] ViolationStmt([PSCustomObject[]]$pods, [PSCustomObject]$verifyInfo) {
    [object]$syntax = $verifyInfo.Syntax;
    [System.Text.StringBuilder]$builder = $verifyInfo.Builder;
    [PSCustomObject]$options = $syntax.TableOptions;
    [string]$lnSnippet = $options.Snippets.Ln;
    if ($pods -and ($pods.Count -gt 0)) {
      foreach ($seed in $pods) {
        [string]$accidentsStmt = $(
          "$($syntax.InAllParameterSetsByAccidentStmt($seed))" +
          "$($lnSnippet)$($lnSnippet)"
        );

        $null = $builder.Append($accidentsStmt);
      }
    }
  }
}

class Rules {
  [string]$CommandName;
  [System.Management.Automation.CommandInfo]$CommandInfo;
  static [hashtable]$Rules = @{
    'UNIQUE-PARAM-SET'      = [MustContainUniqueSetOfParams]::new('UNIQUE-PARAM-SET');
    'UNIQUE-POSITIONS'      = [MustContainUniquePositions]::new('UNIQUE-POSITIONS');
    'SINGLE-PIPELINE-PARAM' = [MustNotHaveMultiplePipelineParams]::new('SINGLE-PIPELINE-PARAM');
    'ACCIDENTAL-ALL-SETS'   = [MustNotBeInAllParameterSetsByAccident]::new('ACCIDENTAL-ALL-SETS');
  }

  Rules([System.Management.Automation.CommandInfo]$commandInfo) {
    $this.CommandName = $commandInfo.Name;
    $this.CommandInfo = $commandInfo;
  }

  [void] ViolationSummaryStmt([hashtable]$violationsByRule, [PSCustomObject]$verifyInfo) {
    # We should compose a summary statement, that shows how many violations occurred
    # across the different rules.
    #
    [object]$syntax = $verifyInfo.Syntax;
    [System.Text.StringBuilder]$builder = $verifyInfo.Builder;
    [PSCustomObject]$options = $syntax.TableOptions;
    [string]$resetSnippet = $options.Snippets.Reset;
    [string]$lnSnippet = $options.Snippets.Ln;
    [string]$punctSnippet = $options.Snippets.Punct;
    [string]$ruleSnippet = $options.Snippets.HeadingUL;
    [string]$indentation = $syntax.Indent(1);
    [string]$doubleIndentation = $syntax.Indent(2);
    [string]$tripleIndentation = $syntax.Indent(3);

    [string]$summaryStmt = if ($violationsByRule.Count -eq 0) {
      "$($options.Snippets.Ok) No violations found.$($lnSnippet)";
    }
    else {
      [int]$total = 0;
      [string]$violationsByRuleStmt = [string]::Empty;

      $violationsByRule.GetEnumerator() | ForEach-Object {
        [PSCustomObject]$vo = $_.Value;
        [PSCustomObject[]]$pods = $vo.Violations;
        $total += $pods.Count;

        [string]$shortName = [Rules]::Rules[$_.Key].Short;
        [string]$quotedShortName = $syntax.QuotedNameStmt($ruleSnippet, $shortName);
        $violationsByRuleStmt += $(
          "$($indentation)$($signals['BULLET-POINT'].Value) " +
          "$($quotedShortName)$($resetSnippet), Count: $($pods.Count)$($lnSnippet)"
        );

        $violationsByRuleStmt += $(
          "$($doubleIndentation)$($punctSnippet)+$($resetSnippet) Reasons: $($lnSnippet)"
        );

        $vo.Reasons | ForEach-Object {
          $violationsByRuleStmt += $(
            "$($tripleIndentation)$($punctSnippet)- $($resetSnippet)$($_)$($lnSnippet)"
          );
        }
      }
      [string]$plural = ($total -eq 1) ? 'violation' : 'violations';
      $violationsByRuleStmt = $(
        "$($options.Snippets.Error) Found the following $($total) $($plural):$($lnSnippet)" +
        "$($resetSnippet)$($violationsByRuleStmt)"
      );

      $violationsByRuleStmt;
    }

    $null = $builder.Append(
      "$($resetSnippet)" +
      "$($lnSnippet)$($global:LoopzUI.EqualsLine)" +
      "$($lnSnippet)>>>>> SUMMARY: $($summaryStmt)$($resetSnippet)" +
      "$($global:LoopzUI.EqualsLine)" +
      "$($lnSnippet)"
    );
  }

  [void] ReportAll([PSCustomObject]$verifyInfo) {
    [hashtable]$violationsByRule = @{};
    [object]$syntax = $verifyInfo.Syntax;
    [System.Text.StringBuilder]$builder = $verifyInfo.Builder;
    [PSCustomObject]$options = $syntax.TableOptions;
    [string]$lnSnippet = $options.Snippets.Ln;
    [string]$resetSnippet = $options.Snippets.Reset;
    [string]$headingSnippet = $options.Snippets.Heading;
    [string]$headingULSnippet = $options.Snippets.HeadingUL;

    [Rules]::Rules.Keys | Sort-Object | ForEach-Object {
      [string]$ruleNameKey = $_;
      [ParameterSetRule]$rule = [Rules]::Rules[$ruleNameKey];

      [PSCustomObject]$vo = $rule.Query($verifyInfo);
      [PSCustomObject[]]$pods = $vo.Violations;
      if ($pods -and ($pods.Count -gt 0)) {
        [string]$description = $verifyInfo.Syntax.Fold(
          $rule.Description, $headingULSnippet, 80, $options.Chrome.Indent * 2
        );

        # Show the rule violation title
        #
        [string]$indentation = [string]::new(' ', $options.Chrome.Indent * 2);
        [string]$underline = [string]::new($options.Chrome.Underline, $($rule.Short.Length));
        [string]$ruleTitle = $(
          "$($lnSnippet)" +
          "$($indentation)$($headingSnippet)$($rule.Short)$($resetSnippet)" +
          "$($lnSnippet)" +
          "$($indentation)$($resetSnippet)$($headingULSnippet)$($underline)$($resetSnippet)" +
          "$($lnSnippet)$($lnSnippet)" +
          "$($resetSnippet)$($description)$($resetSnippet)" +
          "$($lnSnippet)$($lnSnippet)"
        );
        $null = $builder.Append($ruleTitle);

        # Show the violations for this rule
        #
        $violationsByRule[$ruleNameKey] = $vo;
        $rule.ViolationStmt($pods, $verifyInfo);
      }
    }

    $this.ViolationSummaryStmt($violationsByRule, $verifyInfo);
  }

  [PSCustomObject[]] VerifyAll ([PSCustomObject]$verifyInfo) {
    [PSCustomObject[]]$pods = @();

    [Rules]::Rules.GetEnumerator() | ForEach-Object {
      [ParameterSetRule]$rule = $_.Value;

      $pods += $rule.Violations($verifyInfo);
    }

    return $pods;
  }

  [boolean] Test([object]$syntax) {
    [PSCustomObject]$verifyInfo = [PSCustomObject]@{
      CommandInfo = $this.CommandInfo;
      Syntax      = $syntax;
    }

    [PSCustomObject[]]$pods = $this.VerifyAll($verifyInfo);
    return (-not($pods) -or ($pods.Count -eq 0));
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
