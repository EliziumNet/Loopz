using module Elizium.Krayola;

function Convert-Emojis {
  <#
  .NAME
    Convert-Emojis

  .SYNOPSIS
    Converts emojis defined as short codes inside markdown files into their correspond code points.

  .DESCRIPTION
    The need for command as a result of the fact that external documentation platforms, in particular
  gitbook, do not currently support the presence of emoji references inside markdown files. Currently,
  emojis can  only be correctly rendered if the emoji is represented via its code point representation.
  A user may have a large amount of markdown in multiple projects and converting these all by hand would
  be onerous and impractical. This command will automatically convert all emoji short code references
  into their HTML compliant code point representation; eg, the smiley emoji in short code form :smiley:
  is converted to &#x1f603; The command takes files from the pipeline performs the conversion and depending
  on supplied parameters, will either overwrite the original file or write to a new one. The user can
  feed multiple items via the pipeline and they will all be processed in a batch.
    Emoji code point definitions are acquired via the github emoji api, so only github defined emojis
  are currently supported. Some emojis have multiple code points defined for them and are defined as
  a range of values by the github api, eg ascension_island is defined as range: 1f1e6-1f1e8, so in
  this case, the first item in the range is taken to be the value: 1f1e6.
    WhatIf is supported and when enabled, the files are converted but not saved. This allows the user
  to see if all the emojis contained within are converted successfully as an errors are reported during
  the run.

  .LINK
    https://eliziumnet.github.io/Loopz/

  .PARAMETER InputObject
    The current pipeline item representing a file. Any command that can deliver FileInfo items can be
  used, eg Get-Item for a single item or Get-ChildItem for a collection.

  .PARAMETER OutputSuffix
    The suffix appended to the original filename. When specified, the new file generated by the conversion
  process is written with this suffix. When omitted, the original file is over-written.

  .PARAMETER QuerySpan
    Defines a period of time during which successive calls to the github api can not be made. The emoji
  list does not change very often, so the result is cached and is referred to on successive invocations
  to avoid un-necessary api calls. The default value is 7 days, which means (assuming the cache has not
  been deleted) that no 2 queries inside the space of a week are issued to the github api.

  .EXAMPLE 1

  Convert a single and over the original

  Get-Item -Path ./README.md | Convert-Emojis

  .EXAMPLE 2

  Convert a single and create a new corresponding file with 'out' suffix (README-out.md)

  Get-Item -Path ./README.md | Convert-Emojis -OutputSuffix out

  .EXAMPLE 3

  Convert a collection of markdown files with out suffix

  Get-ChildItem ./*.md | Convert-Emojis -OutputSuffix out

  .EXAMPLE 4

  Convert a collection of markdown files without saving

  Get-ChildItem ./*.md | Convert-Emojis -WhatIf

  #>
  [CmdletBinding(SupportsShouldProcess)]
  [Alias('coji')]
  param(
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [System.IO.FileInfo[]]$InputObject,

    [Parameter()]
    [string]$OutputSuffix,

    [Parameter()]
    [TimeSpan]$QuerySpan = $(New-TimeSpan -Days 7),

    [Parameter()]
    [DateTime]$Now = $(Get-Date),

    [Parameter()]
    [switch]$Test
  )

  begin {
    [Krayon]$krayon = Get-Krayon
    [hashtable]$signals = Get-Signals;
    [Scribbler]$scribbler = New-Scribbler -Krayon $krayon -Test:$Test.IsPresent;

    [MarkDownEmojiConverter]$converter = New-EmojiConverter -Now $Now -QuerySpan $QuerySpan;
    $converter.Init();

    [string]$resetSn = $scribbler.Snippets('Reset');
    [string]$lnSn = $scribbler.Snippets('Ln');
    [string]$metaSn = $scribbler.WithArgSnippet('ThemeColour', 'meta');

    function Group-Pairs {
      # to go into Krayola
      [CmdletBinding()]
      [OutputType([line[]])]
      param(
        [Parameter(Mandatory)]
        [couplet[]]$Pairs,

        [Parameter(Mandatory)]
        [int]$Size
      )

      [line[]]$lines = @();
      [couplet[]]$current = @();
      [int]$counter = 0;
      $Pairs | ForEach-Object {
        if ((($counter + 1) % $Size) -eq 0) {
          $current += $_;
          $lines += New-Line $current;
          $current = @();
        }
        else {
          $current += $_;
        }
        $counter++;
      }

      if ($current.Count -gt 0) {
        $lines += New-Line $current;
      }

      return $lines;
    }
    $scribbler.Scribble("$($resetSn)$($metaSn)$($LoopzUI.LightDashLine)$($lnSn)");
  }

  process {
    [string]$documentPath = $_.FullName;
    [System.IO.DirectoryInfo]$directory = $_.Directory;
    [string[]]$document = $converter.Read($documentPath);
    [PSCustomObject]$result = $converter.Convert($document);
    $scribbler.Reset().End();

    [string]$outputPath = if ($PSBoundParameters.ContainsKey('OutputSuffix')) {
      if (-not(Test-IsFileSystemSafe -Value $OutputSuffix)) {
        throw [ArgumentException]::new(
          "OutputSuffix ('$($OutputSuffix)') parameter contains characters not safe for the file system"
        )
      }

      [string]$filename = [System.IO.Path]::GetFileNameWithoutExtension($documentPath);
      [string]$extension = [System.IO.Path]::GetExtension($documentPath);
      [string]$outputFilename = "$($filename)-$($OutputSuffix)$($extension)";
      Join-Path -Path $directory.FullName -ChildPath $outputFilename;
    }
    else {
      $documentPath;
    }

    if (-not($PSBoundParameters.ContainsKey('WhatIf'))) {
      $converter.Write($outputPath, $result.Document);
    }    

    [string]$outputSpecifier = [string]::IsNullOrEmpty($OutputSuffix) `
      ? "OVERWRITE" : $([System.IO.Path]::GetFileName($outputPath));

    [string]$outputAffirm = [string]::IsNullOrEmpty($OutputSuffix);

    [string]$indicator = $signals[$($result.TotalMissingCount -eq 0 ? 'OK-A' : 'BAD-A')].Value;
    [string]$message = "Converted document {0}" -f $indicator;
    [string]$filler = [string]::new(' ', $message.Length);

    [couplet]$documentPair = New-Pair $($documentPath, $outputSpecifier, $outputAffirm);
    [couplet[]]$documentPairs = @($documentPair);

    if ($PSBoundParameters.ContainsKey('WhatIf')) {
      [couplet]$whatIfSignal = Get-FormattedSignal -Name 'WHAT-IF' `
        -Signals $signals -EmojiAsValue -EmojiOnlyFormat '{0}';
      $documentPairs += $whatIfSignal;
    }

    [line]$documentLine = New-Line $($documentPairs);

    $scribbler.Line($message, $documentLine).End();

    if ($result.TotalMissingCount -gt 0) {
      [couplet[]]$pairs = $result.MissingConversions.Keys | Sort-Object | ForEach-Object {
        [int]$lineNo = $_;
        [string[]]$emojis = $result.MissingConversions[$_];

        New-Pair $("line: $lineNo", $($emojis -join ', '));
      }

      Group-Pairs -Pairs $pairs -Size 4 | ForEach-Object {
        $scribbler.Line($filler, $_).End();        
      }
    }

    $scribbler.Flush();
  }

  end {
    $scribbler.Scribble("$($resetSn)$($metaSn)$($LoopzUI.LightDashLine)$($lnSn)");
    $scribbler.Flush();
  }
}
