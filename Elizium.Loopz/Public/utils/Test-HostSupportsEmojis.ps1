
function Test-HostSupportsEmojis {
  <#
  .NAME
    Test-HostSupportsEmojis

  .SYNOPSIS
    This is a rudimentary function to determine if the host can display emojis. This
  function will be super-ceded when this issue (on microsoft/terminal
  https://github.com/microsoft/terminal/issues/1040) is resolved.

  .DESCRIPTION
    There is currently no standard way to determine this. As a crude workaround, this function
  can determine if the host is Windows Terminal and returns true. Fluent Terminal can
  display emojis, but does not render them very gracefully, so the default value
  returned for Fluent is false. Its assumed that hosts on Linux and Mac can support
  the display of emojis, so they return true. If user want to enforce using emojis,
  then they can define LOOPZ_FORCE_EMOJIS in the environment, this will force this
  function to return.

  .LINK
    https://eliziumnet.github.io/Loopz/

  #>
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
