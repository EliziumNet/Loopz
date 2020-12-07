
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
    [string]$lineKey = 'LOOPZ.HEADER-BLOCK.LINE';
    [string]$crumbKey = 'LOOPZ.HEADER-BLOCK.CRUMB-SIGNAL';
    [string]$messageKey = 'LOOPZ.HEADER-BLOCK.MESSAGE';

    $colouredLine = format-ColouredLine -PassThru $PassThru `
      -LineKey $lineKey -CrumbKey $crumbKey -MessageKey $messageKey -Truncate;

    Write-InColour -TextSnippets $colouredLine;
  }
} # show-DefaultHeaderBlock
