
function new-RegularExpression {
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
  try {
    [string]$adjustedExpression = $Expression;

    if ($Escape.ToBool()) {
      $adjustedExpression = [regx]::Escape($adjustedExpression);
    }
    if ($WholeWord.ToBool()) {
      $adjustedExpression = '\b{0}\b' -f $adjustedExpression;
    }
    $resultRegEx = New-Object -TypeName System.Text.RegularExpressions.RegEx -ArgumentList (
      $adjustedExpression);
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
