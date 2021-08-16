
function New-EmojiConverter {
  [CmdletBinding()]
  param(
    [Parameter()]
    [GopherCacheTypes]$CacheType = [GopherCacheTypes]::JsonGoCa,

    [Parameter()]
    [GopherApiTypes]$ApiType = [GopherApiTypes]::GitHubApi,

    [Parameter()]
    [TimeSpan]$QuerySpan = $(New-TimeSpan -Days 1),

    [Parameter()]
    [DateTime]$Now = $(Get-Date)
  )

  [GopherCache]$cache = if ($CacheType -eq [GopherCacheTypes]::JsonGoCa) {
    [JsonGopherCache]::new($Now);
  }
  else {
    throw 'Unknown gopher cache type';
  }

  [EmojiApi]$emojiService = if ($ApiType -eq [GopherApiTypes]::GitHubApi) {
    [GitHubEmojiApi]::new($Now);
  }
  else {
    throw 'Unknown service api type';
  }

  return [MarkDownEmojiConverter]::new($emojiService, $cache, $Now, $QuerySpan);
}
