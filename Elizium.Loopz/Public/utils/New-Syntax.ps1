
function New-Syntax {
  <#
  .NAME
    New-Syntax

  .SYNOPSIS
    Get a new 'Syntax' object for a command.

  .DESCRIPTION
    The Syntax instance is a supporting class for the parameter set tools. It contains
  various formatters, string definitions and utility functionality. The primary feature
  it contains is that relating to the colouring in of the standard syntax statement
  that is derived from a commands parameter set.

  .PARAMETER CommandName
    The name of the command to get syntax instance for

  .PARAMETER Scheme
    The hashtable syntax specific scheme instance 

  .PARAMETER Scribbler
    The Krayola scribbler instance used to manage rendering to console.

  .PARAMETER Signals
    The signals hashtable collection.
  #>
  param(
    [Parameter(Mandatory)]
    [string]$CommandName,

    [Parameter()]
    [hashtable]$Signals = $(Get-Signals),

    [Parameter()]
    [Scribbler]$Scribbler,

    [Parameter()]
    [Hashtable]$Scheme
  )
  if (-not($PSBoundParameters.ContainsKey('Scheme'))) {
    $Scheme = Get-SyntaxScheme -Theme $($Scribbler.Krayon.Theme);
  }
  return [syntax]::new($CommandName, $Signals, $Scribbler, $Scheme);
}
