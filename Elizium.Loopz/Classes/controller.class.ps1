
# The only reason why all the controller classes are implemented in the same file is because
# there is a deficiency in PSScriptAnalyzer (in VSCode) which reports class references as errors
# if they are not defined in the same file from where they are referenced. The only way to circumvent
# this problem is to place all class related code into the same file.
#
enum ControllerType {
  ForeachCtrl = 0
  TraverseCtrl = 1
}

class Counter {
  [int]hidden $_errors = 0;
  [int]hidden $_value = 0;
  [int]hidden $_skipped = 0;

  [int] Increment() {
    return ++$this._value;
  }

  [int] Value() {
    return $this._value;
  }

  [int] IncrementError() {
    return ++$this._errors;
  }

  [int] Errors() {
    return $this._errors;
  }

  [int] IncrementSkipped() {
    return ++$this._skipped;
  }

  [int] Skipped() {
    return $this._skipped;
  }
}

class BaseController {
  [scriptblock]$_header;
  [scriptblock]$_summary;
  [hashtable]hidden $_exchange;
  [int]hidden $_index = 0;
  [boolean]$_trigger = $false;
  [boolean]hidden $_broken = $false;

  BaseController([hashtable]$exchange,
    [scriptblock]$header,
    [scriptblock]$summary) {
    $this._exchange = $exchange;
    $this._header = $header;
    $this._summary = $summary;
  }

  [int] RequestIndex() {
    if ($this._exchange.ContainsKey('LOOPZ.CONTROLLER.STACK')) {
      $this._exchange['LOOPZ.CONTROLLER.STACK'].Peek().Increment();
    }
    return $this._exchange['LOOPZ.FOREACH.INDEX'] = $this._index++;
  }

  [boolean] IsBroken () {
    return $this._broken;
  }

  [boolean] GetTrigger() {
    return $this._trigger;
  }

  # I don't know how to define abstract methods in PowerShell classes, so
  # throwing an exception is the best thing we can do for now.
  #
  [void] SkipItem() {
    throw [System.Management.Automation.MethodInvocationException]::new(
      'Abstract method not implemented (BaseController.SkipItem)');
  }

  [int] Skipped() {
    throw [System.Management.Automation.MethodInvocationException]::new(
      'Abstract method not implemented (BaseController.Skipped)');
  }

  [void] ErrorItem() {
    throw [System.Management.Automation.MethodInvocationException]::new(
      'Abstract method not implemented (BaseController.ErrorItem)');
  }

  [int] Errors() {
    throw [System.Management.Automation.MethodInvocationException]::new(
      'Abstract method not implemented (BaseController.Errors)');
  }

