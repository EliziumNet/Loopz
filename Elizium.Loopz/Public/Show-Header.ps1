
function Show-Header {
  param(
    [Parameter()]
    [hashtable]$PassThru,

    [Parameter()]
    [writer]$Writer
  )

  $Writer.Reset();
  [string]$writerFormatWithArg = $Writer.ApiFormatWithArg;
  [string]$message = $PassThru.ContainsKey(
    'LOOPZ.HEADER-BLOCK.MESSAGE') ? $PassThru['LOOPZ.HEADER-BLOCK.MESSAGE'] : [string]::Empty;

  # get the properties from PassThru ('LOOPZ.HEADER.PROPERTIES')
  # properties should not be a line, because line implies all these properties are
  # written on the same line. Rather it is better described as array of Krayola pairs,
  # which is does not share the same semantics as line. However, since line is just a
  # collection of pairs, the client can use the line abstraction, but not the line
  # method on the writer, unless they want it to actually represent a line.
  #
  [line]$properties = $PassThru.ContainsKey(
    'LOOPZ.HEADER.PROPERTIES') ? $PassThru['LOOPZ.HEADER.PROPERTIES'] : [line]::new(@());

  if ($properties.Line.Length -gt 0) {
    # First line
    #
    [string]$line = $PassThru.ContainsKey('LOOPZ.HEADER-BLOCK.LINE') `
      ? $PassThru['LOOPZ.HEADER-BLOCK.LINE'] : (New-Object String("_", $_LineLength));

    [string]$structuredLine = $($writerFormatWithArg -f 'ThemeColour', 'meta') + $line;

    $Writer.ScribbleLn($structuredLine);

    # Inner detail
    #
    if (-not([string]::IsNullOrEmpty($message))) {
      $Writer.Message($message);
    }
    $Writer.Line($properties);

    # Second line
    #
    [string]$structuredLine = $($writerFormatWithArg -f 'ThemeColour', 'meta') + $line;
    $Writer.ScribbleLn($structuredLine);
  }
  else {
    # Alternative line
    #
    [string]$lineKey = 'LOOPZ.HEADER-BLOCK.LINE';
    [string]$crumbKey = 'LOOPZ.HEADER-BLOCK.CRUMB-SIGNAL';
    [string]$messageKey = 'LOOPZ.HEADER-BLOCK.MESSAGE';

    [string]$structuredLine = Format-StructuredLine -PassThru $passThru `
      -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $messageKey -Writer $Writer;
    $Writer.ScribbleLn($structuredLine);
  }
}
