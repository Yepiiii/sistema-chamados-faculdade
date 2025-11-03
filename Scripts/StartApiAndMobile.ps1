[CmdletBinding()]
param(
    [string]$ApiProjectPath = (Join-Path $PSScriptRoot "..\SistemaChamados.csproj"),
    [string]$ApiLaunchProfile = "http",
    [string]$MobileProjectPath = (Join-Path $PSScriptRoot "..\SistemaChamados.Mobile\SistemaChamados.Mobile.csproj"),
    [string]$MobileTargetFramework = "net8.0-windows10.0.19041.0",
    [switch]$Android,
    [int]$ApiReadyTimeoutSeconds = 90,
    [int]$ApiPollIntervalSeconds = 3,
    [string]$ApiHealthUrl = "http://localhost:5246/swagger/index.html"
)

if ($Android.IsPresent) {
    $MobileTargetFramework = "net8.0-android"
}

Write-Host "Starting API using project: $ApiProjectPath" -ForegroundColor Cyan
$apiJob = Start-Job -ScriptBlock {
    param($projPath, $launchProfile)
    dotnet run --project $projPath --launch-profile $launchProfile
} -ArgumentList $ApiProjectPath, $ApiLaunchProfile

try {
    Write-Host "Waiting for API to respond at $ApiHealthUrl" -ForegroundColor Cyan
    $elapsed = 0
    $apiReady = $false

    while (-not $apiReady -and $elapsed -lt $ApiReadyTimeoutSeconds) {
        Start-Sleep -Seconds $ApiPollIntervalSeconds
        $elapsed += $ApiPollIntervalSeconds

        try {
            Invoke-WebRequest -Uri $ApiHealthUrl -UseBasicParsing -ErrorAction Stop | Out-Null
            $apiReady = $true
        }
        catch {
            if ($elapsed -ge $ApiReadyTimeoutSeconds) {
                throw "API did not respond within $ApiReadyTimeoutSeconds seconds."
            }
        }
    }

    Write-Host "API is running." -ForegroundColor Green

    if ($Android.IsPresent) {
        Write-Host "Launching mobile app for Android. Ensure an emulator or device is available." -ForegroundColor Yellow
    }
    else {
        Write-Host "Launching mobile app targeting $MobileTargetFramework" -ForegroundColor Cyan
    }

    $runArgs = @("build", $MobileProjectPath, "-t:Run", "-f", $MobileTargetFramework)
    dotnet @runArgs
}
finally {
    if ($apiJob.State -eq "Running") {
        Write-Host "Stopping API process..." -ForegroundColor Yellow
        Stop-Job -Job $apiJob -ErrorAction SilentlyContinue
    }

    Receive-Job -Job $apiJob -ErrorAction SilentlyContinue | Out-String | Write-Verbose
    Remove-Job -Job $apiJob -ErrorAction SilentlyContinue
}
