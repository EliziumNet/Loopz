Describe 'Iterator Filters' {
  BeforeAll {
    Get-Module Elizium.Loopz | Remove-Module -Force;
    Import-Module .\Output\Elizium.Loopz\Elizium.Loopz.psm1 `
      -ErrorAction 'stop' -DisableNameChecking -Force;

    Enum TargetEnum {
      Current = 1
      Parent = 2
      Leaf = 4
      Child = 8
      File = 16
    }
  }

  Context "given: statics" {
    It "should: init ok" {
      InModuleScope Elizium.Loopz {
        [int]$length = ([CompoundFilter]::CompoundTypeToClassName).PSBase.Count;
        Write-Host ">>> found '$($length)' members"

        ([CompoundFilter]::CompoundTypeToClassName).PSBase.Keys | ForEach-Object {
          [CompoundType]$compoundType = $_;
          [string]$compoundTypeClass = ([CompoundFilter]::CompoundTypeToClassName)[$compoundType];
          Write-Host "---> compound type: '$($compoundType)', class: '$($compoundTypeClass)'";

          [hashtable]$filters = @{}
          $handler = New-Object $($compoundTypeClass) @($filters);

          $handler | Should -Not -BeNullOrEmpty;
        }
      }
    }
  }

  Context "given: enum" {
    It "should: convert to string" {
      [TargetEnum]$parent = [TargetEnum]::Parent;
      $parent | Should -BeExactly "Parent";
    }
  }

  Context "given: object with enum field" {
    It "should: convert to string" {
      [PSCustomObject]$filter = @{
        Target = [TargetEnum]::Current;
      }

      [PSCustomObject]$subject = [PSCustomObject]@{
        ChildDepthLevel = 2;
        IsChild         = $false;
        IsLeaf          = $true;
        Segments        = @("a", "b", "c");
        Scope           = [PSCustomObject]@{
          Current = "CURRENT-NODE"
          Parent  = "PARENT-NODE"
          Child   = "CHILD-NODE";
          Leaf    = "LEAF-NODE";
        }
      }

      [string]$target = $subject.Scope.$($filter.Target);
      $target | Should -BeExactly "CURRENT-NODE";
    }
  }
}
