# Script para iniciar o Frontend (Desktop/Web) na porta 8080
# Executar como: .\start-frontend.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INICIANDO FRONTEND - DESKTOP/WEB" -ForegroundColor Cyan
Write-Host "  Porta: 8080" -ForegroundColor Cyan
Write-Host "  URL: http://localhost:8080" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Navegar até a pasta do Frontend (um nível acima de Scripts)
$scriptDir = $PSScriptRoot
$projectRoot = Split-Path $scriptDir -Parent
$frontendPath = Join-Path $projectRoot "Frontend\Desktop"

# Verificar se a pasta existe
if (-not (Test-Path $frontendPath)) {
    Write-Host "ERRO: Pasta Frontend/Desktop não encontrada!" -ForegroundColor Red
    Write-Host "Procurado em: $frontendPath" -ForegroundColor Yellow
    Write-Host "Script executado de: $scriptDir" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Pressione qualquer tecla para sair..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

Set-Location $frontendPath
Write-Host "Pasta Frontend: $frontendPath" -ForegroundColor Green
Write-Host ""

Write-Host "Verificando se a porta 8080 está livre..." -ForegroundColor Yellow
$portInUse = netstat -ano | Select-String ":8080" | Select-String "LISTENING"

if ($portInUse) {
    Write-Host "AVISO: Porta 8080 já está em uso!" -ForegroundColor Red
    Write-Host "Processos usando a porta:" -ForegroundColor Yellow
    netstat -ano | Select-String ":8080"
    Write-Host ""
    $continue = Read-Host "Deseja continuar mesmo assim? (S/N)"
    if ($continue -ne "S" -and $continue -ne "s") {
        Write-Host "Execução cancelada." -ForegroundColor Red
        exit
    }
}

Write-Host ""
Write-Host "Verificando servidor web..." -ForegroundColor Yellow

# Tentar http-server primeiro (se tiver Node.js)
$httpServerInstalled = Get-Command http-server -ErrorAction SilentlyContinue

if ($httpServerInstalled) {
    Write-Host "Usando http-server..." -ForegroundColor Green
    Write-Host ""
    Write-Host "Iniciando servidor na porta 8080..." -ForegroundColor Cyan
    Write-Host "Acesse: http://localhost:8080" -ForegroundColor Cyan
    Write-Host "Para parar o servidor, pressione Ctrl+C" -ForegroundColor Yellow
    Write-Host ""
    http-server -p 8080 -c-1 -o
    exit
}

# Usar dotnet-serve (já vem com .NET SDK)
Write-Host "Verificando dotnet-serve..." -ForegroundColor Yellow

$dotnetCheck = Get-Command dotnet -ErrorAction SilentlyContinue
if (-not $dotnetCheck) {
    Write-Host ""
    Write-Host "❌ ERRO: .NET SDK não encontrado!" -ForegroundColor Red
    Write-Host "Instale o .NET SDK em: https://dotnet.microsoft.com/download" -ForegroundColor Cyan
    exit 1
}

# Verificar se dotnet-serve está instalado
$serveInstalled = dotnet tool list -g | Select-String "dotnet-serve"

if (-not $serveInstalled) {
    Write-Host ""
    Write-Host "Instalando dotnet-serve..." -ForegroundColor Cyan
    dotnet tool install -g dotnet-serve
    Write-Host ""
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Erro ao instalar dotnet-serve" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "Iniciando servidor na porta 8080..." -ForegroundColor Green
Write-Host "Acesse: http://localhost:8080" -ForegroundColor Cyan
Write-Host "Para parar o servidor, pressione Ctrl+C" -ForegroundColor Yellow
Write-Host ""

# Executar dotnet-serve
dotnet serve -p 8080 -o