  [void] ForeachBegin () {
    [System.Collections.Stack]$stack = $this._exchange.ContainsKey('LOOPZ.CONTROLLER.STACK') `
      ? ($this._exchange['LOOPZ.CONTROLLER.STACK']) : ([System.Collections.Stack]::new());

    $stack.Push([Counter]::new());
    $this._exchange['LOOPZ.CONTROLLER.DEPTH'] = $stack.Count;
    $this._header.InvokeReturnAsIs($this._exchange);
  }

  [void] ForeachEnd () {
    throw [System.Management.Automation.MethodInvocationException]::new(
      'Abstract method not implemented (BaseController.ForeachEnd)');
  }

  [void] BeginSession () {}
  [void] EndSession () {}

  [void] HandleResult([PSCustomObject]$invokeResult) {
    # Note, the _index at this point has already been incremented and refers to the
    # next allocated item.
    #
    if ($invokeResult) {
      if ($invokeResult.psobject.properties.match('Trigger') -and $invokeResult.Trigger) {
        $this._exchange['LOOPZ.FOREACH.TRIGGER'] = $true;
        $this._trigger = $true;
      }

      if ($invokeResult.psobject.properties.match('Break') -and $invokeResult.Break) {
        $this._broken = $true;
      }

      if ($invokeResult.psobject.properties.match('Skipped') -and $invokeResult.Skipped) {
        $this.SkipItem();
      }
    }
  }
}

class ForeachController : BaseController {
  [int]hidden $_skipped = 0;
  [int]hidden $_errors = 0;

  ForeachController([hashtable]$exchange,
    [scriptblock]$header,
    [scriptblock]$summary
  ): base($exchange, $header, $summary) {

  }

  [void] SkipItem() {
    $this._skipped++;
  }

  [int] Skipped() {
    return $this._skipped;
  }

  [void] ErrorItem() {
    $this._errors++;
  }

  [int] Errors() {
    return $this._errors;
  }

  [void] ForeachEnd () {
    $this._exchange['LOOPZ.FOREACH.TRIGGER'] = $this._trigger;
    $this._exchange['LOOPZ.FOREACH.COUNT'] = $this._index;

    $this._summary.InvokeReturnAsIs($this._index, $this._skipped, $this._trigger, $this._exchange);
  }
}

class TraverseController : BaseController {

  [PSCustomObject]$_session = @{
    Count   = 0;
    Errors  = 0;
    Skipped = 0;
    Trigger = $false;
    Header  = $null;
    Summary = $null;
  }

  TraverseController([hashtable]$exchange,
    [scriptblock]$header,
    [scriptblock]$summary,
    [scriptblock]$sessionHeader,
    [scriptblock]$sessionSummary
  ): base($exchange, $header, $summary) {
    $this._session.Header = $sessionHeader;
    $this._session.Summary = $sessionSummary;
  }

  [void] SkipItem() {
    $this._exchange['LOOPZ.CONTROLLER.STACK'].Peek().IncrementSkipped();
  }

  [int] Skipped() {
    return $this._session.Skipped;
  }

  [void] ErrorItem() {
    $this._exchange['LOOPZ.CONTROLLER.STACK'].Peek().IncrementError();
  }

  [int] Errors() {
    return $this._session.Errors;
  }

  [void] ForeachEnd () {
    $this._exchange['LOOPZ.FOREACH.TRIGGER'] = $this._trigger;
    $this._exchange['LOOPZ.FOREACH.COUNT'] = $this._index;

    [System.Collections.Stack]$stack = $this._exchange['LOOPZ.CONTROLLER.STACK'];
    [Counter]$counter = $stack.Pop();
    $this._exchange['LOOPZ.CONTROLLER.DEPTH'] = $stack.Count;
    $this._session.Count += $counter.Value();
    $this._session.Errors += $counter.Errors();
    $this._session.Skipped += $counter.Skipped();
    if ($this._trigger) {
      $this._session.Trigger = $true;
    }

    $this._summary.InvokeReturnAsIs($counter.Value(), $counter.Skipped(), $this._trigger, $this._exchange);
  }

  [void] BeginSession () {
    [System.Collections.Stack]$stack = [System.Collections.Stack]::new();

    # The Counter for the session represents the top-level invoke
    #
    $stack.Push([Counter]::new());
    $this._exchange['LOOPZ.CONTROLLER.STACK'] = $stack;
    $this._exchange['LOOPZ.CONTROLLER.DEPTH'] = $stack.Count;
    $this._session.Header.InvokeReturnAsIs($this._exchange);
  }

  [void] EndSession () {
    [System.Collections.Stack]$stack = $this._exchange['LOOPZ.CONTROLLER.STACK'];

    # This counter value represents the top-level invoke which is not included in
    # a foreach sequence.
    #
    [Counter]$counter = $stack.Pop();
    $this._exchange['LOOPZ.CONTROLLER.DEPTH'] = $stack.Count;

    if ($stack.Count -eq 0) {
      $this._exchange.Remove('LOOPZ.CONTROLLER.STACK');
    }
    else {
      Write-Warning "!!!!!! END-SESSION; stack contains $($stack.Count) excess items";
    }

    $this._session.Count += $counter.Value();
    $this._session.Summary.InvokeReturnAsIs($this._session.Count,
      $this._session.Skipped,
      $this._session.Trigger,
      $this._exchange
    );
  }
}

function New-Controller {
  [CmdletBinding(DefaultParameterSetName = 'Iterating')]
  [OutputType([BaseController])]
  param (
    [Parameter(ParameterSetName = 'Iterating')]
    [Parameter(ParameterSetName = 'Traversing')]
    [ControllerType]$Type,

    [Parameter(ParameterSetName = 'Iterating')]
    [Parameter(ParameterSetName = 'Traversing')]
    [hashtable]$Exchange,

    [Parameter(ParameterSetName = 'Iterating')]
    [Parameter(ParameterSetName = 'Traversing')]
    [scriptblock]$Header,

    [Parameter(ParameterSetName = 'Iterating')]
    [Parameter(ParameterSetName = 'Traversing')]
    [scriptblock]$Summary,

    [Parameter(ParameterSetName = 'Traversing')]
    [scriptblock]$SessionHeader,

    [Parameter(ParameterSetName = 'Traversing')]
    [scriptblock]$SessionSummary
  )

  $instance = $null;

  switch ($Type) {
    ForeachCtrl {
      $instance = [ForeachController]::new($Exchange, $Header, $Summary);
      break;
    }

    TraverseCtrl {
      $instance = [TraverseController]::new($Exchange, $Header, $Summary,
        $SessionHeader, $SessionSummary);
      break;
    }
  }

  $instance;
}