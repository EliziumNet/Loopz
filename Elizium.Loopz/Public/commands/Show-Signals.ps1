using module Elizium.Krayola;

function Show-Signals {
  <#
  .NAME
    Show-Signals

  .SYNOPSIS
    Shows all defined signals, including user defined signals.

  .DESCRIPTION
    User can override signal definitions in their profile, typically using the provided
  function Update-CustomSignals.

  .LINK
    https://eliziumnet.github.io/Loopz/

  .PARAMETER SourceSignals
    Hashtable containing signals to be displayed.

  .PARAMETER Registry
    Hashtable containing information concerning commands usage of signals.

  .PARAMETER Include
    Provides a filter. When specified, only the applications included in the list
  will be shown.

  .EXAMPLE 1

  Show-Signals

  Show signal definitions and references for all registered commands

  .EXAMPLE 2

  Show-Signals -Include remy, ships

  Show the signal definitions and references for commands 'remy' and 'ships' only
  #>
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
  param(
    [Parameter()]
    [hashtable]$SourceSignals = $(Get-Signals),

    [Parameter()]
    [hashtable]$Registry = $($Loopz.SignalRegistry),

    [Parameter()]
    [string[]]$Include = @(),

    [Parameter()]
    [switch]$Test
  )

  function get-GraphemeLength {
    param(
      [Parameter(Position = 0)]
      [string]$Value
    )
    [System.Text.StringRuneEnumerator]$enumerator = $Value.EnumerateRunes();
    [int]$count = 0;

    while ($enumerator.MoveNext()) {
      $count++;
    }

    return $count;
  }

  function get-TextElementLength {
    param(
      [Parameter(Position = 0)]
      [string]$Value
    )
    # This function is of no use, but leaving it in for reference, until the
    # issue of bad emoji behaviour has been fixed.
    #
    [System.Globalization.TextElementEnumerator]$enumerator = `
      [System.Globalization.StringInfo]::GetTextElementEnumerator($Value);

    [int]$count = 0;

    while ($enumerator.MoveNext()) {
      $count++;
    }

    return $count;
  }

  [hashtable]$theme = Get-KrayolaTheme;
  [Krayon]$krayon = New-Krayon -Theme $theme;
  [Scribbler]$scribbler = New-Scribbler -Krayon $krayon -Test:$Test.IsPresent;

  if ($Include.Count -eq 0) {
    $Include = $Registry.PSBase.Keys;
  }

  [scriptblock]$renderCell = {
    [OutputType([boolean])]
    param(
      [string]$column,
      [string]$value,
      [PSCustomObject]$row,
      [PSCustomObject]$options,
      [object]$scribbler,
      [int]$counter
    )
    [boolean]$result = $true;
    [boolean]$alternate = ($counter % 2) -eq 1;
    [string]$backSnippet = $alternate `
      ? $options.Custom.Snippets.ResetAlternateBack 
    : $options.Custom.Snippets.ResetDefaultBack;

    switch -Regex ($column) {
      'Name' {
        [string]$nameSnippet = ($row.Length.Trim() -eq '2') `
          ? $options.Custom.Snippets.Standard : $options.Custom.Snippets.Cell;

        $scribbler.Scribble("$($backSnippet)$($nameSnippet)$($value)");
        break;
      }

      'Icon' {
        # This tweak is required because unfortunately, some emojis are ill
        # defined causing misalignment.
        # 
        if ($options.Custom.UsingEmojis) {
          [string]$length = $row.Length.Trim();
          if ($length -eq '1') {
            # Chop off the last character
            #
            $value = $value -replace ".$";
          }
        }
        $scribbler.Scribble("$($backSnippet)$($value)");
        break;
      }

      'Length|GraphLn' {
        $scribbler.Scribble("$($backSnippet)$($value)");
        break;
      }

      'Custom' {
        [string]$padded = Format-BooleanCellValue -Value $value -TableOptions $options;
        $null = $scribbler.Scribble("$($backSnippet)$($padded)$($endOfRowSnippet)");

        break;
      }

      default {
        if ($Registry.ContainsKey($column)) {
          [string]$padded = Format-BooleanCellValue -Value $value -TableOptions $options;
          $null = $scribbler.Scribble("$($backSnippet)$($padded)");
        }
        else {
          $scribbler.Scribble("$($backSnippet)$($value)");
        }
      }
    }

    return $result;
  } # RenderCell

  [string]$resetSnippet = $scribbler.Snippets(@('Reset'));
  [string]$endOfRowSnippet = $resetSnippet;
  [string]$headerSnippet = $scribbler.Snippets(@('white', 'bgDarkBlue'));
  [string]$underlineSnippet = $scribbler.Snippets(@('darkGray'));
  [string]$standardSnippet = $scribbler.Snippets(@('darkGreen'));
  [string]$alternateBackSnippet = $scribbler.Snippets(@('bgDarkGray'));
  [string]$defaultBackSnippet = $scribbler.Snippets(@(
      'bg' + $scribbler.Krayon.getDefaultBack()
    ));

  # Make sure that 'Custom' is always the last column
  #
  [string[]]$columnSelection = @('Name', 'Label', 'Icon', 'Length', 'GraphLn') + $(
    $Registry.PSBase.Keys | Where-Object { $Include -contains $_ } | ForEach-Object { $_; }
  ) + 'Custom';

  [PSCustomObject]$custom = [PSCustomObject]@{
    Snippets    = [PSCustomObject]@{
      Header             = $headerSnippet;
      Underline          = $underlineSnippet;
      Standard           = $standardSnippet;
      ResetAlternateBack = "$($resetSnippet)$($alternateBackSnippet)";
      AlternateBack      = "$($alternateBackSnippet)";
      ResetDefaultBack   = "$($resetSnippet)$($defaultBackSnippet)";
    }
    Colours     = [PSCustomObject]@{
      Title = 'darkYellow';
    }
    UsingEmojis = Test-HostSupportsEmojis;
  }

  [PSCustomObject]$tableOptions = Get-TableDisplayOptions -Select $columnSelection `
    -Signals $SourceSignals -Scribbler $scribbler -Custom $custom;

  [string[]]$customKeys = $Loopz.CustomSignals.PSBase.Keys;
  [PSCustomObject[]]$source = $($SourceSignals.GetEnumerator() | ForEach-Object {
      [string]$signalKey = $_.Key;

      [PSCustomObject]$signalDef = [PSCustomObject]@{
        Name    = $_.Key;
        Label   = $_.Value.Key;
        Icon    = $_.Value.Value;
        Length  = $_.Value.Value.Length;
        GraphLn = $(get-GraphemeLength $_.Value.Value);
        Custom  = $($customKeys -contains $signalKey);
      }

      # Now add onto the signal definition, the dependent registered commands
      #
      $Registry.GetEnumerator() | Foreach-Object {
        [string]$commandAlias = $_.Key;
        [boolean]$isUsedBy = $_.Value -contains $signalKey;
        $signalDef | Add-Member -MemberType NoteProperty -Name $commandAlias -Value $isUsedBy;
      }

      $signalDef;
    });

  # NB: The $_ here is within the context of the Select-Object statement just below
  #
  [array]$selection = @(
    'Name'
    @{Name = 'Label'; Expression = { $_.Label }; }
    @{Name = 'Icon'; Expression = { $_.Icon }; }
    @{Name = 'Length'; Expression = { $_.Length }; }
    @{Name = 'GraphLn'; Expression = { $_.GraphLn }; }
    @{Name = 'Custom'; Expression = { $_.Custom }; }
  );

  $selection += $(foreach ($alias in $Registry.PSBase.Keys) {
      @{Name = $alias; Expression = { $_.$alias }; }
    })

  [PSCustomObject[]]$resultSet = ($source | Select-Object -Property $selection);
  [hashtable]$fieldMetaData = Get-FieldMetaData -Data $resultSet;

  [hashtable]$headers, [hashtable]$tableContent = Get-AsTable -MetaData $fieldMetaData `
    -TableData $source -Options $tableOptions;

  [string]$title = 'Signal definitions and references';
  Show-AsTable -MetaData $fieldMetaData -Headers $headers -Table $tableContent `
    -Scribbler $scribbler -Options $tableOptions -Render $renderCell -Title $title;

  $scribbler.Scribble("$($tableOptions.Snippets.Ln)");

  $scribbler.Flush();
} # Show-Signals
