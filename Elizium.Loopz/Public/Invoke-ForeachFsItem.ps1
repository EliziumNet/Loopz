
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
    [scriptblock]$Body,

    [Parameter(ParameterSetName = 'InvokeFunction', Mandatory)]
    [ValidateScript( { -not([string]::IsNullOrEmpty($_)); })]
    [string]$Functee,

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [System.Collections.Hashtable]$PassThru = @{},

    [Parameter(ParameterSetName = 'InvokeScriptBlock')]
    [Parameter(ParameterSetName = 'InvokeFunction')]
    [scriptblock]$Summary = ( { })
  )

  begin {
    [int]$index = 0;
    [int]$skipped = 0;
    [boolean]$broken = $false;
    [boolean]$trigger = $false;
  }

  process {
    if (-not($broken)) {
      if (-not(($pipelineItem.Attributes -band [System.IO.FileAttributes]::Directory) -eq [System.IO.FileAttributes]::Directory)) {
        $pipelineFileInfo = [System.IO.FileInfo]$pipelineItem;

        if ($Condition.Invoke($pipelineFileInfo)) {

          if ('InvokeScriptBlock' -eq $PSCmdlet.ParameterSetName) {
            $result = Invoke-Command -ScriptBlock $Body -ArgumentList @(
              $pipelineFileInfo, $index, $PassThru, $trigger
            );
          }
          elseif ('InvokeFunction' -eq $PSCmdlet.ParameterSetName) {
            $parameters = @{
              Underscore = $pipelineFileInfo;
              Index      = $index;
              PassThru   = $PassThru;
              Trigger    = $trigger;
            }
            $result = & $Functee @parameters;
          }
          $index++;

          if ($result) {
            if ($result.psobject.properties.match('Trigger') -and $result.Trigger) {
              $trigger = $true;
            }

            if ($result.psobject.properties.match('Break') -and $result.Break) {
              $broken = $true;
            }

            if ($result.psobject.properties.match('Product') -and $result.Product) {
              if ([System.IO.FileInfo] -eq $result.Product.GetType()) {
                $result.Product;
              }
            }
          }
        }
      }
    }
    else {
      $skipped++;
    }
  }

  end {
    $Summary.Invoke($index, $skipped, $trigger, $PassThru);
  }
}
