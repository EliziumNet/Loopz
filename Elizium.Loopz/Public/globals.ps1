
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
  }

  SimpleSummaryBlock   = [scriptblock] {
    param(
      [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
      [int]$Count,
      [int]$Skipped,
      [boolean]$Triggered,
      [System.Collections.Hashtable]$PassThru = @{}
    )
  
    [System.Collections.Hashtable]$krayolaTheme = $PassThru.ContainsKey(
      'LOOPZ.WH-FOREACH-DECORATOR.KRAYOLA-THEME') `
      ? $PassThru['LOOPZ.WH-FOREACH-DECORATOR.KRAYOLA-THEME'] : $(Get-KrayolaTheme);

    $metaColours = $krayolaTheme['META-COLOURS'];

    $line = $colouredLine = $null;
    if ($PassThru.ContainsKey('LOOPZ.SUMMARY-BLOCK.LINE')) {
      $line = $PassThru['LOOPZ.SUMMARY-BLOCK.LINE'];
      $colouredLine = @($line) + $metaColours;

      Write-InColour -TextSnippets @(, $colouredLine);
    }

    [string[][]]$properties = @(
      @('Count', $Count),
      @('Skipped', $Skipped),
      @('Triggered', $Triggered)
    )

    [string]$message = $PassThru.ContainsKey('LOOPZ.SUMMARY-BLOCK.MESSAGE') `
      ? $PassThru['LOOPZ.SUMMARY-BLOCK.MESSAGE'] : 'Summary';

    Write-ThemedPairsInColour -Pairs $properties -Theme $krayolaTheme -Message $message;

    if ($colouredLine) {
      Write-InColour -TextSnippets @(, $colouredLine);
    }
  }
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
  LightDotsLine       = ((New-Object String(".", (($_LineLength - 1) / 2))).Replace(".", ". ") + ".");
  TildeLine           = (New-Object String("~", $_LineLength));

  SmallUnderscoreLine = (New-Object String("_", $_SmallLineLength));
  SmallEqualsLine     = (New-Object String("=", $_SmallLineLength));
  SmallDotsLine       = (New-Object String(".", $_SmallLineLength));
  SmallLightDotsLine  = ((New-Object String(".", (($_SmallLineLength - 1) / 2))).Replace(".", ". ") + ".");
  SmallTildeLine      = (New-Object String("~", $_SmallLineLength));
}
