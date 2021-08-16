
enum EmojiSourceTypes {
  ShortCodeEmSrc
}

enum GopherCacheTypes {
  JsonGoCa
}

enum GopherApiTypes {
  GitHubApi
}

class DatedFile {

  [string]$SubPath;
  [string]$DirectoryPath;
  [string]$FileName;
  [string]$FullPath;
  [DateTime]$Now;

  DatedFile([string]$subPath, [string]$fileName, [DateTime]$now) {
    $this.SubPath = $subPath;
    $this.FileName = $fileName;
    $this.Now = $now;
    [string]$path = Use-EliziumPath;

    $this.DirectoryPath = $(
      [string]::IsNullOrEmpty($this.SubPath) ? $path :
      $(Join-Path -Path $path -ChildPath $this.SubPath)
    );

    $this.FullPath = $(Join-Path -Path $this.DirectoryPath -ChildPath $this.FileName);
  }

  [PSCustomObject] TryTouch([boolean]$create) {

    [PSCustomObject]$result = if ($this.Exists()) {
      Set-ItemProperty -LiteralPath $this.FullPath -Name LastWriteTime -Value $this.Now -WhatIf:$false;

      [PSCustomObject]@{
        Found         = $true;
        LastWriteTime = $this.Now;
      }
    }
    elseif ($create) {
      $null = New-Item $this.FullPath -Type File -force -WhatIf:$false;

      $this.TryGetLastWriteTime();
    }
    else {
      [PSCustomObject]@{
        Found = $false;
      };
    }

    return $result;
  }

  [boolean] Exists() {
    return Test-Path -LiteralPath $this.FullPath -Type Leaf;
  }

  [boolean] DirectoryExists() {
    return Test-Path -LiteralPath $this.DirectoryPath -Type Container;
  }

  [PSCustomObject] TryGetLastWriteTime() {
    return $($this.Exists()) ?
    [PSCustomObject]@{
      Found         = $true;
      LastWriteTime = Get-LastWriteTime -Path $this.FullPath;
    } :
    [PSCustomObject]@{
      Found = $false;
    };
  }

  [void] Persist([string]$jsonText) {
    if (-not($this.DirectoryExists())) {
      $null = New-Item -Path $this.DirectoryPath -ItemType Directory -WhatIf:$false;
    }
    Set-Content -LiteralPath $this.FullPath -Value $jsonText -WhatIf:$false;
  }
}

class EmojiApi {
  static [string]$FileName = 'last-query.txt';
  [DatedFile]$DatedFile;
  [string]$Service;
  [string]$BaseUrl;
  [hashtable]$Headers = @{};
  [DateTime]$Now;

  EmojiApi([string]$service, [string]$baseUrl, [DateTime]$now) {
    $this.Service = $service;
    $this.BaseUrl = $baseUrl;
    $this.Now = $now;
  }

  [void] Init() {
    $this.DatedFile = [DatedFile]::new(
      $("$($this.Service)-emoji-api"), [EmojiApi]::FileName, $this.Now
    );
  }

  [boolean] IsLastQueryStale([TimeSpan]$querySpan) {

    [PSCustomObject]$lastQueryInfo = $this.DatedFile.TryGetLastWriteTime();
    [DateTime]$threshold = $this.Now - $querySpan;
    [boolean]$result = -not($lastQueryInfo.Found) -or ($lastQueryInfo.LastWriteTime -lt $threshold);

    return $result;
  }

  [string] Get() {
    throw [System.NotImplementedException]::New('EmojiApi.Get');
  }

  [string] CodePoint([string]$url) {
    throw [System.NotImplementedException]::New('EmojiApi.CodePoint');
  }
}

class GitHubEmojiApi : EmojiApi {
  [regex]$AssetRegEx;

  GitHubEmojiApi([DateTime]$now) : base('github', 'https://api.github.com/emojis', $now) {
    $this.AssetRegEx = [regex]::new(
      "^https://github.githubassets.com/images/icons/emoji/unicode/(?<code>\w{2,8})(-\w{2,8})?.png"
    );
  }

  # 'r/R' format: Tue, 10 Aug 2021 11:01:05 GMT
  #
  [string] Get() {

    [PSCustomObject]$response = $(
      $(
        Invoke-EmojiApiRequest -Uri $this.BaseUrl -Headers $this.Headers
      );
    );
    $null = $this.DatedFile.TryTouch($true);

    return $response.Content;
  }

