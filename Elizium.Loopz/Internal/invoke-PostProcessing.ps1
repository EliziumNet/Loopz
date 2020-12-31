
function invoke-PostProcessing {
  param(
    [Parameter()]
    [string]$InputSource,

    [Parameter()]
    [PSCustomObject]$Rules,

    [Parameter()]
    [hashtable]$signals
  )
  [string]$transformResult = $InputSource;
  [string[]]$appliedSignals = @();
  [array]$iterationRules = $Rules.psobject.Members | where-Object MemberType -like 'NoteProperty';

  foreach ($_r in $iterationRules) {
    $rule = $_r.Value;

    if ($rule['IsApplicable'].InvokeReturnAsIs($transformResult)) {
      $transformResult = $rule['Transform'].InvokeReturnAsIs($transformResult);
      $appliedSignals += $rule['Signal'];
    }
  }

  [PSCustomObject]$result = if ($appliedSignals.Count -gt 0) {
    [string]$indication = [string]::Empty;
    [string[]]$labels = @();

    foreach ($name in $appliedSignals) {
      $indication += $signals[$name].Value;
      $labels += $signals[$name].Key;
    }
    $indication = "[{0}]" -f $indication;

    [PSCustomObject]@{
      TransformResult = $transformResult
      Indication      = $indication;
      Signals         = $appliedSignals;
      Label           = 'Post ({0})' -f $($labels -join ', ');
      Modified        = $true;
    }
  }
  else {
    [PSCustomObject]@{
      TransformResult = $InputSource;
      Modified        = $false;
    }
  }

  $result;
}
