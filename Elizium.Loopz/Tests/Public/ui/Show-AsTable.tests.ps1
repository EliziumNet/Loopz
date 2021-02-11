using module ELizium.Krayola;

Describe 'Show-AsTable' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;
  }

  Context 'given: valid table data' {
    It 'should: show the table' {
      [krayon]$krayon = Get-Krayon;
      [string]$api = $krayon.ApiFormat;
      [hashtable]$signals = Get-Signals;

      [PSCustomObject]$custom = [PSCustomObject]@{
        Colours  = [PSCustomObject]@{
          Mandatory = 'red';
          Switch    = 'magenta';
        }
        Snippets = [PSCustomObject]@{
          Header    = $($api -f 'blue');
          Underline = $($api -f 'yellow');
        }
      }
      [string[]]$columnSelection = @('Name', 'Colour', 'Shape');

      [PSCustomObject]$tableOptions = Get-TableDisplayOptions -Select $columnSelection `
        -Signals $signals -Krayon $krayon -Custom $custom;

      [PSCustomObject[]]$source = @(
        @{ Name = 'dice '; Colour = 'white'; Shape = 'cube' },
        @{ Name = 'ball'; Colour = 'blue'; Shape = 'sphere' },
        @{ Name = 'frisby'; Colour = 'red'; Shape = 'disc' }
      )

      [PSCustomObject[]]$resultSet = ($source `
        | Select-Object -Property @(
          'Name'
          @{Name = 'Colour'; Expression = { $_.Colour }; }
          @{Name = 'Shape'; Expression = { $_.Shape }; }
        )
      );

      [hashtable]$fieldMetaData = Get-FieldMetaData -Data $resultSet;

      [hashtable]$headers, [hashtable]$tableContent = Get-AsTable -MetaData $fieldMetaData `
        -TableData $resultSet -Options $tableOptions;
      [System.Text.StringBuilder]$builder = [System.Text.StringBuilder]::new();

      Show-AsTable -MetaData $fieldMetaData -Headers $headers -Table $tableContent `
        -Builder $builder -Options $tableOptions;
    }
  }
}