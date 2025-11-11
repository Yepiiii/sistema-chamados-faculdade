# Script para iniciar o Backend (API) na porta 5246
# Executar como: .\start-backend.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INICIANDO BACKEND - API" -ForegroundColor Cyan
Write-Host "  Porta: 5246" -ForegroundColor Cyan
Write-Host "  URL Local: http://localhost:5246" -ForegroundColor Cyan
Write-Host "  URL Rede: http://192.168.1.6:5246" -ForegroundColor Cyan
Write-Host "  Swagger: http://localhost:5246/swagger" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Navegar até a pasta do Backend (um nível acima de Scripts)
$scriptDir = $PSScriptRoot
$projectRoot = Split-Path $scriptDir -Parent
$backendPath = Join-Path $projectRoot "Backend"

# Verificar se a pasta existe
if (-not (Test-Path $backendPath)) {
    Write-Host "ERRO: Pasta Backend não encontrada!" -ForegroundColor Red
    Write-Host "Procurado em: $backendPath" -ForegroundColor Yellow
    Write-Host "Script executado de: $scriptDir" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Pressione qualquer tecla para sair..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

Set-Location $backendPath
Write-Host "Pasta Backend: $backendPath" -ForegroundColor Green
Write-Host ""

Write-Host "Verificando se a porta 5246 está livre..." -ForegroundColor Yellow
$portInUse = netstat -ano | Select-String ":5246" | Select-String "LISTENING"

if ($portInUse) {
    Write-Host "AVISO: Porta 5246 já está em uso!" -ForegroundColor Red
    Write-Host "Processos usando a porta:" -ForegroundColor Yellow
    netstat -ano | Select-String ":5246"
    Write-Host ""
    $continue = Read-Host "Deseja continuar mesmo assim? (S/N)"
    if ($continue -ne "S" -and $continue -ne "s") {
        Write-Host "Execução cancelada." -ForegroundColor Red
        exit
    }
}

Write-Host ""
Write-Host "Iniciando Backend..." -ForegroundColor Green
Write-Host "Aguarde ate ver 'Now listening on: http://0.0.0.0:5246'" -ForegroundColor Yellow
Write-Host ""
Write-Host "IMPORTANTE: O Backend estara acessivel em:" -ForegroundColor Green
Write-Host "  - Localhost: http://localhost:5246" -ForegroundColor White
Write-Host "  - Rede Local: http://192.168.1.6:5246" -ForegroundColor White
Write-Host ""
Write-Host "Para parar o servidor, pressione Ctrl+C" -ForegroundColor Yellow
Write-Host ""

# Executar o backend
dotnet run --launch-profile http --urls "http://0.0.0.0:5246"
