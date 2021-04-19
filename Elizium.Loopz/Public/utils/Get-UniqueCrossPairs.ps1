
function Get-UniqueCrossPairs {
  <#
  .NAME
    Get-UniqueCrossPairs

  .SYNOPSIS
    Given 2 string arrays, returns an array of PSCustomObjects, containing
  First and Second properties. The result is a list of all unique pair combinations
  of the 2 input sequences.

  .DESCRIPTION
    Effectively, the result is a matrix with the first collection defining 1 axis
  and the other defining the other axis. Pairs where both elements are the same are
  omitted.

  .LINK
    https://eliziumnet.github.io/Loopz/

  .PARAMETER First
    First string array to compare

  .PARAMETER Second
    The other string array to compare

  .EXAMPLE 1
  Get-UniqueCrossPairs -first a,b,c -second a,c,d

  Returns

  First Second
  ----- ------
  a     c
  a     d
  b     a
  b     c
  b     d
  c     d

  .EXAMPLE 2
  Get-UniqueCrossPairs -first a,b,c -second d

  Returns

  First Second
  ----- ------
  d     a
  d     b
  d     c

  #>
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

    if ($Others.Count -gt 0) {
      [PSCustomObject[]]$pairs = foreach ($o in $Others) {
        [PSCustomObject]@{
          First  = $Item;
          Second = $o;
        }
      }
    }
    $pairs;
  }

  [string[]]$firstCollection = $First.Clone() | Sort-Object -Unique;
  [string[]]$secondCollection = $PSBoundParameters.ContainsKey('Second') ? `
  $($Second.Clone() | Sort-Object -Unique) : $firstCollection.Clone();

  [int]$firstCount = $firstCollection.Count;
  [int]$secondCount = $secondCollection.Count;

  if (($firstCount -eq 0) -or ($secondCount -eq 0)) {
    return @();
  }

  [PSCustomObject[]]$result = if ($firstCount -eq 1) {
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
            [PSCustomObject]@{
              First  = $f;
              Second = $s;
            }

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
