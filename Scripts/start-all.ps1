# Script mestre para iniciar Backend e Frontend simultaneamente
# Executar como: .\start-all.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INICIANDO AMBIENTE DE TESTES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Backend API: http://localhost:5246" -ForegroundColor Green
Write-Host "Frontend Web: http://localhost:8080" -ForegroundColor Green
Write-Host "Mobile APK: http://192.168.1.6:5246/api/" -ForegroundColor Green
Write-Host ""

# Verificar se há processos nas portas
Write-Host "Verificando portas..." -ForegroundColor Yellow

$port5246 = netstat -ano | Select-String ":5246" | Select-String "LISTENING"
$port8080 = netstat -ano | Select-String ":8080" | Select-String "LISTENING"

if ($port5246) {
    Write-Host "AVISO: Porta 5246 (Backend) já está em uso!" -ForegroundColor Red
}

if ($port8080) {
    Write-Host "AVISO: Porta 8080 (Frontend) já está em uso!" -ForegroundColor Red
}

if ($port5246 -or $port8080) {
    Write-Host ""
    $continue = Read-Host "Continuar mesmo assim? (S/N)"
    if ($continue -ne "S" -and $continue -ne "s") {
        Write-Host "Execução cancelada." -ForegroundColor Red
        exit
    }
}

Write-Host ""
Write-Host "Iniciando Backend e Frontend em terminais separados..." -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANTE: " -ForegroundColor Yellow
Write-Host "- Dois novos terminais serão abertos" -ForegroundColor White
Write-Host "- NÃO FECHE os terminais durante os testes" -ForegroundColor White
Write-Host "- Para parar, pressione Ctrl+C em cada terminal" -ForegroundColor White
Write-Host ""

# Obter caminho completo dos scripts
$scriptPath = $PSScriptRoot
$backendScript = Join-Path $scriptPath "start-backend.ps1"
$frontendScript = Join-Path $scriptPath "start-frontend.ps1"

# Iniciar Backend em novo terminal
Write-Host "Iniciando Backend..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", "`"$backendScript`""

# Aguardar 2 segundos
Start-Sleep -Seconds 2

# Iniciar Frontend em novo terminal
Write-Host "Iniciando Frontend..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", "`"$frontendScript`""

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  AMBIENTE INICIADO!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Aguarde alguns segundos e acesse:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Backend (Swagger): http://localhost:5246/swagger" -ForegroundColor Cyan
Write-Host "Frontend (Web):    http://localhost:8080" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para gerar o APK do Mobile, execute:" -ForegroundColor Yellow
Write-Host ".\build-mobile-apk.ps1" -ForegroundColor White
Write-Host ""
Write-Host "Pressione qualquer tecla para sair deste terminal..."
Write-Host "(Os servidores continuarão rodando nos outros terminais)" -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
