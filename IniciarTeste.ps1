# Script para iniciar API e Mobile App em paralelo

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host " SISTEMA DE CHAMADOS - Iniciar Teste" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# 1. Iniciar API em nova janela
Write-Host "[1/3] Iniciando API REST..." -ForegroundColor Yellow
$apiPath = "C:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade"
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd '$apiPath'; Write-Host '[API] Iniciando em http://localhost:5246...' -ForegroundColor Green; dotnet run --project SistemaChamados.csproj --urls http://localhost:5246"
)
Write-Host "[OK] Janela da API aberta" -ForegroundColor Green
Write-Host ""

# 2. Aguardar API inicializar
Write-Host "[2/3] Aguardando API inicializar (15 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# 3. Testar conexão com API
Write-Host "[3/3] Testando conexão com API..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5246/api/categorias" -Method GET -UseBasicParsing -TimeoutSec 5
    Write-Host "[OK] API respondeu com status: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "[AVISO] API ainda não respondeu. Pode levar mais alguns segundos..." -ForegroundColor Yellow
}
Write-Host ""

# 4. Iniciar Mobile App
Write-Host "[4/4] Iniciando Mobile App para Windows..." -ForegroundColor Yellow
$mobilePath = "C:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade\SistemaChamados.Mobile"
cd $mobilePath
Write-Host "[INFO] Compilando e executando Mobile App..." -ForegroundColor Cyan
dotnet build -t:Run -f net8.0-windows10.0.19041.0

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host " Teste Finalizado" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
