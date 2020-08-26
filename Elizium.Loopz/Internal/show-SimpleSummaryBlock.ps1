
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

  [string]$message = $PassThru.ContainsKey('LOOPZ.SUMMARY-BLOCK.MESSAGE') `
    ? $PassThru['LOOPZ.SUMMARY-BLOCK.MESSAGE'] : 'Summary';

  Write-ThemedPairsInColour -Pairs $properties -Theme $krayolaTheme -Message $message;

  # Second line
  #
  if ($colouredLine) {
    Write-InColour -TextSnippets @(, $colouredLine);
  }
} # show-SimpleSummaryBlock
