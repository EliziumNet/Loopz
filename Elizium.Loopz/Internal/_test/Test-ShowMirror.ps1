
    function Test-ShowMirror {
      param(
        [Parameter(Mandatory)]
        [System.IO.DirectoryInfo]$Underscore,

        [Parameter(Mandatory)]
        [int]$Index,

        [Parameter(Mandatory)]
        [System.Collections.Hashtable]$PassThru,

        [Parameter(Mandatory)]
        [boolean]$Trigger,

        [Parameter(Mandatory)]
        [string]$Format
      )

      [string]$result = $Format -f ($Underscore.Name);
      Write-Debug "Custom function; Show-Mirror: '$result'";
      @{ Product = $Underscore }
    }
    