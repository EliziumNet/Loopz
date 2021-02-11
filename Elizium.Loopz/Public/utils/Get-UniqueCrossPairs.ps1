
function Get-UniqueCrossPairs {
  [OutputType([PSCustomObject[]])]
  param(
    [Parameter(Mandatory, Position = 0)]
    [string[]]$First,

    [Parameter(Position = 1)]
    [string[]]$Second
  )
  function get-pairsWithItem {
    [OutputType([PSCustomObject[]])]
    param(
      [Parameter(Mandatory, Position = 0)]
      [string]$Item,

      [Parameter(Mandatory, Position = 1)]
      [string[]]$Others
    )
    [System.Collections.ArrayList]$pairs = @();

    if ($Others.Count -gt 0) {
      foreach ($o in $Others) {
        $null = $pairs.add([PSCustomObject]@{
            First  = $Item;
            Second = $o;
          });
      }
    }
    $pairs;
  }
  [System.Collections.ArrayList]$result = @();

  [string[]]$firstCollection = $First.Clone() | Sort-Object -Unique;
  [string[]]$secondCollection = $PSBoundParameters.ContainsKey('Second') ? `
    $($Second.Clone() | Sort-Object -Unique) : $firstCollection.Clone();

  [int]$firstCount = $firstCollection.Count;
  [int]$secondCount = $secondCollection.Count;

  if (($firstCount -eq 0) -or ($secondCount -eq 0)) {
    return $result;
  }

  if ($firstCount -eq 1) {
    # 1xN
    #
    get-pairsWithItem -Item $firstCollection[0] -Others $($secondCollection -ne $firstCollection[0]);
  }
  elseif ($secondCount -eq 1) {
    # Nx1
    #
    get-pairsWithItem -Item $secondCollection[0] -Others $($firstCollection -ne $secondCollection[0]);
  }
  else {
    # AxB
    #
    [hashtable]$reflections = @{}
    foreach ($f in $firstCollection) {
      foreach ($s in $secondCollection) {
        if ($f -ne $s) {
          if (-not($reflections.ContainsKey($("$f->$s")))) {
            $null = $result.Add([PSCustomObject]@{
                First  = $f;
                Second = $s;
              });
            # Now record the reflection and ensure we don't add it again if we encounter it
            #
            $reflections[$("$s->$f")] = $true;
          }
        }
      }
    }
  }

  return $result;
}
