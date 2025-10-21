# Script para iniciar apenas o App Mobile no Windows
# Uso: .\IniciarApp.ps1
# Pré-requisito: API deve estar rodando em http://localhost:5246

param(
    [switch]$SemAPI
)

Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Sistema de Chamados - App Mobile" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$solutionRoot = Split-Path -Parent $scriptPath
$mobilePath = Join-Path $solutionRoot "SistemaChamados.Mobile"

# Verifica se a API está rodando (a menos que -SemAPI seja usado)
if (-not $SemAPI) {
    Write-Host "Verificando API..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5246/swagger/index.html" -Method GET -TimeoutSec 2 -ErrorAction Stop
        Write-Host "[OK] API está rodando" -ForegroundColor Green
    }
    catch {
        Write-Host "[AVISO] API não está rodando!" -ForegroundColor Red
        Write-Host ""
        Write-Host "O app mobile precisa da API para funcionar." -ForegroundColor Yellow
        Write-Host "Você tem 3 opções:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "1. Iniciar API e App juntos:" -ForegroundColor Cyan
        Write-Host "   .\IniciarSistemaWindows.ps1" -ForegroundColor Gray
        Write-Host ""
        Write-Host "2. Iniciar apenas a API em outro terminal:" -ForegroundColor Cyan
        Write-Host "   cd sistema-chamados-faculdade" -ForegroundColor Gray
        Write-Host "   dotnet run --urls http://localhost:5246" -ForegroundColor Gray
        Write-Host ""
        Write-Host "3. Continuar sem API (app vai falhar ao fazer requisições):" -ForegroundColor Cyan
        Write-Host "   .\IniciarApp.ps1 -SemAPI" -ForegroundColor Gray
        Write-Host ""
        $continuar = Read-Host "Deseja continuar mesmo assim? (S/N)"
        if ($continuar -ne "S" -and $continuar -ne "s") {
            exit 0
        }
    }
}

if (-not (Test-Path $mobilePath)) {
    Write-Host "[ERRO] Pasta do app mobile não encontrada: $mobilePath" -ForegroundColor Red
    exit 1
}

Set-Location $mobilePath

# Verifica se já existe um build
$exePath = ".\bin\Debug\net8.0-windows10.0.19041.0\win10-x64\SistemaChamados.Mobile.exe"
$needsBuild = -not (Test-Path $exePath)

if ($needsBuild) {
    Write-Host ""
    Write-Host "Compilando aplicativo..." -ForegroundColor Green
    Write-Host "Executando: dotnet build -f net8.0-windows10.0.19041.0" -ForegroundColor Cyan
    Write-Host ""
    
    dotnet build -f net8.0-windows10.0.19041.0
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "[ERRO] Falha na compilação" -ForegroundColor Red
        Set-Location $scriptPath
        exit 1
    }
    
    Write-Host ""
    Write-Host "[OK] Compilação concluída" -ForegroundColor Green
}
else {
    Write-Host "[OK] Build existente encontrado, pulando compilação" -ForegroundColor Green
    Write-Host "     Para recompilar, execute: dotnet build -f net8.0-windows10.0.19041.0" -ForegroundColor Gray
}

if (-not (Test-Path $exePath)) {
    Write-Host ""
    Write-Host "[ERRO] Executável não encontrado: $exePath" -ForegroundColor Red
    Set-Location $scriptPath
    exit 1
}

Write-Host ""
Write-Host "Iniciando aplicativo..." -ForegroundColor Green
Write-Host ""

$appProcess = Start-Process -FilePath $exePath -PassThru

Write-Host "========================================" -ForegroundColor Green
Write-Host "   APP MOBILE INICIADO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Processo ID: $($appProcess.Id)" -ForegroundColor Cyan
Write-Host ""
Write-Host "CREDENCIAIS DE TESTE:" -ForegroundColor Yellow
Write-Host "  Admin:     admin@sistema.com / Admin@123" -ForegroundColor Gray
Write-Host "  Aluno:     aluno@sistema.com / Aluno@123" -ForegroundColor Gray
Write-Host "  Professor: professor@sistema.com / Prof@123" -ForegroundColor Gray
Write-Host ""
Write-Host "LOGS DO APLICATIVO:" -ForegroundColor Yellow
Write-Host "  $env:LOCALAPPDATA\SistemaChamados.Mobile-app-log.txt" -ForegroundColor Gray
Write-Host ""
Write-Host "Ver logs em tempo real:" -ForegroundColor Yellow
Write-Host "  Get-Content `"`$env:LOCALAPPDATA\SistemaChamados.Mobile-app-log.txt`" -Wait -Tail 10" -ForegroundColor Cyan
Write-Host ""
Write-Host "COMANDOS ÚTEIS:" -ForegroundColor Yellow
Write-Host "  Recompilar: dotnet build -f net8.0-windows10.0.19041.0" -ForegroundColor Gray
Write-Host "  Limpar:     dotnet clean" -ForegroundColor Gray
Write-Host ""

Set-Location $scriptPath

Write-Host "Pressione ENTER para fechar este terminal..." -ForegroundColor Green
Read-Host
