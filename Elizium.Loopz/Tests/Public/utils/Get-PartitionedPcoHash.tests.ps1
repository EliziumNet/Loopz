
Describe 'Get-PartitionedPcoHash' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;
  }

  BeforeEach {
    [hashtable]$script:_collection = @{
      'BTC'  = [PSCustomObject]@{ Name = 'BitCoin'; Type = 'Block'; Light = $true; Token = [string]::Empty };
      'ETH'  = [PSCustomObject]@{ Name = 'Ethereum'; Type = 'Smart'; Light = $false; Token = 'ERC' };
      'USDT' = [PSCustomObject]@{ Name = 'Tether'; Type = 'Stable'; Light = $false; Token = [string]::Empty };
      'DOT'  = [PSCustomObject]@{ Name = 'Polka'; Type = 'Cross'; Light = $false; Token = [string]::Empty };
      'ADA'  = [PSCustomObject]@{ Name = 'Cardano'; Type = 'Smart'; Light = $false; Token = '???' };
      'LTC'  = [PSCustomObject]@{ Name = 'LiteCoin'; Type = 'Block'; Light = $true; Token = [string]::Empty };
      'LINK' = [PSCustomObject]@{ Name = 'Chain'; Type = 'Smart'; Light = $false; Token = 'ERC' };
      'XLM'  = [PSCustomObject]@{ Name = 'Stella'; Type = 'Smart'; Light = $false; Token = '???' };
      'USDC' = [PSCustomObject]@{ Name = 'USD-C'; Type = 'Stable'; Light = $False; Token = [string]::Empty };
      'EOS'  = [PSCustomObject]@{ Name = 'Eos'; Type = 'Smart'; Light = $false; Token = '???' };
      'NEO'  = [PSCustomObject]@{ Name = 'Neo'; Type = 'Smart'; Light = $false; Token = 'NEP' }
    }
  }

  Context 'given: hash with fields containing common items' {
    It 'should: partition by unique field' {
      [hashtable]$partitioned = Get-PartitionedPcoHash -Hash $_collection -Field 'Name';
      $partitioned.Count | Should -Be 11;
    }

    It 'should: partition by non unique field' {
      [hashtable]$partitioned = Get-PartitionedPcoHash -Hash $_collection -Field 'Type';
      $partitioned.Count | Should -Be 4;

      $partitioned['Block'].Count | Should -Be 2;
      $partitioned['Smart'].Count | Should -Be 6;
      $partitioned['Stable'].Count | Should -Be 2;
      $partitioned['Cross'].Count | Should -Be 1;
    }

    It 'should: partition by boolean field' {
      [hashtable]$partitioned = Get-PartitionedPcoHash -Hash $_collection -Field 'Light';
      $partitioned.Count | Should -Be 2;

      $partitioned['true'].Count | Should -Be 2;
      $partitioned['false'].Count | Should -Be 9;
    }
  }

  Context 'given: Field not defined' {
    It 'should: drop item(s)' {
      [hashtable]$partitioned = Get-PartitionedPcoHash -Hash $_collection -Field 'Currency';
      $partitioned.Count | Should -Be 0;
    }
  }

  Context 'given: contains a non PSCustomObject value' {
    It 'should: throw' {
      [hashtable]$collection = $_collection.Clone();
      $collection['DOGE'] = "Joker";

      {
        Get-PartitionedPcoHash -Hash $collection -Field 'Type'
      } | Should -Throw;
    }
  }
}
