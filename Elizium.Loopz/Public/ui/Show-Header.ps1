
function Show-Header {
  <#
  .NAME
    Show-Header

  .SYNOPSIS
    Function to display header as part of an iteration batch.

  .DESCRIPTION
    Behaviour can be customised by the following entries in the Exchange:
  * 'LOOPZ.SCRIBBLER' (mandatory): the Krayola Scribbler writer object.
  * 'LOOPZ.HEADER-BLOCK.MESSAGE': The custom message to be displayed as
  part of the header.
  * 'LOOPZ.HEADER.PROPERTIES': A Krayon [line] instance contain a collection
  of Krayola [couplet]s. When present, the header displayed will be a static
  line, the collection of these properties then another static line.
  * 'LOOPZ.HEADER-BLOCK.LINE': The static line text. The length of this line controls
  how everything else is aligned (ie the flex part and the message if present).

  .LINK
    https://eliziumnet.github.io/Loopz/

  .PARAMETER Exchange
    The exchange hashtable object.

  #>
  param(
    [Parameter()]
    [hashtable]$Exchange
  )
  [Scribbler]$scribbler = $Exchange['LOOPZ.SCRIBBLER'];
  if (-not($scribbler)) {
    throw [System.Management.Automation.MethodInvocationException]::new(
      "Show-Header: Scribbler missing from Exchange under key 'LOOPZ.SCRIBBLER'");
  }

  [string]$resetSnippet = $scribbler.Snippets(@('Reset'));
  [string]$lnSnippet = $scribbler.Snippets(@('Ln'));
  [string]$metaSnippet = $scribbler.WithArgSnippet('ThemeColour', 'meta');

  $scribbler.Scribble("$($resetSnippet)");

  [string]$message = $Exchange.ContainsKey(
    'LOOPZ.HEADER-BLOCK.MESSAGE') ? $Exchange['LOOPZ.HEADER-BLOCK.MESSAGE'] : [string]::Empty;

  # get the properties from Exchange ('LOOPZ.HEADER.PROPERTIES')
  # properties should not be a line, because line implies all these properties are
  # written on the same line. Rather it is better described as array of Krayola pairs,
  # which is does not share the same semantics as line. However, since line is just a
  # collection of pairs, the client can use the line abstraction, but not the line
  # method on the writer, unless they want it to actually represent a line.
  #
  [line]$properties = $Exchange.ContainsKey(
    'LOOPZ.HEADER.PROPERTIES') ? $Exchange['LOOPZ.HEADER.PROPERTIES'] : [line]::new();

  if ($properties.Line.Length -gt 0) {
    # First line
    #
    [string]$line = $Exchange.ContainsKey('LOOPZ.HEADER-BLOCK.LINE') `
      ? $Exchange['LOOPZ.HEADER-BLOCK.LINE'] : ([string]::new('_', 80));

    [string]$structuredLine = $metaSnippet + $line;
    $scribbler.Scribble("$($structuredLine)$($lnSnippet)");

    # Inner detail
    #
    if (-not([string]::IsNullOrEmpty($message))) {
      [string]$messageSnippet = $scribbler.WithArgSnippet('Message', $message);
      $scribbler.Scribble("$($messageSnippet)");
    }

    [string]$structuredProps = ($properties.Line | ForEach-Object {
        "$($_.Key),$($_.Value),$($_.Affirm)"
      }) -join ';'

    [string]$lineSnippet = $scribbler.WithArgSnippet(
      'Line', $structuredProps
    )
    $scribbler.Scribble("$($lineSnippet)");
          
    # Second line
    #
    $scribbler.Scribble("$($structuredLine)$($lnSnippet)");
  }
  else {
    # Alternative line
    #
    [string]$lineKey = 'LOOPZ.HEADER-BLOCK.LINE';
    [string]$crumbKey = 'LOOPZ.HEADER-BLOCK.CRUMB-SIGNAL';
    [string]$messageKey = 'LOOPZ.HEADER-BLOCK.MESSAGE';

    [string]$structuredLine = Format-StructuredLine -Exchange $exchange `
      -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $messageKey -Truncate;

    $scribbler.Scribble("$($structuredLine)");
  }
}
