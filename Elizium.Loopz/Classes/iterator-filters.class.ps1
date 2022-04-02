using namespace System;
using namespace System.IO;
using namespace System.Management.Automation;
using namespace System.Collections;
using namespace System.Collections.Generic;

[Flags()]
Enum FilterScope {
  Nil = 0

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
  [FilterScope]$Scope = [FilterScope]::Current;
  [char]$Not = '!';

  FilterOptions() { }
  
  FilterOptions([FilterScope]$scope) {
    $this.Scope = $scope;
  }

  FilterOptions([FilterScope]$scope, [char]$not) {
    $this.Scope = $scope;
    $this.Not = $not;
  }

  FilterOptions([FilterOptions]$original) {
    $this.Scope = $original.Scope;
    $this.Not = $original.Not;
  }

  [string] ToString() {
    return "[Options] - Scope: '$($this.Scope)', Not: '$($this.Not)'";
  }
}

class FilterSubject {
  [PSCustomObject]$Data;

  FilterSubject([PSCustomObject]$data) {
    $this.Data = $data;
  }
}

class CoreFilter {
  [FilterOptions]$Options;

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

  GlobFilter([FilterOptions]$options, [string]$glob): base($options) {
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

  RegexFilter([FilterOptions]$options, [string]$expression, [string]$label): base($options) {
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

  # TBD: Preview

  [boolean] Accept([FilterSubject]$subject) {
    throw [PSNotImplementedException]::new('FilterDriver.Accept');
  }

  [List[FileInfo]] SelectFiles([FilterSubject]$subject, [PSCustomObject]$info) {
    return $this.Core.FilesWhere($subject.Value, $info);
  }
}

# A unary filter can drive a NoFilter core filter
#
class UnaryFilter: FilterDriver {
  [CoreFilter]$Core
  UnaryFilter([CoreFilter]$core): base($core) {
    $this.Core = $core;
  }

  [boolean] Accept([FilterSubject]$subject) {
    return $this.Core.Pass($subject.Data.Value.$($this.Core.Options.Scope));
  }

  [List[FileInfo]] SelectFiles([FilterSubject]$subject, [PSCustomObject]$info) {
    return $this.Core.FilesWhere($subject.Data.Value, $info);
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

  CompoundHandler([hashtable]$filters) {
    $this.Filters = $filters;
  }

  [boolean] Accept([FilterSubject]$subject) {
    throw [PSNotImplementedException]::new('CompoundHandler.Accept: ABSTRACT');
  }

  [List[FileInfo]] FilesWhere([FilterSubject]$subject, [PSCustomObject]$info) {
    throw [PSNotImplementedException]::new('CompoundHandler.FilesWhere: ABSTRACT');
  }

  # the strategy should create the subject, then invoke GetSubjectValue.
  # but how does this work in the compound scenarios? The handler will
  # call GetSubjectValue multiple times, one for each appropriate core
  # filter, then pass this value to the core filter in pass/preview etc.
  # The context creates the node via the strategy.
  #
  [string] GetSubjectValue([FilterSubject]$subject, [CoreFilter]$filter) {
    return $subject.Data.Value.$($filter.Options.Scope);
  }
}

class AllCompoundHandler : CompoundHandler {
  AllCompoundHandler([hashtable]$filters): base($filters) { }

  [boolean] Accept([FilterSubject]$subject) {
    [boolean]$accepted = $true;

    [IEnumerator]$enumerator = $this.Filters.GetEnumerator();

    while ($accepted -and $enumerator.MoveNext()) {
      [CoreFilter]$filter = $enumerator.Current.Value;
      
      [string]$value = $this.GetSubjectValue($subject, $filter);
      $accepted = $filter.Pass($value);
    }

    return $accepted;
  }

  [List[FileInfo]] SelectFiles([FilterSubject]$subject, [PSCustomObject]$info) {
    throw [PSNotImplementedException]::new('AllCompoundHandler.SelectFiles: AWAITING IMPL');
  }
}

class AnyCompoundHandler : CompoundHandler {
  AnyCompoundHandler([hashtable]$filters): base($filters) { }

  [boolean] Accept([FilterSubject]$subject) {
    [boolean]$accepted = $false;

    [IEnumerator]$enumerator = $this.Filters.GetEnumerator();
    while (-not($accepted) -and $enumerator.MoveNext()) {
      [CoreFilter]$filter = $enumerator.Current.Value;

      [string]$value = $this.GetSubjectValue($subject, $filter);
      $accepted = $filter.Pass($value);
    }

    return $accepted;
  }

  [List[FileInfo]] SelectFiles([FilterSubject]$subject, [PSCustomObject]$info) {
    throw [PSNotImplementedException]::new('AnyCompoundHandler.SelectFiles: AWAITING IMPL');
  }
}

class CompoundFilter: FilterDriver {

  # Checks the subject.Scope and acts accordingly
  #
  # FilterScope => filter
  #
  [hashtable]$Filters = @{} # should this be integrated into handler?
  [CompoundHandler]$Handler;
  static [hashtable]$CompoundTypeToClassName = @{
    [CompoundType]::All = "AllCompoundHandler";
    [CompoundType]::Any = "AnyCompoundHandler"
  };

  CompoundFilter([CompoundHandler]$handler): base([NoFilter]::new([FilterScope]::Nil)) {
    $this.Handler = $handler;
  }

  # DEPRECATED
  #
  CompoundFilter([CompoundType]$compoundType, [hashtable]$filters) {
    $this.Filters = $filters;

    if (-not([CompoundFilter]::CompoundTypeToClassName.ContainsKey($compoundType))) {
      throw "CompoundFilter.ctor, invalid compound type: '$($compoundType)'";
    }
    # TODO: this handler should be injected via ctor
    #
    $this.Handler = New-Object $([CompoundFilter]::CompoundTypeToClassName[$compoundType]) @($filters);
  }

  [boolean] Accept([FilterSubject]$subject) {
    return $this.Handler.Accept($subject);
  }

  [List[FileInfo]] SelectFiles([FilterSubject]$subject, [PSCustomObject]$info) {
    return $this.Handler.SelectFiles($subject, $info);
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
        Value          = [PSCustomObject]@{
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
