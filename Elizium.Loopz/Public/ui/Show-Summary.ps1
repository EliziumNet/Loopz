
function Show-Summary {
  <#
  .NAME
    Show-Header

  .SYNOPSIS
    Function to display summary as part of an iteration batch.

  .DESCRIPTION
    Behaviour can be customised by the following entries in the Exchange:
  * 'LOOPZ.SCRIBBLER' (mandatory): the Krayola Scribbler writer object.
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

  .LINK
    https://eliziumnet.github.io/Loopz/

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

  [Scribbler]$scribbler = $Exchange['LOOPZ.SCRIBBLER'];
  if (-not($scribbler)) {
    throw [System.Management.Automation.MethodInvocationException]::new(
      "Show-Summary: Scribbler missing from Exchange under key 'LOOPZ.SCRIBBLER'");
  }

  [string]$resetSnippet = $scribbler.Snippets(@('Reset'));
  [string]$lnSnippet = $scribbler.Snippets(@('Ln'));
  [string]$metaSnippet = $scribbler.WithArgSnippet('ThemeColour', 'meta');

  $scribbler.Scribble("$($resetSnippet)");

  # First line
  #
  if ($Exchange.ContainsKey('LOOPZ.SUMMARY-BLOCK.LINE')) {
    [string]$line = $Exchange['LOOPZ.SUMMARY-BLOCK.LINE'];
    [string]$structuredBorderLine = $metaSnippet + $line;

    $scribbler.Scribble("$($structuredBorderLine)$($lnSnippet)");
  }
  else {
    $structuredBorderLine = [string]::Empty;
  }

  # Inner detail
  #

  [string]$message = $Exchange.ContainsKey('LOOPZ.SUMMARY-BLOCK.MESSAGE') `
    ? $Exchange['LOOPZ.SUMMARY-BLOCK.MESSAGE'] : 'Summary';

  [string]$structuredPropsWithMessage = $(
    "$message;Count,$Count;Skipped,$Skipped;Errors,$Errors;Triggered,$Triggered"
  );

  [string]$structuredPropsWithMessage = if ($Triggered -and `
      $Exchange.ContainsKey('LOOPZ.FOREACH.TRIGGER-COUNT')) {

    [int]$triggerCount = $Exchange['LOOPZ.FOREACH.TRIGGER-COUNT'];
    $(
      "$message;Count,$Count;Skipped,$Skipped;Errors,$Errors;Triggered,$triggerCount"
    );
  }
  else {
    $(
      "$message;Count,$Count;Skipped,$Skipped;Errors,$Errors;Triggered,$Triggered"
    );
  }

  [string]$lineSnippet = $scribbler.WithArgSnippet(
    'Line', $structuredPropsWithMessage
  )
  $scribbler.Scribble("$($lineSnippet)");

  [string]$blank = [string]::new(' ', $message.Length);

  # Custom properties
  #
  [line]$summaryProperties = $Exchange.ContainsKey(
    'LOOPZ.SUMMARY.PROPERTIES') ? $Exchange['LOOPZ.SUMMARY.PROPERTIES'] : [line]::new(@());

  if ($summaryProperties.Line.Length -gt 0) {
    $scribbler.Line($blank, $summaryProperties).End();
  }

  # Wide items
  #
  if ($Exchange.ContainsKey('LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS')) {
    [line]$wideItems = $Exchange['LOOPZ.SUMMARY-BLOCK.WIDE-ITEMS'];

    [boolean]$group = ($Exchange.ContainsKey('LOOPZ.SUMMARY-BLOCK.GROUP-WIDE-ITEMS') -and
      $Exchange['LOOPZ.SUMMARY-BLOCK.GROUP-WIDE-ITEMS']);

    if ($group) {
      $scribbler.Line($blank, $wideItems).End();
    }
    else {
      foreach ($couplet in $wideItems.Line) {
        [line]$syntheticLine = New-Line($couplet);

        $scribbler.Line($blank, $syntheticLine).End();
      }
    }
  }

  # Second line
  #
  if (-not([string]::IsNullOrEmpty($structuredBorderLine))) {
    $scribbler.Scribble("$($structuredBorderLine)$($lnSnippet)");
  }
}
