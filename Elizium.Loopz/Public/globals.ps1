
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
  UnderscoreLine      = (New-Object String("_", $_LineLength));
  EqualsLine          = (New-Object String("=", $_LineLength));
  DotsLine            = (New-Object String(".", $_LineLength));
  DashLine            = (New-Object String("-", $_LineLength));
  LightDotsLine       = ((New-Object String(".", (($_LineLength - 1) / 2))).Replace(".", ". ") + ".");
  LightDashLine       = ((New-Object String("-", (($_LineLength - 1) / 2))).Replace("-", "- ") + "-");
  TildeLine           = (New-Object String("~", $_LineLength));

  SmallUnderscoreLine = (New-Object String("_", $_SmallLineLength));
  SmallEqualsLine     = (New-Object String("=", $_SmallLineLength));
  SmallDotsLine       = (New-Object String(".", $_SmallLineLength));
  SmallDashLine       = (New-Object String("-", $_SmallLineLength));
  SmallLightDotsLine  = ((New-Object String(".", (($_SmallLineLength - 1) / 2))).Replace(".", ". ") + ".");
  SmallLightDashLine  = ((New-Object String("-", (($_SmallLineLength - 1) / 2))).Replace("-", "- ") + "-");
  SmallTildeLine      = (New-Object String("~", $_SmallLineLength));
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
    'windows' = @{
      'MISSING' = @('???', '🔻')
    };
    'linux'   = @{
      'MISSING' = @('???', '🔴')
    };
    'mac'     = @{
      'MISSING' = @('???', '🔺')
    };
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
    'FILE-A'       = @('File', '🔖')
    'FILE-B'       = @('File', '📝')
    'PATTERN'      = @('Pattern', '🔍')
    'LITERAL'      = @('Literal', '📚')
    'WITH'         = @('With', '📌')
    'CRUMB-A'      = @('Crumb', '🎯')
    'CRUMB-B'      = @('Crumb', '🧿')
    'CRUMB-C'      = @('Crumb', '💎')
    'SUMMARY-A'    = @('Summary', '🔆')
    'SUMMARY-B'    = @('Summary', '✨')
    'MESSAGE'      = @('Message', '💭')

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
}
