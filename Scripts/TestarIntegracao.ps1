# Script de Teste Integrado - Sistema de Chamados
# Testa Web, Desktop e Mobile simultaneamente

[CmdletBinding()]
param(
    [switch]$SkipBuild,
    [switch]$WebOnly,
    [switch]$DesktopOnly,
    [switch]$MobileOnly,
    [int]$ApiPort = 5246
)

$ErrorActionPreference = "Stop"
$projectRoot = $PSScriptRoot | Split-Path
$apiProject = Join-Path $projectRoot "SistemaChamados.csproj"
$mobileProject = Join-Path $projectRoot "SistemaChamados.Mobile\SistemaChamados.Mobile.csproj"

Write-Host "=== Sistema de Chamados - Teste Integrado ===" -ForegroundColor Cyan
Write-Host ""

# Build projects
if (-not $SkipBuild) {
    Write-Host "Building solution..." -ForegroundColor Yellow
    dotnet build (Join-Path $projectRoot "sistema-chamados-faculdade.sln")
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Build failed!"
        exit 1
    }
    Write-Host "Build successful!" -ForegroundColor Green
    Write-Host ""
}

# Start API
Write-Host "Starting API on port $ApiPort..." -ForegroundColor Yellow
$apiJob = Start-Job -ScriptBlock {
    param($projPath, $port)
    $env:ASPNETCORE_URLS = "http://localhost:$port"
    dotnet run --project $projPath --no-build
} -ArgumentList $apiProject, $ApiPort

try {
    # Wait for API
    Write-Host "Waiting for API to be ready..." -ForegroundColor Yellow
    $maxAttempts = 30
    $attempt = 0
    $apiReady = $false

    while (-not $apiReady -and $attempt -lt $maxAttempts) {
        Start-Sleep -Seconds 2
        $attempt++
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:$ApiPort/swagger/index.html" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                $apiReady = $true
            }
        }
        catch {
            Write-Host "." -NoNewline
        }
    }

    if (-not $apiReady) {
        throw "API did not start within expected time"
    }

    Write-Host ""
    Write-Host "API is running!" -ForegroundColor Green
    Write-Host ""

    # Test endpoints
    Write-Host "Testing API endpoints..." -ForegroundColor Yellow
    
    $loginBody = @{
        Email = "admin@helpdesk.com"
        Senha = "admin123"
    } | ConvertTo-Json

    try {
        $loginResponse = Invoke-RestMethod -Uri "http://localhost:$ApiPort/api/usuarios/login" -Method Post -Body $loginBody -ContentType "application/json"
        Write-Host "✓ Login endpoint working" -ForegroundColor Green
        Write-Host "  Token: $($loginResponse.token.Substring(0, 20))..." -ForegroundColor Gray
    }
    catch {
        Write-Host "✗ Login endpoint failed" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "=== URLs Disponíveis ===" -ForegroundColor Cyan
    Write-Host ""

    if (-not $DesktopOnly -and -not $MobileOnly) {
        Write-Host "WEB Frontend:" -ForegroundColor Yellow
        Write-Host "  http://localhost:$ApiPort/index.html" -ForegroundColor White
        Write-Host ""
    }

    if (-not $WebOnly -and -not $MobileOnly) {
        Write-Host "DESKTOP (abrir arquivos HTML diretamente):" -ForegroundColor Yellow
        Write-Host "  $projectRoot\Desktop\login-desktop.html" -ForegroundColor White
        Write-Host ""
    }

    Write-Host "API Endpoints:" -ForegroundColor Yellow
    Write-Host "  Swagger: http://localhost:$ApiPort/swagger" -ForegroundColor White
    Write-Host "  Base URL: http://localhost:$ApiPort/api/" -ForegroundColor White
    Write-Host ""

    if (-not $WebOnly -and -not $DesktopOnly) {
        Write-Host "MOBILE:" -ForegroundColor Yellow
        Write-Host "  Configure BaseUrl in SistemaChamados.Mobile/appsettings.json" -ForegroundColor White
        Write-Host "  Android Emulator: http://10.0.2.2:$ApiPort/api/" -ForegroundColor Gray
        Write-Host "  Windows: http://localhost:$ApiPort/api/" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  Para rodar o mobile, execute em outro terminal:" -ForegroundColor Yellow
        Write-Host "  dotnet build $mobileProject -t:Run -f net8.0-windows10.0.19041.0" -ForegroundColor Gray
        Write-Host ""
    }

    Write-Host "=== Credenciais de Teste ===" -ForegroundColor Cyan
    Write-Host "Admin:    admin@helpdesk.com / admin123" -ForegroundColor White
    Write-Host "Técnico:  tecnico@helpdesk.com / admin123" -ForegroundColor White
    Write-Host "Usuário:  usuario@helpdesk.com / admin123" -ForegroundColor White
    Write-Host ""

    Write-Host "Pressione CTRL+C para parar a API..." -ForegroundColor Yellow
    
    # Keep running
    while ($true) {
        Start-Sleep -Seconds 1
        if ($apiJob.State -ne "Running") {
            Write-Host "API stopped unexpectedly!" -ForegroundColor Red
            Receive-Job -Job $apiJob | Write-Host
            break
        }
    }
}
finally {
    Write-Host ""
    Write-Host "Stopping API..." -ForegroundColor Yellow
    if ($apiJob.State -eq "Running") {
        Stop-Job -Job $apiJob -ErrorAction SilentlyContinue
    }
    Receive-Job -Job $apiJob -ErrorAction SilentlyContinue | Out-String | Write-Verbose
    Remove-Job -Job $apiJob -ErrorAction SilentlyContinue
    Write-Host "API stopped." -ForegroundColor Green
}
