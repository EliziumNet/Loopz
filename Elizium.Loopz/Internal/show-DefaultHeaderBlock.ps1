
function show-DefaultHeaderBlock {
  param(
    [System.Collections.Hashtable]$PassThru
  )

  [System.Collections.Hashtable]$krayolaTheme = $PassThru.ContainsKey(
    'LOOPZ.KRAYOLA-THEME') `
    ? $PassThru['LOOPZ.KRAYOLA-THEME'] : $(Get-KrayolaTheme);

  $metaColours = $krayolaTheme['META-COLOURS'];

  [string]$message = $PassThru.ContainsKey(
    'LOOPZ.HEADER-BLOCK.MESSAGE') ? $PassThru['LOOPZ.HEADER-BLOCK.MESSAGE'] : [string]::Empty;

  [string]$crumb = $PassThru.ContainsKey(
    'LOOPZ.HEADER-BLOCK.CRUMB') ? $PassThru['LOOPZ.HEADER-BLOCK.CRUMB'] : '[+] ';

  [string[][]]$properties = $PassThru.ContainsKey(
    'LOOPZ.HEADER.PROPERTIES') ? $PassThru['LOOPZ.HEADER.PROPERTIES'] : @();

  [string]$line = $PassThru.ContainsKey('LOOPZ.HEADER-BLOCK.LINE') `
    ? $PassThru['LOOPZ.HEADER-BLOCK.LINE'] : (New-Object String("_", $_LineLength));

  $colouredLine = @($line) + $metaColours;

  if ($properties.Length -gt 0) {
    # First line
    #
    if ($PassThru.ContainsKey('LOOPZ.HEADER-BLOCK.LINE')) {
      $line = $PassThru['LOOPZ.HEADER-BLOCK.LINE'];
      $colouredLine = @($line) + $metaColours;

      Write-InColour -TextSnippets @(, $colouredLine);
    }

    # Inner detail
    #
    [System.Collections.Hashtable]$parameters = @{
      'Theme' = $krayolaTheme;
      'Pairs' = $properties;
    }

    if (-not([string]::IsNullOrEmpty($message))) {
      $parameters['Message'] = $message;
    }

    & 'Write-ThemedPairsInColour' @parameters;

    # Second line
    #
    if ($colouredLine) {
      Write-InColour -TextSnippets @(, $colouredLine);
    }
  }
  else {
    # Alternative line
    #
    $open = $krayolaTheme['OPEN'];
    $close = $krayolaTheme['CLOSE'];
    $char = (-not($line[0] -eq ' ')) ? $line[0] : $line[1]; # Todo: Index check

    if ([string]::IsNullOrEmpty($message)) {
      $colouredLine = @($line) + $metaColours;
      Write-InColour -TextSnippets @(, $colouredLine);
    }
    else {
      $extra = 4 + $crumb.Length; # extra chars in formats
      $tailLength = 3;
      $messageColours = $krayolaTheme['MESSAGE-COLOURS'];
      $leadFormat = "{0}{1} {2} ";
      $tailFormat = " {0} {1}";

      if ($message.Length -gt ($line.Length - $open.Length - $close.Length - $extra)) {
        $lead = (New-Object String($char, $tailLength))
        $tail = (New-Object String($char, $tailLength));
      }
      else {
        $deductions = $extra + $tailLength;
        $leadLength = $line.Length - $deductions - $open.Length - $message.Length - $close.Length;
        $lead = (New-Object String($char, $leadLength));
        $tail = (New-Object String($char, $tailLength));
      }

      $colouredLine = @(
        @(@($leadFormat -f $crumb, $lead, $open) + $metaColours),
        @(@($message) + $messageColours),
        @(@($tailFormat -f $close, $tail) + $metaColours)
      );
      Write-InColour -TextSnippets $colouredLine;
    }
  }
} # show-DefaultHeaderBlock
