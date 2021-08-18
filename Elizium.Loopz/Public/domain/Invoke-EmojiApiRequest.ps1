
function Invoke-EmojiApiRequest {
  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  param(
    [Parameter()]
    [string]$Uri,

    [Parameter()]
    [hashtable]$Headers
  )
  [Microsoft.PowerShell.Commands.BasicHtmlWebResponseObject]$response = $(
    Invoke-WebRequest -Uri $Uri -Headers $Headers
  );

  [PSCustomObject]$result = [PSCustomObject]@{
    StatusCode        = $response.StatusCode;
    StatusDescription = $response.StatusDescription;
    Headers           = $response.Headers;
    Content           = $response.Content;
  }

  return $result;
}
