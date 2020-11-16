
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

  DefaultHeaderBlock    = [scriptblock] {
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
  InlineCodeToOption = [System.Collections.Hashtable]@{
    'm' = 'Multiline';
    'i' = 'IgnoreCase';
    'x' = 'IgnorePatternWhitespace';
    's' = 'Singleline';
    'n' = 'ExplicitCapture';
  }
}
