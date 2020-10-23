
function invoke-ReplaceTextAction {
  [OutputType([string])]
  param(
    [Parameter()]
    $Value,

    [Parameter()]
    [string]$Pattern,

    [Parameter()]
    [string]$With,

    [Parameter()]
    [int]$Quantity,

    [Parameter()]
    [switch]$Whole,

    [Parameter()]
    [ValidateSet('FIRST', 'LAST')]
    $Occurrence
  )
  [string]$result = [string]::Empty;

  if ($PSBoundParameters.ContainsKey('Occurrence')) {
    switch ($Occurrence) {
      'FIRST' {
        $result = (edit-ReplaceFirstMatch -Source $Value `
            -Pattern $Pattern -With $With -Quantity $Quantity `
            -Whole:$Whole).Trim();
        break;
      }

      'LAST' {
        $result = (edit-ReplaceLastMatch -Source $Value `
            -Pattern $Pattern -With $With -Whole:$Whole).Trim();
        break;
      }
    }
  }
  else {
    # Just replace all occurrences
    #
    $result = ($Value -replace $Pattern, $With).Trim();
  }

  $result;
} # invoke-ReplaceTextAction
