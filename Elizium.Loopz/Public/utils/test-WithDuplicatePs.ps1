
function test-WithDuplicatePs { # this should be an internal function
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, ValueFromPipeline = $true)]
    [System.IO.FileSystemInfo]$underscore,

    [Parameter(ParameterSetName = 'MoveToAnchor', Mandatory, Position = 0)]
    [Parameter(ParameterSetName = 'ReplaceWith', Mandatory, Position = 0)]
    [Parameter(ParameterSetName = 'MoveToStart', Mandatory, Position = 0)]
    [Parameter(ParameterSetName = 'MoveToEnd', Mandatory, Position = 0)]
    [ValidateScript( { { $(test-ValidPatternArrayParam -Arg $_ -AllowWildCard ) } })]
    [array]$Pattern,

    [Parameter(ParameterSetName = 'MoveToAnchor', Mandatory)]
    [ValidateScript( { $(test-ValidPatternArrayParam -Arg $_) })]
    [array]$Anchor,

    [Parameter(ParameterSetName = 'MoveToAnchor')]
    [ValidateSet('before', 'after')]
    [string]$Relation = 'after',

    [Parameter(ParameterSetName = 'MoveToAnchor')]
    [Parameter(ParameterSetName = 'ReplaceWith')]
    [Parameter(ParameterSetName = 'Prepend')]
    [Parameter(ParameterSetName = 'Append')]
    [Parameter(ParameterSetName = 'PrependDuplicate')]

    # Commented out so we can test ambiguity that this invocation causes:
    # -Pattern 'hi' -Anchor '~' -Start -Paste 'Hello' -Copy 'a'
    #
    # [Parameter(ParameterSetName = 'HybridStart')]
    # [Parameter(ParameterSetName = 'HybridEnd')]
    [ValidateScript( { { $(test-ValidPatternArrayParam -Arg $_) } })]
    [array]$Copy,

    [Parameter(ParameterSetName = 'MoveToAnchor')]
    [Parameter(ParameterSetName = 'ReplaceWith')]
    [Parameter(ParameterSetName = 'MoveToStart')]
    [Parameter(ParameterSetName = 'MoveToEnd')]
    [string]$With,

    # Both Start & End are members of ReplaceWith, but they shouldn't be supplied at
    # the same time. So how to prevent this? Use ValidateScript instead.
    #
    [Parameter(ParameterSetName = 'ReplaceWith')]
    [Parameter(ParameterSetName = 'MoveToStart', Mandatory)]
    [Parameter(ParameterSetName = 'HybridStart', Mandatory)]
    [ValidateScript( { -not($PSBoundParameters.ContainsKey('End')); })] # validation no longer required
    [switch]$Start,

    [Parameter(ParameterSetName = 'ReplaceWith')]
    [Parameter(ParameterSetName = 'MoveToEnd', Mandatory)]
    [Parameter(ParameterSetName = 'HybridEnd', Mandatory)]
    [ValidateScript( { -not($PSBoundParameters.ContainsKey('Start')); })] # validation no longer required
    [switch]$End,

    [Parameter(ParameterSetName = 'MoveToAnchor')]
    [Parameter(ParameterSetName = 'ReplaceWith')]
    [Parameter(ParameterSetName = 'MoveToStart')]
    [Parameter(ParameterSetName = 'MoveToEnd')]
    [string]$Paste,

    [Parameter(ParameterSetName = 'MoveToAnchor')]
    [Parameter(ParameterSetName = 'ReplaceWith')]
    [Parameter(ParameterSetName = 'MoveToStart')]
    [Parameter(ParameterSetName = 'MoveToEnd')]
    [string]$Drop,

    [Parameter(ParameterSetName = 'Prepend', Mandatory)]
    [Parameter(ParameterSetName = 'PrependDuplicate', Mandatory)]
    [string]$Prepend,

    [Parameter(ParameterSetName = 'Append', Mandatory)]
    [string]$Append,

    [Parameter()]
    [ValidateScript( { -not($PSBoundParameters.ContainsKey('Directory')); })]
    [switch]$File,

    [Parameter()]
    [ValidateScript( { -not($PSBoundParameters.ContainsKey('File')); })]
    [switch]$Directory,

    [Parameter()]
    [Alias('x')]
    [string]$Except = [string]::Empty,

    [Parameter()]
    [Alias('i')]
    [string]$Include,

    [Parameter()]
    [ValidateSet('p', 'a', 'c', 'i', 'x', '*')]
    [string]$Whole,

    [Parameter()]
    [scriptblock]$Condition = ( { return $true; }),

    [Parameter()]
    [ValidateScript( { $_ -gt 0 } )]
    [int]$Top,

    [Parameter()]
    [scriptblock]$Transform,

    [Parameter()]
    [PSCustomObject]$Context = $Loopz.Defaults.Remy.Context,

    [Parameter()]
    [switch]$Diagnose
  )

  Write-Host "  *** test-WithDuplicatePs [Parameter Set '$($PSCmdlet.ParameterSetName)']";
}
