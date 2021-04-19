
function Get-SyntaxScheme {
  <#
  .NAME
    Get-SyntaxScheme

  .SYNOPSIS
    Get the scheme instance required by Command Syntax functionality in the
  parameter set tools.

  .DESCRIPTION
    The scheme is related to the Krayola theme. Some of the entries in the scheme
  are derived from the Krayola theme. The colours are subject to the presence of
  the environment variable 'KRAYOLA_LIGHT_TERMINAL', this is to prevent light
  foreground colours being selected when the background is also using light colours.

  .LINK
    https://eliziumnet.github.io/Loopz/

  .PARAMETER Theme
    The Krayola theme that the scheme will be associated with.
  #>
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
    'COLS.COMMON'         = 'magenta';
  }

  if (Get-IsKrayolaLightTerminal) {
    $scheme['COLS.CELL'] = 'magenta';
    $scheme['COLS.HI-LIGHT'] = 'black';
  }

  return $scheme;
}
