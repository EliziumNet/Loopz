
function invoke-MoveTextAction {
  [OutputType([string])]
  param(
    [Parameter()]
    [string]$Value,

    [Parameter()]
    [string]$Pattern,

    [Parameter()]
    [string[]]$Literal,

    [Parameter()]
    [string]$Target,

    [Parameter()]
    [string]$TargetType,

    [Parameter()]
    [string]$Relation,

    [Parameter()]
    [switch]$Whole
  )
  [string]$result = [string]::Empty;

  [System.Collections.Hashtable]$moveTokenParameters = @{
    'Source'  = $Value;
    'Pattern' = $Pattern;
  }

  if ($PSBoundParameters.ContainsKey('Literal')) {
    $moveTokenParameters['Literal'] = $Literal;
  }

  switch ($TargetType) {
    'MATCHED-ITEM' {
      $moveTokenParameters['Target'] = $Target;
      $moveTokenParameters['Relation'] = $Relation;
      break;
    }
    'START' {
      $moveTokenParameters['Start'] = $true;
      break;
    }
    'END' {
      $moveTokenParameters['End'] = $true;
      break;
    }
    default {
      throw "doRenameFsItems: encountered Invalid 'LOOPZ.RN-FOREACH.TARGET-TYPE': '$targetType'";
    }
  }

  if ($Whole.ToBool()) {
    $moveTokenParameters['Whole'] = $true;
  }
  $result = (edit-MoveToken @moveTokenParameters).Trim();

  $result;
} # invoke-MoveTextAction
