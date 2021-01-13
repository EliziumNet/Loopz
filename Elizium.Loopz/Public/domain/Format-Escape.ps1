
function Format-Escape {
  <#
  .NAME
    Format-Escape

  .SYNOPSIS
    Escapes the regular expression specified. This is just a wrapper around the
  .net regex::escape method, but gives the user a much more user friendly to
  invoke it from the command line

  .DESCRIPTION
    Various functions in Loopz have parameters that accept a regular expression. This
  function gives the user an easy way to escape the regex, without them having to do
  this manually themselves which could be tricky to get right depending on their
  requirements.

  #>
  [Alias('esc')]
  [OutputType([string])]
  param(
    [Parameter(Position = 0, Mandatory)]$pattern
  )
  [regex]::Escape($pattern);
}