  [void] IfModifiedSince() {
    [PSCustomObject]$lastQueryInfo = $this.DatedFile.TryGetLastWriteTime();

    [DateTime]$since = $lastQueryInfo.Found ? $lastQueryInfo.LastWriteTime : $this.Now;
    [string]$rfc1123Date = $since.ToUniversalTime().ToString('r');
    $this.Headers['If-Modified-Since'] = $rfc1123Date;
  }

  [string] CodePoint([string]$url) {
    [string]$result = [string]::Empty;

    if ($this.AssetRegEx.IsMatch($url)) {
      [System.Text.RegularExpressions.Match]$assetMatch = $this.AssetRegEx.Match($url);
      $assetMatch.Groups

      if ($assetMatch.Groups['code'].Success) {
        $result = $assetMatch.Groups['code'].Value;
      }
    }

    return $result;
  }
}

class GopherCache {
  [DatedFile]$DatedFile;
  [DateTime]$Now;

  GopherCache([DateTime]$now) {
    $this.Now = $now;
  }

  [void] Init() {
    throw [System.NotImplementedException]::New('GopherCache.Init');
  }

  [PSCustomObject] FetchAll([DateTime]$lastUpdated) {
    throw [System.NotImplementedException]::New('GopherCache.FetchAll');
  }

  Save([string]$jsonText) {
    throw [System.NotImplementedException]::New('GopherCache.Save');
  }
}

class JsonGopherCache : GopherCache {
  static [string]$FileName = 'emoji-api.store.json';
  [hashtable]$HashContent;
  
  JsonGopherCache([DateTime]$now): base($now) {

  }

  hidden [int]$_depth = 5;

