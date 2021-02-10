
class Syntax {
  [string]$CommandName;
  [hashtable]$Theme;
  [hashtable]$Signals
  [string]$Api;
  [hashtable]$Scheme;

  [string]$ParamNamePattern = "\-(?<name>\w+)";
  [string]$TypePattern = "\<(?<type>[\w\[\]]+)\>";
  [string]$NegativeTypePattern = "(?!\s+\<[\w\[\]]+\>)";

  [PSCustomObject]$Regex;
  [PSCustomObject]$Snippets;
  [PSCustomObject]$Formats;
  [PSCustomObject]$TableOptions;

  [string[]]$CommonParamSet = @('Verbose', 'Debug', 'ErrorAction', 'WarningAction',
    'InformationAction', 'VerboseAction', 'DebugAction', 'ProgressAction',
    'ErrorVariable', 'WarningVariable', 'InformationVariable', 'DebugVariable',
    'VerboseVariable', 'ProgressVariable', 'OutVariable', 'OutBuffer',
    'PipelineVariable', 'WhatIf', 'Confirm');

  Syntax([string]$commandName, [hashtable]$theme, [hashtable]$signals, [string]$api) {
    function snippets {
      param(
        [string[]]$Items
      )
      [string]$result = [string]::Empty;
      foreach ($i in $Items) {
        $result += $($api -f $i);
      }
      return $result;
    }

    function snippet {
      param(
        [string[]]$Items
      )
      return $api -f $Items;
    }

    $this.CommandName = $commandName;
    $this.Theme = $theme;
    $this.Signals = $signals;
    $this.Api = $api;

    $this.Regex = [PSCustomObject]@{
      Param = [PSCustomObject]@{
        OptionalPos_A   = New-RegularExpression `
          -Expression $("\[\[$($this.ParamNamePattern)\]\s$($this.TypePattern)\]");

        OptionalNamed_B = New-RegularExpression `
          -Expression $("\[$($this.ParamNamePattern)\s$($this.TypePattern)\]");

        ManNamed_C      = New-RegularExpression `
          -Expression $("$($this.ParamNamePattern)\s$($this.TypePattern)");

        ManPos_D        = New-RegularExpression `
          -Expression $("\[$($this.ParamNamePattern)\]\s$($this.TypePattern)");

        Switch          = New-RegularExpression `
          -Expression $("\[$($this.ParamNamePattern)\]$($this.NegativeTypePattern)");         
      }
    }

    $this.Scheme = @{
      'COLS.PUNCTUATION'    = $theme['META-COLOURS'];
      'COLS.HEADER'         = 'black', 'bgYellow';
      'COLS.UNDERLINE'      = $theme['META-COLOURS'];
      'COLS.CELL'           = 'gray';
      'COLS.TYPE'           = 'darkCyan';
      'COLS.MAN-PARAM'      = $theme['AFFIRM-COLOURS'];
      'COLS.OPT-PARAM'      = 'blue' # $theme['VALUE-COLOURS'];
      'COLS.CMD-NAME'       = 'green';
      'COLS.PARAM-SET-NAME' = 'darkGreen';
      'COLS.SWITCH'         = 'cyan'; # magenta
    }

    $this.Snippets = [PSCustomObject]@{
      Punct        = $(snippets($this.Scheme['COLS.PUNCTUATION']));
      Type         = $(snippets($this.Scheme['COLS.TYPE']));
      Mandatory    = $(snippets($this.Scheme['COLS.MAN-PARAM']));
      Optional     = $(snippets($this.Scheme['COLS.OPT-PARAM']));
      Switch       = $(snippets($this.Scheme['COLS.SWITCH']));
      Default      = $(snippets($this.Scheme['COLS.CELL']));
      ParamSetName = $(snippets($this.Scheme['COLS.PARAM-SET-NAME']));
      Command      = $(snippets($this.Scheme['COLS.CMD-NAME']));
      Reset        = $(snippets('Reset'));
      Space        = $(snippets('Reset')) + ' ';
    }

    $this.Formats = @{
      # NB: The single letter suffix attached to these names (A-D) are important as it reflects
      # the order in which regex replacement must occur. If these replacements are not done in
      # this strict order, then the correct replacements will not occur. This is because some
      # matches are sub-sets of others; eg
      # '-Param <type>' is a substring of '[-Param <type>]' so in the case, the latter replacement
      # must be performed before the former. The order of replacement goes from the most
      # prescriptive to the least.
      #
      OptionalPos_A    = [string]$(
        # [[-Param] <type>] ... optional, positional parameter
        #
        $this.Snippets.Punct + '[[' + $this.Snippets.Optional + '-${name}' + $this.Snippets.Punct + ']' +
        $this.Snippets.Space + '<' + $this.Snippets.Type + '${type}' + $this.Snippets.Punct + '>]' +
        $this.Snippets.Space
      );

      OptionalNamed_B  = [string]$(
        # [-Param <type>] ... optional, non-positional parameter
        #
        $this.Snippets.Punct + '[' + $this.Snippets.Optional + '-${name}' + $this.Snippets.Type +
        $this.Snippets.Space +
        $this.Snippets.Punct + '<' + $this.Snippets.Type + '${type}' + $this.Snippets.Punct + '>]'
      );

      MandatoryNamed_C = [string]$(
        # -Param <type> ... mandatory, non-positional parameter
        # (requires passing with parameter name)
        #
        $this.Snippets.Mandatory + '-${name}' + $this.Snippets.Space + $this.Snippets.Punct +
        '<' + $this.Snippets.Type + '${type}' + $this.Snippets.Punct + '>'
      );

      MandatoryPos_D   = [string]$(
        # [-Param] <type> ... mandatory, positional parameter
        # (using the parameter name is optional, if passed in the right position among other
        # arguments passed positionally)
        #
        $this.Snippets.Punct + '[' + $this.Snippets.Mandatory + '-${name}' + $this.Snippets.Punct + ']' +
        $this.Snippets.Space +
        $this.Snippets.Punct + '<' + $this.Snippets.Type + '${type}' + $this.Snippets.Punct + '>'
      );

      # We need to use a negative look-ahead (?!) and only match if the param is not followed by <type>
      # [-Param]
      #
      OptionalSwitch   = [string]$(
        $this.Snippets.Punct + '[' + $this.Snippets.Switch + '-${name}' + $this.Snippets.Punct + ']'
      );

      # -Param
      # (Initially this might seem counter intuitive, since an Option/Flag is optional, but in the
      # context of a parameter set. An optional can be mandatory if the presence of the flag defines
      # that parameter set.)
      #
    }

    $this.TableOptions = [PSCustomObject]@{
      Select   = @('Name', 'Type', 'Mandatory', 'Pos', 'PipeValue', 'Alias');

      Chrome   = [PSCustomObject]@{
        Indent    = 3;
        Underline = '=';
        Inter     = 1;
      }

      Colours  = [PSCustomObject]@{
        Header    = 'blue';
        Cell      = 'white';
        Underline = 'yellow';
        HiLight   = 'green';
      }

      Values   = [PSCustomObject]@{
        True  = $signals['SWITCH-ON'].Value
        False = $signals['SWITCH-OFF'].Value
      }

      Align    = @{
        Header = 'right';
        Cell   = 'left';
      }

      Snippets = [PSCustomObject]@{
        Reset = $(snippets('Reset'));
      }

      Custom   = [PSCustomObject]@{
        Colours          = [PSCustomObject]@{
          Mandatory = $this.Scheme['COLS.MAN-PARAM'];
          Switch    = $this.Scheme['COLS.SWITCH'];
        }
        Snippets         = [PSCustomObject]@{
          Header    = $(snippets($this.Scheme['COLS.HEADER']));
          Underline = $(snippets($this.Scheme['COLS.UNDERLINE']));
          Mandatory = $(snippets($this.Scheme['COLS.MAN-PARAM']));
          Switch    = $(snippets($this.Scheme['COLS.SWITCH']));
          Cell      = $(snippets($this.Scheme['COLS.OPT-PARAM']));
          Type      = $(snippets($this.Scheme['COLS.TYPE']));
          Command   = $(snippets($this.Scheme['COLS.CMD-NAME']));
        }
        ParameterSetInfo = $null;
      }
    }
  } # ctor

  [string] ParamSetStmt(
    [System.Management.Automation.CommandInfo]$commandInfo,
    [System.Management.Automation.CommandParameterSetInfo]$paramSet
  ) {

    [string]$defaultLabel = ($commandInfo.DefaultParameterSet -eq $paramSet.Name) `
      ? " (Default)" : [string]::Empty;

    [string]$structuredParamSetStmt = `
    $(
      "$($this.Snippets.Reset)===> Parameter Set: '" +
      "$($this.Snippets.ParamSetName)$($paramSet.Name)$($this.Snippets.Reset)'" +
      "$defaultLabel"
    );

    return $structuredParamSetStmt;
  }

  [string] SyntaxStmt(
    [System.Management.Automation.CommandParameterSetInfo]$paramSet
  ) {
    #
    # the syntax can be processed by regex: (gcm command -syntax) -replace '\]? \[*(?=-|<C)',"`r`n "
    # this expression is used in the unit tests.

    [string]$source = $paramSet.ToString();
    [string]$structuredSyntax = $(
      "$($this.Snippets.Reset)Syntax: $($this.Snippets.Command)$($this.CommandName) $source"
    );

    $structuredSyntax = $this.Regex.Param.OptionalPos_A.Replace(
      $structuredSyntax, $this.Formats.OptionalPos_A);

    $structuredSyntax = $this.Regex.Param.OptionalNamed_B.Replace(
      $structuredSyntax, $this.Formats.OptionalNamed_B);

    $structuredSyntax = $this.Regex.Param.ManNamed_C.Replace(
      $structuredSyntax, $this.Formats.MandatoryNamed_C);

    $structuredSyntax = $this.Regex.Param.ManPos_D.Replace(
      $structuredSyntax, $this.Formats.MandatoryPos_D);

    $structuredSyntax = $this.Regex.Param.Switch.Replace(
      $structuredSyntax, $this.Formats.OptionalSwitch);

    # We need to process Mandatory switch parameters, which are of the form
    # -Param. However, this pattern is way too generic, so we can't identify
    # by applying a regex on the syntax. Instead, we need to query the parameter
    # set's parameters to find them and colourise them directly.
    #
    [PSCustomObject[]]$resultSet = $($paramSet.Parameters | Where-Object {
        ($_.Name -NotIn $syntax.CommonParamSet) -and
        ($_.IsMandatory) -and ($_.ParameterType.Name -eq 'SwitchParameter')
      });

    if ($resultSet -and ($resultSet.Count -gt 0)) {
      [string[]]$names = $resultSet.Name;

      $names | ForEach-Object {
        $expression = "\-$_";

        $structuredSyntax = $($structuredSyntax -replace $expression, $(
            # -Param
            #
            $this.Snippets.Switch + '-' + $this.Snippets.Mandatory + $_
          ))
      }
    }

    # NB: this is a straight string replace, not regex replace
    #
    $structuredSyntax = $structuredSyntax.Replace('[<CommonParameters>]',
      "$($this.Snippets.Punct)[<$($this.Snippets.Default)CommonParameters$($this.Snippets.Punct)>]"
    );

    return $structuredSyntax;
  }
}
