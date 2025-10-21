# ========================================
# Criar Chamados Demo (API Endpoint)
# ========================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Criar Chamados de Demonstracao" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se API esta rodando
Write-Host "[1/3] Verificando se API esta rodando..." -ForegroundColor Yellow

try {
    $testResponse = Invoke-WebRequest -Uri "http://localhost:5246/swagger/index.html" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
    Write-Host "[OK] API detectada" -ForegroundColor Green
} catch {
    Write-Host "[AVISO] API nao esta rodando" -ForegroundColor Yellow
    Write-Host "[INFO] Iniciando API..." -ForegroundColor Cyan
    
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $repoRoot = Split-Path -Parent $scriptDir
    $backendPath = Join-Path $repoRoot "Backend"
    
    # Iniciar API em background
    $apiJob = Start-Job -ScriptBlock {
        param($path)
        Set-Location $path
        dotnet run --urls="http://localhost:5246"
    } -ArgumentList $backendPath
    
    Write-Host "[INFO] Aguardando API inicializar (8s)..." -ForegroundColor Cyan
    Start-Sleep -Seconds 8
    
    try {
        $testResponse = Invoke-WebRequest -Uri "http://localhost:5246/swagger/index.html" -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
        Write-Host "[OK] API iniciada" -ForegroundColor Green
    } catch {
        Write-Host "[ERRO] Falha ao iniciar API" -ForegroundColor Red
        Stop-Job -Job $apiJob -ErrorAction SilentlyContinue
        Remove-Job -Job $apiJob -ErrorAction SilentlyContinue
        exit 1
    }
}

Write-Host ""
Write-Host "[2/3] Criando chamados demo..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "http://localhost:5246/api/Demo/criar-chamados-demo" -Method Post -ContentType "application/json"
    
    Write-Host "[OK] Chamados criados!" -ForegroundColor Green
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  SUCESSO!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Total de chamados criados: $($response.Total)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Por usuario:" -ForegroundColor White
    Write-Host "  - Aluno: $($response.Aluno) chamados" -ForegroundColor Cyan
    Write-Host "  - Professor: $($response.Professor) chamados" -ForegroundColor Cyan
    Write-Host "  - Admin: $($response.Admin) chamados" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Por status:" -ForegroundColor White
    Write-Host "  - Abertos: $($response.PorStatus.Abertos)" -ForegroundColor Cyan
    Write-Host "  - Em Andamento: $($response.PorStatus.EmAndamento)" -ForegroundColor Cyan
    Write-Host "  - Encerrados: $($response.PorStatus.Encerrados)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
} catch {
    Write-Host "[ERRO] Falha ao criar chamados!" -ForegroundColor Red
    Write-Host "Detalhes: $_" -ForegroundColor Red
    exit 1
}

Write-Host "[3/3] Verificando resultado..." -ForegroundColor Yellow

try {
    $chamados = Invoke-RestMethod -Uri "http://localhost:5246/api/chamados" -Method Get
    Write-Host "[OK] Chamados verificados: $($chamados.Count) no total" -ForegroundColor Green
} catch {
    Write-Host "[AVISO] Nao foi possivel verificar (pode ser necessario autenticacao)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Chamados de demonstracao criados com sucesso!" -ForegroundColor Green
Write-Host "Teste o sistema com usuarios realistas!" -ForegroundColor Cyan
Write-Host ""
