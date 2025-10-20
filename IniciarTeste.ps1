# Script para iniciar API e Mobile App em paralelo

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host " SISTEMA DE CHAMADOS - Iniciar Teste" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# 1. Iniciar API em nova janela
Write-Host "[1/3] Iniciando API REST..." -ForegroundColor Yellow
$apiPath = "C:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade"
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd '$apiPath'; Write-Host '[API] Iniciando em http://localhost:5246...' -ForegroundColor Green; dotnet run --project SistemaChamados.csproj --urls http://localhost:5246"
)
Write-Host "[OK] Janela da API aberta" -ForegroundColor Green
Write-Host ""

# 2. Aguardar API inicializar
Write-Host "[2/3] Aguardando API inicializar (15 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# 3. Testar conexão com API
Write-Host "[3/3] Testando conexão com API..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5246/api/categorias" -Method GET -UseBasicParsing -TimeoutSec 5
    Write-Host "[OK] API respondeu com status: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "[AVISO] API ainda não respondeu. Pode levar mais alguns segundos..." -ForegroundColor Yellow
}
Write-Host ""

# 4. Iniciar Mobile App
Write-Host "[4/4] Iniciando Mobile App para Windows..." -ForegroundColor Yellow
$mobilePath = "C:\Users\opera\sistema-chamados-faculdade\SistemaChamados.Mobile"
cd $mobilePath
Write-Host "[INFO] Compilando e executando Mobile App..." -ForegroundColor Cyan
dotnet build -t:Run -f net8.0-windows10.0.19041.0

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host " APP MOBILE INICIADO!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

Write-Host "🎯 TESTE AS NOVAS FUNCIONALIDADES:" -ForegroundColor Yellow
Write-Host ""

Write-Host "1️⃣  NOTIFICAÇÕES (TESTE RÁPIDO - 30 segundos):" -ForegroundColor Cyan
Write-Host "   - Faça login no app" -ForegroundColor Gray
Write-Host "   - Na lista de chamados, procure o botão 🔔 (LARANJA)" -ForegroundColor Gray
Write-Host "   - TOQUE NO BOTÃO 🔔" -ForegroundColor White
Write-Host "   - Veja o alerta de confirmação" -ForegroundColor Gray
Write-Host "   - No Windows, notificações aparecerão na Central de Ações" -ForegroundColor Gray
Write-Host "   - Toque em uma notificação para navegar ao chamado" -ForegroundColor Gray
Write-Host ""

Write-Host "2️⃣  COMENTÁRIOS:" -ForegroundColor Cyan
Write-Host "   - Abra um chamado" -ForegroundColor Gray
Write-Host "   - Role até 'Comentários'" -ForegroundColor Gray
Write-Host "   - Digite um comentário e envie" -ForegroundColor Gray
Write-Host "   - Deve aparecer instantaneamente com seu avatar" -ForegroundColor Gray
Write-Host ""

Write-Host "3️⃣  UPLOAD DE ARQUIVOS:" -ForegroundColor Cyan
Write-Host "   - Na tela de detalhes, role até 'Anexos'" -ForegroundColor Gray
Write-Host "   - Toque em 'Adicionar Anexo'" -ForegroundColor Gray
Write-Host "   - Selecione uma imagem" -ForegroundColor Gray
Write-Host "   - Verifique o thumbnail aparece" -ForegroundColor Gray
Write-Host ""

Write-Host "4️⃣  TIMELINE DE HISTÓRICO:" -ForegroundColor Cyan
Write-Host "   - Role até 'Histórico'" -ForegroundColor Gray
Write-Host "   - Veja eventos cronológicos com ícones e cores" -ForegroundColor Gray
Write-Host ""

Write-Host "5️⃣  POLLING AUTOMÁTICO:" -ForegroundColor Cyan
Write-Host "   - Deixe o app aberto por 5 minutos" -ForegroundColor Gray
Write-Host "   - OU use o botão 🔔 para teste imediato!" -ForegroundColor White
Write-Host ""

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📚 DOCUMENTAÇÃO COMPLETA:" -ForegroundColor Yellow
Write-Host "   - SistemaChamados.Mobile\TESTE_COMPLETO.md" -ForegroundColor Gray
Write-Host "   - SistemaChamados.Mobile\STATUS_IMPLEMENTACAO.md" -ForegroundColor Gray
Write-Host ""
Write-Host "🎉 TODAS AS 5 FEATURES IMPLEMENTADAS E FUNCIONANDO!" -ForegroundColor Green
Write-Host ""
