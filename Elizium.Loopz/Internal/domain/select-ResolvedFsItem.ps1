  function select-ResolvedFsItem {
    [OutputType([boolean])]
    param(
      [Parameter(Mandatory)]
      [string]$FsItem,

      [Parameter(Mandatory)]
      [AllowEmptyCollection()]
      [string[]]$Filter,

      [Parameter()]
      [switch]$Case
    )

    [boolean]$liked = $false;
    [int]$counter = 0;

    do {
      $liked = $Case.ToBool() `
        ? $FsItem -CLike $Filter[$counter] `
        : $FsItem -Like $Filter[$counter];
      $counter++;
    } while (-not($liked) -and ($counter -lt $Filter.Count));

    $liked;
  }
