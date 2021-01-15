
function Show-Summary {
  <#
  .NAME
    Show-Header

  .SYNOPSIS
    Function to display summary as part of an iteration batch.

  .DESCRIPTION
    Behaviour can be customised by the following entries in the Exchange:
  * 'LOOPZ.KRAYON' (mandatory): the Krayola Krayon writer object.
  * 'LOOPZ.SUMMARY-BLOCK.MESSAGE': The custom message to be displayed as
  part of the summary.
  * 'LOOPZ.SUMMARY.PROPERTIES': A Krayon [line] instance contain a collection
  of Krayola [couplet]s. The first line of summary properties shows the values of
  $Count, $Skipped and $Triggered. The properties, if present are appended to this line.
  * 'LOOPZ.SUMMARY-BLOCK.LINE': The static line text. The length of this line controls
  how everything else is aligned (ie the flex part and the message if present).
  * 'LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS': The collection (an array of Krayola [lines]s)
  containing 'wide' items and therefore should be on their own separate line.
  * 'LOOPZ.SUMMARY-BLOCK.GROUP-WIDE-ITEMS': Perhaps the wide items are not so wide after
  all, so if this entry is set (a boolean value), the all wide items appear on their
  own line.

  .PARAMETER CapturedOnly

  .PARAMETER Count
    The number items processed, this is the number of items in the pipeline which match
  the $Pattern specified and therefore are allocated an index.

  .PARAMETER Errors
    The number of errors that occurred during the batch.

  .PARAMETER Exchange
    The exchange hashtable object.

  .PARAMETER Skipped
    The number of pipeline items skipped. An item is skipped for the following reasons:
  * Item name does not match the $Include expression
  * Item name satisfies the $Exclude expression. ($Exclude overrides $Include)
  * Iteration is terminated early by the invoked function/script-block returning a
  PSCustomObject with a Break property set to $true.
  * FileSystem item is not of the request type. Eg, if File is specified, then all
  directory items will be skipped.
  * An item fails to satisfy the $Condition predicate.
  * Number of items processed breaches Top.

  .PARAMETER Triggered
    Indicates whether any of the processed pipeline items were actioned in a modifying
  batch; ie if no items were mutated, then Triggered would be $false.

  #>
  param(
    [Parameter()]
    [int]$Count,

    [Parameter()]
    [int]$Skipped,

    [Parameter()]
    [int]$Errors,

    [Parameter()]
    [boolean]$Triggered,

    [Parameter()]
    [hashtable]$Exchange = @{}
  )

  [Krayon]$krayon = $Exchange['LOOPZ.KRAYON'];
  if (-not($krayon)) {
    throw "Writer missing from Exchange under key 'LOOPZ.KRAYON'"
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
  [line]$properties = New-Line(@(
      $(New-Pair('Count', $Count)),
      $(New-Pair('Skipped', $Skipped)),
      $(New-Pair('Errors', $Errors)),
      $(New-Pair('Triggered', $Triggered))
    ));

  [string]$message = $Exchange.ContainsKey('LOOPZ.SUMMARY-BLOCK.MESSAGE') `
    ? $Exchange['LOOPZ.SUMMARY-BLOCK.MESSAGE'] : 'Summary';

  $null = $krayon.Line($message, $properties);
  [string]$blank = [string]::new(' ', $message.Length);

  # Custom properties
  #
  [line]$summaryProperties = $Exchange.ContainsKey(
    'LOOPZ.SUMMARY.PROPERTIES') ? $Exchange['LOOPZ.SUMMARY.PROPERTIES'] : [line]::new(@());

  if ($summaryProperties.Line.Length -gt 0) {
    $null = $krayon.Line($blank, $summaryProperties);
  }

  # Wide items
  #
  if ($Exchange.ContainsKey('LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS')) {
    [line]$wideItems = $Exchange['LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS'];

    [boolean]$group = ($Exchange.ContainsKey('LOOPZ.SUMMARY-BLOCK.GROUP-WIDE-ITEMS') -and
      $Exchange['LOOPZ.SUMMARY-BLOCK.GROUP-WIDE-ITEMS']);

    if ($group) {
      $null = $krayon.Line($blank, $wideItems);
    }
    else {
      foreach ($couplet in $wideItems.Line) {
        [line]$syntheticLine = New-Line($couplet);
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
