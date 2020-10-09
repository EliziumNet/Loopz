
function Move-Match {

  # Parameter sets to indicate:
  # vanilla move (Pattern)
  # vanilla move formatted (Pattern, Paste)
  # exotic move (Pattern, With)
  # exotic move formatted (Pattern, With, Paste)
  # (Move, Cut, CutAndPaste)
  # Since this is an internal function, we can have separate parameters
  # for quantities instead of shoe-horning into With/Pattern parameters
  # as excess array elements for brevity and end user convenience.
  #
  [Alias('Move-Match', 'moma')]
  [OutputType([string])]
  param (
    [Parameter(Mandatory)]
    [string]$Source,

    [Parameter()]
    [string]$Pattern,

    [Parameter()]
    [string]$LiteralPattern,

    [Parameter()]
    [ValidateSet('F', 'L', '*')]
    [string]$PatternOccurrence = 'F',

    [Parameter()]
    [string]$Anchor,

    [Parameter()]
    [string]$LiteralAnchor,

    [Parameter()]
    [ValidateSet('F', 'L')]
    [string]$AnchorOccurrence = 'F',

    [Parameter()]
    [ValidateSet('before', 'after')]
    [string]$Relation = 'after',

    [Parameter()]
    [switch]$Whole,

    [Parameter()]
    [switch]$Start,

    [Parameter()]
    [switch]$End,

    [Parameter()]
    [string]$With, # if empty, then Cut op

    [Parameter()]
    [string[]]$LiteralWith, # if empty, then Cut op

    [Parameter()]
    [ValidateSet('F', 'L')]
    [string]$WithOccurrence = 'F',

    [Parameter()]
    [string]$Paste
  )


}
