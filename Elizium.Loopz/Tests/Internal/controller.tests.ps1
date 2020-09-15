
Describe 'controller' {

  BeforeAll {
    . .\Internal\controller.class.ps1
  }

  Context 'given: ForeachController' {
    It 'should: ' {
      [scriptblock]$Header = {
        param(
          [System.Collections.Hashtable]$_passThru
        )
      };

      [scriptblock]$Summary = {
        param(
          [int]$_count,
          [int]$_skipped,
          [boolean]$_trigger,
          [System.Collections.Hashtable]$_passThru
        )
      };

      [System.Collections.Hashtable]$passThru = @{}

      $controller = New-Controller -Type ForeachCtrl -PassThru $passThru -Header $Header -Summary $Summary;

      if ($controller) {

      }
    }
  }
}
