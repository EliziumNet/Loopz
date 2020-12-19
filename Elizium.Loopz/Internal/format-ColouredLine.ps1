
function format-ColouredLine {
  [OutputType([array])]
  param(
    [Parameter(Mandatory)]
    [hashtable]$PassThru,

    [Parameter(Mandatory)]
    [string]$LineKey,

    [Parameter()]
    [string]$CrumbKey,

    [Parameter()]
    [string]$MessageKey,

    [Parameter()]
    [switch]$Truncate,

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

  [hashtable]$theme = $PassThru.ContainsKey(
    'LOOPZ.KRAYOLA-THEME') `
    ? $PassThru['LOOPZ.KRAYOLA-THEME'] : $(Get-KrayolaTheme);

  [array]$metaColours = $theme['META-COLOURS'];
  [array]$messageColours = $theme['MESSAGE-COLOURS'];

  [string]$line = $PassThru.ContainsKey($LineKey) `
    ? $PassThru[$LineKey] : ([string]::new("_", 81));
  [string]$char = ($line -match '[^\s]') ? $matches[0] : ' ';
  [string]$wing = [string]::new($char, $wingLength);

  [string]$message = -not([string]::IsNullOrEmpty($MessageKey)) -and ($PassThru.ContainsKey($MessageKey)) `
    ? $PassThru[$MessageKey] : $null;

  [string]$crumb = if (-not([string]::IsNullOrEmpty($CrumbKey)) -and ($PassThru.ContainsKey($CrumbKey))) {
    if ($PassThru.ContainsKey('LOOPZ.SIGNALS')) {
      [hashtable]$signals = $PassThru['LOOPZ.SIGNALS'];
      [string]$crumbName = $PassThru[$CrumbKey];
      $signals[$crumbName][1];
    }
    else {
      '+';
    }
  }
  else {
    $null;
  }

  [array[]]$colouredLine = if ([string]::IsNullOrEmpty($message) -and [string]::IsNullOrEmpty($crumb)) {
    @(
      @(@($line) + $metaColours),

      # This is a hack because of multi-dimensional array issues in PowerShell
      #
      @(@([string]::Empty) + $messageColours)
    );
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

      @(
        @(@($startSnippet) + $metaColours),
        @(@($message) + $messageColours),
        @(@($endSnippet) + $metaColours)
      );
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

      @(
        @(@($startSnippet) + $metaColours),
        @(@($message) + $messageColours),
        @(@($endSnippet) + $metaColours)
      );
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

      @(
        @(@($lineSnippet) + $metaColours),

        # This is a hack because of multi-dimensional array issues in PowerShell
        #
        @(@([string]::Empty) + $messageColours)
      );
    }
  }

  return $colouredLine;
}