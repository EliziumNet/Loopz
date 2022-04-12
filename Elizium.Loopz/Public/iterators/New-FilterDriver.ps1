
function New-FilterDriver {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
  [CmdletBinding()]
  [OutputType([FilterDriver])]
  param(  
    [Parameter(Mandatory)]
    [hashtable]$Parameters
  )
  function get-newOptions {
    [OutputType([FilterOptions])]
    param(
      [Parameter(Mandatory)]
      [FilterOptions]$Scope
    )
    [boolean]$notDefined = $Parameters.ContainsKey("Not");

    $notDefined ? $(
      [FilterOptions]::new($Scope, $Parameters["Not"])
    ) : $(
      [FilterOptions]::new($Scope)
    );
  }

  function get-core {
    [OutputType([CoreFilter])]
    param(
      [Parameter(Mandatory, Position = 0)]
      [string]$CoreClass,

      [Parameter(Mandatory, Position = 1)]
      [FilterScope]$Scope,

      [Parameter(Mandatory, Position = 2)]
      [array]$ArgumentList
    )

    [FilterOptions]$options = get-newOptions -Scope $Scope;
    [array]$combined = @(, $options) + $ArgumentList;

    return $(New-Object $CoreClass $combined);
  }

  function get-unary {
    [OutputType([UnaryFilter])]
    param(
      [Parameter(Mandatory, Position = 0)]
      [string]$CoreClass,

      [Parameter(Mandatory, Position = 1)]
      [FilterScope]$Scope,

      [Parameter(Position = 2)]
      [array]$ArgumentList = @()
    )
    [FilterOptions]$options = get-newOptions -Scope $Scope;
    [array]$combined = ($ArgumentList.Count -gt 0) `
      ? $(@(, $options) + $ArgumentList) `
      : @(, $options);

    return [UnaryFilter]::new(
      $(New-Object $CoreClass $combined)
    )
  }

  function get-compound {
    [OutputType([CompoundFilter])]
    param(
      [Parameter(Mandatory, Position = 0)]
      [hashtable]$Filters
    )

    [string]$handlerClass = [CompoundHandler]::CompoundTypeToClassName[$(
      ([CompoundType]$Parameters["op"])
    )];

    return [CompoundFilter]::new($(
        New-Object $handlerClass $Filters
      ));
  }

  function get-filters {
    [OutputType([hashtable])]
    param(
      [Parameter(Mandatory)]
      [string]$ChildClass,

      [Parameter(Mandatory)]
      [array]$ChildArgs,

      [Parameter(Mandatory)]
      [string]$LeafClass,

      [Parameter(Mandatory)]
      [array]$LeafArgs
    )
    [hashtable]$filters = @{
      [FilterScope]::Child = $(
        get-core -CoreClass $ChildClass -Scope $([FilterScope]::Child) -ArgumentList $ChildArgs
      );

      [FilterScope]::Leaf  = $(
        get-core -CoreClass $LeafClass -Scope $([FilterScope]::Leaf) -ArgumentList $LeafArgs
      );
    }

    return $filters;
  }

  # Assuming that the parameter set validation on Select-ChildFsItems(yank), ensures
  # that the correct parameters appear inside PSBoundParameters(parameters), so we
  # don"t have to re-check here.
  #
  [FilterDriver]$driver = if ($Parameters.ContainsKey("cl")) {

    get-unary -CoreClass "GlobFilter" -Scope $([FilterScope]::Child) -ArgumentList @(
      , $Parameters["ChildLike"]);
  }
  elseif ($Parameters.ContainsKey("cm")) {

    get-unary -CoreClass "RegexFilter" -Scope $([FilterScope]::Child) -ArgumentList @(
      $Parameters["ChildPattern"], "child-filter-pattern");
  }
  elseif ($Parameters.ContainsKey("ll")) {

    get-unary -CoreClass "GlobFilter" -Scope $([FilterScope]::Leaf) @(
      , $Parameters["LeafLike"]);
  }
  elseif ($Parameters.ContainsKey("lm")) {

    get-unary -CoreClass "RegexFilter" -Scope $([FilterScope]::Leaf) @(
      $Parameters["LeafPattern"], "leaf-filter-pattern");
  }
  elseif ($Parameters.ContainsKey("cl_lm")) {

    [hashtable]$filters = get-filters -ChildClass "GlobFilter" `
      -ChildArgs @(, $Parameters["ChildLike"]) `
      -LeafClass "RegexFilter" `
      -LeafArgs @($Parameters["LeafPattern"], "leaf-filter-pattern");
  
    get-compound $filters;
  }
  elseif ($Parameters.ContainsKey("cl_ll")) {

    [hashtable]$filters = get-filters -ChildClass "GlobFilter" `
      -ChildArgs @(, $Parameters["ChildLike"]) `
      -LeafClass "GlobFilter" `
      -LeafArgs @($Parameters["LeafLike"]);

    get-compound $filters;
  }
  elseif ($parameters.ContainsKey("cm_lm")) {

    [hashtable]$filters = get-filters -ChildClass "RegexFilter" `
      -ChildArgs @($Parameters["ChildPattern"], "child-filter-pattern") `
      -LeafClass "RegexFilter" `
      -LeafArgs @($Parameters["LeafPattern"], "leaf-filter-pattern");

    get-compound $filters;
  }
  elseif ($parameters.ContainsKey("cm_ll")) {

    [hashtable]$filters = get-filters -ChildClass "RegexFilter" `
      -ChildArgs @($Parameters["ChildPattern"], "child-filter-pattern") `
      -LeafClass "GlobFilter" `
      -LeafArgs @(, $Parameters["LeafLike"]);

    get-compound $filters;
  }
  else {

    get-unary -CoreClass "NoFilter" -Scope $([FilterScope]::Nil);
  }

  return $driver;
}
