
function Get-PartitionedPcoHash {
  <#
  .NAME
    Get-PartitionedPcoHash

  .SYNOPSIS
    Partitions a hash of PSCustomObject (Pco)s by a specified field name.

  .DESCRIPTION
    Given a hashtable whose values are PSCustomObjects, will return a hashtable of
  hashtables, keyed by the field specified. This effectively re-groups the hashtable
  entries based on a custom field. The first level hash in the result is keyed,
  by the field specified. The second level has is the original hash key. So
  given the original hash [ORIGINAL-KEY]=>[PSCustomObject], after partitioning,
  the same PSCustomObject can be accessed, via 2 steps $outputHash[$Field][ORIGINAL-KEY].
  
  .PARAMETER Field
    The name of the field to partition by

  .PARAMETER Hash
    The input hashtable to partition
  #>
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
