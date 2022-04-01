using namespace System;
using namespace System.IO;
using namespace System.Management.Automation;
using namespace System.Collections;
using namespace System.Collections.Generic;

[Flags()]
Enum FilterScope {
  # filter applies to the current node's name (this would apply to files
  # and directories)
  #
  Current = 1

  # filter applies to the name of the parent of the current node
  Parent = 2

  # filter applies to node only if it is a leaf directory
  Leaf = 4

  # filter applies to node only if it is a child directory
  Child = 8

  # filter applies to node if it is a file
  File = 16
}

class FilterOptions {
  [char]$Not = '!';
}

class FilterSubject {
  [PSCustomObject]$Data;
  [int]$Segment;

  FilterSubject([int]$segment) {
    $this.Segment = $segment;
  }

  FilterSubject([PSCustomObject]$data) {
    $this.Data = $data;
  }
}

class CoreFilter {
  [FilterOptions]$Options;
  [FilterScope]$Scope = [FilterScope]::Current;

  CoreFilter([FilterOptions]$options) {
    $this.Options = $options;
  }

  [boolean]$_negate = $false;

  [boolean] Pass([string]$value) {
    throw [PSNotImplementedException]::new('CoreFilter.Pass');
  }

  [List[FileInfo]] FilesWhere([string]$value, [PSCustomObject]$info) {

    [List[FileInfo]]$collection = $(
      $info.DirectoryInfo.GetFiles()
    );

    return $collection;
  } 
} # CoreFilter

class NoFilter : CoreFilter {
  NoFilter([FilterOptions]$options): base($options) {

  }

  [string] ToString() {
    return "(NoFilter)";
  }

  [boolean] Pass([string]$value) {
    return $true;
  }
} # NoFilter

class GlobFilter : CoreFilter {
  [string]$Glob;

  GlobFilter([string]$glob, [FilterOptions]$options): base($options) {
    [string]$adjusted = if ($glob.StartsWith($options.Not)) {
      $this._negate = $true;
      $glob.Substring(1);
    }
    else {
      $glob
    }
    $this.Glob = $adjusted;
  }

  [boolean] Pass([string]$value) {
    [boolean]$result = $value -like $this.Glob;
    return $this._negate ? -not($result) : $result;
  }

  [List[FileInfo]] FilesWhere([string]$value, [PSCustomObject]$info) {

    [List[FileInfo]]$collection = $(
      $info.DirectoryInfo.GetFiles()
    );

    return $collection;
  }

  [string] ToString() {
    return "(glob: '$($this.Glob)')";
  }
} # GlobFilter

class RegexFilter : CoreFilter {
  [Regex]$Rexo;

  RegexFilter([string]$expression, [string]$label, [FilterOptions]$options): base($options) {
    [string]$adjusted = if ($expression.StartsWith($options.Not)) {
      $this._negate = $true;
      $expression.Substring(1);
    }
    else {
      $expression;
    }
    $this.Rexo = New-RegularExpression -Expression $adjusted -Label $label;
  }

  [boolean] Pass([string]$value) {
    [boolean]$result = $this.Rexo.IsMatch($value);
    return $this._negate ? -not($result) : $result;
  }

  [List[FileInfo]] FilesWhere([string]$value, [PSCustomObject]$info) {

    [List[FileInfo]]$collection = $(
      $info.DirectoryInfo.GetFiles()
    );

    return $collection;
  }

  [string] ToString() {
    return "(pattern: '$($this.Rexo)')";
  }
} # RegexFilter

class FilterDriver {
  [CoreFilter]$Core;

  FilterDriver([CoreFilter]$core) {
    $this.Core = $core;
  }

  [boolean] Accept([FilterSubject]$subject) {
    throw [PSNotImplementedException]::new('FilterDriver.Accept');
  }

  [List[FileInfo]] FilesWhere([FilterSubject]$subject, [PSCustomObject]$info) {
    return $this.Core.FilesWhere($subject.Value, $info);
  }

  # the strategy should create the subject, then invoke GetSubjectValue.
  # but how does this work in the compound scenarios? The handler will
  # call GetSubjectValue multiple times, one for each appropriate core
  # filter, then pass this value to the core filter in pass/preview etc.
  # The context creates the node via the strategy.
  #
  [string] GetSubjectValue([FilterSubject]$subject, [CoreFilter]$filter) {
    # TODO: get this properly, using the FilterTarget on the core filter
    #
    # map $filter.Scope to an entry on the subject value
    #
    return $subject.Value;
  }
}

