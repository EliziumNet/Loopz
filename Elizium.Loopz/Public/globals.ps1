
$global:LoopzHelpers = @{
  # Helper Script Blocks
  #
  WhItemDecoratorBlock = [scriptblock] {
    param(
      [Parameter(Mandatory)]
      $_underscore,

      [Parameter(Mandatory)]
      [int]$_index,

      [Parameter(Mandatory)]
      [System.Collections.Hashtable]$_passThru,

      [Parameter(Mandatory)]
      [boolean]$_trigger
    )

    return Write-HostFeItemDecorator -Underscore $_underscore `
      -Index $_index `
      -PassThru $_passThru `
      -Trigger $_trigger
  } # WhItemDecoratorBlock

  DefaultHeaderBlock   = [scriptblock] {
    param(
      [System.Collections.Hashtable]$PassThru = @{}
    )

    show-DefaultHeaderBlock -PassThru $PassThru;
  } # SimpleHeaderBlock

  SimpleSummaryBlock   = [scriptblock] {
    param(
      [int]$Count,
      [int]$Skipped,
      [boolean]$Triggered,
      [System.Collections.Hashtable]$PassThru = @{}
    )

    show-SimpleSummaryBlock -Count $Count -Skipped $Skipped -Triggered $Triggered -PassThru $PassThru;
  } # SimpleSummaryBlock
}

# Session UI state
#
[int]$global:_LineLength = 121;
[int]$global:_SmallLineLength = 81;
#
$global:LoopzUI = [ordered]@{
  # Line definitions:
  #
  UnderscoreLine      = ([string]::new("_", $_LineLength));
  EqualsLine          = ([string]::new("=", $_LineLength));
  DotsLine            = ([string]::new(".", $_LineLength));
  DashLine            = ([string]::new("-", $_LineLength));
  LightDotsLine       = (([string]::new(".", (($_LineLength - 1) / 2))).Replace(".", ". ") + ".");
  LightDashLine       = (([string]::new("-", (($_LineLength - 1) / 2))).Replace("-", "- ") + "-");
  TildeLine           = ([string]::new("~", $_LineLength));

  SmallUnderscoreLine = ([string]::new("_", $_SmallLineLength));
  SmallEqualsLine     = ([string]::new("=", $_SmallLineLength));
  SmallDotsLine       = ([string]::new(".", $_SmallLineLength));
  SmallDashLine       = ([string]::new("-", $_SmallLineLength));
  SmallLightDotsLine  = (([string]::new(".", (($_SmallLineLength - 1) / 2))).Replace(".", ". ") + ".");
  SmallLightDashLine  = (([string]::new("-", (($_SmallLineLength - 1) / 2))).Replace("-", "- ") + "-");
  SmallTildeLine      = ([string]::new("~", $_SmallLineLength));
}

$global:Loopz = [PSCustomObject]@{
  InlineCodeToOption    = [System.Collections.Hashtable]@{
    'm' = 'Multiline';
    'i' = 'IgnoreCase';
    'x' = 'IgnorePatternWhitespace';
    's' = 'Singleline';
    'n' = 'ExplicitCapture';
  }

  FsItemTypePlaceholder = '*{_fileSystemItemType}';

  SignalLabel           = 0;
  SignalEmoji           = 1;

  MissingSignal         = @{
    'windows' = @('???', '🔻');
    'linux'   = @('???', '🔴');
    'mac'     = @('???', '🔺');
  }

  # TODO:
  # - See 
  #   * https://devblogs.microsoft.com/commandline/windows-command-line-unicode-and-utf-8-output-text-buffer/
  #   * https://stackoverflow.com/questions/49476326/displaying-unicode-in-powershell
  #
  DefaultSignals        = [ordered]@{
    # Operations
    #
    'CUT-A'        = @('Cut', '✂️')
    'CUT-B'        = @('Cut', '🔪')
    'COPY-A'       = @('Copy', '🍒')
    'COPY-B'       = @('Copy', '🥒')
    'MOVE-A'       = @('Move', '🍺')
    'MOVE-B'       = @('Move', '🍻')
    'PASTE-A'      = @('Paste', '🌶️')
    'PASTE-B'      = @('Paste', '🥜')
    'OVERWRITE-A'  = @('Overwrite', '♻️')
    'OVERWRITE-B'  = @('Overwrite', '❗')

    # Thingies
    #
    'DIRECTORY-A'  = @('Directory', '📁')
    'DIRECTORY-B'  = @('Directory', '🗂️')
    'FILE-A'       = @('File', '🏷️')
    'FILE-B'       = @('File', '📝')
    'PATTERN'      = @('Pattern', '🔍')
    'WITH'         = @('With', '🍑')
    'CRUMB-A'      = @('Crumb', '🎯')
    'CRUMB-B'      = @('Crumb', '🧿')
    'CRUMB-C'      = @('Crumb', '💎')
    'SUMMARY-A'    = @('Summary', '🔆')
    'SUMMARY-B'    = @('Summary', '✨')
    'MESSAGE'      = @('Message', '🗯️')

    # Media
    #
    'AUDIO'        = @('Audio', '🎶')
    'TEXT'         = @('Text', '🆎')
    'DOCUMENT'     = @('Document', '📜')
    'IMAGE'        = @('Image', '🖼️')
    'MOVIE'        = @('Movie', '🎬')

    # Indicators
    #
    'WHAT-IF'      = @('WhatIf', '☑️')
    'WARNING-A'    = @('Warning', '⚠️')
    'WARNING-B'    = @('Warning', '👻')
    'SWITCH-ON'    = @('On', '✔️')
    'SWITCH-OFF'   = @('Off', '❌')
    'OK-A'         = @('🆗', '🚀')
    'OK-B'         = @('🆗', '🌟')
    'BAD-A'        = @('Bad', '💥')
    'BAD-B'        = @('Bad', '💢')
    'PROHIBITED'   = @('Prohibited', '🚫')
    'INCLUDE'      = @('Include', '💠')
    'SOURCE'       = @('Source', '🎀')
    'DESTINATION'  = @('Destination', '☀️')
    'TRIM'         = @('Trim', '🌊')
    'MULTI-SPACES' = @('Spaces', '❄️')

    # Outcomes
    #
    'FAILED-A'     = @('Failed', '☢️')
    'FAILED-B'     = @('Failed', '💩')
    'SKIPPED-A'    = @('Skipped', '💤')
    'SKIPPED-B'    = @('Skipped', '👾')
    'ABORTED-A'    = @('Aborted', '✖️')
    'ABORTED-B'    = @('Aborted', '👽')
    'CLASH'        = @('Clash', '📛')
    'NOT-ACTIONED' = @('Not Actioned', '⛔')

    # Command Specific
    #
    'REMY.ANCHOR'  = @('Anchor', '⚓')
    'REMY.POST'    = @('Post Process', '🌈')
  }

  OverrideSignals       = @{ # Label, Emoji
    'windows' = @{
      # defaults based on windows, so there should be no need for overrides
    };

    'linux'   = @{
      # tbd
    };

    'mac'     = @{
      # tbd
    };
  }

  # DefaultSignals resolved into Signals by Initialize-Signals
  #
  Signals               = $null;

  # User defined signals, should be populated by profile
  #
  CustomSignals         = $null;

  Defaults              = [PSCustomObject]@{
    Remy = [PSCustomObject]@{
      Title          = 'Rename'
      ItemMessage    = 'Rename Item'
      SummaryMessage = 'Rename Summary'
    }
  }

  Rules                 = [PSCustomObject]@{
    Remy = [PSCustomObject]@{
      Trim   = @{
        'IsApplicable' = [scriptblock] {
          param([string]$_Input)
          $($_Input.StartsWith(' ') -or $_Input.EndsWith(' '));
        };

        'Transform'    = [scriptblock] {
          param([string]$_Input)
          $_Input.Trim();
        };
        'Signal'       = 'TRIM'
      }

      Spaces = @{
        'IsApplicable' = [scriptblock] {
          param([string]$_Input)
          $_Input -match "\s{2,}";
        };

        'Transform'    = [scriptblock] {
          param([string]$_Input)
          $_Input -replace "\s{2,}", ' '
        };
        'Signal'       = 'MULTI-SPACES'
      }
    }
  }
}
