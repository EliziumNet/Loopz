
function Show-Summary {
  param(
    [Parameter()]
    [int]$Count,

    [Parameter()]
    [int]$Skipped,

    [Parameter()]
    [boolean]$Triggered,

    [Parameter()]
    [hashtable]$Exchange = @{}
  )

  [Krayon]$krayon = $Exchange['LOOP.KRAYON'];
  if (-not($krayon)) {
    throw "Writer missing from Exchange under key 'LOOP.KRAYON'"
  }

  [string]$writerFormatWithArg = $krayon.ApiFormatWithArg;

  # First line
  #
  if ($Exchange.ContainsKey('LOOPZ.SUMMARY-BLOCK.LINE')) {
    [string]$line = $Exchange['LOOPZ.SUMMARY-BLOCK.LINE'];

    # Assuming writerFormatWithArg is &[{0},{1}]
    # => generates &[ThemeColour,meta] which is an instruction to set the
    # colours to the krayola theme's 'META-COLOURS'
    #
    [string]$structuredBorderLine = $($writerFormatWithArg -f 'ThemeColour', 'meta') + $line;
    $null = $krayon.ScribbleLn($structuredBorderLine);
  }
  else {
    $structuredBorderLine = [string]::Empty;
  }

  # Inner detail
  #
  [line]$properties = kl(@(
      $(kp('Count', $Count)),
      $(kp('Skipped', $Skipped)),
      $(kp('Triggered', $Triggered))
    ));

  [line]$summaryProperties = $Exchange.ContainsKey(
    'LOOPZ.SUMMARY-BLOCK.PROPERTIES') ? $Exchange['LOOPZ.SUMMARY-BLOCK.PROPERTIES'] : [line]::new(@());

  if ($summaryProperties.Line.Length -gt 0) {
    $properties.append($summaryProperties);
  }

  [string]$message = $Exchange.ContainsKey('LOOPZ.SUMMARY-BLOCK.MESSAGE') `
    ? $Exchange['LOOPZ.SUMMARY-BLOCK.MESSAGE'] : 'Summary';

  $null = $krayon.Line($message, $properties);

  # Wide items
  #
  if ($Exchange.ContainsKey('LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS')) {
    [line]$wideItems = $Exchange['LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS'];

    [boolean]$group = ($Exchange.ContainsKey('LOOPZ.SUMMARY-BLOCK.GROUP-WIDE-ITEMS') -and
      $Exchange['LOOPZ.SUMMARY-BLOCK.GROUP-WIDE-ITEMS']);
    [string]$blank = [string]::new(' ', $message.Length);

    if ($group) {
      $null = $krayon.Line($blank, $wideItems);
    }
    else {
      foreach ($couplet in $wideItems.Line) {
        [line]$syntheticLine = kl($couplet);
        $null = $krayon.Line($blank, $syntheticLine);
      }
    }
  }

  # Second line
  #
  if (-not([string]::IsNullOrEmpty($structuredBorderLine))) {
    $null = $krayon.ScribbleLn($structuredBorderLine);
  }
}
