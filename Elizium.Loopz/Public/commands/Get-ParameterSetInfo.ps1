
function Get-ParameterSetInfo { # <= Get-NewCommandDetail
  #  by KirkMunro (https://github.com/PowerShell/PowerShell/issues/8692)
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string[]]$Name
  )
  process {
    if ($_ -isnot [System.Management.Automation.CommandInfo]) {
      Get-Command -Name $_ | Get-ParameterSetInfo
    }
    else {
      [scriptblock]$evaluate = { # this is getting a bit long, we need to store this elsewhere
        [OutputType([string])]
        param(
          [string]$value,
          [PSCustomObject]$columnData,
          [boolean]$isHeader,
          [PSCustomObject]$Options
        )
        # If the client wants to use this default, the meta data must
        # contain an int Max field denoting the max value size.
        #
        $max = $columnData.Max;

        [string]$align = $isHeader ? $Options.HeaderAlign : $Options.ValueAlign;
        return $(Get-PaddedLabel -Label $value -Width $max -Align $align);
      }

      [array]$commonParamSet = @('Verbose', 'Debug', 'ErrorAction', 'WarningAction',
        'InformationAction', 'VerboseAction', 'DebugAction', 'ProgressAction',
        'ErrorVariable', 'WarningVariable', 'InformationVariable', 'DebugVariable',
        'VerboseVariable', 'ProgressVariable', 'OutVariable', 'OutBuffer',
        'PipelineVariable', 'WhatIf', 'Confirm');

      [Krayon]$krayon = Get-Krayon
      [hashtable]$theme = $krayon.Theme;
      [hashtable]$scheme = @{
        'PUNCTUATION'    = $theme['META-COLOURS'];
        'TYPE-COL'       = 'darkCyan';
        'MAN-PARAM'      = $theme['AFFIRM-COLOURS'];
        'OPT-PARAM'      = $theme['VALUE-COLOURS'];
        'COMMAND-NAME'   = 'green';
        'PARAM-SET-NAME' = 'darkGreen';
        'TABLE-COLS'     = $theme['KEY-COLOURS'];
        'TABLE-DEF-VAL'  = 'gray';
        'SWITCH-COL'     = 'magenta';
      }
      [string]$api = $krayon.ApiFormat;
      #
      [string]$manParamCol = $scheme['MAN-PARAM'];
      [string]$optParamCol = $scheme['OPT-PARAM'];
      [string]$punctCol = $scheme['PUNCTUATION'];
      [string]$typeCol = $scheme['TYPE-COL'];
      [string]$defaultCol = $scheme['TABLE-DEF-VAL'];
      [string]$switchCol = $scheme['SWITCH-COL'];
      [string]$paramSetNameCol = $scheme['PARAM-SET-NAME'];
      [string]$commandCol = $scheme['COMMAND-NAME'];
      #
      # TODO: These segments should be populated onto the options object
      # Perhaps on a sub-object just for segments => Snippets
      #
      [string]$punctSegment = $($api -f $punctCol);
      [string]$typeSegment = $($api -f $typeCol);
      [string]$manSegment = $($api -f $manParamCol);
      [string]$switchSegment = $($api -f $switchCol);
      [string]$defaultSegment = $($api -f $defaultCol);
      [string]$paramSetNameSegment = $($api -f $paramSetNameCol);
      [string]$commandSegment = $($api -f $commandCol);
      #
      [string]$resetSegment = $($api -f 'Reset');

      [string]$parameterNamePattern = "\-(?<name>\w+)";
      [string]$typePattern = "\<(?<type>\w+)\>";
      [string]$mandatoryPattern = "$parameterNamePattern\s$typePattern";

      [string]$paramWithInsideTypePattern = "\[$parameterNamePattern\s$typePattern\]";
      [string]$paramWithExternalTypePattern = "\[$parameterNamePattern\]\s$typePattern";
      [string]$optionalTypedParamPattern = "$paramWithInsideTypePattern|$paramWithExternalTypePattern"
      #
      [regex]$mandatoryParamExpr = New-RegularExpression -Expression $mandatoryPattern;
      [regex]$optionalParamExpr = New-RegularExpression -Expression $optionalTypedParamPattern;
      [regex]$switchExpr = New-RegularExpression -Expression $('\[' + $parameterNamePattern + '\]');

      [string]$typeSegmentFormat = $punctSegment + '<' + $typeSegment + '${type}' + $punctSegment + '>';
      #
      [string]$mandatoryFormat = $manSegment + '-${name} ' + $punctSegment + $typeSegmentFormat;
      [string]$optionalFormat = $punctSegment + '[' + '&[' + $optParamCol + ']' + '-${name} ' + $typeSegmentFormat + $punctSegment + ']';
      [string]$switchFormat = $punctSegment + '[' + $switchSegment + '-${name}' + $punctSegment + ']';
    
      # Since we're inside a process block $_ refers to a CommandInfo (the result of get-command) and
      # one property is ParameterSets.
      #
      foreach ($parameterSet in $_.ParameterSets) {

        $parametersToShow = $parameterSet.Parameters | Where-Object Name -NotIn $commonParamSet;
        $parameterGroups = $parametersToShow.where( { $_.Position -ge 0 }, 'split')
        $parameterGroups[0] = @($parameterGroups[0] | Sort-Object -Property Position)
        $parametersToShow = $parameterGroups[0] + $parameterGroups[1]

        # Yup we want this => this needs to be extracted out so it can be reused
        # We can inject info here to provide extra context
        #
        [PSCustomObject[]]$parameterObjects = ($parametersToShow `
          | Select-Object -Property @( # table columns
            'Name'
            @{Name = 'Type'; Expression = { $_.ParameterType.Name }; }
            @{Name = 'Mandatory'; Expression = { $_.IsMandatory } }
            @{Name = 'Pos'; Expression = { if ($_.Position -eq [int]::MinValue) { 'named' } else { $_.Position } } }
            @{Name = 'PipeValue'; Expression = { $_.ValueFromPipeline } }
            @{Name = 'PipeName'; Expression = { $_.ValueFromPipelineByPropertyName } }
            @{Name = 'Alias'; Expression = { $_.Aliases -join ',' } }
          ));

        [hashtable]$fieldMetaData = @{}

        # Just look at the first row, so we can see each field
        #
        foreach ($field in $parameterObjects[0].psobject.properties.name) {
          $fieldMetaData[$field] = @{
            ParamName = $field; # don't call this ParamName => FieldName
            # !array compound statement: => .$field
            # Note, we also add the field name to the collection, because the field name
            # might be larger than any of the field values
            # 
            Max       = Get-LargestLength $($parameterObjects.$field + $field);
            Type      = $parameterObjects[0].$field.GetType();
          }
        }

        [PSCustomObject]$tableOptions = [PSCustomObject]@{
          Indent           = 3;
          Underline        = '-';
          Inter            = 1;
          Select           = @('Name', 'Type', 'Mandatory', 'Pos', 'PipeValue', 'Alias');
          HeaderCol        = 'blue';
          ValueCol         = 'white';
          UnderlineCol     = 'yellow';
          HighlightCol     = 'green';
          TrueValue        = '✔️';
          FalseValue       = '✖️';
          HeaderAlign      = 'right';
          ValueAlign       = 'left';
          # These items are non generic and should only be reference by client side Evaluate script blocks
          #
          MandatoryCol     = 'red';
          SwitchCol        = $switchCol;
          ParameterSetInfo = $parameterSet;
        }

        [hashtable]$headers, [hashtable]$table = `
          Get-AsTable -MetaData $fieldMetaData -TableData $parameterObjects -Options $tableOptions -Evaluate $evaluate;

        [string]$defaultLabel = ($_.DefaultParameterSet -eq $ParameterSet.Name) ? " (Default)" : [string]::Empty;
        [string]$structuredParameterSetStmt = `
          "$resetSegment===> Parameter Set: '$paramSetNameSegment$($ParameterSet.Name)$resetSegment'$defaultLabel";
        [string]$structuredSyntax = "Syntax: $commandSegment$($_.Name) $parameterSet";

        #
        # the syntax can be processed by regex: (gcm command -syntax) -replace '\]? \[*(?=-|<C)',"`r`n "

        $structuredSyntax = $optionalParamExpr.Replace($structuredSyntax, $optionalFormat);
        $structuredSyntax = $mandatoryParamExpr.Replace($structuredSyntax, $mandatoryFormat);
        $structuredSyntax = $switchExpr.Replace($structuredSyntax, $switchFormat);
        $structuredSyntax = $structuredSyntax.Replace('[<CommonParameters>]',
          "$punctSegment[<$($defaultSegment)CommonParameters$punctSegment>]")

        $krayon.Ln().End();
        $krayon.ScribbleLn($structuredParameterSetStmt).End();
        $krayon.ScribbleLn($structuredSyntax).End();
        $krayon.Ln().End();

        [scriptblock]$render = {
          [OutputType([boolean])]
          param(
            [string]$column,
            [string]$value,
            [PSCustomObject]$Options,
            [Krayon]$Krayon
          )
          [boolean]$result = $true;
          [string]$api = $Krayon.ApiFormat;
          # https://github.com/EliziumNet/Krayola/issues/41
          # (Krayon.Scribble does not render a vanilla string)
          #
          switch -Regex ($column) {
            'Name' {
              [System.Management.Automation.CommandParameterInfo]$parameter = `
                $Options.ParameterSetInfo.Parameters | Where-Object Name -eq $value.Trim();
              [string]$parameterType = $parameter.ParameterType;

              if ($parameter.IsMandatory) {
                $krayon.Scribble("$($api -f $Options.MandatoryCol)$value").End();
              }
              elseif ($parameterType -eq 'switch') {
                $krayon.Scribble("$($api -f $Options.SwitchCol)$value").End();
              }
              else {
                $krayon.Scribble("$($api -f $Options.ValueCol)$value").End();
              }
            }

            'Type' {
              $krayon.Scribble("$($api -f 'darkCyan')$value").End();              
            }

            'Mandatory|PipeValue' {
              [string]$coreValue = $value.Trim() -eq 'True' ? $Options.TrueValue : $Options.FalseValue;
              [string]$padded = Get-PaddedLabel -Label $coreValue -Width $value.Length -Align $Options.ValueAlign;
              $krayon.Reset().Text($padded).End();
            }

            default {
              # let's not do anything here and revert to default handling
              #
              $result = $false;
            }
          }
          # https://devblogs.microsoft.com/scripting/use-the-get-command-powershell-cmdlet-to-find-parameter-set-information/
          # https://blogs.msmvps.com/jcoehoorn/blog/2017/10/02/powershell-expandproperty-vs-property/

          return $result;
        } # render

        Show-AsTable -MetaData $fieldMetaData -Headers $headers -Table $table `
          -Scheme $scheme -Krayon $krayon -Options $tableOptions -Render $render;
      }
      $krayon.Ln().End();
    }
  }
}
