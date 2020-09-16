
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
  [System.Collections.Hashtable]hidden $_passThru;
  [int]hidden $_index = 0;
  [int]hidden $_skipped = 0;
  [int]hidden $_errors = 0;
  [boolean]$_trigger = $false;
  [boolean]hidden $_broken = $false;

  BaseController([System.Collections.Hashtable]$passThru,
    [scriptblock]$header,
    [scriptblock]$summary) {
    $this._passThru = $passThru;
    $this._header = $header;
    $this._summary = $summary;
  }

  [int] RequestIndex() {
    if ($this._passThru.ContainsKey('LOOPZ.CONTROLLER.STACK')) {
      $this._passThru['LOOPZ.CONTROLLER.STACK'].Peek().Increment();
    }
    return $this._passThru['LOOPZ.FOREACH.INDEX'] = $this._index++;
  }

  [boolean] IsBroken () {
    return $this._broken;
  }

  [boolean] GetTrigger() {
    return $this._trigger;
  }

  [void] SkipItem() {
    $this._skipped++;
  }

  [void] ErrorItem() {
    if ($this._passThru.ContainsKey('LOOPZ.CONTROLLER.STACK')) {
      $this._passThru['LOOPZ.CONTROLLER.STACK'].Peek().Increment();
    }
    $this._errors++;
  }

  [void]ForeachBegin () {
    [System.Collections.Stack]$stack = $this._passThru.ContainsKey('LOOPZ.CONTROLLER.STACK') `
      ? ($this._passThru['LOOPZ.CONTROLLER.STACK']) : ([System.Collections.Stack]::new());

    $stack.Push([Counter]::new());
    $this._skipped = 0;
    $this._errors = 0;
    $this._header.Invoke($this._passThru);
  }

  [void]ForeachEnd () {
    $this._passThru['LOOPZ.FOREACH.TRIGGER'] = $this._trigger;
    $this._passThru['LOOPZ.FOREACH.COUNT'] = $this._index;

    [int]$count = 0;
    [int]$skipped = 0;
    if ($this._passThru.ContainsKey('LOOPZ.CONTROLLER.STACK')) {
      [Counter]$counter = $this._passThru['LOOPZ.CONTROLLER.STACK'].Pop();
      $count = $counter.Value();
      $skipped = $counter.Skipped();
    } else {
      $count = $this._index;
      $skipped = $this._skipped;
    }
    $this._summary.Invoke($count, $skipped, $this._trigger, $this._passThru);
  }

  [void]StartSession () {}
  [void]EndSession () {}

  [void] HandleResult([PSCustomObject]$invokeResult) {
    # Note, the _index at this point has already been incremented and refers to the
    # next allocated item.
    #
    if ($invokeResult) {
      if ($invokeResult.psobject.properties.match('Trigger') -and $invokeResult.Trigger) {
        $this._passThru['LOOPZ.FOREACH.TRIGGER'] = $true;
        $this._trigger = $true;
      }

      if ($invokeResult.psobject.properties.match('Break') -and $invokeResult.Break) {
        $this._broken = $true;
      }

      if ($invokeResult.psobject.properties.match('Skipped') -and $invokeResult.Skipped) {
        $this._skipped++;
      }
    }
  }
}

class ForeachController : BaseController {
  ForeachController([System.Collections.Hashtable]$passThru,
    [scriptblock]$header,
    [scriptblock]$summary
  ): base($passThru, $header, $summary) {

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

  TraverseController([System.Collections.Hashtable]$passThru,
    [scriptblock]$header,
    [scriptblock]$summary,
    [scriptblock]$sessionHeader,
    [scriptblock]$sessionSummary
  ): base($passThru, $header, $summary) {
    $this._session.Header = $sessionHeader;
    $this._session.Summary = $sessionSummary;
  }

  [void]ForeachEnd () {
    [Counter]$counter = $this._passThru['LOOPZ.CONTROLLER.STACK'].Peek();
    $this._session.Count += $counter.Value();
    $this._session.Errors += $counter.Errors();
    $this._session.Skipped += $counter.Skipped();
    if ($this._trigger) {
      $this._session.Trigger = $true;
    }

    ([BaseController]$this).ForeachEnd();
  }

  [void]StartSession () {
    [System.Collections.Stack]$stack = [System.Collections.Stack]::new();
    $stack.Push([Counter]::new());
    $this._passThru['LOOPZ.CONTROLLER.STACK'] = $stack;
    $this._session.Header.Invoke($this._passThru);
  }

  [void]EndSession () {
    [System.Collections.Stack]$stack = $this._passThru['LOOPZ.CONTROLLER.STACK'];

    # This counter value represents the top-level invoke which is not included in
    # a foreach sequence.
    #
    [Counter]$counter = $stack.Pop();

    if ($stack.Count -eq 0) {
      $this._passThru.Remove('LOOPZ.CONTROLLER.STACK');
    } else {
      Write-Warning "!!!!!! END-SESSION; stack contains $($stack.Count) excess items";
    }

    $this._session.Count += $counter.Value();
    $this._session.Summary.Invoke($this._session.Count,
      $this._session.Skipped,
      $this._session.Trigger,
      $this._passThru
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
    [System.Collections.Hashtable]$PassThru,

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
      $instance = [ForeachController]::new($PassThru, $Header, $Summary);
      break;
    }

    TraverseCtrl {
      $instance = [TraverseController]::new($PassThru, $Header, $Summary,
        $SessionHeader, $SessionSummary);
      break;
    }
  }

  $instance;
}