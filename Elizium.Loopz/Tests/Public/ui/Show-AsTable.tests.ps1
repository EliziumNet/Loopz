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

      [PSCustomObject]$tableOptions = [PSCustomObject]@{
        Select       = @('Name', 'Colour', 'Shape');

        Chrome       = [PSCustomObject]@{
          Indent    = 3;
          Underline = '-';
          Inter     = 1;
        }

        Colours      = [PSCustomObject]@{
          Header    = 'blue';
          Cell      = 'white';
          Underline = 'yellow';
          HiLight   = 'green';
        }

        Values       = [PSCustomObject]@{
          True  = '✔️';
          False = '✖️';
        }

        Align        = @{
          Header = 'right';
          Cell   = 'left';
        }

        Custom       = [PSCustomObject]@{
          Colours          = [PSCustomObject]@{
            Mandatory = 'red';
            Switch    = 'magenta';
          }
          Snippets         = [PSCustomObject]@{
            Header    = $($api -f 'blue');
            Underline = $($api -f 'yellow');
          }
        }
      }

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

      Show-AsTable -MetaData $fieldMetaData -Headers $headers -Table $tableContent `
        -Krayon $krayon -Options $tableOptions;
    }
  }
}