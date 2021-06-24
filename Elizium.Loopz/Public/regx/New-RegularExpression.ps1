
function New-RegularExpression {
  <#
  .NAME
    New-RegularExpression

  .SYNOPSIS
    regex factory function.

  .DESCRIPTION
    Creates a regex object from the $Expression specified. Supports inline regex
  flags ('mixsn') which must be specified at the end of the $Expression after a
  '/'.

  .LINK
    https://eliziumnet.github.io/Loopz/

  .PARAMETER Escape
    switch parameter to indicate that the expression should be escaped. (This is an
  alternative to the '~' prefix).

  .PARAMETER Expression
    The pattern for the regular expression. If it starts with a tilde ('~'), then
  the whole expression is escaped so any special regex characters are interpreted
  literally.

  .PARAMETER Label
    string that gives a name to the regular expression being created and is used for
  logging/error reporting purposes only, so it's not mandatory.

  .PARAMETER WholeWord
    switch parameter to indicate the expression should be wrapped with word boundary
  markers \b, so an $Expression defined as 'foo' would be adjusted to '\bfoo\b'.

  .EXAMPLE 1 (Create a regular expression object)
  New-RegularExpression -Expression '(?<y>\d{4})-(?<m>\d{2})-(?<d>\d{2})'

  .EXAMPLE 2 (with WholeWord)
  New-RegularExpression -Expression '(?<y>\d{4})-(?<m>\d{2})-(?<d>\d{2})' -WholeWord

  .EXAMPLE 3 (Escaped)
  New-RegularExpression -Expression '(123)' -Escape

  .EXAMPLE 4 (Escaped with leading ~)
  New-RegularExpression -Expression '~(123)'

  .EXAMPLE 5 (Create a case insensitive expression)
  New-RegularExpression -Expression 'DATE/i'
  #>
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions',
    '', Justification = 'Not a state changing function, its a factory')]
  [OutputType([System.Text.RegularExpressions.RegEx])]
  param(
    [Parameter(Position = 0, Mandatory)]
    [string]$Expression,

    [Parameter()]
    [switch]$Escape,

    [Parameter()]
    [switch]$WholeWord,

    [Parameter()]
    [string]$Label
  )

  [System.Text.RegularExpressions.RegEx]$resultRegEx = $null;
  [System.Text.RegularExpressions.RegEx]$extractOptionsRegEx = New-Object `
    -TypeName System.Text.RegularExpressions.RegEx -ArgumentList (
    '[\/\\](?<codes>[mixsn]{1,5})$');

  try {
    [string]$adjustedExpression = ($Expression.StartsWith('~') -or $Escape.IsPresent) `
      ? [regex]::Escape($Expression.Substring(1)) : $Expression;

    [string[]]$optionsArray = @();

    [string]$options = if ($extractOptionsRegEx.IsMatch($adjustedExpression)) {
      $null, $adjustedExpression, [System.Text.RegularExpressions.Match]$optionsMatch = `
        Split-Match -Source $adjustedExpression -PatternRegEx $extractOptionsRegEx;

      [string]$inlineCodes = $optionsMatch.Groups['codes'];

      # NOTE, beware of [string]::ToCharArray, the returned result MUST be cast to [string[]]
      #
      [string[]]$inlineCodes.ToCharArray() | ForEach-Object {
        $optionsArray += $Loopz.InlineCodeToOption[$_]
      }

      $optionsArray -join ', ';
    } else {
      $null;
    }

    if (-not([string]::IsNullOrEmpty($options))) {
      Write-Debug "New-RegularExpression; created RegEx for pattern: '$adjustedExpression', with options: '$options'";
    }

    if ($WholeWord.ToBool()) {
      $adjustedExpression = '\b{0}\b' -f $adjustedExpression;
    }

    $arguments = $options ? @($adjustedExpression, $options) : @(, $adjustedExpression);
    $resultRegEx = New-Object -TypeName System.Text.RegularExpressions.RegEx -ArgumentList (
      $arguments);
  }
  catch [System.Management.Automation.MethodInvocationException] {
    [string]$message = ($PSBoundParameters.ContainsKey('Label')) `
      ? $('Regular expression ({0}) "{1}" is not valid, ... terminating ({2}).' `
        -f $Label, $adjustedExpression, $_.Exception.Message)
    : $('Regular expression "{0}" is not valid, ... terminating ({1}).' `
        -f $adjustedExpression, $_.Exception.Message);
    Write-Error -Message $message -ErrorAction Stop;
  }

  $resultRegEx;
}
