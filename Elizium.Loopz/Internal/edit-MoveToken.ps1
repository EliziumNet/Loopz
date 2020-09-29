
function edit-MoveToken {
  [Alias('Move-Token', 'moto')]
  [CmdletBinding(DefaultParameterSetName = 'MoveRelative')]
  [OutputType([string])]
  param (
    [Parameter(Mandatory)]
    [string]$Source,

    [Parameter(Mandatory)]
    [string]$Pattern,

    [Parameter(ParameterSetName = 'MoveRelative')]
    [string]$Target,

    [Parameter(ParameterSetName = 'MoveRelative')]
    [ValidateSet('before', 'after')]
    [string]$Relation = 'after',

    [Parameter()]
    [switch]$Whole,

    [Parameter(ParameterSetName = 'MoveToStart')]
    [switch]$Start,

    [Parameter(ParameterSetName = 'MoveToEnd')]
    [switch]$End,

    [Parameter()]
    [string]$With = [string]::Empty
  )

  [string]$result = $Source;
  [string]$adjustedPattern = $Whole ? ('\b{0}\b' -f $Pattern.Replace('\b', '')) : $Pattern;

  # Source = '31-12-1999 new years eve is: ';
  # Pattern = '\d{2}-\d{2}-\d{4}'
  # Target = 'is: '
  # Relation = 'after'

  if ($Source -match $adjustedPattern) {
    [string]$wholePatternMatched = ('\b{0}\b' -f $matches[0]);
    [string]$patternMatched = $matches[0]; # => 31-12-1999
    [System.Text.RegularExpressions.RegEx]$patternMatchedRegEx = `
      New-Object -TypeName System.Text.RegularExpressions.RegEx -ArgumentList ($Whole ? $wholePatternMatched : $patternMatched);
    [string]$patternRemoved = $patternMatchedRegEx.Replace($Source, '', 1);
    [string]$replaceWith = [string]::IsNullOrEmpty($With) ? $patternMatched : $With;

    if ($PSBoundParameters.ContainsKey('Target')) {
      if ($patternRemoved -match $Target) {
        [string]$targetMatched = $matches[0]; # 'is: '
        [string]$captureExpression = ('(?<target>{0})' -f $targetMatched).Replace(' ', '\s'); # => '(?<target>is:\s)'

        # The natural way to perform the regex replacement, would be to use something like:
        # $patternRemoved -replace $captureExpression, '${target} ...' or
        # $patternRemoved -replace $captureExpression, '... ${target}' depending on the Relation. However, the
        # second parameter of the replace operator has to be a literal string (') not template string ("),
        # because group reference ${target} would be incorrectly interpreted by the template string instead of
        # leaving it to be used by the regex string replacement. This is why we have to do this in a clunky 2
        # stage process.
        #
        [string]$withPattern = ($Relation -eq 'after') `
          ? $targetMatched + $replaceWith `
          : $replaceWith + $targetMatched;

        [System.Text.RegularExpressions.RegEx]$captureRegEx = `
          New-Object -TypeName System.Text.RegularExpressions.RegEx -ArgumentList $captureExpression;

        # Only replace the first occurrence of the Target in the source
        #
        $result = $captureRegEx.Replace($patternRemoved, $withPattern, 1);
      }
    }
    else {
      if ($Start.ToBool()) {
        $result = $replaceWith + $patternRemoved;
      }
      elseif ($end.ToBool()) {
        $result = $patternRemoved + $replaceWith;
      }
      else {
        throw 'edit-MoveToken invoked with invalid parameters'
      }
    }
  }

  $result;
}
