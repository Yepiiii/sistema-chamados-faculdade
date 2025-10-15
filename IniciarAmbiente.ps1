# Script para iniciar API + Mobile App automaticamente
# Uso: .\IniciarAmbiente.ps1 -Plataforma windows|android

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("windows", "android")]
    [string]$Plataforma = "windows"
)

Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Sistema de Chamados - Inicializacao" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Iniciar a API em uma nova janela
Write-Host "[1/2] Iniciando API Backend..." -ForegroundColor Yellow
Write-Host "      Abrindo nova janela do PowerShell..." -ForegroundColor Gray

Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd '$PWD'; Write-Host '=== API Backend ===' -ForegroundColor Green; dotnet run --project SistemaChamados.csproj --urls http://localhost:5246"
)

Write-Host "[OK] API iniciada em nova janela" -ForegroundColor Green
Write-Host ""

# Aguardar alguns segundos para API iniciar
Write-Host "[2/2] Aguardando API inicializar..." -ForegroundColor Yellow
Start-Sleep -Seconds 8

# Testar se API está respondendo
Write-Host "      Testando conexao com API..." -ForegroundColor Gray
$tentativas = 0
$maxTentativas = 5
$apiOk = $false

while ($tentativas -lt $maxTentativas -and -not $apiOk) {
    try {
        $null = Invoke-WebRequest -Uri "http://localhost:5246/api/categorias" -Method GET -TimeoutSec 2 -ErrorAction Stop
        $apiOk = $true
        Write-Host "[OK] API esta respondendo!" -ForegroundColor Green
    }
    catch {
        $tentativas++
        if ($tentativas -lt $maxTentativas) {
            Write-Host "      Tentativa $tentativas/$maxTentativas... aguardando..." -ForegroundColor Gray
            Start-Sleep -Seconds 2
        }
    }
}

if (-not $apiOk) {
    Write-Host "[AVISO] API nao respondeu apos $maxTentativas tentativas" -ForegroundColor Yellow
    Write-Host "        Verifique a janela da API para ver se ha erros" -ForegroundColor Yellow
    Write-Host ""
    $response = Read-Host "Deseja continuar mesmo assim? (S/N)"
    if ($response -ne "S" -and $response -ne "s") {
        Write-Host "Operacao cancelada." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Iniciando Mobile App ($Plataforma)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar configuracao para Android
if ($Plataforma -eq "android") {
    $appsettings = Get-Content "SistemaChamados.Mobile\appsettings.json" -Raw
    if ($appsettings -match "localhost" -and $appsettings -notmatch "10\.0\.2\.2") {
        Write-Host "[AVISO] appsettings.json usa 'localhost'" -ForegroundColor Yellow
        Write-Host "        Para funcionar no Android Emulator, deve ser '10.0.2.2'" -ForegroundColor Yellow
        Write-Host ""
        $fix = Read-Host "Corrigir automaticamente? (S/N)"
        if ($fix -eq "S" -or $fix -eq "s") {
            $appsettings = $appsettings -replace "localhost:5246", "10.0.2.2:5246"
            $appsettings | Set-Content "SistemaChamados.Mobile\appsettings.json"
            Write-Host "[OK] Configuracao atualizada!" -ForegroundColor Green
            Write-Host ""
        }
    }
}

# Iniciar mobile app
Set-Location "SistemaChamados.Mobile"

if ($Plataforma -eq "windows") {
    Write-Host "Compilando e executando app Windows..." -ForegroundColor Cyan
    Write-Host ""
    dotnet build -t:Run -f net8.0-windows10.0.19041.0
}
elseif ($Plataforma -eq "android") {
    Write-Host "Compilando e executando app Android..." -ForegroundColor Cyan
    Write-Host ""
    dotnet build -t:Run -f net8.0-android
}

Set-Location ..

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Finalizacao" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "API Backend: http://localhost:5246" -ForegroundColor Green
Write-Host "Mobile App: Executando em $Plataforma" -ForegroundColor Green
Write-Host ""
Write-Host "Para encerrar:" -ForegroundColor Yellow
Write-Host "  1. Feche o app mobile" -ForegroundColor White
Write-Host "  2. Feche a janela da API (Ctrl+C)" -ForegroundColor White
Write-Host ""
