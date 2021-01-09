
function New-RegularExpression {
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
    [string]$adjustedExpression = $Expression.StartsWith('~') `
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

    if ($Escape.ToBool()) {
      $adjustedExpression = [regex]::Escape($adjustedExpression);
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
