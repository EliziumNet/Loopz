
Describe 'invoke-PostProcessing' {

  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;

    InModuleScope Elizium.Loopz {
      [hashtable]$script:_signals = @{
        'REMY.POST'    = @('Post Process', '🐋');
        'TRIM'         = @('Trim', '🍀');
        'MULTI-SPACES' = @('Spaces', '🐠');
      }
    }
  }

  Context 'given: input source with no applicable rules' {
    It 'should: return input source un-modified' {
      InModuleScope Elizium.Loopz {
        [string]$source = 'this is a normal result';
        [PSCustomObject]$post = invoke-PostProcessing -InputSource $source -Rules $Loopz.Rules.Remy `
          -Signals $_signals;

        $post.Modified | Should -BeFalse;
        $post.TransformResult | Should -BeExactly $source;
      }
    }
  }

  Context 'given: input source with consecutive spaces' {
    It 'should: apply SPACES rule' {
      InModuleScope Elizium.Loopz {
        [string]$source = 'this      is a  messy   result';

        [PSCustomObject]$post = invoke-PostProcessing -InputSource $source -Rules $Loopz.Rules.Remy `
          -Signals $_signals;

        $post.Modified | Should -BeTrue;
        $post.TransformResult | Should -BeExactly 'this is a messy result';
        $post.Signals | Should -HaveCount 1;
        $post.Signals[0] | Should -BeExactly 'MULTI-SPACES';
        $post.Indication | Should -Not -BeNullOrEmpty;

        Write-Debug ">>> INDICATION: '$($post.Label)' > '$($post.Indication)'";
      }
    }
  }

  Context 'given: input source with leading/trailing spaces' {
    It 'should: apply TRIM rule' {
      InModuleScope Elizium.Loopz {
        [string]$source = '  this is a trim-able result  ';

        [PSCustomObject]$post = invoke-PostProcessing -InputSource $source -Rules $Loopz.Rules.Remy `
          -Signals $_signals;

        $post.Modified | Should -BeTrue;
        $post.TransformResult | Should -BeExactly 'this is a trim-able result';
        $post.Signals | Should -HaveCount 1;
        $post.Signals[0] | Should -BeExactly 'TRIM';
        $post.Indication | Should -Not -BeNullOrEmpty;

        Write-Debug ">>> INDICATION: '$($post.Label)' > '$($post.Indication)'";
      }
    }
  }

  Context 'given: input source with consecutive spaces and consecutive spaces' {
    It 'should: apply SPACES & TRIM rules' {
      InModuleScope Elizium.Loopz {
        [string]$source = ' this      is a  really messy  and trim-able   result  ';

        [PSCustomObject]$post = invoke-PostProcessing -InputSource $source -Rules $Loopz.Rules.Remy `
          -Signals $_signals;

        $post.Modified | Should -BeTrue;
        $post.TransformResult | Should -BeExactly 'this is a really messy and trim-able result';
        $post.Signals | Should -HaveCount 2;
        $post.Indication | Should -Not -BeNullOrEmpty;

        Write-Debug ">>> INDICATION: '$($post.Label)' > '$($post.Indication)'";
      }
    }
  }
}
