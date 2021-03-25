
function Get-FieldMetaData {
  <#
  .NAME
    Get-FieldMetaData

  .SYNOPSIS
    Derives the meta data from the table data provided.

  .DESCRIPTION
    THe source table data is just an array of PSCustomObjects where each object
  represents a row in the table. The meta data is required to format the table
  cells correctly so that each cell is properly aligned.
  
  .PARAMETER Data
    Hashtable containing the table data.
  #>
  param(
    [Parameter()]
    [ValidateScript( { $_ -and $_.Count -gt 0 })]
    [PSCustomObject[]]$Data
  )
  [hashtable]$fieldMetaData = @{}

  # Just look at the first row, so we can see each field
  #
  foreach ($field in $Data[0].psobject.properties.name) {

    try { 
      $fieldMetaData[$field] = [PSCustomObject]@{
        FieldName = $field;
        # !array compound statement: => .$field
        # Note, we also add the field name to the collection, because the field name
        # might be larger than any of the field values
        # 
        Max       = Get-LargestLength $($Data.$field + $field);
        Type      = $Data[0].$field.GetType();
      }
    }
    catch {
      Write-Debug "Get-FieldMetaData, ERR: (field: '$field')";
      Write-Debug "Get-FieldMetaData, ERR: (field length: '$($field.Length)')";
      Write-Debug "Get-FieldMetaData, ERR: (fieldMetaData defined?: $($null -ne $fieldMetaData))";
      Write-Debug "Get-FieldMetaData, ERR: (type: '$($field.GetType())')";
      Write-Debug "Get-FieldMetaData, ERR: ($($_.Exception.Message))";
      Write-Debug "..."
      # TODO: find out why this is happening
      # Strange error sometimes occurs with Get-LargestLength on boolean fields
      #
      $fieldMetaData[$field] = [PSCustomObject]@{
        FieldName = $field;
        Max       = [Math]::max($field.Length, "false".Length);
        Type      = $field.GetType();
      }
    }
  }

  return $fieldMetaData;
}
