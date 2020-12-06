
Describe 'format-ColouredLine' -Tag 'Current' {
  BeforeAll {
    . .\Internal\format-ColouredLine.ps1

    [string]$script:LineKey = 'LOOPZ.HEADER-BLOCK.LINE';
    [string]$script:CrumbKey = 'LOOPZ.HEADER-BLOCK.CRUMB';
    [string]$script:MessageKey = 'LOOPZ.HEADER-BLOCK.MESSAGE';
    [string]$script:ruler = $LoopzUI.DotsLine;
  }

  # General note about these tests; Assertions should include the line length
  # being equal to the ruler length (ruler = $LoopzUI.EqualsLine)

  Context 'given: Plain line' {
    It 'should: create coloured line without crumb or message' -Tag 'Current' {
      [System.Collections.Hashtable]$passThru = @{
        'LOOPZ.HEADER-BLOCK.LINE' = $LoopzUI.EqualsLine;
      }

      $line = format-ColouredLine -PassThru $passThru -LineKey $LineKey -CrumbKey $CrumbKey;

      Write-Host "$ruler"
      Write-InColour -TextSnippets $line;
    }
  } # given: Plain line

  Context 'given: Message and Crumb' {
    BeforeEach {
      [System.Collections.Hashtable]$signals = @{
        'CRUMB-B' = @('Crumb', '🚀')
      }
      [System.Collections.Hashtable]$script:passThru = @{
        'LOOPZ.SIGNALS'            = $signals;
        'LOOPZ.HEADER-BLOCK.CRUMB' = 'CRUMB-B';
        'LOOPZ.HEADER-BLOCK.LINE'  = $LoopzUI.EqualsLine;
      }
    }

    It 'should: create coloured line' {
      $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = 'Children of the Damned';

      $line = format-ColouredLine -PassThru $passThru `
        -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey;

      Write-Host "$ruler"
      Write-InColour -TextSnippets $line;
    }

    Context 'and: Large message' {
      It 'should: create coloured line with Overflowing message' {
        [string]$longMessage = ([string]::new('.', 6)).Replace('.', 'The Number of the Beast ');
        $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;

        $line = format-ColouredLine -PassThru $passThru `
          -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey;

        Write-Host "$ruler"
        Write-InColour -TextSnippets $line;
      }

      Context 'and: Truncate' {
        It 'should: create coloured line with Truncated message' {
          [string]$longMessage = ([string]::new('.', 6)).Replace('.', 'Hallowed by thy Name ');
          $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;

          $line = format-ColouredLine -PassThru $passThru `
            -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate;

          Write-Host "$ruler"
          Write-InColour -TextSnippets $line;

          # THIS FAILS WHEN MinimumFlexSize is specified
          $line = format-ColouredLine -PassThru $passThru `
            -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate -MinimumFlexSize 12;

          Write-Host "$ruler"
          Write-InColour -TextSnippets $line;

          # THIS FAILS WHEN MinimumFlexSize is specified
          $line = format-ColouredLine -PassThru $passThru `
            -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate -MinimumFlexSize 3;

          Write-Host "$ruler"
          Write-InColour -TextSnippets $line;
        }

        Context 'and: LineKey not present' {
          It 'should: create coloured line with Truncated message' {
            $passThru.Remove($LineKey);

            [string]$longMessage = ([string]::new('.', 6)).Replace('.', 'Hallowed by thy Fame ');
            $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;

            $line = format-ColouredLine -PassThru $passThru `
              -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate;

            Write-Host "$ruler"
            Write-InColour -TextSnippets $line;
          }
        }
      }
    }
  } # given: Message and Crumb

  Context 'given: Message Only' {
    BeforeEach {
      [System.Collections.Hashtable]$script:passThru = @{
        'LOOPZ.HEADER-BLOCK.LINE' = $LoopzUI.EqualsLine;
      }
    }

    It 'should: create coloured line' {
      $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = '22 Acacia Avenue';

      $line = format-ColouredLine -PassThru $passThru `
        -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey;

      Write-Host "$ruler"
      Write-InColour -TextSnippets $line;
    }

    Context 'and: Large message' {
      It 'should: create coloured line with Overflowing message' {
        [string]$longMessage = ([string]::new('.', 5)).Replace('.', 'Stranger in a Strange Land ');

        $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;

        $line = format-ColouredLine -PassThru $passThru `
          -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey;

        Write-Host "$ruler"
        Write-InColour -TextSnippets $line;
      }
    }

    Context 'and: Truncate' {
      It 'should: create coloured line with Truncated message' {
        [string]$longMessage = ([string]::new('.', 8)).Replace('.', 'Heaven Can Wait ');

        $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;
        $passThru['LOOPZ.HEADER-BLOCK.LINE'] = $LoopzUI.SmallEqualsLine;

        $line = format-ColouredLine -PassThru $passThru `
          -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate;

        Write-Host "$($LoopzUI.SmallDotsLine)"
        Write-InColour -TextSnippets $line;

        $line = format-ColouredLine -PassThru $passThru `
          -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate -MinimumFlexSize 3;

        Write-Host "$($LoopzUI.SmallDotsLine)"
        Write-InColour -TextSnippets $line;

        $line = format-ColouredLine -PassThru $passThru `
          -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate -MinimumFlexSize 9;

        Write-Host "$($LoopzUI.SmallDotsLine)"
        Write-InColour -TextSnippets $line;
      }

      Context 'and: LineKey not present' {
        It 'should: create coloured line with Truncated message' {
          $passThru.Remove($LineKey);

          [string]$longMessage = ([string]::new('.', 8)).Replace('.', 'Heaven Can Bait ');
          $passThru['LOOPZ.HEADER-BLOCK.MESSAGE'] = $longMessage;

          $line = format-ColouredLine -PassThru $passThru `
            -LineKey $LineKey -CrumbKey $CrumbKey -MessageKey $MessageKey -Truncate;

          Write-Host "$($LoopzUI.SmallDotsLine)"
          Write-InColour -TextSnippets $line;
        }
      }
    }
  } # given: Message Only

  Context 'given: Crumb Only' {
    BeforeEach {
      [System.Collections.Hashtable]$signals = @{
        'CRUMB-B' = @('Crumb', '🔥')
      }
      [System.Collections.Hashtable]$script:passThru = @{
        'LOOPZ.SIGNALS'            = $signals;
        'LOOPZ.HEADER-BLOCK.CRUMB' = 'CRUMB-B';
        'LOOPZ.HEADER-BLOCK.LINE'  = $LoopzUI.TildeLine;
      }
    }

    It 'should: create coloured line' {
      $line = format-ColouredLine -PassThru $passThru -LineKey $LineKey -CrumbKey $CrumbKey;

      Write-Host "$ruler"
      Write-InColour -TextSnippets $line;
    }
  }
}
