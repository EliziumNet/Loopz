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
      [hashtable]$_exchange,

      [Parameter(Mandatory)]
      [boolean]$_trigger
    )

    return Write-HostFeItemDecorator -Underscore $_underscore `
      -Index $_index `
      -Exchange $_exchange `
      -Trigger $_trigger
  } # WhItemDecoratorBlock

  HeaderBlock          = [scriptblock] {
    param(
      [hashtable]$Exchange = @{}
    )

    Show-Header -Exchange $Exchange;
  } # HeaderBlock

  SummaryBlock         = [scriptblock] {
    param(
      [int]$Count,
      [int]$Skipped,
      [int]$Errors,
      [boolean]$Triggered,
      [hashtable]$Exchange = @{}
    )

    Show-Summary -Count $Count -Skipped $Skipped `
      -Errors $Errors -Triggered $Triggered -Exchange $Exchange;
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
  DependencyPlaceholder = '*{_dependency}';

  SignalLabel           = 0;
  SignalEmoji           = 1;

  MissingSignal         = @{
    'windows' = (@('???', '🔻', '?!'));
    'linux'   = (@('???', '🔴', '?!'));
    'mac'     = (@('???', '🔺', '?!'));
  }

  # TODO:
  # - See
  #   * https://devblogs.microsoft.com/commandline/windows-command-line-unicode-and-utf-8-output-text-buffer/
  #   * https://stackoverflow.com/questions/49476326/displaying-unicode-in-powershell
  #
  DefaultSignals        = [ordered]@{
    # Operations
    #
    'CUT-A'           = (@('Cut', '✂️', ' Σ'));
    'CUT-B'           = (@('Cut', '🦄', ' Σ'));
    'COPY-A'          = (@('Copy', '🍒', ' ©️'));
    'COPY-B'          = (@('Copy', '😺', ' ©️'));
    'MOVE-A'          = (@('Move', '🍺', '≈≈'));
    'MOVE-B'          = (@('Move', '🦊', '≈≈'));
    'PASTE-A'         = (@('Paste', '🌶️', ' ¶'));
    'PASTE-B'         = (@('Paste', '🦆', ' ¶'));
    'OVERWRITE-A'     = (@('Overwrite', '♻️', ' Ø'));
    'OVERWRITE-B'     = (@('Overwrite', '❗', '!!'));
    'PREPEND'         = (@('Prepend', '⏭️', '>|'));
    'APPEND'          = (@('Append', '⏮️', '|<'));

    # Thingies
    #
    'DIRECTORY-A'     = (@('Directory', '📁', 'd>'));
    'DIRECTORY-B'     = (@('Directory', '📂', 'D>'));
    'FILE-A'          = (@('File', '💠', 'f>'));
    'FILE-B'          = (@('File', '📝', 'F>'));
    'PATTERN'         = (@('Pattern', '🛡️', 'p:'));
    'WITH'            = (@('With', '🍑', ' Ψ'));
    'CRUMB-A'         = (@('Crumb', '🎯', '+'));
    'CRUMB-B'         = (@('Crumb', '🧿', '+'));
    'CRUMB-C'         = (@('Crumb', '💎', '+'));
    'SUMMARY-A'       = (@('Summary', '🔆', '*'));
    'SUMMARY-B'       = (@('Summary', '✨', '*'));
    'MESSAGE'         = (@('Message', 'Ⓜ️', '()'));
    'CAPTURE'         = (@('Capture', '☂️', 'λ'));
    'MISSING-CAPTURE' = (@('Missing Capture', '☔', '!λ'));

    # Media
    #
    'AUDIO'           = (@('Audio', '🎶', '_A'));
    'TEXT'            = (@('Text', '🆎', '_T'));
    'DOCUMENT'        = (@('Document', '📜', '_D'));
    'IMAGE'           = (@('Image', '🌌', '_I'));
    'MOVIE'           = (@('Movie', '🎬', '_M'));

    # Indicators
    #
    'WHAT-IF'         = (@('WhatIf', '☑️', '✓'));
    'WARNING-A'       = (@('Warning', '⚠️', ')('));
    'WARNING-B'       = (@('Warning', '👻', ')('));
    'SWITCH-ON'       = (@('On', '✔️', '✓'));
    'SWITCH-OFF'      = (@('Off', '✖️', '×'));
    'INVALID'         = (@('Invalid', '❌', 'XX'));
    'BECAUSE'         = (@('Because', '⚗️', '??'));
    'OK-A'            = (@('OK', '🚀', ':)'));
    'OK-B'            = (@('OK', '🌟', ':D'));
    'BAD-A'           = (@('Bad', '💥', ' ß'));
    'BAD-B'           = (@('Bad', '💢', ':('));
    'PROHIBITED'      = (@('Prohibited', '🚫', ' þ'));
    'INCLUDE'         = (@('Include', '➕', '++'));
    'EXCLUDE'         = (@('Exclude', '➖', '--'));
    'SOURCE'          = (@('Source', '🎀', '+='));
    'DESTINATION'     = (@('Destination', '☀️', '=+'));
    'TRIM'            = (@('Trim', '🌊', '%%'));
    'MULTI-SPACES'    = (@('Spaces', '❄️', '__'));
    'DIAGNOSTICS'     = (@('Diagnostics', '🧪', ' Δ'));
    'LOCKED'          = (@('Locked', '🔐', '>/'));
    'NOVICE'          = (@('Novice', '🔰', ' Ξ'));
    'TRANSFORM'       = (@('Transform', '🤖', ' τ'));
    'BULLET-A'        = (@('Bullet Point', '🔶', '⬥'));
    'BULLET-B'        = (@('Bullet Point', '🟢', '⬡'));
    'BULLET-C'        = (@('Bullet Point', '🟨', '⬠'));
    'BULLET-D'        = (@('Bullet Point', '💠', '⬣'));

    # Outcomes
    #
    'FAILED-A'        = (@('Failed', '☢️', '$!'));
    'FAILED-B'        = (@('Failed', '💩', '$!'));
    'SKIPPED-A'       = (@('Skipped', '💤', 'zz'));
    'SKIPPED-B'       = (@('Skipped', '👾', 'zz'));
    'ABORTED-A'       = (@('Aborted', '✖️', 'o:'));
    'ABORTED-B'       = (@('Aborted', '👽', 'o:'));
    'CLASH'           = (@('Clash', '📛', '>¬'));
    'NOT-ACTIONED'    = (@('Not Actioned', '⛔', '-¬'));

    # Command Specific
    #
    'REMY.ANCHOR'     = (@('Anchor', '⚓', ' §'));
    'REMY.POST'       = (@('Post Process', '🌈', '=>'));
    'REMY.DROP'       = (@('Drop', '💧', ' ╬'));
    'REMY.UNDO'       = (@('Undo Rename', '❎', ' μ'));
    'GREPS'           = (@('greps', '🔍', 'γ'));
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

  SignalRegistry        = @{
    'greps' = @('GREPS');

    'remy'  = @(
      'ABORTED-A', 'APPEND', 'BECAUSE', 'CAPTURE', 'CLASH', 'COPY-A', 'CUT-A', 'DIAGNOSTICS',
      'DIRECTORY-A', 'EXCLUDE', 'FILE-A', 'INCLUDE', 'LOCKED', 'MULTI-SPACES', 'NOT-ACTIONED',
      'NOVICE', 'PASTE-A', 'PATTERN', 'PREPEND', 'REMY.ANCHOR', 'REMY.ANCHOR', 'REMY.DROP',
      'REMY.POST', 'REMY.UNDO', 'TRANSFORM', 'TRIM', 'WHAT-IF', 'WITH'
    );

    'sharp' = @(
      'BULLET-A', 'BULLET-C', 'BULLET-D'
    );

    'ships' = @(
      'BULLET-B', 'SWITCH-ON', 'SWITCH-OFF'
    );

    'shire' = @(
      'FAILED-A', 'INVALID', 'OK-A'
    )
  }

  Defaults              = [PSCustomObject]@{
    Remy = [PSCustomObject]@{
      Marker  = [char]0x2BC1;

      Context = [PSCustomObject]@{
        Title             = 'Rename';
        ItemMessage       = 'Rename Item';
        SummaryMessage    = 'Rename Summary';
        Locked            = 'LOOPZ_REMY_LOCKED';
        UndoDisabledEnVar = 'LOOPZ_REMY_UNDO_DISABLED';
        OperantShortCode  = 'remy';
      }
    }
  }

  Rules                 = [PSCustomObject]@{
    Remy = @(
      @{
        ID             = 'MissingCapture';
        'IsApplicable' = [scriptblock] {
          param([string]$_Input)
          $_Input -match '\$\{\w+\}';
        };

        'Transform'    = [scriptblock] {
          param([string]$_Input)
          $_Input -replace "\$\{\w+\}", ''
        };
        'Signal'       = 'MISSING-CAPTURE'
      },

      @{
        ID             = 'Trim';
        'IsApplicable' = [scriptblock] {
          param([string]$_Input)
          $($_Input.StartsWith(' ') -or $_Input.EndsWith(' '));
        };

        'Transform'    = [scriptblock] {
          param([string]$_Input)
          $_Input.Trim();
        };
        'Signal'       = 'TRIM'
      },

      @{
        ID             = 'Spaces';
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
    );
  }

  InvalidCharacterSet   = [char[]]'<>:"/\|?*';
}
