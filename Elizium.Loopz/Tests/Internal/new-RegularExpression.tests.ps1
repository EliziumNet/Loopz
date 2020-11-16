
using namespace System.Text.RegularExpressions;

Describe 'new-RegularExpression' -Tag 'Current' {
  BeforeAll {
    . .\Public\globals.ps1
    . .\Internal\new-RegularExpression.ps1
  }

  Context 'given: Pattern contains single inline code' {
    It 'should: Create regex with option <Inc>' -TestCases @(
      @{ Inc = 'm'; Expected = [RegexOptions]::Multiline }
      @{ Inc = 'i'; Expected = [RegexOptions]::IgnoreCase }
      @{ Inc = 'x'; Expected = [RegexOptions]::IgnorePatternWhitespace }
      @{ Inc = 's'; Expected = [RegexOptions]::Singleline }
      @{ Inc = 'n'; Expected = [RegexOptions]::ExplicitCapture }
    ) {
      [Regex]$expression = new-RegularExpression -Expression "utopia/$Inc";

      $expression.Options | Should -Be $Expected
    }
  }

  Context 'given: Pattern contains multiple inline codes' {
    It 'should: Create regex with multiple options' -Tag 'Current' {
      [Regex]$expression = new-RegularExpression -Expression "utopia\mix";
      $expression.Options -band [RegexOptions]::Multiline | Should -BeTrue;
      $expression.Options -band [RegexOptions]::IgnoreCase | Should -BeTrue;
      $expression.Options -band [RegexOptions]::IgnorePatternWhitespace | Should -BeTrue;

      $expression.Options -band [RegexOptions]::Singleline | Should -BeFalse;
      $expression.Options -band [RegexOptions]::ExplicitCapture | Should -BeFalse;

      # This assertion is not strictly necessary, but its handy to see how RegEx stores
      # it options and it points out that you can't interact with the options using
      # the options enum as you'd expect (see the next test). This is just a general
      # issue around enums.
      #
      $expression.Options | Should -BeExactly 'IgnoreCase, Multiline, IgnorePatternWhitespace'
    }
  }

  Context 'given: Pattern contains no inline codes' {
    It 'should: Create regex with no custom options' {
      [Regex]$expression = new-RegularExpression -Expression "utopia";
      $expression.Options | Should -Be 'None' # ... not [RegexOptions]::None;
    }
  }
}