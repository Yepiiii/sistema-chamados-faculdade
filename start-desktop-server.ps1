# Script para iniciar o servidor do Desktop Frontend
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INICIANDO DESKTOP FRONTEND" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$desktopPath = Join-Path $PSScriptRoot "Frontend\Desktop"

if (-not (Test-Path $desktopPath)) {
    Write-Host "ERRO: Pasta Frontend\Desktop nao encontrada!" -ForegroundColor Red
    Read-Host "Pressione ENTER"
    exit
}

Write-Host "Pasta Desktop: $desktopPath" -ForegroundColor Green
Write-Host ""

# Verificar se a porta 8080 está em uso
$port8080 = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
if ($port8080) {
    Write-Host "AVISO: Porta 8080 ja esta em uso!" -ForegroundColor Yellow
    Write-Host "Finalizando processo na porta 8080..." -ForegroundColor Yellow
    
    $processId = $port8080.OwningProcess | Select-Object -First 1
    Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

Write-Host "Iniciando servidor HTTP na porta 8080..." -ForegroundColor Green
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  DESKTOP FRONTEND RODANDO!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "URL: http://localhost:8080" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pressione Ctrl+C para parar o servidor" -ForegroundColor Yellow
Write-Host ""

Set-Location $desktopPath

# Iniciar servidor HTTP
try {
    python -m http.server 8080 --bind 127.0.0.1
} catch {
    Write-Host ""
    Write-Host "ERRO ao iniciar servidor!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Verifique se o Python esta instalado:" -ForegroundColor Yellow
    Write-Host "  python --version" -ForegroundColor White
    Read-Host "Pressione ENTER"
}
