
function Test-HostSupportsEmojis {
  [OutputType([boolean])]
  param()

  function Test-WinHostSupportsEmojis {
    [OutputType([boolean])]
    param()

    # Fluent Terminal: $($env:TERM_PROGRAM -eq 'FluentTerminal')
    #
    return $($null -ne $env:WT_SESSION);
  }
  function Test-DefHostSupportsEmojis {
    [OutputType([boolean])]
    param()

    return $true;
  }

  [boolean]$result = if ($null -eq $(Get-EnvironmentVariable -Variable 'LOOPZ_FORCE_EMOJIS')) {
    # Currently, it is not known how well emojis are displayed in a linux console and results
    # so far found on a mac are less than desirable (not because emojis are not supported, but
    # they do not appear to be well aligned and as a result looks slightly scruffy). For this
    # reason, they will be default configured not to use emoji display, although the user if they
    # wish can override this by defining LOOPZ_FORCE_EMOJIS in their environment.
    #
    [hashtable]$supportsEmojis = @{
      'windows' = [PSCustomObject]@{
        FnInfo     = Get-Command -Name Test-WinHostSupportsEmojis -CommandType Function;
        Positional = @();
      };
      'default' = [PSCustomObject]@{
        FnInfo     = Get-Command -Name Test-DefHostSupportsEmojis -CommandType Function;
        Positional = @();
      };
    }

    Invoke-ByPlatform -Hash $supportsEmojis;
  }
  else {
    $true;
  }

  return $result;
}
