
function Invoke-ForeachFsItem {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
  [CmdletBinding(DefaultParameterSetName = 'InvokeScriptBlock')]
  param(
    [Parameter(ParameterSetName = 'InvokeScriptBlock', Mandatory, ValueFromPipeline = $true)]
    [Parameter(ParameterSetName = 'InvokeFunction', Mandatory, ValueFromPipeline = $true)]
    [System.IO.FileSystemInfo]$pipelineItem,

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [scriptblock]$Condition = ( { return $true; }),

    [Parameter(ParameterSetName = 'InvokeScriptBlock', Mandatory)]
    [scriptblock]$Block,

    [Parameter(ParameterSetName = 'InvokeFunction', Mandatory)]
    [ValidateScript( { -not([string]::IsNullOrEmpty($_)); })]
    [string]$Functee,

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [System.Collections.Hashtable]$PassThru = @{},

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [scriptblock]$Summary = (
      # $index, $skipped, $trigger, $PassThru
      { }
    ),

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [ValidateScript( { -not($PSBoundParameters.ContainsKey('Directory')) })]
    [switch]$File,

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [ValidateScript( { -not($PSBoundParameters.ContainsKey('File')) })]
    [switch]$Directory
  )

  begin {
    [boolean]$manageIndex = -not($PassThru.ContainsKey('LOOPZ.FOREACH-INDEX'));
    [int]$index = $manageIndex ? 0 : $PassThru['LOOPZ.FOREACH-INDEX'];
    [int]$skipped = 0;
    [boolean]$broken = $false;
    [boolean]$trigger = $false;
  }

  process {
    [boolean]$itemIsDirectory = ($pipelineItem.Attributes -band
      [System.IO.FileAttributes]::Directory) -eq [System.IO.FileAttributes]::Directory;

    [boolean]$acceptAll = -not($File.ToBool()) -and -not($Directory.ToBool());

    if (-not($broken)) {
      if ( $acceptAll -or ($Directory.ToBool() -and $itemIsDirectory) -or
        ($File.ToBool() -and -not($itemIsDirectory)) ) {
        if ($Condition.Invoke($pipelineItem)) {
          try {
            if ('InvokeScriptBlock' -eq $PSCmdlet.ParameterSetName) {
              $result = Invoke-Command -ScriptBlock $Block -ArgumentList @(
                $pipelineItem, $index, $PassThru, $trigger;
              );
            }
            elseif ('InvokeFunction' -eq $PSCmdlet.ParameterSetName) {
              $parameters = @{
                Underscore = $pipelineItem;
                Index      = $index;
                PassThru   = $PassThru;
                Trigger    = $trigger;
              }
              $result = & $Functee @parameters;
            }
          }
          catch {
            Write-Error "Foreach Error: ($_), for item: '$($pipelineItem.Name)'";
          }
          finally {
            if ($manageIndex) {
              $index++;
            } else {
              $index = $PassThru['LOOPZ.FOREACH-INDEX'];
            }

            if ($result) {
              if ($result.psobject.properties.match('Trigger') -and $result.Trigger) {
                $trigger = $true;
              }

              if ($result.psobject.properties.match('Break') -and $result.Break) {
                $broken = $true;
              }

              if ($result.psobject.properties.match('Product') -and $result.Product) {
                $result.Product;
              }
            }
          }
        } else {
          # IDEA! We could allow the user to provide an extra script block which we
          # invoke for skipped items and set a string containing the reason why it was
          # skipped. 
          $null = $skipped++;
        }
      }
      else {
        $null = $skipped++;
      }
    } else {
      $null = $skipped++;
    }
  }

  end {
    $Summary.Invoke($index, $skipped, $trigger, $PassThru);
  }
}
