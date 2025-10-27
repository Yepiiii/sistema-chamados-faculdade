# ========================================
#  ABRIR FRONTEND NO NAVEGADOR
# ========================================
# Script para abrir o Frontend Web (Backend deve estar rodando)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ABRINDO FRONTEND WEB" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se backend está rodando
Write-Host "Verificando se backend está rodando..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "http://localhost:5246/" -Method Head -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop
    Write-Host "[OK] Backend está rodando!" -ForegroundColor Green
}
catch {
    Write-Host "[ERRO] Backend não está rodando!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Por favor, inicie o backend primeiro:" -ForegroundColor Yellow
    Write-Host "  .\IniciarWeb.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "Ou manualmente:" -ForegroundColor Yellow
    Write-Host "  cd Backend" -ForegroundColor White
    Write-Host "  dotnet run" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host ""

# Abrir navegador
Write-Host "Abrindo navegador..." -ForegroundColor Cyan

$url = "http://localhost:5246/pages/login.html"

try {
    # Tentar Chrome
    if (Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe") {
        Start-Process "chrome.exe" -ArgumentList "--new-window", $url
        Write-Host "[OK] Chrome aberto!" -ForegroundColor Green
    }
    # Tentar Edge
    elseif (Test-Path "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe") {
        Start-Process "msedge.exe" -ArgumentList $url
        Write-Host "[OK] Edge aberto!" -ForegroundColor Green
    }
    # Navegador padrão
    else {
        Start-Process $url
        Write-Host "[OK] Navegador aberto!" -ForegroundColor Green
    }
}
catch {
    Write-Host "[ERRO] Não foi possível abrir o navegador" -ForegroundColor Red
    Write-Host "Abra manualmente: $url" -ForegroundColor White
}

Write-Host ""
Write-Host "URL: $url" -ForegroundColor Cyan
Write-Host ""
