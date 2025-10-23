# Script para iniciar API e Mobile juntos
# Uso: .\IniciarSistema.ps1 [-Plataforma windows|android]

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
Write-Host "Iniciando aplicativo mobile ($Plataforma)..." -ForegroundColor Green
Write-Host ""

Set-Location $repoPath
$mobilePath = Join-Path $solutionRoot "SistemaChamados.Mobile"
if (-not (Test-Path $mobilePath)) {
    Write-Host "[ERRO] Pasta da aplicacao mobile nao encontrada em $mobilePath" -ForegroundColor Red
    Stop-Job -Job $apiJob
    Remove-Job -Job $apiJob
    exit 1
}
Set-Location $mobilePath

if ($Plataforma -eq "windows") {
    Write-Host "Executando: dotnet build -t:Run -f net8.0-windows10.0.19041.0" -ForegroundColor Cyan
    dotnet build -t:Run -f net8.0-windows10.0.19041.0

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  APP MOBILE INICIADO NO WINDOWS" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""

    Write-Host "TESTE AS NOVAS FUNCIONALIDADES" -ForegroundColor Yellow
    Write-Host ""

    Write-Host "1. Notificacoes (teste rapido)" -ForegroundColor Cyan
    Write-Host "   - Faca login no app" -ForegroundColor Gray
    Write-Host "   - Na lista, procure o botao de notificacao" -ForegroundColor Gray
    Write-Host "   - Clique no botao para gerar notificacoes" -ForegroundColor Gray
    Write-Host "   - Veja o alerta de confirmacao" -ForegroundColor Gray
    Write-Host "   - Notificacoes aparecem na Central de Acoes" -ForegroundColor Gray
    Write-Host "   - Clique em uma notificacao para abrir o chamado" -ForegroundColor Gray
    Write-Host ""

    Write-Host "2. Comentarios" -ForegroundColor Cyan
    Write-Host "   - Abra um chamado" -ForegroundColor Gray
    Write-Host "   - Role ate a area de comentarios" -ForegroundColor Gray
    Write-Host "   - Envie um comentario" -ForegroundColor Gray
    Write-Host "   - Comentario aparece instantaneamente" -ForegroundColor Gray
    Write-Host ""

    Write-Host "3. Upload de arquivos" -ForegroundColor Cyan
    Write-Host "   - No detalhe do chamado, role ate anexos" -ForegroundColor Gray
    Write-Host "   - Clique em adicionar anexo" -ForegroundColor Gray
    Write-Host "   - Selecione uma imagem" -ForegroundColor Gray
    Write-Host "   - Verifique o thumbnail" -ForegroundColor Gray
    Write-Host ""

    Write-Host "4. Timeline de historico" -ForegroundColor Cyan
    Write-Host "   - Role ate a timeline" -ForegroundColor Gray
    Write-Host "   - Confira eventos cronologicos com icones" -ForegroundColor Gray
    Write-Host ""

    Write-Host "5. Polling automatico" -ForegroundColor Cyan
    Write-Host "   - Mantenha o app aberto por alguns minutos" -ForegroundColor Gray
    Write-Host "   - Alternativa: clique no botao de notificacao" -ForegroundColor Gray
    Write-Host "   - Lista atualiza automaticamente" -ForegroundColor Gray
    Write-Host ""
}
elseif ($Plataforma -eq "android") {
    $config = Get-Content "appsettings.json" -Raw
    if ($config -match "localhost" -and $config -notmatch "10\\.0\\.2\\.2") {
        Write-Host "[AVISO] appsettings.json usa localhost" -ForegroundColor Yellow
        Write-Host "        Para emulador Android, troque por 10.0.2.2" -ForegroundColor Yellow
        Write-Host ""
        $alterar = Read-Host "Deseja ajustar automaticamente? (S/N)"
        if ($alterar -eq "S" -or $alterar -eq "s") {
            $config = $config -replace "localhost:5246", "10.0.2.2:5246"
            $config | Set-Content "appsettings.json"
            Write-Host "[OK] Configuracao atualizada" -ForegroundColor Green
        }
    }

    Write-Host "Executando: dotnet build -t:Run -f net8.0-android" -ForegroundColor Cyan
    dotnet build -t:Run -f net8.0-android

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  APP MOBILE INICIADO NO ANDROID" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""

    Write-Host "TESTE AS NOVAS FUNCIONALIDADES" -ForegroundColor Yellow
    Write-Host ""

    Write-Host "1. Notificacoes (teste rapido)" -ForegroundColor Cyan
    Write-Host "   - Faca login no app" -ForegroundColor Gray
    Write-Host "   - Acesse a lista de chamados e toque no botao de notificacao" -ForegroundColor Gray
    Write-Host "   - Confirme o alerta" -ForegroundColor Gray
    Write-Host "   - Puxe a bandeja de notificacoes" -ForegroundColor Gray
    Write-Host "   - Toque em uma notificacao para abrir o chamado" -ForegroundColor Gray
    Write-Host ""

    Write-Host "2. Comentarios" -ForegroundColor Cyan
    Write-Host "   - Abra um chamado" -ForegroundColor Gray
    Write-Host "   - Role ate a area de comentarios" -ForegroundColor Gray
    Write-Host "   - Envie um comentario" -ForegroundColor Gray
    Write-Host "   - Comentario aparece instantaneamente" -ForegroundColor Gray
    Write-Host ""

    Write-Host "3. Upload de arquivos" -ForegroundColor Cyan
    Write-Host "   - Role ate anexos" -ForegroundColor Gray
    Write-Host "   - Toque em adicionar anexo" -ForegroundColor Gray
    Write-Host "   - Escolha imagem da galeria ou camera" -ForegroundColor Gray
    Write-Host "   - Verifique o thumbnail" -ForegroundColor Gray
    Write-Host ""

    Write-Host "4. Timeline de historico" -ForegroundColor Cyan
    Write-Host "   - Role ate a timeline" -ForegroundColor Gray
    Write-Host "   - Veja eventos com cores e icones" -ForegroundColor Gray
    Write-Host ""

    Write-Host "5. Polling automatico" -ForegroundColor Cyan
    Write-Host "   - Deixe o app aberto ou use o botao de notificacao" -ForegroundColor Gray
    Write-Host "   - Alteracoes refletem em poucos segundos" -ForegroundColor Gray
    Write-Host ""

    Write-Host "Documentacao complementar" -ForegroundColor Yellow
    Write-Host "   - SistemaChamados.Mobile\\TESTE_COMPLETO.md" -ForegroundColor Gray
    Write-Host "   - SistemaChamados.Mobile\\POLLING_NOTIFICATIONS_GUIDE.md" -ForegroundColor Gray
    Write-Host ""
}

Set-Location $repoPath

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Features em destaque" -ForegroundColor Green
Write-Host "   - Timeline de Historico" -ForegroundColor Green
Write-Host "   - Thread de Comentarios" -ForegroundColor Green
Write-Host "   - Upload de Arquivos" -ForegroundColor Green
Write-Host "   - Polling Service" -ForegroundColor Green
Write-Host "   - Notificacoes Locais" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
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
