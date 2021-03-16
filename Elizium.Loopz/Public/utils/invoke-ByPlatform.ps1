
function Invoke-ByPlatform {
  <#
  .NAME
    Invoke-ByPlatform

  .SYNOPSIS
    Given a hashtable, invokes the function/script-block whose corresponding key matches
  the operating system name as returned by Get-PlatformName.

  .DESCRIPTION
    Provides a way to provide OS specific functionality. Returns $null if the $Hash does
  not contain an entry corresponding to the current platform.
    (Doesn't support invoking a function with named parameters; PowerShell doesn't currently
  support this, not even via splatting, if this changes, this will be implemented.)

  .PARAMETER Hash
    A hashtable object whose keys are values that can be returned by Get-PlatformName. The
  values are of type PSCustomObject and can contain the following properties:
  + FnInfo: A FunctionInfo instance. This can be obtained from an existing function by
  invoking Get-Command -Name <function-name>
  + Positional: an array of positional parameter values

  #>
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSPossibleIncorrectUsageOfAssignmentOperator", "")]
  param(
    [Parameter()]
    [hashtable]$Hash
  )

  $result = $null;
  [string]$platform = Get-PlatformName;

  [PSCustomObject]$invokeInfo = if ($Hash.ContainsKey($platform)) {
    $Hash[$platform];
  }
  elseif ($Hash.ContainsKey('default')) {
    $Hash['default'];
  }
  else {
    Write-Error "!!!!!! Missing platform: '$platform' (and no default available)" -ErrorAction Continue;
    $null;
  }

  if ($invokeInfo -and $invokeInfo.FnInfo) {
    if ($invokeInfo.psobject.properties.match('Positional') -and ($null -ne $invokeInfo.Positional)) {
      [array]$positional = $invokeInfo.Positional;

      if ([scriptblock]$block = $invokeInfo.FnInfo.ScriptBlock) {
        $result = $block.InvokeReturnAsIs($positional);
      }
      else {
        Write-Error $("ScriptBlock for function: '$($invokeInfo.FnInfo.Name)', ('$platform': platform) is missing") `
          -ErrorAction Continue;
      }
    }
    elseif ($invokeInfo.psobject.properties.match('Named') -and $invokeInfo.Named) {
      [hashtable]$named = $invokeInfo.Named;

      $result = & $invokeInfo.FnInfo.Name @named;
    }
    else {
      Write-Error $("Missing Positional/Named: '$($invokeInfo.FnInfo.Name)', ('$platform': platform)") `
        -ErrorAction Continue;
    }
  }

  return $result;
}
