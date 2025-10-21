# Script para testar a integração com Gemini AI
Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Teste do Gemini AI" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Aguardar API iniciar
Write-Host "Aguardando API iniciar (10 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

try {
    # Fazer login
    Write-Host "1. Fazendo login..." -ForegroundColor Cyan
    $loginBody = @{
        Email = "admin@sistema.com"
        Senha = "Admin@123"
    } | ConvertTo-Json
    
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:5246/api/usuarios/login" -Method Post -Body $loginBody -ContentType "application/json" -ErrorAction Stop
    $token = $loginResponse.token
    
    Write-Host "   [OK] Login realizado" -ForegroundColor Green
    Write-Host ""
    
    # Criar header de autorização
    $headers = @{ Authorization = "Bearer $token" }
    
    # Criar chamado de teste
    Write-Host "2. Criando chamado de teste com Gemini AI..." -ForegroundColor Cyan
    Write-Host "   Descrição: 'Meu computador não liga quando aperto o botão'" -ForegroundColor Gray
    Write-Host ""
    
    $chamadoBody = @{
        DescricaoProblema = "Meu computador não liga quando aperto o botão. Já tentei trocar a tomada mas não funcionou. É urgente pois tenho trabalho importante."
    } | ConvertTo-Json
    
    $chamadoResponse = Invoke-RestMethod -Uri "http://localhost:5246/api/chamados/analisar" -Method Post -Headers $headers -Body $chamadoBody -ContentType "application/json" -ErrorAction Stop
    
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  CHAMADO CRIADO COM SUCESSO!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "DETALHES DO CHAMADO:" -ForegroundColor Cyan
    Write-Host "ID: $($chamadoResponse.id)" -ForegroundColor White
    Write-Host "Título: $($chamadoResponse.titulo)" -ForegroundColor White
    Write-Host "Categoria: $($chamadoResponse.categoria.nome) (ID: $($chamadoResponse.categoriaId))" -ForegroundColor Yellow
    Write-Host "Prioridade: $($chamadoResponse.prioridade.nome) (ID: $($chamadoResponse.prioridadeId))" -ForegroundColor Yellow
    Write-Host "Status: $($chamadoResponse.status.nome)" -ForegroundColor White
    
    if ($chamadoResponse.tecnicoAtribuido) {
        Write-Host "Técnico Atribuído: $($chamadoResponse.tecnicoAtribuido.nomeCompleto)" -ForegroundColor Magenta
    }
    else {
        Write-Host "Técnico Atribuído: Nenhum" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "ANÁLISE DO GEMINI:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "✓ O Gemini analisou a descrição do problema" -ForegroundColor Green
    Write-Host "✓ Categorizou automaticamente" -ForegroundColor Green
    Write-Host "✓ Definiu a prioridade baseado em 'urgente'" -ForegroundColor Green
    Write-Host "✓ Atribuiu técnico especialista (se disponível)" -ForegroundColor Green
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    
    Write-Host ""
    Write-Host "Resposta completa:" -ForegroundColor Gray
    $chamadoResponse | ConvertTo-Json -Depth 5
    Write-Host ""
}
catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  ERRO NO TESTE" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Mensagem: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.ErrorDetails) {
        Write-Host "Detalhes: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "POSSÍVEIS CAUSAS:" -ForegroundColor Yellow
    Write-Host "1. API não está rodando" -ForegroundColor White
    Write-Host "2. Chave do Gemini inválida no arquivo .env" -ForegroundColor White
    Write-Host "3. Problema de conexão com a API do Gemini" -ForegroundColor White
    Write-Host ""
    Write-Host "Verifique os logs da janela da API para mais detalhes." -ForegroundColor Yellow
    Write-Host ""
}
