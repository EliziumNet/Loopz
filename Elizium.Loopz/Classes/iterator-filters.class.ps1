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

  [string] ToString() {
    return "(pattern: '$($this.Rexo)')";
  }
} # RegexFilter

class FilterDriver {
  [CoreFilter]$Core;

  FilterDriver([CoreFilter]$core) {
    $this.Core = $core;
  }

  [boolean] Preview([FilterSubject]$subject, [FilterScope]$contextScope) {
    throw [PSNotImplementedException]::new("FilterDriver.Preview - ABSTRACT");
  }

  [boolean] Accept([FilterSubject]$subject) {
    throw [PSNotImplementedException]::new("FilterDriver.Accept - ABSTRACT");
  }
}

# A unary filter can drive a NoFilter core filter
#
class UnaryFilter: FilterDriver {
  [CoreFilter]$Core
  UnaryFilter([CoreFilter]$core): base($core) {
    $this.Core = $core;
  }

  [boolean] Preview([FilterSubject]$subject, [FilterScope]$contextScope) {
    return $(
      ($this.Core.Options.Scope -ne $contextScope) -or ($this.Accept($subject));
    );
  }

  [boolean] Accept([FilterSubject]$subject) {
    return $this.Core.Pass($subject.Data.Value.$($this.Core.Options.Scope));
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

class FilterIterator {
  [IEnumerable]$Filters;

  FilterIterator([IEnumerable]$filters) {
    $this.Filters = $filters;
  }

  [boolean] Iterate([ScriptBlock]$callback) {
    throw [PSNotImplementedException]::new('FilterIterator.Iterate: ABSTRACT');
  }
}

class FilterAll: FilterIterator {
  FilterAll([IEnumerable]$filters): base($filters) { }

  [boolean] Iterate([ScriptBlock]$callback) {
    [boolean]$result = $true;

    [IEnumerator]$enumerator = $this.Filters.GetEnumerator();

    while ($result -and $enumerator.MoveNext()) {
      [CoreFilter]$filter = $enumerator.Current.Value;
      $result = $callback.InvokeReturnAsIs($filter);
    }

    return $result;
  }
}

class FilterAny: FilterIterator {
  FilterAny([IEnumerable]$filters): base($filters) { }

  [boolean] Iterate([ScriptBlock]$callback) {
    [boolean]$result = $false;

    [IEnumerator]$enumerator = $this.Filters.GetEnumerator();

    while (-not($result) -and $enumerator.MoveNext()) {
      [CoreFilter]$filter = $enumerator.Current.Value;
      $result = $callback.InvokeReturnAsIs($filter);
    }

    return $result;
  }
}

class BaseHandler {
  [IEnumerable]$Filters;
  [FilterIterator]$Iterator;

  BaseHandler([IEnumerable]$filters, [FilterIterator]$iterator) {
    $this.Filters = $filters;
    $this.Iterator = $iterator;
  }

  [void] Iterate([ScriptBlock]$callback) {
    throw [PSNotImplementedException]::new('CompoundHandler.Iterate: ABSTRACT');
  }

  [boolean] Accept([FilterSubject]$subject) {

    [boolean]$accepted = $this.Iterator.Iterate({
        param(
          [CoreFilter]$filter
        )
        return $filter.Pass($subject.Data.Value.$($filter.Options.Scope));
      });

    return $accepted;
  }
}

class CompoundHandler: BaseHandler {

  static [hashtable]$CompoundTypeToClassName = @{
    [CompoundType]::All = "AllCompoundHandler";
    [CompoundType]::Any = "AnyCompoundHandler"
  };

  CompoundHandler([IEnumerable]$filters, [FilterIterator]$iterator): base(
    $filters, $iterator
  ) { }

  [boolean] Preview([FilterSubject]$subject, [FilterScope]$contextScope) {
    [boolean]$result = if ($filter = $this.GetFilterByScope($contextScope)) {
      $filter.Pass($this.GetSubjectValue($subject, $filter));
    }
    else {
      $true;
    }

    return $result;
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

  [CoreFilter] GetFilterByScope([FilterScope]$scope) {
    return $this.Filters[$scope]
  }
}

class AllCompoundHandler : CompoundHandler {
  AllCompoundHandler([hashtable]$filters): base(
    $filters,
    [FilterAll]::new($filters)
  ) { }

}

class AnyCompoundHandler : CompoundHandler {
  AnyCompoundHandler([hashtable]$filters): base(
    $filters,
    [FilterAny]::new($filters)
  ) { }

}

class CompoundFilter: FilterDriver {

  [CompoundHandler]$Handler;

  CompoundFilter([CompoundHandler]$handler): base([NoFilter]::new([FilterScope]::Nil)) {
    $this.Handler = $handler;
  }

  [boolean] Preview([FilterSubject]$subject, [FilterScope]$contextScope) {
    return $this.Handler.Preview($subject, $contextScope);
  }

  [boolean] Accept([FilterSubject]$subject) {
    return $this.Handler.Accept($subject);
  }
}

class PolyHandler: BaseHandler {

  static [hashtable]$CompoundTypeToClassName = @{
    [CompoundType]::All = "AllPolyHandler";
    [CompoundType]::Any = "AnyPolyHandler"
  };

  PolyHandler([IEnumerable]$filters, [FilterIterator]$iterator): base(
    $filters,
    $iterator
  ) { }
}

class AllPolyHandler : PolyHandler {
  AllPolyHandler([CoreFilter[]]$filters): base(
    $filters,
    [FilterAll]::new($filters)
  ) { }

}

class AnyPolyHandler : PolyHandler {
  AnyPolyHandler([CoreFilter[]]$filters): base(
    $filters,
    [FilterAny]::new($filters)
  ) { }

}

class PolyFilter {

  [PolyHandler]$Handler;

  PolyFilter([PolyHandler]$handler) {
    $this.Handler = $handler;
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
  [FilterDriver]$Driver;
  [int]$ChildDepthLevel = 0;
  [int]$ChildSegmentIndex = -1;
  [boolean]$PreferChildScope = $true;
  [boolean]$PreviewLeafNodes = $false; ;

  FilterStrategy([PSCustomObject]$strategyInfo) {
    $this.Driver = $strategyInfo.Driver;
    $this.ChildSegmentIndex = $strategyInfo.ChildSegmentIndex;
    $this.ChildDepthLevel = $strategyInfo.ChildDepthLevel;
    $this.PreferChildScope = $strategyInfo.PreferChildScope;
    $this.PreviewLeafNodes = $strategyInfo.PreviewLeafNodes;
  }

  [FilterNode] GetDirectoryNode([PSCustomObject]$info) {
    [PSCustomObject]$meta = $this.GetSegmentMetaData($info);

    [FilterSubject]$subject = [FilterSubject]::new([PSCustomObject]@{
        IsChild      = $meta.ChildName -eq $info.DirectoryInfo.Name;
        IsLeaf       = $meta.IsLeaf;
        CurrentDepth = $info.Exchange['LOOPZ.CONTROLLER.DEPTH'];
        Value        = [PSCustomObject]@{
          Current = $info.DirectoryInfo.Name;
          Parent  = $info.DirectoryInfo.Parent.Name
          Child   = $meta.ChildName;
          Leaf    = $meta.LeafName;
        }
      });

    [FilterNode]$node = [FilterNode]::new([PSCustomObject]@{
        DirectoryInfo = $info.DirectoryInfo;
        Subject       = $subject;
      });

    return $node;
  }

  [boolean] Preview([FilterNode]$node) {
    throw [PSNotImplementedException]::new("FilterStrategy.Preview - ABSTRACT");
  }

  static [array] GetSegments ([string]$rootPath, [string]$fullName) {
    [string]$rootParentPath = Split-Path -Path $rootPath;
    [string]$relativePath = $fullName.Substring($rootParentPath.Length + 1);

    [array]$segments = $($global:IsWindows) ? $($relativePath -split "\\") : $(
      $($relativePath -split [Path]::AltDirectorySeparatorChar)
    );

    return $segments;
  }

  [PSCustomObject] GetSegmentMetaData ([PSCustomObject]$info) {
    # Loopz DEPTH: a depth of 1 corresponds to the root path specified
    # by the user, so all sub-directories visited by Invoke-TraverseDirectory
    # have a depth of 2 or more. This is why the ChildDepthLevel is set to
    # 2, ie they are the immediate descendants of the user specified root.
    # When the current depth is only 2, there are only 2 segments, 1 is the root
    # and the other is either the child or leaf scopes, hence PreferChildScope
    # which defaults to true. When PreferChildScope = true, then when there
    # is only a single remaining available segment, it is assigned to the child
    # scope.
    #
    [boolean]$isLeaf = $($info.DirectoryInfo.GetDirectories()).Count -eq 0;
    [string]$fullName = $info.DirectoryInfo.FullName;
    [string]$rootPath = $info.Exchange["LOOPZ.FILTER.ROOT-PATH"];

    [string]$rootParentPath = Split-Path -Path $rootPath;
    [string]$relativePath = $fullName.Substring($rootParentPath.Length + 1);

    [array]$segments = $($global:IsWindows) ? $($relativePath -split "\\") : $(
      $($relativePath -split [Path]::AltDirectorySeparatorChar)
    );

    [boolean]$childAv, [boolean]$leafAv = $this.PreferChildScope ? $(
      @(
        $($segments.Length -gt $this.ChildSegmentIndex),
        $($segments.Length -gt ($this.ChildSegmentIndex + 1))
      )
    ) : $(
      @(
        $($segments.Length -gt ($this.ChildSegmentIndex + 1)),
        $($segments.Length -gt $this.ChildSegmentIndex)
      )
    );

    $result = [PSCustomObject]@{
      IsLeaf         = $isLeaf;
      ChildAvailable = $childAv;
      LeafAvailable  = $leafAv;
      ChildName      = $($childAv ?
        $segments[$this.ChildSegmentIndex] : [string]::Empty
      );
      LeafName       = $($($leafAv -and $isLeaf) ?
        $segments[-1] : [string]::Empty
      );
    }

    return $result;
  }
}

class LeafGenerationStrategy: FilterStrategy {
  
  LeafGenerationStrategy([FilterDriver]$Driver): base([PSCustomObject]@{
      Driver            = $Driver;
      ChildSegmentIndex = 1;
      ChildDepthLevel   = 2;
      PreferChildScope  = $true;
      PreviewLeafNodes  = $true;
    }) {

  }

  [boolean] Preview([FilterNode]$node) {
    # We need to know what the context scope is. This scope is then applied to the driver.
    # The strategy knows the context scope so it should just pass in the one that is
    # appropriate. For the LeafGenerationStrategy, the context scope should be child, which
    # means that we should Preview this node if it is not a child node or it is a child node
    # and passes the child filter.
    #
    return $($node.Data.Subject.Data.IsLeaf -and $this.PreviewLeafNodes) -or
    $(-not($node.Data.Subject.Data.IsChild) -or 
      $this.Driver.Preview($node.Data.Subject, [FilterScope]::Child));
  }
}

# Might have to build a PolyDriver, which is similar to PolyFilter, but for
# directories. But, this PolyDriver/PolyFilter thing looks like it pointing
# to a code smell. We should only need 1 Poly entity, that satisfies the
# needs of directories and files.
#
# Perhaps we have a MultiFilter derived from FilterDriver. The MultiFilter takes
# a MultiHandler, which can contain multiple filters, but these filters are
# tied to [FilterScope]::Current.
#
# TODO: Rename all Driver derivatives to be xxxDriver instead of xxxFilter because
# the latter is confusing.
#
class TraverseAllStrategy: FilterStrategy {
  TraverseAllStrategy([FilterDriver]$Driver): base([PSCustomObject]@{
      Driver            = $Driver;
      ChildSegmentIndex = 1;
      ChildDepthLevel   = 2;
      PreferChildScope  = $true;
      PreviewLeafNodes  = $true;
    }) {

  }

  [boolean] Preview([FilterNode]$node) {
    return $(
      $this.Driver.Preview($node.Data.Subject, [FilterScope]::Current)
    );
  }
}

# Kerberus is the overall filter controller
# since FilterScope is a bit based enum, we don't have to store it on each
# individual core filter, it can be stored either on Kerberus, or the strategy
#
class Kerberus {
  [FilterStrategy]$Strategy

  Kerberus([FilterStrategy]$strategy) {
    $this.Strategy = $strategy;
  }

  [boolean] Preview([FilterSubject]$subject) {
    return $this.Strategy($subject);
  }

  [boolean] Pass([FilterSubject]$subject) {
    throw "NOT IMPLEMENTED YET";
  }
}
