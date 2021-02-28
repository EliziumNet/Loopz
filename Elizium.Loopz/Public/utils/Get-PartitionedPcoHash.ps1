
function Get-PartitionedPcoHash {
  param(
    [Parameter(Mandatory)]
    [hashtable]$Hash,

    [Parameter(Mandatory)]
    [string]$Field
  )

  [Hashtable]$partitioned = @{}

  $Hash.GetEnumerator() | ForEach-Object {

    if ($_.Value -is [PSCustomObject]) {
      [string]$partitionKey = (($_.Value.$Field) -is [string]) ? ($_.Value.$Field).Trim() : ($_.Value.$Field);

      if (-not([string]::IsNullOrEmpty($partitionKey))) {
        [hashtable]$partition = if ($partitioned.ContainsKey($partitionKey)) {
          $partitioned[$partitionKey];
        }
        else {
          @{}
        }
        $partition[$_.Key] = $_.Value;
        $partitioned[$partitionKey] = $partition;
      }
      else {
        Write-Debug "WARNING: Get-PartitionedPcoHash field: '$Field' not present on object for key '$($_.Key)'";
      }
    }
    else {
      throw [System.Management.Automation.MethodInvocationException]::new(
        "Get-PartitionedPcoHash invoked with hash whose value for key '$($_.Key)' is not a PSCustomObject");
    }
  }

  return $partitioned;
}
