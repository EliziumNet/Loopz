
Describe 'Get-PsObjectField' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;
  }

  BeforeEach {
    [PSCustomObject]$memberObject = [PSCustomObject]@{
      Name = 'Nimrod';
    }
    [PSCustomObject]$script:testObject = [PSCustomObject]@{
      Enabled = $false;
      Activated = $true;
      No = 99;
      Greeting = 'Hello Brave New World';
      Date = [DateTime]::new(2525, 12, 31);
      Member   = $memberObject;
    }
  }

  Context 'given: member present' {
    Context 'and: boolean false' {
      It 'should: return field value' {
        Get-PsObjectField -Object $testObject -Field 'Enabled' | Should -BeFalse;
      }
    }

    Context 'and: boolean true' {
      It 'should: return field value' {
        Get-PsObjectField -Object $testObject -Field 'Activated' | Should -BeTrue;
      }
    }

    Context 'and: int member' {
      It 'should: return field value' {
        Get-PsObjectField -Object $testObject -Field 'No' | Should -Be 99;
      }
    }

    Context 'and: string member' {
      It 'should: return field value' {
        Get-PsObjectField -Object $testObject -Field 'Greeting' | Should -BeExactly 'Hello Brave New World';
      }
    }

    Context 'and: DateTime member' {
      It 'should: return field value' {
        [string]$format = 'yyyy-MM-dd';
        (Get-PsObjectField -Object $testObject -Field 'Date').ToString($format) | Should -Be '2525-12-31';
      }
    }

    Context 'and: PSCustomObject member' {
      It 'should: return field value' {
        (Get-PsObjectField -Object $testObject -Field 'Member').Name | Should -BeExactly 'Nimrod';
      }
    }
  }

  Context 'given: member NOT present' {
    Context 'and: default provided' {
      It 'should: return default' {
        Get-PsObjectField -Object $testObject -Field 'Bye' -Default 'Sayonara' | Should -BeExactly 'Sayonara';
      }
    }

    Context 'and: default NOT provided' {
      It 'should: return null' {
        $null -eq (Get-PsObjectField -Object $testObject -Field 'Cheerio') | Should -BeTrue;
      }
    }    
  }
}
