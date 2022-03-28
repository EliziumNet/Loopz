
class Shell {
  [string]$FullPath;
  [System.Text.StringBuilder] $_builder = [System.Text.StringBuilder]::new()

  Shell([string]$path) {
    $this.FullPath = $path;
  }

  [void] persist() {
    throw [System.Management.Automation.MethodInvocationException]::new(
      'Abstract method not implemented (Shell.persist)');
  }
}

class PoShShell : Shell {
  PoShShell([string]$path): base($path) {
  }

  [void] rename ([string]$from, [string]$to) {
    [string]$toFilename = [System.IO.Path]::GetFileName($to)
    [void]$this._builder.AppendLine($("Rename-Item -LiteralPath '$from' -NewName '$toFilename'"));
  }

  [void] persist([string]$content) {
    Set-Content -LiteralPath $this.FullPath -Value $content;
  }
}

class Operant {

}

class Undo : Operant {
  [Shell]$Shell;
  [System.Collections.ArrayList]$Operations = [System.Collections.ArrayList]::new();

  Undo([Shell]$shell) {
    $this.Shell = $shell;
  }

  [void] alert([PSCustomObject]$operation) {
    # User should pass in a PSCustomObject with Directory, From and To fields
    #
    [void]$this.Operations.Add($operation);
  }

  [void] persist() {
    throw [System.Management.Automation.MethodInvocationException]::new(
      'Abstract method not implemented (Undo.persist)');
  }
}

class UndoRename : Undo {
  UndoRename([Shell]$shell) : base($shell) {

  }

  [string] generate() {
    [string]$result = if ($this.Operations.count -gt 0) {
      $($this.Operations.count - 1)..0 | ForEach-Object {
        [PSCustomObject]$operation = $this.Operations[$_];

        [string]$toPath = Join-Path -Path $operation.Directory -ChildPath $operation.To;
        $this.Shell.rename($toPath, $operation.From);
      }

      $this.Shell._builder.ToString();
    }
    else {
      [string]::Empty;
    }

    return $result;
  }

  [void] finalise() {
    $this.Shell.persist($this.generate());
  }
}
