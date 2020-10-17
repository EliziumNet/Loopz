
function Format-Escape {
  [Alias('esc')]
  [OutputType([string])]
  param(
    [Parameter(Position = 0, Mandatory)]$pattern
  )
  [regex]::Escape($pattern);
}
