# 🚀 Script de Teste - Sistema de Chamados Mobile
# Uso: .\TestarMobile.ps1 -Plataforma windows|android

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("windows", "android", "verificar")]
    [string]$Plataforma = "verificar"
)

Clear-Host
Write-Host "================================" -ForegroundColor Cyan
Write-Host "  Sistema de Chamados - Mobile" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Testar API
Write-Host "Verificando API..." -ForegroundColor Yellow
try {
    $null = Invoke-WebRequest -Uri "http://localhost:5246/api/categorias" -Method GET -TimeoutSec 3 -ErrorAction Stop
    Write-Host "[OK] API rodando" -ForegroundColor Green
    $apiOk = $true
} catch {
    Write-Host "[ERRO] API nao esta rodando!" -ForegroundColor Red
    Write-Host "Execute: dotnet run --project SistemaChamados.csproj" -ForegroundColor Yellow
    $apiOk = $false
}

Write-Host ""

# Se for modo verificar
if ($Plataforma -eq "verificar") {
    Write-Host "Verificando workloads..." -ForegroundColor Yellow
    dotnet workload list
    
    Write-Host ""
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "Para testar, execute:" -ForegroundColor Yellow
    Write-Host "  .\TestarMobile.ps1 -Plataforma windows" -ForegroundColor White
    Write-Host "  .\TestarMobile.ps1 -Plataforma android" -ForegroundColor White
    Write-Host ""
    exit
}

# Verificar se API está rodando
if (-not $apiOk) {
    Write-Host "ERRO: Inicie a API primeiro!" -ForegroundColor Red
    exit 1
}

# Executar conforme plataforma
if ($Plataforma -eq "windows") {
    Write-Host "Iniciando app Windows..." -ForegroundColor Cyan
    Write-Host ""
    Set-Location "SistemaChamados.Mobile"
    dotnet build -t:Run -f net8.0-windows10.0.19041.0
    Set-Location ..
}
elseif ($Plataforma -eq "android") {
    Write-Host "Iniciando app Android..." -ForegroundColor Cyan
    Write-Host ""
    
    # Verificar configuração
    $config = Get-Content "SistemaChamados.Mobile\appsettings.json" -Raw
    if ($config -match "localhost" -and $config -notmatch "10\.0\.2\.2") {
        Write-Host "[AVISO] appsettings.json usa 'localhost'" -ForegroundColor Yellow
        Write-Host "        Para emulador funcionar, deve ser '10.0.2.2'" -ForegroundColor Yellow
        Write-Host ""
    }
    
    Set-Location "SistemaChamados.Mobile"
    dotnet build -t:Run -f net8.0-android
    Set-Location ..
}
