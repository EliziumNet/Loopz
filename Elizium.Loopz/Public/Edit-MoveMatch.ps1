
function edit-ShiftToken {
  # Since this is an internal function, we can have separate parameters
  # for quantities instead of shoe-horning into With/Pattern parameters
  # as excess array elements for brevity and end user convenience.
  #
  [CmdletBinding(DefaultParameterSetName = 'MoveRelative')]
  [OutputType([string])]
  param (
    [Parameter(Mandatory)]
    [string]$Source,

    [Parameter(Mandatory)]
    [string]$Pattern,

    [Parameter(Mandatory)]
    [string]$LiteralPattern,

    [Parameter()]
    [ValidateSet('F', 'L', '*')]
    [string]$PatternOccurrence = 'F',

    [Parameter(ParameterSetName = 'MoveRelative')]
    [string]$Anchor,

    [string]$LiteralAnchor,

    [Parameter()]
    [ValidateSet('F', 'L')]
    [string]$AnchorOccurrence = 'F',

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
