# Script para executar o app Mobile no WINDOWS
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Sistema de Chamados - Mobile (WINDOWS)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se o backend esta rodando
Write-Host "Verificando backend..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5246" -Method GET -TimeoutSec 5 -UseBasicParsing -ErrorAction SilentlyContinue
    Write-Host "Backend esta rodando em http://localhost:5246" -ForegroundColor Green
} catch {
    Write-Host "ATENCAO: Backend nao esta respondendo!" -ForegroundColor Red
    Write-Host "  Execute o backend primeiro: dotnet run --project SistemaChamados.csproj" -ForegroundColor Yellow
    Write-Host ""
    $continuar = Read-Host "Deseja continuar mesmo assim? (S/N)"
    if ($continuar -ne "S" -and $continuar -ne "s") {
        exit
    }
}

Write-Host ""
Write-Host "Configuracoes:" -ForegroundColor Cyan
Write-Host "  Backend API: http://localhost:5246" -ForegroundColor White
Write-Host "  Plataforma: Windows 11" -ForegroundColor White
Write-Host ""

Write-Host "Iniciando app mobile no Windows..." -ForegroundColor Yellow
Write-Host ""

# Executar o projeto mobile para Windows
dotnet build SistemaChamados.Mobile/SistemaChamados.Mobile.csproj -t:Run -f net8.0-windows10.0.19041.0

Write-Host ""
Write-Host "App mobile encerrado." -ForegroundColor Cyan
