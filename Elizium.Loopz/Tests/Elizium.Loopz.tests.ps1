﻿$moduleRoot = Resolve-Path "$PSScriptRoot/.."
$moduleName = Split-Path $moduleRoot -Leaf

Describe "General project validation: $moduleName" -Tag "Source" {

  $scripts = Get-ChildItem $moduleRoot -Include *.ps1, *.psm1, *.psd1 -Recurse

  # TestCases are splatted to the script so we need hashtables
  $testCase = $scripts | Foreach-Object { @{file = $_ } }
  It "Script <file> should be valid powershell" -TestCases $testCase -Tag "Source" {
    param($file)

    $file.fullName | Should -Exist

    $contents = Get-Content -Path (Resolve-Path $file.fullName) -ErrorAction Stop
    $errors = $null
    $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
    $errors.Count | Should -Be 0
  }
}