class UnaryFilter: FilterDriver {
  [CoreFilter]$Core
  UnaryFilter([CoreFilter]$core) {
    $this.Core = $core;
  }

  [boolean] Accept([FilterSubject]$subject) {
    return $this.Core.Pass($subject.Value.$($this.Core.Scope));
  }

  [List[FileInfo]] FilesWhere([FilterSubject]$subject, [PSCustomObject]$info) {
    return $this.Core.FilesWhere($subject.Value, $info);
  }
}

# The CompoundType denotes what happen when there are multiple filters in force.
# This is the intermediate type (CompoundFilter.All, CompoundFilter.Any)
#
Enum CompoundType {
  # All filters must pass
  All

  # At least 1 filter must pass
  Any
}

class CompoundHandler {
  [hashtable]$Filters;

  # not sure that we actually need the scope here,as its
  # stored in the Filters hashtable
  #
  CompoundHandler([hashtable]$filters) {
    $this.Filters = $filters;
  }

  [boolean] Accept([FilterSubject]$subject) {
    throw [PSNotImplementedException]::new('CompoundHandler.Accept');
  }

  [List[FileInfo]] FilesWhere([FilterSubject]$subject, [PSCustomObject]$info) {
    throw [PSNotImplementedException]::new('CompoundHandler.FilesWhere');
  }

  [string] GetFilterScope([FilterSubject]$subject, [CoreFilter]$filter) {
    return $subject.Value.$($filter.Scope);
  }
}

class AllCompoundHandler : CompoundHandler {
  AllCompoundHandler([hashtable]$filters): base($filters) { }

  [boolean] Accept([FilterSubject]$subject) {
    [boolean]$accepted = $true;

    [IEnumerator]$enumerator = $this.Filters.GetEnumerator();

    while ($accepted -and $enumerator.MoveNext()) {
      [CoreFilter]$filter = $enumerator.Current;

      [string]$value = $this.GetFilterScope($subject, $filter);
      $accepted = $filter.Pass($value);
    }

    return $accepted;
  }

  [List[FileInfo]] FilesWhere([FilterSubject]$subject, [PSCustomObject]$info) {
    throw [PSNotImplementedException]::new('AllCompoundHandler.FilesWhere: AWAITING IMPL');
  }
}

class AnyCompoundHandler : CompoundHandler {
  AnyCompoundHandler([hashtable]$filters): base($filters) { }

  [boolean] Accept([FilterSubject]$subject) {
    [boolean]$accepted = $false;

    [IEnumerator]$enumerator = $this.Filters.GetEnumerator();
    while (-not($accepted) -and $enumerator.MoveNext()) {
      [CoreFilter]$filter = $enumerator.Current;

      [string]$value = $this.GetFilterScope($subject, $filter);
      $accepted = $filter.Pass($value);
    }

    return $accepted;
  }

  [List[FileInfo]] FilesWhere([FilterSubject]$subject, [PSCustomObject]$info) {
    throw [PSNotImplementedException]::new('AnyCompoundHandler.FilesWhere: AWAITING IMPL');
  }
}

class CompoundFilter: FilterDriver {

  # Checks the subject.Scope and acts accordingly
  #
  # FilterScope => filter
  #
  [hashtable]$Filters = @{}
  [CompoundHandler]$Handler;
  static [hashtable]$CompoundTypeToClassName = @{
    [CompoundType]::All = "AllCompoundHandler";
    [CompoundType]::Any = "AnyCompoundHandler"
  };

  CompoundFilter([CompoundType]$compoundType, [hashtable]$filters) {
    $this.Filters = $filters;

    if (-not([CompoundFilter]::CompoundTypeToClassName.ContainsKey($compoundType))) {
      throw "CompoundFilter.ctor, invalid compound type: '$($compoundType)'";
    }
    $this.Handler = New-Object $([CompoundFilter]::CompoundTypeToClassName[$compoundType]) @($filters);
  }

  [boolean] Accept([FilterSubject]$subject) {
    return $this.Handler.Accept($subject);
  }

