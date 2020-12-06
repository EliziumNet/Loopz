
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
    'LOOPZ.HEADER-BLOCK.CRUMB') ? $PassThru['LOOPZ.HEADER-BLOCK.CRUMB'] : $null;

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

    Write-ThemedPairsInColour @parameters;

    # Second line
    #
    if ($colouredLine) {
      Write-InColour -TextSnippets @(, $colouredLine);
    }
  }
  else {
    # Alternative line
    #
    [string]$open = $krayolaTheme['OPEN'];
    [string]$close = $krayolaTheme['CLOSE'];
    [string]$char = ($line -match '[^\s]') ? $matches[0] : ' ';

    if ([string]::IsNullOrEmpty($message)) {
      if (-not([string]::IsNullOrEmpty($crumb))) {
        [int]$leadLength = 3;
        [string]$lead = (New-Object String($char, $leadLength));
        [string]$lineFormat = "{0} {1}{2}{3} {4}";
        [int]$extra = 2; # no of extra spaces in $lineFormat
        [int]$deductions = $lead.Length + $open.Length + $crumb.Length + $close.Length + $extra;
        [int]$tailLength = $line.Length - $deductions;
        [string]$tail = (New-Object String($char, $tailLength));

        $colouredLine = @(
          @(@($lineFormat -f $lead, $open, $crumb, $close, $tail) + $metaColours)
        );
      } else {
        $colouredLine = @($line) + $metaColours;
      }
      Write-InColour -TextSnippets @(, $colouredLine);
    }
    else {
      if ([string]::IsNullOrEmpty($crumb)) {
        $crumb = if ($PassThru.ContainsKey('LOOPZ.SIGNALS')) {
          [System.Collections.Hashtable]$signals = $PassThru['LOOPZ.SIGNALS'];
          $signals['CRUMB-B'][1];
        } else {
           '+';
        }
      }
      [int]$extra = 4 + $crumb.Length; # extra chars in formats
      [int]$tailLength = 3;
      [object[]]$messageColours = $krayolaTheme['MESSAGE-COLOURS'];
      [string]$leadFormat = "{0}{1} {2} ";
      [string]$tailFormat = " {0} {1}";

      if ($message.Length -gt ($line.Length - $open.Length - $close.Length - $extra)) {
        [string]$lead = (New-Object String($char, $tailLength));
        [string]$tail = (New-Object String($char, $tailLength));
      }
      else {
        [int]$deductions = $open.Length + $message.Length + $close.Length + $extra + $tailLength;
        [int]$leadLength = $line.Length - $deductions;
        [string]$lead = (New-Object String($char, $leadLength));
        [string]$tail = (New-Object String($char, $tailLength));
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
