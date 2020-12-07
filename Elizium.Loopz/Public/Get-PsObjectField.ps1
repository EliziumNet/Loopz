
function Get-PsObjectField {
  param(
    [Parameter(Position = 0, Mandatory)]
    [PSCustomObject]$Object,

    [Parameter(Position = 1, Mandatory)]
    [string]$Field,

    [Parameter(Position = 2)]
    $Default = $null
  )

  ($Object.psobject.properties.match($Field) -and $Object.$Field) ? ($Object.$Field) : $Default;
}
