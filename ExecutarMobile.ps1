# Script para executar o app Mobile
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Sistema de Chamados - Mobile App" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se o backend está rodando
Write-Host "Verificando backend..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5246" -Method GET -TimeoutSec 5 -UseBasicParsing -ErrorAction SilentlyContinue
    Write-Host "✓ Backend está rodando em http://localhost:5246" -ForegroundColor Green
} catch {
    Write-Host "✗ ATENÇÃO: Backend não está respondendo!" -ForegroundColor Red
    Write-Host "  Execute o backend primeiro: dotnet run --project SistemaChamados.csproj" -ForegroundColor Yellow
    Write-Host ""
    $continuar = Read-Host "Deseja continuar mesmo assim? (S/N)"
    if ($continuar -ne "S" -and $continuar -ne "s") {
        exit
    }
}

Write-Host ""
Write-Host "Configurações:" -ForegroundColor Cyan
Write-Host "  Backend API: http://localhost:5246" -ForegroundColor White
Write-Host "  Mobile (Emulador): http://10.0.2.2:5246/api/" -ForegroundColor White
Write-Host ""

Write-Host "Iniciando app mobile..." -ForegroundColor Yellow
Write-Host ""

# Executar o projeto mobile
dotnet build SistemaChamados.Mobile/SistemaChamados.Mobile.csproj -t:Run -f net8.0-android

Write-Host ""
Write-Host "Para executar em um dispositivo específico:" -ForegroundColor Cyan
Write-Host "  1. Liste os dispositivos: adb devices" -ForegroundColor White
Write-Host "  2. Execute: dotnet build SistemaChamados.Mobile/SistemaChamados.Mobile.csproj -t:Run -f net8.0-android /p:AndroidAttachDebugger=true" -ForegroundColor White
