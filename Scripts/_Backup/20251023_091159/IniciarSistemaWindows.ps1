# Script para iniciar API e Mobile no Windows (executável direto)
# Uso: .\IniciarSistemaWindows.ps1

Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Sistema de Chamados - Windows" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoPath = $scriptPath
$solutionRoot = Split-Path -Parent $repoPath
Set-Location $repoPath

Write-Host "Verificando processos anteriores..." -ForegroundColor Yellow
$apiProcess = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "SistemaChamados" }
if ($apiProcess) {
    Write-Host "Finalizando API anterior..." -ForegroundColor Yellow
    Stop-Process -Name "SistemaChamados" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

Write-Host "Iniciando API..." -ForegroundColor Green
$apiJob = Start-Job -ScriptBlock {
    Set-Location $using:repoPath
    dotnet run --project SistemaChamados.csproj --urls http://localhost:5246
}

Write-Host "Aguardando API inicializar..." -ForegroundColor Yellow
Start-Sleep -Seconds 8

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
    Write-Host "[ERRO] API nao conseguiu iniciar" -ForegroundColor Red
    Write-Host "Verificando output da API:" -ForegroundColor Yellow
    Receive-Job -Job $apiJob
    Stop-Job -Job $apiJob
    Remove-Job -Job $apiJob
    exit 1
}

Write-Host ""
Write-Host "Compilando aplicativo mobile..." -ForegroundColor Green

$mobilePath = Join-Path $solutionRoot "SistemaChamados.Mobile"
if (-not (Test-Path $mobilePath)) {
    Write-Host "[ERRO] Pasta da aplicacao mobile nao encontrada em $mobilePath" -ForegroundColor Red
    Stop-Job -Job $apiJob
    Remove-Job -Job $apiJob
    exit 1
}

Set-Location $mobilePath

Write-Host "Executando: dotnet build -f net8.0-windows10.0.19041.0" -ForegroundColor Cyan
$buildOutput = dotnet build -f net8.0-windows10.0.19041.0 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERRO] Falha na compilacao" -ForegroundColor Red
    Write-Host $buildOutput
    Stop-Job -Job $apiJob
    Remove-Job -Job $apiJob
    exit 1
}

Write-Host "[OK] Compilacao concluida" -ForegroundColor Green

$exePath = ".\bin\Debug\net8.0-windows10.0.19041.0\win10-x64\SistemaChamados.Mobile.exe"
if (-not (Test-Path $exePath)) {
    Write-Host "[ERRO] Executavel nao encontrado em $exePath" -ForegroundColor Red
    Stop-Job -Job $apiJob
    Remove-Job -Job $apiJob
    exit 1
}

Write-Host ""
Write-Host "Iniciando aplicativo..." -ForegroundColor Green
Write-Host ""

$appProcess = Start-Process -FilePath $exePath -PassThru

Write-Host "========================================" -ForegroundColor Green
Write-Host "  APP MOBILE INICIADO NO WINDOWS" -ForegroundColor Green
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
Write-Host "Para ver logs em tempo real:" -ForegroundColor Yellow
Write-Host "  Get-Content `"`$env:LOCALAPPDATA\SistemaChamados.Mobile-app-log.txt`" -Wait -Tail 10" -ForegroundColor Cyan
Write-Host ""
Write-Host "CORRECOES APLICADAS:" -ForegroundColor Green
Write-Host "  - Rotas de navegacao corrigidas (usando ///)" -ForegroundColor Gray
Write-Host "  - Servico de notificacoes com fallback" -ForegroundColor Gray
Write-Host "  - Logs detalhados para debug" -ForegroundColor Gray
Write-Host ""

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
    $jobId = $apiJob.Id
    Write-Host "       Job ID: $jobId" -ForegroundColor Cyan
    Write-Host "       Para parar depois: Stop-Job -Id $jobId; Remove-Job -Id $jobId" -ForegroundColor Yellow
}

Set-Location $repoPath