  [void] Init() {
    [string]$subPath = $(Join-Path -Path 'cache' -ChildPath 'emojis');
    $this.DatedFile = [DatedFile]::new(
      $subPath, 'emoji-api.store.json', $this.Now
    );
  
    $this.HashContent = $this.DatedFile.Exists() ? `
      $this.JsonTextToHash($(Get-Content -LiteralPath $this.DatedFile.FullPath)) : @{};
  }

  Save([string]$jsonText) {
    $this.HashContent = $this.JsonTextToHash($jsonText);
    $this.DatedFile.Persist($jsonText);
  }

  [hashtable] JsonTextToHash([string]$jsonText) {
    return $($jsonText | ConvertFrom-Json -Depth $this._depth -AsHashtable);
  }

  [string] JsonHashToText([hashtable]$jsonHash) {
    [PSCustomObject]$jsonObject = [PSCustomObject]$jsonHash;
    return $($jsonObject | ConvertTo-Json -Depth $this._depth);
  }
}

class GopherConverter {
  [DateTime]$Now;
  [TimeSpan]$QuerySpan;

  GopherConverter([DateTime]$now, [TimeSpan]$querySpan) {
    $this.Now = $now;
    $this.QuerySpan = $querySpan;
  }

  [void] Init() {
    throw [System.NotImplementedException]::New('GopherConverter.Init');
  }

  [PSCustomObject] Convert([string]$documentPath) {
    throw [System.NotImplementedException]::New('GopherConverter.Convert');
  }

  [string] As([string]$name) {
    throw [System.NotImplementedException]::New('GopherConverter.As');
  }

  [string[]] Read([string]$documentPath) {
    throw [System.NotImplementedException]::New('GopherConverter.Read');
  }

  [void] Write([string]$documentPath, [string[]]$document) {
    throw [System.NotImplementedException]::New('GopherConverter.Write');
  }
}

class MarkDownEmojiConverter : GopherConverter {
  [string]$Capture = 'name';
  [regex]$GenericEmojiRegEx;
  [EmojiApi]$EmojiService;
  [GopherCache]$Cache;
  [hashtable]$Emojis;
  [hashtable]$Memoize;
  [string]$Format = "&#x{0};";

  [string]$ContainerPattern = ':{0}:';
  [string]$CorePattern = '(?<name>\w{2,40})';
  [string]$GenericPattern;

  MarkDownEmojiConverter([EmojiApi]$emojiService, [GopherCache]$cache,
    [DateTime]$now, [TimeSpan]$querySpan): base($now, $querySpan) {

    $this.EmojiService = $emojiService;
    $this.Cache = $cache;
    $this.GenericPattern = $($this.ContainerPattern -f $this.CorePattern);
    $this.GenericEmojiRegEx = [regex]::new($this.GenericPattern);
  }

  [void] Init() {
    $this.EmojiService.Init();
    $this.Cache.Init();

    [PSCustomObject]$cacheLastWriteInfo = $this.Cache.DatedFile.TryGetLastWriteTime();

    if ($cacheLastWriteInfo.Found) {
      if ($this.EmojiService.IsLastQueryStale($this.QuerySpan)) {
        $this.EmojiService.IfModifiedSince($this.Now);
        [string]$jsonText = $this.EmojiService.Get();
        $this.Cache.Save($jsonText);
      }
    }
    else {
      [string]$jsonText = $this.EmojiService.Get();
      $this.Cache.Save($jsonText);
    }

    $this.Emojis = $this.Cache.HashContent;
    $this.Memoize = @{}
  }

  [PSCustomObject] Convert([string[]]$sourceDocument) {
    [hashtable]$missingConversions = @{}
    [PSCustomObject]$contraInfo = [PSCustomObject]@{
      TotalMissingCount = 0;
    }

    [scriptblock]$missing = {
      param(
        [string]$emojiName,
        [int]$lineNo,
        [System.Text.RegularExpressions.MatchCollection]$mc
      )

      if ($missingConversions.ContainsKey($lineNo)) {
        [string[]]$faults = @($missingConversions[$lineNo]);
        $faults += $emojiName;
        $missingConversions[$lineNo] = $faults;
      }
      else {
        $missingConversions[$lineNo] = @($emojiName);        
      }
      $contraInfo.TotalMissingCount += $mc.Count;
    }

    [int]$lineNo = 1;
    [string[]]$convertedDocument = foreach ($line in $sourceDocument) {
      $this.ReplaceAllShortToCodePoint($line, $lineNo, $missing);
      $lineNo++;
    }

    [PSCustomObject]$result = [PSCustomObject]@{
      SourceLineCount     = $sourceDocument.Count;
      ConversionLineCount = $convertedDocument.Count;
      TotalMissingCount   = $contraInfo.TotalMissingCount;
      RegEx               = $this.GenericEmojiRegEx;
      MissingConversions  = $missingConversions;
      Document            = $convertedDocument;
    }
    return $result;
  }

  # Whatever pattern is used, it must contain a named capture group called 'name'
  # which represents the name of the emoji
  #
  [string] ReplaceAllShortToCodePoint([string]$documentLine, [int]$lineNo, [scriptblock]$contra) {
    [System.Text.RegularExpressions.MatchCollection]$mc = $this.GenericEmojiRegEx.Matches($documentLine);

    [string]$result = if ($mc.Count -gt 0) {
      [System.Collections.Generic.HashSet[String]]$set = [System.Collections.Generic.HashSet[String]]::New();

      $mc | ForEach-Object {
        [System.Text.RegularExpressions.GroupCollection]$groups = $_.Groups;

        if ($groups[$this.Capture].Success) {
          [string]$captureValue = $groups[$this.Capture].Value;

          if (-not($set.Contains($captureValue))) {
            $null = $set.Add($captureValue);
          }
        }
      }

      [string]$line = $documentLine;
      $set.GetEnumerator() | ForEach-Object {
        [regex]$customRegex = [regex]::new($($this.ContainerPattern -f $_));
        [string]$conversion = $this.As($_);

        if ([string]::IsNullOrEmpty($conversion)) {
          $contra.InvokeReturnAsIs($_, $lineNo, $customRegex.Matches($line));
        }
        else {
          $line = $customRegex.Replace($line, $conversion);
        }
      }

      $line;
    }
    else {
      $documentLine;
    }

    return $result;
  }

  [string] As([string]$name) {
    [string]$result = if ($this.Memoize.ContainsKey($name)) {
      $this.Memoize[$name];
    }
    else {
      [string]$emojiUrl = $this.Emojis[$name];
      [string]$codePoint = $this.EmojiService.CodePoint($emojiUrl);
      $this.Memoize[$name] = $(
        [string]::IsNullOrEmpty($codePoint) ? [string]::Empty : $($this.Format -f $codePoint)
      );

      $this.Memoize[$name];
    }

    return $result;
  }

  [string[]] Read([string]$documentPath) {
    return [System.IO.File]::ReadAllLines($documentPath);
  }

  [void] Write([string]$documentPath, [string[]]$document) {
    [System.IO.File]::WriteAllLines(
      $documentPath, $document, [System.Text.Encoding]::UTF8
    );
  }
}