  [List[FileInfo]] FilesWhere([FilterSubject]$subject, [PSCustomObject]$info) {
    return $this.Handler.Accept($subject, $info);
  }
}

class FilterNode {
  [PSCustomObject]$Data;

  FilterNode([PSCustomObject]$source) {
    $this.Data = $source;
  }

  [string] ToString() {
    return "FilterNode?"
  }
}


class FilterStrategy {
  [int]$ChildSegmentNo = 0;

  FilterStrategy([PSCustomObject]$strategyInfo) {
    $this.ChildSegmentNo = $strategyInfo.ChildSegmentNo;
  }

  [FilterNode] GetNode([PSCustomObject]$info) {
    throw [NotImplementedException]::new("FilterStrategy.GetNode");
  }

  [boolean] Preview([FilterNode]$node) {
    throw [PSNotImplementedException]::new("FilterStrategy.Preview");
  }

  static [array] GetSegments ([string]$rootPath, [string]$fullName) {
    [string]$rootParentPath = Split-Path -Path $rootPath;
    [string]$relativePath = $fullName.Substring($rootParentPath.Length + 1);

    [array]$segments = $($global:IsWindows) ? $($relativePath -split "\\") : $(
      $($relativePath -split [Path]::AltDirectorySeparatorChar)
    );

    return $segments;
  } 
}

class LeafGenerationStrategy: FilterStrategy {
  
  LeafGenerationStrategy(): base([PSCustomObject]@{
      ChildSegmentNo = 2;
    }) {

  }

  [FilterNode] GetNode([PSCustomObject]$info) {
    [boolean]$isLeaf = $($info.DirectoryInfo.GetDirectories()).Count -eq 0;
    [string]$rootPath = $info.Exchange["LOOPZ.FILTER.ROOT-PATH"];
    [string[]]$segments = [FilterStrategy]::GetSegments($rootPath, $info.DirectoryInfo.FullName);

    [boolean]$childAvailable = $($segments.Length -gt $this.ChildSegmentNo);
    [boolean]$leafAvailable = $($segments.Length -gt ($this.ChildSegmentNo + 1));

    [string]$childName = $($childAvailable ?
      $segments[$this.ChildSegmentNo] : [string]::Empty
    );

    [string]$leafName = $($($leafAvailable -and $isLeaf) ?
      $segments[-1] : [string]::Empty
    );

    # segment 0 means something, not quite sure yet
    #
    [FilterSubject]$subject = [FilterSubject]::new([PSCustomObject]@{
        ChildSegmentNo = $this.ChildSegmentNo;
        IsChild        = $childName -eq $info.DirectoryInfo.Name;
        IsLeaf         = $isLeaf;
        SegmentNo      = 1;
        Segments       = $segments;
        FilterScope    = [PSCustomObject]@{
          Current = $info.DirectoryInfo.Name;
          Parent  = $info.DirectoryInfo.Parent.Name
          Child   = $childName;
          Leaf    = $leafName;
        }
      });

    [FilterNode]$node = [FilterNode]::new([PSCustomObject]@{
        DirectoryInfo = $info.DirectoryInfo;
        Subject       = $subject;
      });

    return $node;
  }

  [boolean] Preview([FilterNode]$node) {
    # -not($node.Data.Subject.IsChild may not be valid in this context
    # because child was only relevant in the yank scenario.
    #
    return $(-not($node.Data.Subject.IsChild) -or 
      $node.Data.Filter.Preview($node.Data.Subject));

    # throw [PSNotImplementedException]::new(
    #   'FilterStrategy.Preview'
    # );
  }
}

# Kerberus is the overall filter controller
# since FilterScope is a bit based enum, we don't have to store it on each
# individual core filter, it can be stored either on Kerberus, or the strategy
#
class Kerberus {
  [FilterDriver]$Driver;

  Kerberus([FilterDriver]$driver) {
    $this.Driver = $driver;
  }

  [boolean] Preview([FilterSubject]$subject) {
    return $this.Driver($subject);
  }

  [boolean] Pass([FilterSubject]$subject) {
    return $this.Driver.Pass($subject);
  }

  [List[FileInfo]] FilesWhere([FilterSubject]$subject, [PSCustomObject]$info) {
    return $this.Driver($info);
  } 
}
