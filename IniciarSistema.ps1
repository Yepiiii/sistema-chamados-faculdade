# Script para iniciar API e Mobile juntos
# Uso: .\IniciarSistema.ps1

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

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoPath = $scriptPath
$solutionRoot = Split-Path -Parent $repoPath
Set-Location $repoPath

# Fechar processos anteriores (opcional)
Write-Host "Verificando processos anteriores..." -ForegroundColor Yellow
$apiProcess = Get-Process | Where-Object {$_.ProcessName -eq "SistemaChamados"}
if ($apiProcess) {
    Write-Host "Finalizando API anterior..." -ForegroundColor Yellow
    Stop-Process -Name "SistemaChamados" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

# Iniciar API em background
Write-Host "Iniciando API..." -ForegroundColor Green
$apiJob = Start-Job -ScriptBlock {
    Set-Location $using:repoPath
    dotnet run --project SistemaChamados.csproj --urls http://localhost:5246
}

Write-Host "Aguardando API inicializar..." -ForegroundColor Yellow
Start-Sleep -Seconds 8

# Testar se API está rodando
$tentativas = 0
$maxTentativas = 10
$apiOk = $false

while ($tentativas -lt $maxTentativas -and -not $apiOk) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5246/swagger/index.html" -Method GET -TimeoutSec 2 -ErrorAction Stop
        if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500) {
            Write-Host "[OK] API rodando em http://localhost:5246" -ForegroundColor Green
            $apiOk = $true
        }
        else {
            throw "Status code: $($response.StatusCode)"
        }
    }
    catch {
        $tentativas++
        Write-Host "Aguardando API... ($tentativas/$maxTentativas)" -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    }
}

if (-not $apiOk) {
    Write-Host ""
    Write-Host "[ERRO] API nao conseguiu iniciar!" -ForegroundColor Red
    Write-Host "Verificando output da API:" -ForegroundColor Yellow
    Receive-Job -Job $apiJob
    Stop-Job -Job $apiJob
    Remove-Job -Job $apiJob
    exit 1
}

Write-Host ""
Write-Host "Iniciando aplicativo mobile ($Plataforma)..." -ForegroundColor Green
Write-Host ""

# Iniciar mobile
Set-Location $repoPath
$mobilePath = Join-Path $solutionRoot "SistemaChamados.Mobile"
if (-not (Test-Path $mobilePath)) {
    Write-Host "[ERRO] Pasta da aplicação mobile não encontrada em $mobilePath" -ForegroundColor Red
    Stop-Job -Job $apiJob
    Remove-Job -Job $apiJob
    exit 1
}
Set-Location $mobilePath

if ($Plataforma -eq "windows") {
    Write-Host "Executando: dotnet build -t:Run -f net8.0-windows10.0.19041.0" -ForegroundColor Cyan
    dotnet build -t:Run -f net8.0-windows10.0.19041.0
}
elseif ($Plataforma -eq "android") {
    # Verificar configuração para Android
    $config = Get-Content "appsettings.json" -Raw
    if ($config -match "localhost" -and $config -notmatch "10\.0\.2\.2") {
        Write-Host "[AVISO] appsettings.json usa 'localhost'" -ForegroundColor Yellow
        Write-Host "        Para emulador Android funcionar, altere para '10.0.2.2'" -ForegroundColor Yellow
        Write-Host ""
        $alterar = Read-Host "Deseja alterar automaticamente? (S/N)"
        if ($alterar -eq "S" -or $alterar -eq "s") {
            $config = $config -replace "localhost:5246", "10.0.2.2:5246"
            $config | Set-Content "appsettings.json"
            Write-Host "[OK] Configuracao atualizada!" -ForegroundColor Green
        }
    }
    
    Write-Host "Executando: dotnet build -t:Run -f net8.0-android" -ForegroundColor Cyan
    dotnet build -t:Run -f net8.0-android
}

Set-Location $repoPath

# Ao finalizar, perguntar se quer parar a API
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
$parar = Read-Host "Deseja parar a API? (S/N)"
if ($parar -eq "S" -or $parar -eq "s") {
    Write-Host "Parando API..." -ForegroundColor Yellow
    Stop-Job -Job $apiJob
    Remove-Job -Job $apiJob
    Write-Host "[OK] API parada" -ForegroundColor Green
}
else {
    Write-Host ""
    Write-Host "[INFO] API ainda esta rodando em background" -ForegroundColor Cyan
    Write-Host "       Job ID: $($apiJob.Id)" -ForegroundColor Cyan
    Write-Host "       Para parar depois: Stop-Job -Id $($apiJob.Id); Remove-Job -Id $($apiJob.Id)" -ForegroundColor Yellow
}
