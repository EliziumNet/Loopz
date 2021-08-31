
function get-CurrentTime {
  param(
    [string]$Format = 'dd-MMM-yyyy_HH-mm-ss'
  )
  return Get-Date -Format $Format;
}
