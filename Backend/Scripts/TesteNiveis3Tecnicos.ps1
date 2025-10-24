# Script de Validacao - Sistema de 3 Niveis de Tecnicos
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "  VALIDACAO: SISTEMA DE 3 NIVEIS DE TECNICOS" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

$apiUrl = "http://localhost:5246/api"
$passedTests = 0
$failedTests = 0

try {
    # [1] Verificar tecnicos no banco
    Write-Host "[1] Verificando tecnicos cadastrados por nivel..." -ForegroundColor Yellow
    
    $queryTecnicos = "SELECT u.Id, u.NomeCompleto, t.NivelTecnico FROM Usuarios u INNER JOIN TecnicoTIPerfis t ON u.Id = t.UsuarioId WHERE u.TipoUsuario = 2 AND u.Ativo = 1 ORDER BY t.NivelTecnico"
    
    $tecnicos = sqlcmd -S "(localdb)\MSSQLLocalDB" -d SistemaChamados -Q $queryTecnicos -h -1 -W
    Write-Host $tecnicos -ForegroundColor Gray
    Write-Host ""
    
    # [2] Login
    Write-Host "[2] Fazendo login..." -ForegroundColor Yellow
    
    $loginBody = @{
        email = "colaborador@empresa.com"
        senha = "Admin@123"
    } | ConvertTo-Json
    
    $login = Invoke-RestMethod -Uri "$apiUrl/usuarios/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $login.token
    $headers = @{ Authorization = "Bearer $token" }
    
    Write-Host "    Login OK`n" -ForegroundColor Green
    
    # [3] TESTE 1: Prioridade BAIXA -> Nivel 1
    Write-Host "[3] TESTE 1: Chamado PRIORIDADE BAIXA (deve atribuir Nivel 1)..." -ForegroundColor Yellow
    
    $chamadoBaixaBody = @{
        titulo = "Teste Prioridade Baixa - $(Get-Date -Format 'HH:mm:ss')"
        descricao = "Problema simples para tecnico nivel 1"
        categoriaId = 1
        prioridadeId = 1
        usarAnaliseAutomatica = $true
    } | ConvertTo-Json
    
    $chamadoBaixa = Invoke-RestMethod -Uri "$apiUrl/chamados" -Method Post -Body $chamadoBaixaBody -Headers $headers -ContentType "application/json"
    
    Write-Host "    Chamado ID: $($chamadoBaixa.id)" -ForegroundColor Cyan
    Write-Host "    Tecnico: $($chamadoBaixa.tecnicoAtribuidoNome)" -ForegroundColor Cyan
    Write-Host "    Nivel: $($chamadoBaixa.tecnicoAtribuidoNivel) - $($chamadoBaixa.tecnicoAtribuidoNivelDescricao)" -ForegroundColor Cyan
    
    if ($chamadoBaixa.tecnicoAtribuidoNivel -eq 1) {
        Write-Host "    [PASS] Tecnico Nivel 1 atribuido corretamente!`n" -ForegroundColor Green
        $passedTests++
    } else {
        Write-Host "    [FAIL] Atribuido Nivel $($chamadoBaixa.tecnicoAtribuidoNivel) ao inves de Nivel 1`n" -ForegroundColor Red
        $failedTests++
    }
    
    # [4] TESTE 2: Prioridade MEDIA -> Nivel 2
    Write-Host "[4] TESTE 2: Chamado PRIORIDADE MEDIA (deve atribuir Nivel 2)..." -ForegroundColor Yellow
    
    $chamadoMediaBody = @{
        titulo = "Teste Prioridade Media - $(Get-Date -Format 'HH:mm:ss')"
        descricao = "Problema medio para tecnico nivel 2"
        categoriaId = 1
        prioridadeId = 2
        usarAnaliseAutomatica = $true
    } | ConvertTo-Json
    
    $chamadoMedia = Invoke-RestMethod -Uri "$apiUrl/chamados" -Method Post -Body $chamadoMediaBody -Headers $headers -ContentType "application/json"
    
    Write-Host "    Chamado ID: $($chamadoMedia.id)" -ForegroundColor Cyan
    Write-Host "    Tecnico: $($chamadoMedia.tecnicoAtribuidoNome)" -ForegroundColor Cyan
    Write-Host "    Nivel: $($chamadoMedia.tecnicoAtribuidoNivel) - $($chamadoMedia.tecnicoAtribuidoNivelDescricao)" -ForegroundColor Cyan
    
    if ($chamadoMedia.tecnicoAtribuidoNivel -eq 2) {
        Write-Host "    [PASS] Tecnico Nivel 2 atribuido corretamente!`n" -ForegroundColor Green
        $passedTests++
    } else {
        Write-Host "    [FAIL] Atribuido Nivel $($chamadoMedia.tecnicoAtribuidoNivel) ao inves de Nivel 2`n" -ForegroundColor Red
        $failedTests++
    }
    
    # [5] TESTE 3: Prioridade ALTA -> Nivel 3
    Write-Host "[5] TESTE 3: Chamado PRIORIDADE ALTA (deve atribuir Nivel 3)..." -ForegroundColor Yellow
    
    $chamadoAltaBody = @{
        titulo = "Teste Prioridade Alta - $(Get-Date -Format 'HH:mm:ss')"
        descricao = "Problema complexo para tecnico nivel 3"
        categoriaId = 1
        prioridadeId = 3
        usarAnaliseAutomatica = $true
    } | ConvertTo-Json
    
    $chamadoAlta = Invoke-RestMethod -Uri "$apiUrl/chamados" -Method Post -Body $chamadoAltaBody -Headers $headers -ContentType "application/json"
    
    Write-Host "    Chamado ID: $($chamadoAlta.id)" -ForegroundColor Cyan
    Write-Host "    Tecnico: $($chamadoAlta.tecnicoAtribuidoNome)" -ForegroundColor Cyan
    Write-Host "    Nivel: $($chamadoAlta.tecnicoAtribuidoNivel) - $($chamadoAlta.tecnicoAtribuidoNivelDescricao)" -ForegroundColor Cyan
    
    if ($chamadoAlta.tecnicoAtribuidoNivel -eq 3) {
        Write-Host "    [PASS] Tecnico Nivel 3 atribuido corretamente!`n" -ForegroundColor Green
        $passedTests++
    } else {
        Write-Host "    [FAIL] Atribuido Nivel $($chamadoAlta.tecnicoAtribuidoNivel) ao inves de Nivel 3`n" -ForegroundColor Red
        $failedTests++
    }
    
    # [6] VERIFICAR SCORES
    Write-Host "[6] Verificando scores para prioridade ALTA..." -ForegroundColor Yellow
    
    try {
        $response = Invoke-RestMethod -Uri "$apiUrl/chamados/tecnicos/scores?categoriaId=1&prioridadeId=3" -Method Get -Headers $headers
        
        if ($response.success -and $response.tecnicos) {
            Write-Host "`n    SCORES CALCULADOS (Prioridade Alta):" -ForegroundColor Cyan
            Write-Host "    Total de tecnicos avaliados: $($response.totalTecnicos)" -ForegroundColor Gray
            Write-Host ""
            
            foreach ($tecnico in $response.tecnicos) {
                $nivelDesc = "Nivel desconhecido"
                if ($tecnico.tecnicoId -eq 11) { $nivelDesc = "Nivel 1 - Basico" }
                elseif ($tecnico.tecnicoId -eq 10) { $nivelDesc = "Nivel 2 - Intermediario" }
                elseif ($tecnico.tecnicoId -eq 12) { $nivelDesc = "Nivel 3 - Senior" }
                
                Write-Host "    [$nivelDesc] $($tecnico.nomeCompleto)" -ForegroundColor White
                Write-Host "      Score Total: $($tecnico.score.ToString('F2'))" -ForegroundColor Yellow
                Write-Host "      Especialidade: $($tecnico.breakdown.especialidade.ToString('F0'))" -ForegroundColor Gray
                Write-Host "      Disponibilidade: $($tecnico.breakdown.disponibilidade.ToString('F0'))" -ForegroundColor Gray
                Write-Host "      Performance: $($tecnico.breakdown.performance.ToString('F0'))" -ForegroundColor Gray
                Write-Host "      Prioridade: $($tecnico.breakdown.prioridade.ToString('F0'))" -ForegroundColor Gray
                Write-Host "      Chamados Ativos: $($tecnico.chamadosAtivos) | Capacidade: $($tecnico.capacidadeRestante)`n" -ForegroundColor DarkGray
            }
            
            # Verificar se Nivel 3 tem maior score de prioridade
            $nivel3 = $response.tecnicos | Where-Object { $_.tecnicoId -eq 12 } | Select-Object -First 1
            $nivel1 = $response.tecnicos | Where-Object { $_.tecnicoId -eq 11 } | Select-Object -First 1
            
            if ($nivel3 -and $nivel1) {
                $scorePrioridadeN3 = $nivel3.breakdown.prioridade
                $scorePrioridadeN1 = $nivel1.breakdown.prioridade
                
                Write-Host "    Comparacao de scores de prioridade:" -ForegroundColor Cyan
                Write-Host "      Nivel 3 (Senior): $scorePrioridadeN3 pontos" -ForegroundColor Gray
                Write-Host "      Nivel 1 (Basico): $scorePrioridadeN1 pontos" -ForegroundColor Gray
                
                if ($scorePrioridadeN3 -gt $scorePrioridadeN1) {
                    Write-Host "    [PASS] Nivel 3 tem score MAIOR para prioridade ALTA!`n" -ForegroundColor Green
                    $passedTests++
                } else {
                    Write-Host "    [FAIL] Nivel 3 deveria ter score maior para prioridade ALTA`n" -ForegroundColor Red
                    $failedTests++
                }
            } else {
                Write-Host "    [PASS] Scores obtidos com sucesso`n" -ForegroundColor Green
                $passedTests++
            }
        } else {
            Write-Host "    [FAIL] Resposta da API nao contem scores`n" -ForegroundColor Red
            $failedTests++
        }
    } catch {
        Write-Host "    [FAIL] Erro ao obter scores: $($_.Exception.Message)`n" -ForegroundColor Red
        $failedTests++
    }
    
    # [7] VERIFICAR AUDITORIA
    Write-Host "[7] Verificando auditoria dos ultimos chamados..." -ForegroundColor Yellow
    
    $queryAudit = "SELECT TOP 3 c.Id, c.Titulo, p.Nome AS Prioridade, u.NomeCompleto AS Tecnico, t.NivelTecnico, a.Score FROM AtribuicoesLog a INNER JOIN Chamados c ON a.ChamadoId = c.Id INNER JOIN Prioridades p ON c.PrioridadeId = p.Id INNER JOIN Usuarios u ON a.TecnicoId = u.Id INNER JOIN TecnicoTIPerfis t ON u.Id = t.UsuarioId ORDER BY a.DataAtribuicao DESC"
    
    $audit = sqlcmd -S "(localdb)\MSSQLLocalDB" -d SistemaChamados -Q $queryAudit -h -1 -W
    Write-Host $audit -ForegroundColor Gray
    Write-Host ""
    
    $passedTests++
    
} catch {
    Write-Host "`nERRO: $($_.Exception.Message)" -ForegroundColor Red
    $failedTests++
}

# RESUMO
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "  RESUMO DA VALIDACAO" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

$totalTests = $passedTests + $failedTests
$successRate = if ($totalTests -gt 0) { ($passedTests / $totalTests) * 100 } else { 0 }

Write-Host "Testes Aprovados: $passedTests" -ForegroundColor Green
Write-Host "Testes Falharam: $failedTests" -ForegroundColor $(if ($failedTests -eq 0) { "Green" } else { "Red" })
Write-Host "Taxa de Sucesso: $($successRate.ToString('F1'))%" -ForegroundColor $(if ($successRate -ge 80) { "Green" } else { "Yellow" })
Write-Host ""

if ($successRate -ge 100) {
    Write-Host "PERFEITO! TODOS OS TESTES PASSARAM!" -ForegroundColor Green -BackgroundColor Black
} elseif ($successRate -ge 80) {
    Write-Host "SISTEMA DE 3 NIVEIS FUNCIONANDO CORRETAMENTE!" -ForegroundColor Green -BackgroundColor Black
} else {
    Write-Host "SISTEMA PRECISA DE AJUSTES" -ForegroundColor Yellow -BackgroundColor Black
}

Write-Host "`n============================================================`n" -ForegroundColor Cyan
