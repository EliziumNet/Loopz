
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
      [hashtable]$_passThru,

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
      [hashtable]$PassThru = @{}
    )

    show-DefaultHeaderBlock -PassThru $PassThru;
  } # SimpleHeaderBlock

  HeaderBlock          = [scriptblock] {
    param(
      [hashtable]$PassThru = @{},
      [writer]$Writer
    )

    Show-Header -PassThru $PassThru;
  } # HeaderBlock

  SimpleSummaryBlock   = [scriptblock] {
    param(
      [int]$Count,
      [int]$Skipped,
      [boolean]$Triggered,
      [hashtable]$PassThru = @{}
    )

    show-SimpleSummaryBlock -Count $Count -Skipped $Skipped `
      -Triggered $Triggered -PassThru $PassThru;
  } # SimpleSummaryBlock

  SummaryBlock         = [scriptblock] {
    param(
      [int]$Count,
      [int]$Skipped,
      [boolean]$Triggered,
      [hashtable]$PassThru = @{}
    )

    Show-Summary -Count $Count -Skipped $Skipped `
      -Triggered $Triggered -PassThru $PassThru;
  } # SummaryBlock
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
  InlineCodeToOption    = [hashtable]@{
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
    'windows' = (kp(@('???', '🔻')));
    'linux'   = (kp(@('???', '🔴')));
    'mac'     = (kp(@('???', '🔺')));
  }

  # TODO:
  # - See 
  #   * https://devblogs.microsoft.com/commandline/windows-command-line-unicode-and-utf-8-output-text-buffer/
  #   * https://stackoverflow.com/questions/49476326/displaying-unicode-in-powershell
  #
  DefaultSignals        = [ordered]@{
    # Operations
    #
    'CUT-A'        = (kp(@('Cut', '✂️')));
    'CUT-B'        = (kp(@('Cut', '🔪')));
    'COPY-A'       = (kp(@('Copy', '🍒')));
    'COPY-B'       = (kp(@('Copy', '🥒')));
    'MOVE-A'       = (kp(@('Move', '🍺')));
    'MOVE-B'       = (kp(@('Move', '🍻')));
    'PASTE-A'      = (kp(@('Paste', '🌶️')));
    'PASTE-B'      = (kp(@('Paste', '🥜')));
    'OVERWRITE-A'  = (kp(@('Overwrite', '♻️')));
    'OVERWRITE-B'  = (kp(@('Overwrite', '❗')));

    # Thingies
    #
    'DIRECTORY-A'  = (kp(@('Directory', '📁')));
    'DIRECTORY-B'  = (kp(@('Directory', '🗂️')));
    'FILE-A'       = (kp(@('File', '🏷️')));
    'FILE-B'       = (kp(@('File', '📝')));
    'PATTERN'      = (kp(@('Pattern', '🔍')));
    'WITH'         = (kp(@('With', '🍑')));
    'CRUMB-A'      = (kp(@('Crumb', '🎯')));
    'CRUMB-B'      = (kp(@('Crumb', '🧿')));
    'CRUMB-C'      = (kp(@('Crumb', '💎')));
    'SUMMARY-A'    = (kp(@('Summary', '🔆')));
    'SUMMARY-B'    = (kp(@('Summary', '✨')));
    'MESSAGE'      = (kp(@('Message', '🗯️')));
    'CAPTURE'      = (kp(@('Capture', '☂️')));

    # Media
    #
    'AUDIO'        = (kp(@('Audio', '🎶')));
    'TEXT'         = (kp(@('Text', '🆎')));
    'DOCUMENT'     = (kp(@('Document', '📜')));
    'IMAGE'        = (kp(@('Image', '🖼️')));
    'MOVIE'        = (kp(@('Movie', '🎬')));

    # Indicators
    #
    'WHAT-IF'      = (kp(@('WhatIf', '☑️')));
    'WARNING-A'    = (kp(@('Warning', '⚠️')));
    'WARNING-B'    = (kp(@('Warning', '👻')));
    'SWITCH-ON'    = (kp(@('On', '✔️')));
    'SWITCH-OFF'   = (kp(@('Off', '❌')));
    'OK-A'         = (kp(@('🆗', '🚀')));
    'OK-B'         = (kp(@('🆗', '🌟')));
    'BAD-A'        = (kp(@('Bad', '💥')));
    'BAD-B'        = (kp(@('Bad', '💢')));
    'PROHIBITED'   = (kp(@('Prohibited', '🚫')));
    'INCLUDE'      = (kp(@('Include', '💠')));
    'SOURCE'       = (kp(@('Source', '🎀')));
    'DESTINATION'  = (kp(@('Destination', '☀️')));
    'TRIM'         = (kp(@('Trim', '🌊')));
    'MULTI-SPACES' = (kp(@('Spaces', '❄️')));
    'DIAGNOSTICS'  = (kp(@('Diagnostics', '🧪')));

    # Outcomes
    #
    'FAILED-A'     = (kp(@('Failed', '☢️')));
    'FAILED-B'     = (kp(@('Failed', '💩')));
    'SKIPPED-A'    = (kp(@('Skipped', '💤')));
    'SKIPPED-B'    = (kp(@('Skipped', '👾')));
    'ABORTED-A'    = (kp(@('Aborted', '✖️')));
    'ABORTED-B'    = (kp(@('Aborted', '👽')));
    'CLASH'        = (kp(@('Clash', '📛')));
    'NOT-ACTIONED' = (kp(@('Not Actioned', '⛔')));

    # Command Specific
    #
    'REMY.ANCHOR'  = (kp(@('Anchor', '⚓')));
    'REMY.POST'    = (kp(@('Post Process', '🌈')));
    'REMY.DROP'    = (kp(@('Drop', '💧')));
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
      Marker         = [char]0x2BC1
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
