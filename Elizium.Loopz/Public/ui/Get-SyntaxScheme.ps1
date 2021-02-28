
function Get-SyntaxScheme {
  [OutputType([Hashtable])]
  param(
    [Parameter()]
    [Hashtable]$Theme
  )
  [Hashtable]$scheme = @{
    'COLS.PUNCTUATION'    = $Theme['META-COLOURS'];
    'COLS.HEADER'         = 'black', 'bgYellow';
    'COLS.HEADER-UL'      = 'darkYellow';
    'COLS.UNDERLINE'      = $Theme['META-COLOURS'];
    'COLS.CELL'           = 'gray';
    'COLS.TYPE'           = 'darkCyan';
    'COLS.MAN-PARAM'      = $Theme['AFFIRM-COLOURS'];
    'COLS.OPT-PARAM'      = 'blue'
    'COLS.CMD-NAME'       = 'darkGreen';
    'COLS.PARAM-SET-NAME' = 'green';
    'COLS.SWITCH'         = 'cyan';
    'COLS.HI-LIGHT'       = 'white';
    'COLS.SPECIAL'        = 'darkYellow';
    'COLS.ERROR'          = 'black', 'bgRed';
    'COLS.OK'             = 'black', 'bgGreen';
  }

  if (Get-IsKrayolaLightTerminal) {
    $scheme['COLS.CELL'] = 'magenta';
    $scheme['COLS.HI-LIGHT'] = 'black';
  }

  return $scheme;
}
