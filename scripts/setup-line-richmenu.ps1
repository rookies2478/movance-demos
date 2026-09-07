# Movance LINE Official Account - rich menu create / upload / set default / verify
#
# Usage (run in your own interactive PowerShell):
#   powershell -File line_richmenu_setup.ps1
#   or: pwsh -File line_richmenu_setup.ps1
#
# Spec:
# - Uses env var LINE_CHANNEL_ACCESS_TOKEN if present
# - Otherwise prompts via Read-Host -AsSecureString (not shown on screen)
# - Token is never written to a file, never logged, never committed to Git
# - Token is used only in memory for the API calls, and references are
#   dropped (best effort) at the end of the script

$ErrorActionPreference = 'Stop'

$imagePath = $env:LINE_RICHMENU_IMAGE_PATH
if (-not $imagePath) { $imagePath = 'C:\dev\movance-demos\line-richmenu-2500x1686.jpg' }
$baseUrl = 'https://rookies2478.github.io/movance-demos/'

$plainToken = $null
$secure = $null
$bstr = [IntPtr]::Zero
$headers = $null

try {
    if ($env:LINE_CHANNEL_ACCESS_TOKEN) {
        $plainToken = $env:LINE_CHANNEL_ACCESS_TOKEN
        Write-Host 'Using LINE_CHANNEL_ACCESS_TOKEN from environment variable.'
    }
    else {
        $secure = Read-Host -Prompt 'Enter LINE Channel Access Token (input hidden)' -AsSecureString
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
        $plainToken = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    }

    if ([string]::IsNullOrEmpty($plainToken)) {
        throw 'Token was not provided. Aborting.'
    }

    $headers = @{ Authorization = "Bearer $plainToken" }

    $bodyObj = @{
        size        = @{ width = 2500; height = 1686 }
        selected    = $true
        name        = 'Movance Reservation Demo'
        chatBarText = 'Menu'
        areas       = @(
            @{ bounds = @{ x = 0;    y = 0; width = 834; height = 1686 }; action = @{ type = 'uri'; label = 'Reserve'; uri = "$baseUrl#course" } }
            @{ bounds = @{ x = 834;  y = 0; width = 833; height = 1686 }; action = @{ type = 'uri'; label = 'Access';  uri = "$baseUrl#access" } }
            @{ bounds = @{ x = 1667; y = 0; width = 833; height = 1686 }; action = @{ type = 'uri'; label = 'FAQ';     uri = "$baseUrl#faq" } }
        )
    }
    $bodyJson = $bodyObj | ConvertTo-Json -Depth 10

    Write-Host '[1/5] Checking image file...'
    if (-not (Test-Path $imagePath)) { throw "Image not found: $imagePath" }
    $imageBytes = [IO.File]::ReadAllBytes($imagePath)
    Write-Host "  -> OK ($($imageBytes.Length) bytes, $imagePath)"

    Write-Host '[2/5] Creating rich menu...'
    $createHeaders = $headers.Clone()
    $createHeaders['Content-Type'] = 'application/json; charset=utf-8'
    $createRes = Invoke-RestMethod -Method Post -Uri 'https://api.line.me/v2/bot/richmenu' `
        -Headers $createHeaders -Body ([Text.Encoding]::UTF8.GetBytes($bodyJson))
    $richMenuId = $createRes.richMenuId
    Write-Host "  -> Created: richMenuId=$richMenuId"

    Write-Host '[3/5] Uploading image...'
    $uploadHeaders = $headers.Clone()
    $uploadHeaders['Content-Type'] = 'image/jpeg'
    Invoke-RestMethod -Method Post -Uri "https://api-data.line.me/v2/bot/richmenu/$richMenuId/content" `
        -Headers $uploadHeaders -Body $imageBytes | Out-Null
    Write-Host '  -> Upload succeeded'

    Write-Host '[4/5] Setting as default rich menu...'
    Invoke-RestMethod -Method Post -Uri "https://api.line.me/v2/bot/user/all/richmenu/$richMenuId" `
        -Headers $headers | Out-Null
    Write-Host '  -> Set as default succeeded'

    Write-Host '[5/5] Verifying...'
    $info = Invoke-RestMethod -Uri 'https://api.line.me/v2/bot/info' -Headers $headers
    $detail = Invoke-RestMethod -Uri "https://api.line.me/v2/bot/richmenu/$richMenuId" -Headers $headers
    $defaultCheck = Invoke-RestMethod -Uri 'https://api.line.me/v2/bot/user/all/richmenu' -Headers $headers

    Write-Host "  -> Bot connectivity OK: displayName = $($info.displayName)"
    Write-Host "  -> Rich menu registration OK: name=$($detail.name) size=$($detail.size.width)x$($detail.size.height) areas=$($detail.areas.Count)"
    $match = if ($defaultCheck.richMenuId -eq $richMenuId) { '(match)' } else { '(MISMATCH!)' }
    Write-Host "  -> Default check OK: richMenuId=$($defaultCheck.richMenuId) $match"

    Write-Host ''
    Write-Host "Done: richMenuId = $richMenuId"
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
    throw
}
finally {
    # Best-effort in-memory cleanup (PowerShell strings are immutable, so full
    # wipe cannot be guaranteed, but references are dropped here).
    if ($bstr -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
    if ($secure) { $secure.Dispose() }
    $plainToken = $null
    $headers = $null
    Remove-Variable -Name plainToken, headers, secure, bstr, createHeaders, uploadHeaders -ErrorAction SilentlyContinue
    [GC]::Collect()
}
