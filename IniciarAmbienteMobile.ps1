# ============================================================
# SCRIPT COMPLETO - AMBIENTE MOBILE + API
# ============================================================
# Este script configura todo o ambiente para testar o app mobile

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "  CONFIGURANDO AMBIENTE - APP MOBILE + API" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

# PASSO 1: Verificar/Iniciar API
Write-Host "[1] Verificando API Backend..." -ForegroundColor Yellow

$apiUrl = "http://localhost:5246"
$apiJaRodando = $false

try {
    $response = Invoke-WebRequest -Uri $apiUrl -Method Get -TimeoutSec 3 -UseBasicParsing -ErrorAction Stop
    Write-Host "    API ja esta ONLINE!" -ForegroundColor Green
    $apiJaRodando = $true
} catch {
    Write-Host "    API nao esta rodando. Iniciando..." -ForegroundColor Yellow
    
    # Iniciar API em nova janela
    $apiPath = "C:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade\Backend"
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$apiPath'; Write-Host 'Iniciando API Backend...' -ForegroundColor Cyan; dotnet run" -WindowStyle Normal
    
    Write-Host "    Aguardando API inicializar (20 segundos)..." -ForegroundColor Gray
    Start-Sleep -Seconds 20
    
    # Testar conexao
    $tentativas = 0
    $maxTentativas = 3
    
    while ($tentativas -lt $maxTentativas -and -not $apiJaRodando) {
        $tentativas++
        Write-Host "    Testando conexao... (tentativa $tentativas)" -ForegroundColor Gray
        try {
            $response = Invoke-WebRequest -Uri $apiUrl -Method Get -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
            $apiJaRodando = $true
            Write-Host "    API ONLINE!" -ForegroundColor Green
        } catch {
            if ($tentativas -lt $maxTentativas) {
                Start-Sleep -Seconds 5
            }
        }
    }
}

Write-Host ""

# PASSO 2: Verificar Visual Studio
Write-Host "[2] Verificando Visual Studio..." -ForegroundColor Yellow

$vsProcess = Get-Process -Name "devenv" -ErrorAction SilentlyContinue

if ($vsProcess) {
    Write-Host "    Visual Studio ja esta aberto!" -ForegroundColor Green
    Write-Host "    PID: $($vsProcess.Id)" -ForegroundColor Gray
} else {
    Write-Host "    Abrindo Visual Studio..." -ForegroundColor Yellow
    $solutionPath = "C:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade\SistemaChamados.sln"
    Start-Process $solutionPath
    Write-Host "    Visual Studio abrindo..." -ForegroundColor Green
}

Write-Host ""

# PASSO 3: Resumo Final
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  STATUS DO AMBIENTE" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

if ($apiJaRodando) {
    Write-Host "  API Backend: ONLINE" -ForegroundColor Green
    Write-Host "  URL: $apiUrl" -ForegroundColor White
} else {
    Write-Host "  API Backend: VERIFICANDO..." -ForegroundColor Yellow
    Write-Host "  Verifique a janela do PowerShell da API" -ForegroundColor Gray
    Write-Host "  URL: $apiUrl" -ForegroundColor White
}

Write-Host ""

if ($vsProcess) {
    Write-Host "  Visual Studio: ABERTO" -ForegroundColor Green
} else {
    Write-Host "  Visual Studio: ABRINDO..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "  Projeto Mobile: SistemaChamados.Mobile" -ForegroundColor White
Write-Host "  Localizacao: Mobile/SistemaChamados.Mobile.csproj" -ForegroundColor Gray

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "  PROXIMOS PASSOS" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

Write-Host "1. No Visual Studio, aguarde o projeto carregar completamente" -ForegroundColor White
Write-Host ""
Write-Host "2. No topo da janela do VS:" -ForegroundColor White
Write-Host "   - Clique na seta ao lado do botao 'Play'" -ForegroundColor Gray
Write-Host "   - Selecione 'SistemaChamados.Mobile' como projeto de inicializacao" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Escolha o dispositivo/plataforma:" -ForegroundColor White
Write-Host "   - Android Emulator (requer emulador configurado)" -ForegroundColor Gray
Write-Host "   - Windows Machine (para testar no Windows)" -ForegroundColor Gray
Write-Host "   - iOS Simulator (apenas no Mac)" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Pressione F5 ou clique no botao verde para executar" -ForegroundColor White
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan

if ($apiJaRodando) {
    Write-Host "`n  AMBIENTE PRONTO PARA TESTE!" -ForegroundColor Green -BackgroundColor Black
} else {
    Write-Host "`n  AGUARDE API INICIALIZAR ANTES DE TESTAR!" -ForegroundColor Yellow -BackgroundColor Black
}

Write-Host "`n============================================================`n" -ForegroundColor Cyan

# INFORMACOES ADICIONAIS
Write-Host "INFORMACOES UTEIS:" -ForegroundColor Cyan
Write-Host "  - API URL: http://localhost:5246" -ForegroundColor White
Write-Host "  - Login teste: colaborador@empresa.com / Admin@123" -ForegroundColor White
Write-Host "  - Para parar API: Feche a janela PowerShell da API" -ForegroundColor White
Write-Host ""
