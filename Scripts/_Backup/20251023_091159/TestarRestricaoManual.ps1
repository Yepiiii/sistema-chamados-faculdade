# Script para testar restricao de criacao manual de chamados
# Apenas Admin pode criar com classificacao manual
# Alunos e Professores DEVEM usar IA

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TESTE: Restricao de Classificacao Manual" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$baseUrl = "http://localhost:5246/api"

# Função auxiliar para login
function Get-Token {
    param($email, $senha)
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/usuarios/login" -Method Post `
            -Body (@{Email=$email;Senha=$senha} | ConvertTo-Json) -ContentType "application/json"
        return $response.token
    } catch {
        Write-Host "[ERRO] Erro no login: $_" -ForegroundColor Red
        return $null
    }
}

# Teste 1: Aluno tentando criar com classificacao manual (DEVE FALHAR)
Write-Host "Teste 1: ALUNO tentando criar chamado MANUAL..." -ForegroundColor Yellow
$tokenAluno = Get-Token "aluno@sistema.com" "Aluno@123"
if ($tokenAluno) {
    try {
        $headers = @{ Authorization = "Bearer $tokenAluno" }
        $body = @{
            UsarAnaliseAutomatica = $false
            Titulo = "Teste Manual Aluno"
            Descricao = "Tentativa de criar manualmente"
            CategoriaId = 1
            PrioridadeId = 2
        } | ConvertTo-Json
        
        $result = Invoke-RestMethod -Uri "$baseUrl/chamados" -Method Post -Headers $headers -Body $body -ContentType "application/json"
        Write-Host "[ERRO] Aluno conseguiu criar manual - TESTE FALHOU!" -ForegroundColor Red
    } catch {
        if ($_.Exception.Response.StatusCode -eq 403) {
            Write-Host "[OK] Aluno bloqueado corretamente (403 Forbidden)" -ForegroundColor Green
        } else {
            Write-Host "[AVISO] Erro inesperado: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

Start-Sleep -Seconds 1

# Teste 2: Professor tentando criar com classificacao manual (DEVE FALHAR)
Write-Host "`nTeste 2: PROFESSOR tentando criar chamado MANUAL..." -ForegroundColor Yellow
$tokenProf = Get-Token "professor@sistema.com" "Prof@123"
if ($tokenProf) {
    try {
        $headers = @{ Authorization = "Bearer $tokenProf" }
        $body = @{
            UsarAnaliseAutomatica = $false
            Titulo = "Teste Manual Professor"
            Descricao = "Tentativa de criar manualmente"
            CategoriaId = 2
            PrioridadeId = 1
        } | ConvertTo-Json
        
        $result = Invoke-RestMethod -Uri "$baseUrl/chamados" -Method Post -Headers $headers -Body $body -ContentType "application/json"
        Write-Host "[ERRO] Professor conseguiu criar manual - TESTE FALHOU!" -ForegroundColor Red
    } catch {
        if ($_.Exception.Response.StatusCode -eq 403) {
            Write-Host "[OK] Professor bloqueado corretamente (403 Forbidden)" -ForegroundColor Green
        } else {
            Write-Host "[AVISO] Erro inesperado: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

Start-Sleep -Seconds 1

# Teste 3: Admin criando com classificacao manual (DEVE FUNCIONAR)
Write-Host "`nTeste 3: ADMIN criando chamado MANUAL..." -ForegroundColor Yellow
$tokenAdmin = Get-Token "admin@sistema.com" "Admin@123"
if ($tokenAdmin) {
    try {
        $headers = @{ Authorization = "Bearer $tokenAdmin" }
        $body = @{
            UsarAnaliseAutomatica = $false
            Titulo = "Teste Manual Admin"
            Descricao = "Admin pode criar manualmente"
            CategoriaId = 1
            PrioridadeId = 3
        } | ConvertTo-Json
        
        $result = Invoke-RestMethod -Uri "$baseUrl/chamados" -Method Post -Headers $headers -Body $body -ContentType "application/json"
        Write-Host "[OK] Admin criou chamado manual com sucesso!" -ForegroundColor Green
        Write-Host "   ID do chamado: $($result.id)" -ForegroundColor Gray
    } catch {
        Write-Host "[ERRO] Admin nao conseguiu criar manual - TESTE FALHOU!" -ForegroundColor Red
        Write-Host "   Erro: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Start-Sleep -Seconds 1

# Teste 4: Aluno criando com IA (DEVE FUNCIONAR)
Write-Host "`nTeste 4: ALUNO criando chamado com IA..." -ForegroundColor Yellow
if ($tokenAluno) {
    try {
        $headers = @{ Authorization = "Bearer $tokenAluno" }
        $body = @{
            Descricao = "Computador travando muito na sala 202"
        } | ConvertTo-Json
        
        $result = Invoke-RestMethod -Uri "$baseUrl/chamados" -Method Post -Headers $headers -Body $body -ContentType "application/json"
        Write-Host "[OK] Aluno criou com IA com sucesso!" -ForegroundColor Green
        Write-Host "   ID: $($result.id) | Titulo: $($result.titulo)" -ForegroundColor Gray
        Write-Host "   Categoria: $($result.categoria.nome) | Prioridade: $($result.prioridade.nome)" -ForegroundColor Gray
    } catch {
        Write-Host "[ERRO] Aluno nao conseguiu criar com IA - TESTE FALHOU!" -ForegroundColor Red
        Write-Host "   Erro: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Start-Sleep -Seconds 1

# Teste 5: Professor criando com IA (DEVE FUNCIONAR)
Write-Host "`nTeste 5: PROFESSOR criando chamado com IA..." -ForegroundColor Yellow
if ($tokenProf) {
    try {
        $headers = @{ Authorization = "Bearer $tokenProf" }
        $body = @{
            Descricao = "Preciso acessar o portal academico urgente"
        } | ConvertTo-Json
        
        $result = Invoke-RestMethod -Uri "$baseUrl/chamados" -Method Post -Headers $headers -Body $body -ContentType "application/json"
        Write-Host "[OK] Professor criou com IA com sucesso!" -ForegroundColor Green
        Write-Host "   ID: $($result.id) | Titulo: $($result.titulo)" -ForegroundColor Gray
        Write-Host "   Categoria: $($result.categoria.nome) | Prioridade: $($result.prioridade.nome)" -ForegroundColor Gray
    } catch {
        Write-Host "[ERRO] Professor nao conseguiu criar com IA - TESTE FALHOU!" -ForegroundColor Red
        Write-Host "   Erro: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "RESUMO DOS TESTES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "[OK] = Passou | [ERRO] = Falhou`n" -ForegroundColor Gray
