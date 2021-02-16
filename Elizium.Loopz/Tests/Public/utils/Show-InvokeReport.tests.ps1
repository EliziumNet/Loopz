
Describe 'Show-InvokeReport' -Tag 'Current' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;
  }

  Context 'given: test-WithDuplicatePs param set missing mandatory' {
    It 'should: show duplicate parameter sets' {
      InModuleScope Elizium.Loopz {
        'test-WithDuplicatePs' | Show-InvokeReport -Params @('prepend');
      }
    }
  }

  Context 'given: test-WithDuplicatePs param set missing mandatory' {
    It 'should: show the correctly and single resolved parameter set' {
      InModuleScope Elizium.Loopz {
        'test-WithDuplicatePs' | Show-InvokeReport -Params @('append', 'underscore', 'diagnose', 'top');
      }
    }
  }

  Context 'given: test-WithDuplicatePs and ambiguous parameter set' {
    It 'should: show duplicate parameter sets' {
      InModuleScope Elizium.Loopz {
        'test-WithDuplicatePs' | Show-InvokeReport -Params @('underscore', 'prepend');

        # This should only return 2 parameter sets: Prepend and PrependDuplicate
        #
      }
    }
  }

  Context 'given: test-WithDuplicatePs and ambiguous parameter set' -Skip {
    It 'should: show duplicate parameter sets' {
      InModuleScope Elizium.Loopz {
        'test-WithDuplicatePs' | Show-InvokeReport -Params @('prepend');

        # This should only return 2 parameter sets: Prepend and PrependDuplicate
        #
      }
    }
  }
}
