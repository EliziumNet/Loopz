  function select-ResolvedDirectory {
    [OutputType([boolean])]
    param(
      [Parameter(Mandatory)]
      [System.IO.DirectoryInfo]$DirectoryInfo,

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
        ? $DirectoryInfo.Name -CLike $Filter[$counter] `
        : $DirectoryInfo.Name -Like $Filter[$counter];
      $counter++;
    } while (-not($liked) -and ($counter -lt $Filter.Count));

    $liked;
  }
