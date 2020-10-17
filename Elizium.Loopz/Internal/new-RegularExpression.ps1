
function new-RegularExpression {
  [OutputType([System.Text.RegularExpressions.RegEx])]
  param(
    [Parameter(Position = 0, Mandatory)]
    [string]$Expression
  )

  [System.Text.RegularExpressions.RegEx]$resultRegEx = $null;
  try {
    $resultRegEx = New-Object -TypeName System.Text.RegularExpressions.RegEx -ArgumentList ($Expression);

  } catch [System.Management.Automation.MethodInvocationException] {

  }

  $resultRegEx;
}
