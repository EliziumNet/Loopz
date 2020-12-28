
function Show-Summary {
  param(
    [Parameter()]
    [int]$Count,

    [Parameter()]
    [int]$Skipped,

    [Parameter()]
    [boolean]$Triggered,

    [Parameter()]
    [hashtable]$PassThru = @{},

    [Parameter()]
    [writer]$Writer
  )

  [string]$writerFormatWithArg = $Writer.ApiFormatWithArg;

  # First line
  #
  if ($PassThru.ContainsKey('LOOPZ.SUMMARY-BLOCK.LINE')) {
    [string]$line = $PassThru['LOOPZ.SUMMARY-BLOCK.LINE'];

    # Assuming writerFormatWithArg is &[{0},{1}]
    # => generates &[ThemeColour,meta] which is an instruction to set the
    # colours to the krayola theme's 'META-COLOURS'
    #
    [string]$structuredBorderLine = $($writerFormatWithArg -f 'ThemeColour', 'meta') + $line;
    $Writer.ScribbleLn($structuredBorderLine);
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

  [line]$summaryProperties = $PassThru.ContainsKey(
    'LOOPZ.SUMMARY-BLOCK.PROPERTIES') ? $PassThru['LOOPZ.SUMMARY-BLOCK.PROPERTIES'] : [line]::new(@());

  if ($summaryProperties.Line.Length -gt 0) {
    $properties.append($summaryProperties);
  }

  [string]$message = $PassThru.ContainsKey('LOOPZ.SUMMARY-BLOCK.MESSAGE') `
    ? $PassThru['LOOPZ.SUMMARY-BLOCK.MESSAGE'] : 'Summary';

  $Writer.Line($message, $properties);

  # Wide items
  #
  if ($PassThru.ContainsKey('LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS')) {
    [line]$wideItems = $PassThru['LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS'];

    [boolean]$group = ($PassThru.ContainsKey('LOOPZ.SUMMARY-BLOCK.GROUP-WIDE-ITEMS') -and
      $PassThru['LOOPZ.SUMMARY-BLOCK.GROUP-WIDE-ITEMS']);
    [string]$blank = [string]::new(' ', $message.Length);

    if ($group) {
      $Writer.Line($blank, $wideItems);
    }
    else {
      foreach ($couplet in $wideItems.Line) {
        [line]$syntheticLine = kl($couplet);
        $Writer.Line($blank, $syntheticLine);
      }
    }
  }

  # Second line
  #
  if (-not([string]::IsNullOrEmpty($structuredBorderLine))) {
    $Writer.ScribbleLn($structuredBorderLine);
  }
}
