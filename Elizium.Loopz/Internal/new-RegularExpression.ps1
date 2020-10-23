
function new-RegularExpression {
  [OutputType([System.Text.RegularExpressions.RegEx])]
  param(
    [Parameter(Position = 0, Mandatory)]
    [string]$Expression,

    [Parameter()]
    [switch]$Escape,

    [Parameter()]
    [switch]$WholeWord
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

  }

  $resultRegEx;
}
