
Describe 'Show-InvokeReport' -Tag 'PSTools' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking;

    InModuleScope Elizium.Loopz {
      function script:Test-InvokedWithParams {
        #SupportsShouldProcess
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '',
          Justification = 'This is just a test')]
        [CmdletBinding(SupportsShouldProcess)]
        param(
          [Parameter(Mandatory, ValueFromPipeline = $true, Position = 0)]
          [System.IO.FileSystemInfo]$underscore,

          [Parameter(ParameterSetName = 'MoveToAnchor', Mandatory, Position = 1)]
          [Parameter(ParameterSetName = 'ReplaceWith', Mandatory, Position = 1)]
          [Parameter(ParameterSetName = 'MoveToStart', Mandatory, Position = 1)]
          [Parameter(ParameterSetName = 'MoveToEnd', Mandatory, Position = 1)]
          [array]$Pattern,

          [Parameter(ParameterSetName = 'MoveToAnchor', Mandatory, Position = 2)]
          [array]$Anchor,

          [Parameter(ParameterSetName = 'MoveToAnchor', Position = 3)]
          [ValidateSet('before', 'after')]
          [string]$Relation = 'after',

          [Parameter(ParameterSetName = 'MoveToAnchor')]
          [Parameter(ParameterSetName = 'ReplaceWith')]
          [Parameter(ParameterSetName = 'Prepend')]
          [Parameter(ParameterSetName = 'Append')]
          [Parameter(ParameterSetName = 'PrependDuplicate')]
          [array]$Copy,

          [Parameter(ParameterSetName = 'MoveToAnchor')]
          [Parameter(ParameterSetName = 'ReplaceWith')]
          [Parameter(ParameterSetName = 'MoveToStart')]
          [Parameter(ParameterSetName = 'MoveToEnd')]
          [string]$With,

          [Parameter(ParameterSetName = 'ReplaceWith')]
          [Parameter(ParameterSetName = 'MoveToStart', Mandatory)]
          [Parameter(ParameterSetName = 'HybridStart', Mandatory)]
          [switch]$Start,

          [Parameter(ParameterSetName = 'ReplaceWith')]
          [Parameter(ParameterSetName = 'MoveToEnd', Mandatory)]
          [Parameter(ParameterSetName = 'HybridEnd', Mandatory)]
          [switch]$End,

          [Parameter(ParameterSetName = 'MoveToAnchor')]
          [Parameter(ParameterSetName = 'ReplaceWith')]
          [Parameter(ParameterSetName = 'MoveToStart')]
          [Parameter(ParameterSetName = 'MoveToEnd')]
          [string]$Paste,

          [Parameter(ParameterSetName = 'MoveToAnchor')]
          [Parameter(ParameterSetName = 'ReplaceWith')]
          [Parameter(ParameterSetName = 'MoveToStart')]
          [Parameter(ParameterSetName = 'MoveToEnd')]
          [string]$Drop,

          [Parameter(ParameterSetName = 'Prepend', Mandatory)]
          [Parameter(ParameterSetName = 'PrependDuplicate', Mandatory)]
          [string]$Prepend,

          [Parameter(ParameterSetName = 'Append', Mandatory)]
          [string]$Append,

          [Parameter()]
          [switch]$File,

          [Parameter()]
          [switch]$Directory,

          [Parameter()]
          [Alias('x')]
          [string]$Except = [string]::Empty,

          [Parameter()]
          [Alias('i')]
          [string]$Include,

          [Parameter()]
          [ValidateSet('p', 'a', 'c', 'i', 'x', '*')]
          [string]$Whole,

          [Parameter()]
          [scriptblock]$Condition = ( { return $true; }),

          [Parameter()]
          [ValidateScript( { $_ -gt 0 } )]
          [int]$Top,

          [Parameter()]
          [scriptblock]$Transform,

          [Parameter()]
          [PSCustomObject]$Context = $Loopz.Defaults.Remy.Context,

          [Parameter()]
          [switch]$Diagnose,

          [Parameter(ParameterSetName = 'DuplicatePositions', Mandatory, Position = 999)]
          [object]$DuplicatePosA,

          [Parameter(ParameterSetName = 'DuplicatePositions', Position = 999)]
          [object]$DuplicatePosB,

          [Parameter(ParameterSetName = 'DuplicatePositions', Position = 999)]
          [object]$DuplicatePosC,

          [Parameter(ParameterSetName = 'SamePositions', Mandatory, Position = 111)]
          [object]$SameA,

          [Parameter(ParameterSetName = 'SamePositions', Position = 111)]
          [object]$SameB,

          [Parameter()]
          [Parameter(ParameterSetName = 'InAllSetsByAccident', Position = 777)]
          [object]$Bad
        )
      }
    }
  }

  Context 'given: Test-InvokedWithParams param set missing mandatory' {
    It 'should: show duplicate parameter sets' {
      InModuleScope Elizium.Loopz {
        'Test-InvokedWithParams' | Show-InvokeReport -Params @('prepend') -Test;
      }
    }
  }

  Context 'given: Test-InvokedWithParams param set missing mandatory' {
    It 'should: show the correctly and single resolved parameter set' {
      InModuleScope Elizium.Loopz {
        'Test-InvokedWithParams' | Show-InvokeReport -Params @(
          'append', 'underscore', 'diagnose', 'top') -Test;
      }
    }
  }

  Context 'given: Test-InvokedWithParams and ambiguous parameter set' {
    It 'should: show duplicate parameter sets' -Tag 'BUG' {
      InModuleScope Elizium.Loopz {
        'Test-InvokedWithParams' | Show-InvokeReport -Params @(
          'underscore', 'prepend') -Common  -Test;

        # This should only return 2 parameter sets: Prepend and PrependDuplicate
        #
      }
    }
  }

  Context 'given: Test-InvokedWithParams and ambiguous parameter set' -Skip {
    It 'should: show duplicate parameter sets' {
      InModuleScope Elizium.Loopz {
        'Test-InvokedWithParams' | Show-InvokeReport -Params @('prepend') -Test;

        # This should only return 2 parameter sets: Prepend and PrependDuplicate
        #
      }
    }
  }
}
