
function Get-PsObjectField {
  <#
  .NAME
    Get-PsObjectField

  .SYNOPSIS
    Simplifies getting the value of a field from a PSCustomObject.

  .DESCRIPTION
    Returns the value of the specified field. If the field is missing, then
  the default is returned.

  .LINK
    https://eliziumnet.github.io/Loopz/

  .PARAMETER Default
    Default value to return if the $Field doesn't exist on the $Object.

  .PARAMETER Field
    The field to get value of.

  .PARAMETER Object
    The object to get the field value from.

  #>
  param(
    [Parameter(Position = 0, Mandatory)]
    [PSCustomObject]$Object,

    [Parameter(Position = 1, Mandatory)]
    [string]$Field,

    [Parameter(Position = 2)]
    $Default = $null
  )

  ($Object.psobject.properties.match($Field) -and ($null -ne $Object.$Field)) ? ($Object.$Field) : $Default;
}
