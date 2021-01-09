
function Show-Header {
  param(
    [Parameter()]
    [hashtable]$Exchange
  )

  [Krayon]$krayon = $Exchange['LOOP.KRAYON'];

  if (-not($krayon)) {
    throw "Writer missing from Exchange under key 'LOOP.KRAYON'"
  }
  $null = $krayon.Reset();
  [string]$writerFormatWithArg = $krayon.ApiFormatWithArg;
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
      ? $Exchange['LOOPZ.HEADER-BLOCK.LINE'] : ([string]::new('_', $_LineLength)); # $_LineLength ??? (oops my bad)

    [string]$structuredLine = $($writerFormatWithArg -f 'ThemeColour', 'meta') + $line;

    $null = $krayon.ScribbleLn($structuredLine);

    # Inner detail
    #
    if (-not([string]::IsNullOrEmpty($message))) {
      $null = $krayon.Message($message);
    }
    $null = $krayon.Line($properties);

    # Second line
    #
    [string]$structuredLine = $($writerFormatWithArg -f 'ThemeColour', 'meta') + $line;
    $null = $krayon.ScribbleLn($structuredLine);
  }
  else {
    # Alternative line
    #
    [string]$lineKey = 'LOOPZ.HEADER-BLOCK.LINE';
    [string]$crumbKey = 'LOOPZ.HEADER-BLOCK.CRUMB-SIGNAL';
    [string]$messageKey = 'LOOPZ.HEADER-BLOCK.MESSAGE';

    [string]$structuredLine = Format-StructuredLine -Exchange $exchange `
      -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $messageKey -Krayon $krayon;
    $null = $krayon.ScribbleLn($structuredLine);
  }
}