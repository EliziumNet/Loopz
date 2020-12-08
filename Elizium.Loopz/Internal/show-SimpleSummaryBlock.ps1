
function show-SimpleSummaryBlock {
  param(
    [int]$Count,
    [int]$Skipped,
    [boolean]$Triggered,
    [System.Collections.Hashtable]$PassThru = @{}
  )

  [System.Collections.Hashtable]$krayolaTheme = $PassThru.ContainsKey(
    'LOOPZ.KRAYOLA-THEME') `
    ? $PassThru['LOOPZ.KRAYOLA-THEME'] : $(Get-KrayolaTheme);

  $metaColours = $krayolaTheme['META-COLOURS'];

  # First line
  #
  $line = $colouredLine = $null;
  if ($PassThru.ContainsKey('LOOPZ.SUMMARY-BLOCK.LINE')) {
    $line = $PassThru['LOOPZ.SUMMARY-BLOCK.LINE'];
    $colouredLine = @($line) + $metaColours;

    Write-InColour -TextSnippets @(, $colouredLine);
  }

  # Inner detail
  #
  [string[][]]$properties = @(
    @('Count', $Count),
    @('Skipped', $Skipped),
    @('Triggered', $Triggered)
  )

  [string[][]]$summaryProperties = $PassThru.ContainsKey(
    'LOOPZ.SUMMARY-BLOCK.PROPERTIES') ? $PassThru['LOOPZ.SUMMARY-BLOCK.PROPERTIES'] : @();

  if ($summaryProperties.Length -gt 0) {
    $properties += $summaryProperties;
  }

  [string]$message = $PassThru.ContainsKey('LOOPZ.SUMMARY-BLOCK.MESSAGE') `
    ? $PassThru['LOOPZ.SUMMARY-BLOCK.MESSAGE'] : 'Summary';

  Write-ThemedPairsInColour -Pairs $properties -Theme $krayolaTheme -Message $message;

  # Wide items
  #
  if ($PassThru.ContainsKey('LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS')) {
    [string[][]]$wideItems = $PassThru['LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS'];

    [boolean]$group = ($PassThru.ContainsKey('LOOPZ.SUMMARY-BLOCK.GROUP-WIDE-ITEMS') -and
      $PassThru['LOOPZ.SUMMARY-BLOCK.GROUP-WIDE-ITEMS']);

    if ($group) {
      Write-ThemedPairsInColour -Pairs $wideItems -Theme $krayolaTheme `
        -Message (New-Object String(' ', $message.Length));
    }
    else {
      foreach ($wideItem in $wideItems) {
        [string[][]]$syntheticWide = @(
          , $wideItem
        );

        Write-ThemedPairsInColour -Pairs $syntheticWide -Theme $krayolaTheme `
          -Message (New-Object String(' ', $message.Length));
      }
    }
  }

  # Second line
  #
  if ($colouredLine) {
    Write-InColour -TextSnippets @(, $colouredLine);
  }
} # show-SimpleSummaryBlock
