# ========================================
#  INICIAR FRONTEND WEB + BACKEND
# ========================================
# Script para testar o Frontend Web completo
# Data: 27/10/2025

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INICIANDO SISTEMA DE CHAMADOS WEB" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Passo 1: Copiar Frontend para wwwroot
Write-Host "[1/3] Copiando Frontend para Backend/wwwroot..." -ForegroundColor Yellow
$copiarScript = Join-Path $PSScriptRoot "CopiarFrontend.ps1"
& $copiarScript

Write-Host ""
Write-Host "[OK] Frontend sincronizado!" -ForegroundColor Green
Write-Host ""

# Passo 2: Iniciar Backend em nova janela
Write-Host "[2/3] Iniciando Backend API..." -ForegroundColor Yellow

$scriptBlock = {
    Set-Location "C:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade\Backend"
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host "    SERVIDOR API BACKEND" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Aguarde o servidor iniciar..." -ForegroundColor Yellow
    Write-Host ""
    dotnet run
}

Start-Process powershell -ArgumentList "-NoExit", "-Command", $scriptBlock

Write-Host "[OK] Backend sendo iniciado em nova janela!" -ForegroundColor Green
Write-Host ""

# Aguardar backend iniciar (10 segundos)
Write-Host "[3/3] Aguardando backend iniciar (10 segundos)..." -ForegroundColor Yellow
for ($i = 10; $i -gt 0; $i--) {
    Write-Host "  $i..." -NoNewline -ForegroundColor Cyan
    Start-Sleep -Seconds 1
}
Write-Host ""
Write-Host ""

# Passo 3: Abrir navegador
Write-Host "[OK] Abrindo navegador..." -ForegroundColor Green
Start-Sleep -Seconds 1

# Tentar abrir no Chrome primeiro, depois Edge, depois navegador padrão
$urls = @(
    "http://localhost:5246/",
    "http://localhost:5246/pages/login.html",
    "http://localhost:5246/swagger"
)

try {
    # Tentar Chrome
    if (Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe") {
        Start-Process "chrome.exe" -ArgumentList "--new-window", $urls[0]
        Write-Host "[OK] Chrome aberto!" -ForegroundColor Green
    }
    # Tentar Edge
    elseif (Test-Path "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe") {
        Start-Process "msedge.exe" -ArgumentList $urls[0]
        Write-Host "[OK] Edge aberto!" -ForegroundColor Green
    }
    # Navegador padrão
    else {
        Start-Process $urls[0]
        Write-Host "[OK] Navegador padrão aberto!" -ForegroundColor Green
    }
}
catch {
    Write-Host "[AVISO] Não foi possível abrir automaticamente" -ForegroundColor Yellow
    Write-Host "Abra manualmente: $($urls[0])" -ForegroundColor White
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  SISTEMA INICIADO COM SUCESSO!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "URLs DISPONÍVEIS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Frontend Web:" -ForegroundColor Yellow
Write-Host "    http://localhost:5246/" -ForegroundColor White
Write-Host "    http://localhost:5246/pages/login.html" -ForegroundColor White
Write-Host ""
Write-Host "  API Documentation:" -ForegroundColor Yellow
Write-Host "    http://localhost:5246/swagger" -ForegroundColor White
Write-Host ""

Write-Host "CONTAS DE TESTE:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  [USUÁRIO]" -ForegroundColor Green
Write-Host "    Email: usuario@teste.com" -ForegroundColor White
Write-Host "    Senha: teste123" -ForegroundColor White
Write-Host ""
Write-Host "  [TÉCNICO]" -ForegroundColor Blue
Write-Host "    Email: tecnico@teste.com" -ForegroundColor White
Write-Host "    Senha: teste123" -ForegroundColor White
Write-Host ""
Write-Host "  [ADMIN]" -ForegroundColor Magenta
Write-Host "    Email: admin@teste.com" -ForegroundColor White
Write-Host "    Senha: teste123" -ForegroundColor White
Write-Host ""

Write-Host "TESTES DISPONÍVEIS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Testar Cadastro:" -ForegroundColor Yellow
Write-Host "     - Criar nova conta em /pages/cadastro.html" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Testar Login:" -ForegroundColor Yellow
Write-Host "     - Fazer login com contas de teste" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Testar Fluxos:" -ForegroundColor Yellow
Write-Host "     - Usuario: Criar chamado" -ForegroundColor Gray
Write-Host "     - Tecnico: Ver chamados atribuídos" -ForegroundColor Gray
Write-Host "     - Admin: Gerenciar sistema" -ForegroundColor Gray
Write-Host ""
Write-Host "  4. Testar Acessibilidade:" -ForegroundColor Yellow
Write-Host "     - Pressione F12 (DevTools)" -ForegroundColor Gray
Write-Host "     - Console: auditAccessibility()" -ForegroundColor Gray
Write-Host ""

Write-Host "DOCUMENTAÇÃO:" -ForegroundColor Cyan
Write-Host "  - TESTE_FUNCIONAL.md (guia completo)" -ForegroundColor White
Write-Host "  - TESTE_ACESSIBILIDADE.md (testes WCAG)" -ForegroundColor White
Write-Host ""

Write-Host "PARA PARAR:" -ForegroundColor Cyan
Write-Host "  - Feche a janela do Backend (PowerShell)" -ForegroundColor White
Write-Host "  - Ou pressione Ctrl+C na janela do Backend" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Bons testes! 🚀" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
