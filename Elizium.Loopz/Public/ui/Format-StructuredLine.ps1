
function Format-StructuredLine {
  <#
  .NAME
    Format-StructuredLine

  .SYNOPSIS
    Helper function to make it easy to generate a line to be displayed.

  .DESCRIPTION
    A structured line is some text that includes embedded colour instructions that
  will be interpreted by the Krayola krayon writer. This function behaves like a
  layout manager for a single line.

  .PARAMETER CrumbKey
    The key used to index into the $Exchange hashtable to denote which crumb is used.

  .PARAMETER Exchange
    The exchange hashtable object.

  .PARAMETER Krayon
    The writer object which contains the Krayola theme.

  .PARAMETER LineKey
    The key used to index into the $Exchange hashtable to denote the core line.

  .PARAMETER MessageKey
    The key used to index into the $Exchange hashtable to denote what message to display.

  .PARAMETER Options

   + this is the crumb
   |
   V                                                          <-- message ->|
  [@@] --------------------------------------------------- [  Rename (WhatIf) ] ---
                                                                                |<-- This is a trailing wing
                                                                                whose length is WingLength
       |<--- flex part (which must be at least   -------->|
                        MinimumFlexSize in length, it shrinks to accommodate the message)

    A PSCustomObject that allows further customisation of the structured line. Can contain the following
  fields:
  - WingLength: The size of the lead and tail portions of the line ('---')
  - MinimumFlexSize: The smallest size that the flex part can shrink to, to accommodate
  the message. If the message is so large that is pushes up against the minimal flex size
  it will be truncated according to the presence of Truncate switch
  - Ellipses: When message truncation occurs, the ellipses string is used to indicate that
  the message has been truncated.
  - WithLead: boolean flag to indicate whether a leading wing is displayed which would precede
  the crumb. In the above example and by default, there is no leading wing.

  .PARAMETER Truncate
    switch parameter to indicate whether the message is truncated to fit the line length.

  #>
  [OutputType([string])]
  param(
    [Parameter(Mandatory)]
    [hashtable]$Exchange,

    # We need to replace the exchange key parameters with direct parameters
    [Parameter(Mandatory)]
    [string]$LineKey,

    [Parameter()]
    [string]$CrumbKey,

    [Parameter()]
    [string]$MessageKey,

    [Parameter()]
    [switch]$Truncate,

    [Parameter()]
    [Krayon]$Krayon,

    [Parameter()]
    [PSCustomObject]$Options = (@{
        WingLength      = 3;
        MinimumFlexSize = 6;
        Ellipses        = ' ...';
        WithLead        = $false;
      })
  )
  [int]$wingLength = Get-PsObjectField $Options 'WingLength' 3;
  [int]$minimumFlexSize = Get-PsObjectField $Options 'MinimumFlexSize' 6;
  [string]$ellipses = Get-PsObjectField $Options 'Ellipses' ' ...';
  [boolean]$withLead = Get-PsObjectField $Options 'WithLead' $false;
  [string]$formatWithArg = $Krayon.ApiFormatWithArg;

  [hashtable]$theme = $Krayon.Theme;

  [string]$line = $Exchange.ContainsKey($LineKey) `
    ? $Exchange[$LineKey] : ([string]::new("_", 81));
  [string]$char = ($line -match '[^\s]') ? $matches[0] : ' ';
  [string]$wing = [string]::new($char, $wingLength);

  [string]$message = -not([string]::IsNullOrEmpty($MessageKey)) -and ($Exchange.ContainsKey($MessageKey)) `
    ? $Exchange[$MessageKey] : $null;

  [string]$crumb = if (-not([string]::IsNullOrEmpty($CrumbKey)) -and ($Exchange.ContainsKey($CrumbKey))) {
    if ($Exchange.ContainsKey('LOOPZ.SIGNALS')) {
      [hashtable]$signals = $Exchange['LOOPZ.SIGNALS'];
      [string]$crumbName = $Exchange[$CrumbKey];
      $signals[$crumbName].Value;
    }
    else {
      '+';
    }
  }
  else {
    $null;
  }

  [string]$structuredLine = if ([string]::IsNullOrEmpty($message) -and [string]::IsNullOrEmpty($crumb)) {
    $($formatWithArg -f "ThemeColour", "meta") + $line;
  }
  else {
    [string]$open = $theme['OPEN'];
    [string]$close = $theme['CLOSE'];

    # TODO: The deductions need to be calculated in a dynamic form, to cater
    # for optional fields.
    #

    if (-not([string]::IsNullOrEmpty($message)) -and -not([string]::IsNullOrEmpty($crumb))) {
      # 'lead' + 'open' + 'crumb' + 'close' + 'mid' + 'open' + 'message' + 'close' + 'tail'
      #
      # '*{lead} *{open}*{crumb}*{close} *{mid} *{open} *{message} *{close} *{tail}' => Format
      # +-----------------------------------------------|--------|-----------------+
      # | Start                                         |        | End             | => Snippet
      #
      [string]$startFormat = '*{open}*{crumb}*{close} *{mid} *{open} ';
      if ($withLead) {
        $startFormat = '*{lead} ' + $startFormat;
      }
      [string]$endFormat = ' *{close} *{tail}';

      [string]$startSnippet = $startFormat.Replace('*{lead}', $wing). `
        Replace('*{open}', $open). `
        Replace('*{crumb}', $crumb). `
        Replace('*{close}', $close);

      [string]$endSnippet = $endFormat.Replace('*{close}', $close). `
        Replace('*{tail}', $wing);

      [string]$withoutMid = $startSnippet.Replace('*{mid}', '') + $endSnippet;
      [int]$deductions = $withoutMid.Length + $minimumFlexSize;
      [int]$messageSpace = $line.Length - $deductions;
      [boolean]$overflow = $message.Length -gt $messageSpace;

      [int]$midSize = if ($overflow) {
        # message size is the unknown variable and $midSize is a known
        # quantity: minimumFlexSize.
        #
        if ($Truncate.ToBool()) {
          [int]$messageKeepAmount = $messageSpace - $ellipses.Length;
          $message = $message.Substring(0, $messageKeepAmount) + $ellipses;
        }
        $minimumFlexSize;
      }
      else {
        # midSize is the unknown variable and the message size is a known
        # quantity: $message.Length
        #
        [int]$deductions = $withoutMid.Length + $message.Length;
        $line.Length - $deductions;
      }

      [string]$mid = [string]::new($char, $midSize);
      $startSnippet = $startSnippet.Replace('*{mid}', $mid);

      $($formatWithArg -f "ThemeColour", "meta") + $startSnippet + `
      $($formatWithArg -f "ThemeColour", "message") + $message + `
      $($formatWithArg -f "ThemeColour", "meta") + $endSnippet;
    }
    elseif (-not([string]::IsNullOrEmpty($message))) {
      # 'lead' + 'open' + 'message' + 'close' + 'tail'
      #
      # '*{lead} *{open} *{message} *{close} *{tail}'
      # +----------------|--------|-----------------+
      # | Start          |        | End             | => Snippet
      #
      # The lead is mandatory in this case so ignore withLead
      #
      [string]$startFormat = '*{lead} *{open} ';
      [string]$endFormat = ' *{close} *{tail}';
      [string]$endSnippet = $endFormat.Replace('*{close}', $close). `
        Replace('*{tail}', $wing);

      [string]$withoutLead = $startFormat.Replace('*{lead}', ''). `
        Replace('*{open}', $open);

      [int]$deductions = $minimumFlexSize + $withoutLead.Length + $endSnippet.Length;
      [int]$messageSpace = $line.Length - $deductions;
      [boolean]$overflow = $message.Length -gt $messageSpace;
      [int]$leadSize = if ($overflow) {
        if ($Truncate.ToBool()) {
          # Truncate the message
          #
          [int]$messageKeepAmount = $messageSpace - $Ellipses.Length;
          $message = $message.Substring(0, $messageKeepAmount) + $Ellipses;
        }
        $minimumFlexSize;
      }
      else {
        $line.Length - $withoutLead.Length - $message.Length - $endSnippet.Length;
      }

      # The lead is now the variable part so should be calculated last
      #
      [string]$lead = [string]::new($char, $leadSize);
      [string]$startSnippet = $startFormat.Replace('*{lead}', $lead). `
        Replace('*{open}', $open);

      $($formatWithArg -f "ThemeColour", "meta") + $startSnippet + `
      $($formatWithArg -f "ThemeColour", "message") + $message + `
      $($formatWithArg -f "ThemeColour", "meta") + $endSnippet;
    }
    elseif (-not([string]::IsNullOrEmpty($crumb))) {
      # 'lead' + 'open' + 'crumb' + 'close' + 'tail'
      #
      # '*{lead} *{open}*{crumb}*{close} *{tail}'
      # +--------------------------------+------+
      # |Start                           |End   | => 2 Snippets can be combined into lineSnippet
      #                                              because they use the same colours.
      #
      [string]$startFormat = '*{open}*{crumb}*{close} ';
      if ($withLead) {
        $startFormat = '*{lead} ' + $startFormat;
      }

      [string]$startFormat = '*{open}*{crumb}*{close} ';
      [string]$startSnippet = $startFormat.Replace('*{lead}', $wing). `
        Replace('*{open}', $open). `
        Replace('*{crumb}', $crumb). `
        Replace('*{close}', $close);

      [string]$withTailFormat = $startSnippet + '*{tail}';
      [int]$deductions = $startSnippet.Length;
      [int]$tailSize = $line.Length - $deductions;
      [string]$tail = [string]::new($char, $tailSize);
      [string]$lineSnippet = $withTailFormat.Replace('*{tail}', $tail);

      $($formatWithArg -f "ThemeColour", "meta") + $lineSnippet;
    }
  }

  # Write-Host ">>> structuredLine: '$structuredLine'";
  return $structuredLine;
}
