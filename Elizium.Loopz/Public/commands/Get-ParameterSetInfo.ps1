
function Get-ParameterSetInfo {
  # <= Get-NewCommandDetail
  #  by KirkMunro (https://github.com/PowerShell/PowerShell/issues/8692)
  #
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string[]]$Name
  )

  begin {
    [array]$commonParamSet = @('Verbose', 'Debug', 'ErrorAction', 'WarningAction',
      'InformationAction', 'VerboseAction', 'DebugAction', 'ProgressAction',
      'ErrorVariable', 'WarningVariable', 'InformationVariable', 'DebugVariable',
      'VerboseVariable', 'ProgressVariable', 'OutVariable', 'OutBuffer',
      'PipelineVariable', 'WhatIf', 'Confirm');

    [Krayon]$krayon = Get-Krayon
    [hashtable]$theme = $krayon.Theme;

    # This scheme is specific to Get-ParameterSetInfo
    #
    [hashtable]$parSetScheme = @{
      'COLS.PUNCTUATION'    = $theme['META-COLOURS'];
      'COLS.HEADER'         = 'blue';
      'COLS.UNDERLINE'      = $theme['META-COLOURS'];
      #
      'COLS.CELL'           = 'gray';
      'COLS.TYPE'           = 'darkCyan';
      'COLS.MAN-PARAM'      = $theme['AFFIRM-COLOURS'];
      'COLS.OPT-PARAM'      = $theme['VALUE-COLOURS'];
      'COLS.CMD-NAME'       = 'green';
      'COLS.PARAM-SET-NAME' = 'darkGreen';
      'COLS.SWITCH'         = 'magenta';
    }
    #
    [string]$api = $krayon.ApiFormat;
    [string]$punctSnippet = $($api -f $parSetScheme['COLS.PUNCTUATION']);
    [string]$typeSnippet = $($api -f $parSetScheme['COLS.TYPE']);
    [string]$manSnippet = $($api -f $parSetScheme['COLS.MAN-PARAM']);
    [string]$optSnippet = $($api -f $parSetScheme['COLS.OPT-PARAM']);
    [string]$switchSnippet = $($api -f $parSetScheme['COLS.SWITCH']);
    [string]$defaultSnippet = $($api -f $parSetScheme['COLS.CELL']);
    [string]$paramSetNameSnippet = $($api -f $parSetScheme['COLS.PARAM-SET-NAME']);
    [string]$commandSnippet = $($api -f $parSetScheme['COLS.CMD-NAME']);
    [string]$resetSnippet = $($api -f 'Reset');
    #
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

    # NB: These Format variables are used as the replacement text in regex replace operations
    # which means they can't be defined with interpolated strings; named capture group
    # references would not be evaluated.
    #
    [string]$typeSegmentFormat = $punctSnippet + '<' + $typeSnippet + '${type}' + $punctSnippet + '>';
    [string]$mandatoryFormat = $manSnippet + '-${name} ' + $punctSnippet + $typeSegmentFormat;
    [string]$optionalFormat = $punctSnippet + '[' + $optSnippet + '-${name} ' + $typeSegmentFormat + $punctSnippet + ']';
    [string]$switchFormat = $punctSnippet + '[' + $switchSnippet + '-${name}' + $punctSnippet + ']';

    [PSCustomObject]$tableOptions = [PSCustomObject]@{
      Select  = @('Name', 'Type', 'Mandatory', 'Pos', 'PipeValue', 'Alias');

      Chrome  = [PSCustomObject]@{
        Indent    = 3;
        Underline = '-';
        Inter     = 1;
      }

      Colours = [PSCustomObject]@{
        Header    = 'blue';
        Cell      = 'white';
        Underline = 'yellow';
        HiLight   = 'green';
      }

      Values  = [PSCustomObject]@{
        True  = '✔️';
        False = '✖️';
      }

      Align   = @{
        Header = 'right';
        Cell   = 'left';
      }

      Custom  = [PSCustomObject]@{
        Colours          = [PSCustomObject]@{
          Mandatory = $parSetScheme['COLS.MAN-PARAM'];
          Switch    = $parSetScheme['COLS.SWITCH'];
        }
        Snippets         = [PSCustomObject]@{
          Header    = $($api -f $parSetScheme['COLS.HEADER']);
          Underline = $($api -f $parSetScheme['COLS.UNDERLINE']);
          Mandatory = $($api -f $parSetScheme['COLS.MAN-PARAM']);
          Switch    = $($api -f $parSetScheme['COLS.SWITCH']);
          Cell      = $($api -f $parSetScheme['COLS.OPT-PARAM']);
          Type      = $($api -f $parSetScheme['COLS.TYPE']);
        }
        ParameterSetInfo = $null;
      }
    }
  }

  process {
    if ($_ -isNot [System.Management.Automation.CommandInfo]) {
      Get-Command -Name $_ | Get-ParameterSetInfo
    }
    else {
      # Since we're inside a process block $_ refers to a CommandInfo (the result of get-command) and
      # one property is ParameterSets.
      #
      foreach ($parameterSet in $_.ParameterSets) {

        $parametersToShow = $parameterSet.Parameters | Where-Object Name -NotIn $commonParamSet;
        $parameterGroups = $parametersToShow.where( { $_.Position -ge 0 }, 'split');
        $parameterGroups[0] = @($parameterGroups[0] | Sort-Object -Property Position);
        $parametersToShow = $parameterGroups[0] + $parameterGroups[1];

        [PSCustomObject[]]$resultSet = ($parametersToShow `
          | Select-Object -Property @( # this is a query statement
            'Name'
            @{Name = 'Type'; Expression = { $_.ParameterType.Name }; }
            @{Name = 'Mandatory'; Expression = { $_.IsMandatory } }
            @{Name = 'Pos'; Expression = { if ($_.Position -eq [int]::MinValue) { 'named' } else { $_.Position } } }
            @{Name = 'PipeValue'; Expression = { $_.ValueFromPipeline } }
            @{Name = 'PipeName'; Expression = { $_.ValueFromPipelineByPropertyName } }
            @{Name = 'Alias'; Expression = { $_.Aliases -join ',' } }
          ));

        [hashtable]$fieldMetaData = Get-FieldMetaData -Data $resultSet;
        $tableOptions.Custom.ParameterSetInfo = $parameterSet;

        [hashtable]$headers, [hashtable]$tableContent = Get-AsTable -MetaData $fieldMetaData `
          -TableData $resultSet -Options $tableOptions;

        [string]$defaultLabel = ($_.DefaultParameterSet -eq $ParameterSet.Name) ? " (Default)" : [string]::Empty;
        [string]$structuredParameterSetStmt = `
          "$resetSnippet===> Parameter Set: '$paramSetNameSnippet$($ParameterSet.Name)$resetSnippet'$defaultLabel";
        [string]$structuredSyntax = "Syntax: $commandSnippet$($_.Name) $parameterSet";

        #
        # the syntax can be processed by regex: (gcm command -syntax) -replace '\]? \[*(?=-|<C)',"`r`n "

        $structuredSyntax = $optionalParamExpr.Replace($structuredSyntax, $optionalFormat);
        $structuredSyntax = $mandatoryParamExpr.Replace($structuredSyntax, $mandatoryFormat);
        $structuredSyntax = $switchExpr.Replace($structuredSyntax, $switchFormat);
        $structuredSyntax = $structuredSyntax.Replace('[<CommonParameters>]',
          "$punctSnippet[<$($defaultSnippet)CommonParameters$punctSnippet>]")

        $krayon.Ln().End();
        $krayon.ScribbleLn($structuredParameterSetStmt).End();
        $krayon.ScribbleLn($structuredSyntax).End();
        $krayon.Ln().End();

        [scriptblock]$renderParSetCell = {
          [OutputType([boolean])]
          param(
            [string]$column,
            [string]$value,
            [PSCustomObject]$Options,
            [Krayon]$Krayon
          )
          [boolean]$result = $true;
          # https://github.com/EliziumNet/Krayola/issues/41
          # (Krayon.Scribble does not render a vanilla string)
          #
          switch -Regex ($column) {
            'Name' {
              [System.Management.Automation.CommandParameterInfo]$parameterInfo = `
                $Options.Custom.ParameterSetInfo.Parameters | Where-Object Name -eq $value.Trim();
              [string]$parameterType = $parameterInfo.ParameterType;

              if ($parameterInfo.IsMandatory) {
                $krayon.Scribble("$($Options.Custom.Snippets.Mandatory)$value").End();
              }
              elseif ($parameterType -eq 'switch') {
                $krayon.Scribble("$($Options.Custom.Snippets.Switch)$value").End();
              }
              else {
                $krayon.Scribble("$($Options.Custom.Snippets.Cell)$value").End();
              }
            }

            'Type' {
              $krayon.Scribble("$($Options.Custom.Snippets.Type)$value").End();              
            }

            'Mandatory|PipeValue' {
              [string]$coreValue = $value.Trim() -eq 'True' ? $Options.Values.True : $Options.Values.False;
              [string]$padded = Get-PaddedLabel -Label $coreValue -Width $value.Length -Align $Options.Align.Cell;
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
        } # renderParSetCell

        Show-AsTable -MetaData $fieldMetaData -Headers $headers -Table $tableContent `
          -Krayon $krayon -Options $tableOptions -Render $renderParSetCell;
      }
      $krayon.Ln().End();
    }
  }
}
