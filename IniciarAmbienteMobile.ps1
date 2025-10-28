# ========================================
# Script: Iniciar Ambiente Mobile Completo
# ========================================
# Inicia backend GuiNRB + Mobile MAUI

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " INICIANDO AMBIENTE MOBILE - GUINRB" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "" -ForegroundColor White

# 1. Verificar se backend existe
Write-Host "1. Verificando backend..." -ForegroundColor Yellow
if (-not (Test-Path "program.cs")) {
    Write-Host "   ERRO: Backend nao encontrado!" -ForegroundColor Red
    Write-Host "   Execute este script na raiz do projeto" -ForegroundColor Yellow
    exit 1
}
Write-Host "   OK Backend encontrado!" -ForegroundColor Green

# 2. Verificar se mobile existe
Write-Host "`n2. Verificando mobile..." -ForegroundColor Yellow
if (-not (Test-Path "SistemaChamados.Mobile\SistemaChamados.Mobile.csproj")) {
    Write-Host "   ERRO: Mobile nao encontrado!" -ForegroundColor Red
    Write-Host "   Execute primeiro: .\CopiarMobileCompleto.ps1" -ForegroundColor Yellow
    exit 1
}
Write-Host "   OK Mobile encontrado!" -ForegroundColor Green

# 3. Limpar e restaurar backend
Write-Host "`n3. Preparando backend..." -ForegroundColor Yellow
Write-Host "   Limpando build anterior..." -ForegroundColor Gray
dotnet clean --verbosity quiet
Write-Host "   Restaurando pacotes..." -ForegroundColor Gray
dotnet restore --verbosity quiet
Write-Host "   OK!" -ForegroundColor Green

# 4. Iniciar backend em janela separada
Write-Host "`n4. Iniciando backend..." -ForegroundColor Yellow
Write-Host "   Porta: 5246" -ForegroundColor Cyan
Write-Host "   Abrindo nova janela PowerShell..." -ForegroundColor Gray

$backendPath = Resolve-Path (Get-Location)
$backendScript = @"
Set-Location '$backendPath'
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ' BACKEND GUINRB - PORTA 5246' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ''
dotnet run
"@

Start-Process powershell -ArgumentList "-NoExit", "-Command", $backendScript

Write-Host "   OK Backend iniciando..." -ForegroundColor Green
Write-Host "   Aguardando inicializacao..." -ForegroundColor Gray

# 5. Aguardar backend inicializar
$maxTentativas = 30
$tentativa = 0
$backendOk = $false

while ($tentativa -lt $maxTentativas -and -not $backendOk) {
    Start-Sleep -Seconds 1
    $tentativa++
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5246/api/Categorias" -Method Get -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $backendOk = $true
        }
    } catch {
        # Ignorar erros
    }
    
    if ($tentativa % 5 -eq 0) {
        Write-Host "   Tentativa $tentativa/$maxTentativas..." -ForegroundColor Gray
    }
}

if ($backendOk) {
    Write-Host "   OK Backend respondendo!" -ForegroundColor Green
} else {
    Write-Host "   AVISO: Backend demorou mais que esperado" -ForegroundColor Yellow
    Write-Host "   Aguarde mais alguns segundos antes de iniciar mobile" -ForegroundColor Yellow
    Write-Host "   Pressione qualquer tecla quando o backend estiver pronto..." -ForegroundColor Cyan
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

# 6. Restaurar pacotes do mobile
Write-Host "`n5. Preparando mobile..." -ForegroundColor Yellow
Push-Location "SistemaChamados.Mobile"

Write-Host "   Restaurando pacotes..." -ForegroundColor Gray
dotnet restore --verbosity quiet

Write-Host "   Verificando workloads MAUI..." -ForegroundColor Gray
$workloads = dotnet workload list 2>&1 | Out-String

if ($workloads -notmatch "maui-android") {
    Write-Host "   AVISO: Workload MAUI Android nao instalado" -ForegroundColor Yellow
    Write-Host "   Execute: dotnet workload install maui-android" -ForegroundColor Cyan
    Pop-Location
    exit 1
}

Write-Host "   OK!" -ForegroundColor Green

# 7. Escolher plataforma
Write-Host "`n6. Escolha a plataforma:" -ForegroundColor Yellow
Write-Host "   1. Android (Emulador)" -ForegroundColor White
Write-Host "   2. Android (Dispositivo Fisico)" -ForegroundColor White
Write-Host "   3. Windows" -ForegroundColor White
Write-Host "" -ForegroundColor White

$escolha = Read-Host "Opcao (1-3)"

switch ($escolha) {
    "1" {
        Write-Host "`n7. Iniciando Android (Emulador)..." -ForegroundColor Yellow
        Write-Host "   URL: http://10.0.2.2:5246/api/" -ForegroundColor Cyan
        dotnet build -t:Run -f net8.0-android
    }
    "2" {
        Write-Host "`n7. Iniciando Android (Dispositivo Fisico)..." -ForegroundColor Yellow
        Write-Host "   ATENCAO: Verifique o IP em Constants.cs" -ForegroundColor Yellow
        Write-Host "   URL: Configurada em BaseUrlPhysicalDevice" -ForegroundColor Cyan
        dotnet build -t:Run -f net8.0-android
    }
    "3" {
        Write-Host "`n7. Iniciando Windows..." -ForegroundColor Yellow
        Write-Host "   URL: http://localhost:5246/api/" -ForegroundColor Cyan
        dotnet build -t:Run -f net8.0-windows10.0.19041.0
    }
    default {
        Write-Host "`nOpcao invalida! Executando Android Emulador..." -ForegroundColor Yellow
        dotnet build -t:Run -f net8.0-android
    }
}

Pop-Location

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " AMBIENTE MOBILE INICIADO!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "" -ForegroundColor White

Write-Host "BACKEND:" -ForegroundColor Yellow
Write-Host "  http://localhost:5246" -ForegroundColor White
Write-Host "  http://localhost:5246/swagger" -ForegroundColor White
Write-Host "" -ForegroundColor White

Write-Host "MOBILE:" -ForegroundColor Yellow
Write-Host "  Executando na plataforma escolhida" -ForegroundColor White
Write-Host "" -ForegroundColor White

Write-Host "USUARIOS DE TESTE:" -ForegroundColor Yellow
Write-Host "  (Verificar no backend se existem usuarios seed)" -ForegroundColor Gray
Write-Host "" -ForegroundColor White

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "" -ForegroundColor White
