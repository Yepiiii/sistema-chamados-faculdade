# Script para abrir o projeto no Visual Studio e preparar para execução

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$solutionPath = Join-Path $repoRoot "sistema-chamados-faculdade.sln"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ABRIR PROJETO NO VISUAL STUDIO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if(-not (Test-Path $solutionPath)) {
    Write-Host "❌ Solução não encontrada em:" -ForegroundColor Red
    Write-Host "   $solutionPath" -ForegroundColor Gray
    exit 1
}

Write-Host "✅ Solução encontrada!" -ForegroundColor Green
Write-Host ""
Write-Host "📂 Abrindo Visual Studio 2022..." -ForegroundColor Cyan
Write-Host ""

# Abrir no Visual Studio
Start-Process $solutionPath

Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  PRÓXIMOS PASSOS NO VISUAL STUDIO" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

Write-Host "1️⃣  Aguarde o Visual Studio abrir completamente" -ForegroundColor White
Write-Host ""

Write-Host "2️⃣  No Solution Explorer (lado direito):" -ForegroundColor White
Write-Host "   - Localize 'SistemaChamados.Mobile'" -ForegroundColor Gray
Write-Host "   - Clique direito > 'Definir como Projeto de Inicialização'" -ForegroundColor Gray
Write-Host "   - O projeto ficará em negrito" -ForegroundColor Gray
Write-Host ""

Write-Host "3️⃣  Na barra de ferramentas superior:" -ForegroundColor White
Write-Host "   - Procure o dropdown de dispositivos (ao lado do Play)" -ForegroundColor Gray
Write-Host "   - Se mostrar 'Android Emulator', clique nele" -ForegroundColor Gray
Write-Host ""

Write-Host "4️⃣  Selecione um emulador:" -ForegroundColor White
Write-Host ""
Write-Host "   OPÇÃO A - Usar emulador existente:" -ForegroundColor Cyan
Write-Host "   - Selecione um emulador da lista" -ForegroundColor Gray
Write-Host ""
Write-Host "   OPÇÃO B - Criar novo emulador:" -ForegroundColor Cyan
Write-Host "   - Clique em 'Create New Emulator...'" -ForegroundColor Gray
Write-Host "   - Escolha: Pixel 5 ou Pixel 7" -ForegroundColor Gray
Write-Host "   - API Level: 33 (Android 13.0) ou superior" -ForegroundColor Gray
Write-Host "   - Clique 'Create'" -ForegroundColor Gray
Write-Host ""

Write-Host "5️⃣  Executar:" -ForegroundColor White
Write-Host "   - Pressione F5 (ou clique no botão Play verde)" -ForegroundColor Gray
Write-Host "   - Aguarde compilação e inicialização do emulador" -ForegroundColor Gray
Write-Host "   - O app abrirá automaticamente!" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  APÓS O APP ABRIR" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "✅ TESTE RÁPIDO DE NOTIFICAÇÕES:" -ForegroundColor Green
Write-Host ""
Write-Host "1. Faça login no app" -ForegroundColor White
Write-Host "2. Na lista de chamados, procure o botão 🔔 (laranja)" -ForegroundColor White
Write-Host "3. Toque no botão 🔔" -ForegroundColor White
Write-Host "4. Puxe a barra de notificações do emulador" -ForegroundColor White
Write-Host "5. Deve ver 3 notificações com cores diferentes!" -ForegroundColor White
Write-Host "6. Toque em uma notificação" -ForegroundColor White
Write-Host "7. App navega para o detalhe do chamado ✨" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  LOGS E DEBUG" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "No Visual Studio, veja a janela 'Output' (Ctrl+Alt+O)" -ForegroundColor White
Write-Host "Selecione 'Debug' no dropdown" -ForegroundColor Gray
Write-Host ""
Write-Host "Logs esperados:" -ForegroundColor Cyan
Write-Host "  [ChamadosListViewModel] Polling iniciado." -ForegroundColor DarkGray
Write-Host "  [PollingService] Timer iniciado..." -ForegroundColor DarkGray
Write-Host "  [NotificationService] Exibindo notificação..." -ForegroundColor DarkGray
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "  Visual Studio está abrindo!" -ForegroundColor Green
Write-Host "  Siga os passos acima para testar 🚀" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
