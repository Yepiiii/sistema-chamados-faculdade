# Script para iniciar apenas o Backend
# Use este script quando estiver usando Live Server para o frontend

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Iniciando Backend para Live Server" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Parar processos anteriores
Write-Host "[INFO] Verificando processos anteriores..." -ForegroundColor Yellow
$processos = Get-Process -Name "SistemaChamados" -ErrorAction SilentlyContinue
if ($processos) {
    Write-Host "[INFO] Parando processos anteriores..." -ForegroundColor Yellow
    $processos | Stop-Process -Force
    Start-Sleep -Seconds 2
}

# Iniciar backend em nova janela
Write-Host "[INFO] Iniciando backend..." -ForegroundColor Green
Write-Host ""

Start-Process powershell -ArgumentList "-NoExit", "-Command", @"
cd '$PWD\Backend'
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ' Backend do Sistema de Chamados' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ''
Write-Host '[INFO] Rodando em: http://localhost:5246' -ForegroundColor Green
Write-Host '[INFO] Swagger em: http://localhost:5246/swagger' -ForegroundColor Yellow
Write-Host ''
Write-Host 'Pressione Ctrl+C para parar o servidor' -ForegroundColor Gray
Write-Host ''
dotnet run
"@

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " Backend iniciado!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Backend rodando em: " -NoNewline -ForegroundColor White
Write-Host "http://localhost:5246" -ForegroundColor Cyan
Write-Host "Swagger disponível em: " -NoNewline -ForegroundColor White
Write-Host "http://localhost:5246/swagger" -ForegroundColor Cyan
Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host " Instruções para Live Server" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "IMPORTANTE: " -ForegroundColor Red -NoNewline
Write-Host "Abra o Live Server da pasta Frontend!`n" -ForegroundColor Yellow

Write-Host "OPÇÃO 1 (RECOMENDADA):" -ForegroundColor Green
Write-Host "1. No VS Code, navegue até a pasta " -NoNewline
Write-Host "Frontend" -ForegroundColor Cyan
Write-Host "2. Clique com botão direito em " -NoNewline
Write-Host "index.html" -ForegroundColor Cyan
Write-Host "   (que está DENTRO da pasta Frontend)"
Write-Host "3. Selecione " -NoNewline
Write-Host "'Open with Live Server'" -ForegroundColor Cyan
Write-Host "4. Abrirá em: " -NoNewline
Write-Host "http://localhost:5500" -ForegroundColor Green
Write-Host ""

Write-Host "OPÇÃO 2 (Se abriu da raiz):" -ForegroundColor Yellow
Write-Host "Acesse manualmente: " -NoNewline
Write-Host "http://localhost:5500/Frontend/index.html" -ForegroundColor Cyan
Write-Host ""
Write-Host "O frontend (Live Server) se conectará" -ForegroundColor White
Write-Host "automaticamente ao backend (porta 5246)" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host " URLs de Teste" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "Live Server Frontend:" -ForegroundColor White
Write-Host "  http://localhost:5500/index.html" -ForegroundColor Cyan
Write-Host "  http://localhost:5500/pages/login.html" -ForegroundColor Cyan
Write-Host ""
Write-Host "Backend API:" -ForegroundColor White
Write-Host "  http://localhost:5246/api/Categorias" -ForegroundColor Cyan
Write-Host "  http://localhost:5246/swagger" -ForegroundColor Cyan
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " Contas de Teste" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Usuario: " -NoNewline -ForegroundColor White
Write-Host "usuario@teste.com / teste123" -ForegroundColor Yellow
Write-Host "Tecnico: " -NoNewline -ForegroundColor White
Write-Host "tecnico@teste.com / teste123" -ForegroundColor Yellow
Write-Host "Admin:   " -NoNewline -ForegroundColor White
Write-Host "admin@teste.com / teste123" -ForegroundColor Yellow
Write-Host ""
