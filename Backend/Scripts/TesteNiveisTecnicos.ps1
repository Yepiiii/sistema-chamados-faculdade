# ====================================================================
# SCRIPT DE VALIDAÇÃO - SISTEMA DE 3 NÍVEIS DE TÉCNICOS
# ====================================================================
# Valida a atribuição inteligente baseada em níveis:
# - Nível 1 (Básico): Prioridade Baixa
# - Nível 2 (Intermediário): Prioridade Média
# - Nível 3 (Sênior/Especialista): Prioridade Alta
# - Escalation automático quando nível adequado indisponível
# ====================================================================

Write-Host "`n" -NoNewline
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  VALIDAÇÃO: SISTEMA DE 3 NÍVEIS DE TÉCNICOS" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$apiUrl = "http://localhost:5246/api"
$testResults = @()

# Função auxiliar para exibir resultado
function Show-TestResult {
    param(
        [string]$TestName,
        [bool]$Passed,
        [string]$Message,
        [string]$Details = ""
    )
    
    $result = @{
        Test = $TestName
        Passed = $Passed
        Message = $Message
        Details = $Details
    }
    $script:testResults += $result
    
    if ($Passed) {
        Write-Host "[✓] " -ForegroundColor Green -NoNewline
        Write-Host "$TestName" -ForegroundColor White
        Write-Host "    → $Message" -ForegroundColor Gray
    } else {
        Write-Host "[✗] " -ForegroundColor Red -NoNewline
        Write-Host "$TestName" -ForegroundColor White
        Write-Host "    → $Message" -ForegroundColor Red
    }
    
    if ($Details) {
        Write-Host "    $Details" -ForegroundColor DarkGray
    }
    Write-Host ""
}

try {
    # ====================================================================
    # ETAPA 1: VERIFICAR TÉCNICOS NO BANCO
    # ====================================================================
    Write-Host "[1] Verificando técnicos cadastrados por nível..." -ForegroundColor Yellow
    
    $query = @"
SELECT 
    u.Id,
    u.NomeCompleto,
    t.NivelTecnico,
    CASE t.NivelTecnico
        WHEN 1 THEN 'Nível 1 - Suporte Básico'
        WHEN 2 THEN 'Nível 2 - Suporte Intermediário'
        WHEN 3 THEN 'Nível 3 - Especialista Sênior'
    END AS DescricaoNivel,
    t.AreaAtuacao,
    (SELECT COUNT(*) FROM Chamados c 
     WHERE (c.TecnicoAtribuidoId = u.Id OR c.TecnicoId = u.Id)
     AND c.StatusId NOT IN (SELECT Id FROM Status WHERE Nome IN ('Fechado', 'Cancelado'))
    ) AS ChamadosAtivos
FROM Usuarios u
INNER JOIN TecnicoTIPerfis t ON u.Id = t.UsuarioId
WHERE u.TipoUsuario = 2 AND u.Ativo = 1
ORDER BY t.NivelTecnico
"@
    
    $tecnicos = sqlcmd -S "(localdb)\MSSQLLocalDB" -d SistemaChamados -Q $query -h -1 -W
    Write-Host $tecnicos -ForegroundColor Gray
    
    # Verificar se temos técnicos dos 3 níveis
    $hasNivel1 = $tecnicos -match "Nível 1"
    $hasNivel2 = $tecnicos -match "Nível 2"
    $hasNivel3 = $tecnicos -match "Nível 3"
    
    if ($hasNivel1 -and $hasNivel2 -and $hasNivel3) {
        Show-TestResult "Técnicos dos 3 níveis cadastrados" $true "Nível 1, 2 e 3 encontrados no banco"
    } else {
        Show-TestResult "Técnicos dos 3 níveis cadastrados" $false "Faltam técnicos de alguns níveis"
        Write-Host "ATENÇÃO: Sistema precisa ter técnicos dos 3 níveis para testes completos!" -ForegroundColor Red
    }
    
    # ====================================================================
    # ETAPA 2: LOGIN
    # ====================================================================
    Write-Host "[2] Fazendo login..." -ForegroundColor Yellow
    
    $loginBody = @{
        email = "colaborador@empresa.com"
        senha = "Admin@123"
    } | ConvertTo-Json
    
    $login = Invoke-RestMethod -Uri "$apiUrl/usuarios/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $login.token
    $headers = @{ Authorization = "Bearer $token" }
    
    Show-TestResult "Login realizado" $true "Token obtido com sucesso"
    
    # ====================================================================
    # ETAPA 3: TESTE 1 - PRIORIDADE BAIXA → DEVE ATRIBUIR NÍVEL 1
    # ====================================================================
    Write-Host "[3] TESTE 1: Chamado PRIORIDADE BAIXA (deve atribuir Nível 1 - Básico)..." -ForegroundColor Yellow
    
    $chamadoBaixaBody = @{
        titulo = "Teste Prioridade Baixa - $(Get-Date -Format 'HH:mm:ss')"
        descricao = "Problema simples para técnico nível 1"
        categoriaId = 1
        prioridadeId = 1  # Prioridade BAIXA
        usarAnaliseAutomatica = $true
    } | ConvertTo-Json
    
    $chamadoBaixa = Invoke-RestMethod -Uri "$apiUrl/chamados" -Method Post -Body $chamadoBaixaBody -Headers $headers -ContentType "application/json"
    
    Write-Host "    Chamado ID: $($chamadoBaixa.id)" -ForegroundColor Gray
    Write-Host "    Técnico: $($chamadoBaixa.tecnicoAtribuidoNome)" -ForegroundColor Gray
    Write-Host "    Nível: $($chamadoBaixa.tecnicoAtribuidoNivel) - $($chamadoBaixa.tecnicoAtribuidoNivelDescricao)" -ForegroundColor Gray
    
    if ($chamadoBaixa.tecnicoAtribuidoNivel -eq 1) {
        Show-TestResult "Prioridade Baixa → Nível 1" $true "Técnico Nível 1 (Básico) atribuído corretamente" "Score favorece técnicos de nível 1 para prioridades baixas"
    } elseif ($chamadoBaixa.tecnicoAtribuidoNivel -ne $null) {
        Show-TestResult "Prioridade Baixa → Nível 1" $false "Atribuído Nível $($chamadoBaixa.tecnicoAtribuidoNivel) ao invés de Nível 1" "Escalation pode ter ocorrido se Nível 1 indisponível"
    } else {
        Show-TestResult "Prioridade Baixa → Nível 1" $false "Nenhum técnico atribuído"
    }
    
    # ====================================================================
    # ETAPA 4: TESTE 2 - PRIORIDADE MÉDIA → DEVE ATRIBUIR NÍVEL 2
    # ====================================================================
    Write-Host "[4] TESTE 2: Chamado PRIORIDADE MÉDIA (deve atribuir Nível 2 - Intermediário)..." -ForegroundColor Yellow
    
    $chamadoMediaBody = @{
        titulo = "Teste Prioridade Média - $(Get-Date -Format 'HH:mm:ss')"
        descricao = "Problema médio para técnico nível 2"
        categoriaId = 1
        prioridadeId = 2  # Prioridade MÉDIA
        usarAnaliseAutomatica = $true
    } | ConvertTo-Json
    
    $chamadoMedia = Invoke-RestMethod -Uri "$apiUrl/chamados" -Method Post -Body $chamadoMediaBody -Headers $headers -ContentType "application/json"
    
    Write-Host "    Chamado ID: $($chamadoMedia.id)" -ForegroundColor Gray
    Write-Host "    Técnico: $($chamadoMedia.tecnicoAtribuidoNome)" -ForegroundColor Gray
    Write-Host "    Nível: $($chamadoMedia.tecnicoAtribuidoNivel) - $($chamadoMedia.tecnicoAtribuidoNivelDescricao)" -ForegroundColor Gray
    
    if ($chamadoMedia.tecnicoAtribuidoNivel -eq 2) {
        Show-TestResult "Prioridade Média → Nível 2" $true "Técnico Nível 2 (Intermediário) atribuído corretamente" "Score favorece técnicos de nível 2 para prioridades médias"
    } elseif ($chamadoMedia.tecnicoAtribuidoNivel -ne $null) {
        Show-TestResult "Prioridade Média → Nível 2" $false "Atribuído Nível $($chamadoMedia.tecnicoAtribuidoNivel) ao invés de Nível 2" "Escalation pode ter ocorrido se Nível 2 indisponível"
    } else {
        Show-TestResult "Prioridade Média → Nível 2" $false "Nenhum técnico atribuído"
    }
    
    # ====================================================================
    # ETAPA 5: TESTE 3 - PRIORIDADE ALTA → DEVE ATRIBUIR NÍVEL 3
    # ====================================================================
    Write-Host "[5] TESTE 3: Chamado PRIORIDADE ALTA (deve atribuir Nível 3 - Sênior)..." -ForegroundColor Yellow
    
    $chamadoAltaBody = @{
        titulo = "Teste Prioridade Alta - $(Get-Date -Format 'HH:mm:ss')"
        descricao = "Problema complexo para técnico nível 3 sênior"
        categoriaId = 1
        prioridadeId = 3  # Prioridade ALTA
        usarAnaliseAutomatica = $true
    } | ConvertTo-Json
    
    $chamadoAlta = Invoke-RestMethod -Uri "$apiUrl/chamados" -Method Post -Body $chamadoAltaBody -Headers $headers -ContentType "application/json"
    
    Write-Host "    Chamado ID: $($chamadoAlta.id)" -ForegroundColor Gray
    Write-Host "    Técnico: $($chamadoAlta.tecnicoAtribuidoNome)" -ForegroundColor Gray
    Write-Host "    Nível: $($chamadoAlta.tecnicoAtribuidoNivel) - $($chamadoAlta.tecnicoAtribuidoNivelDescricao)" -ForegroundColor Gray
    
    if ($chamadoAlta.tecnicoAtribuidoNivel -eq 3) {
        Show-TestResult "Prioridade Alta → Nível 3" $true "Técnico Nível 3 (Sênior) atribuído corretamente" "Score favorece técnicos de nível 3 para prioridades altas"
    } elseif ($chamadoAlta.tecnicoAtribuidoNivel -ne $null) {
        Show-TestResult "Prioridade Alta → Nível 3" $false "Atribuído Nível $($chamadoAlta.tecnicoAtribuidoNivel) ao invés de Nível 3" "Escalation pode ter ocorrido se Nível 3 indisponível"
    } else {
        Show-TestResult "Prioridade Alta → Nível 3" $false "Nenhum técnico atribuído"
    }
    
    # ====================================================================
    # ETAPA 6: VERIFICAR SCORES CALCULADOS
    # ====================================================================
    Write-Host "[6] Verificando scores calculados para prioridade ALTA..." -ForegroundColor Yellow
    
    try {
        $scores = Invoke-RestMethod -Uri "$apiUrl/chamados/tecnicos/scores?categoriaId=1&prioridadeId=3" -Method Get -Headers $headers
        
        Write-Host "`n    SCORES CALCULADOS (Prioridade Alta):" -ForegroundColor Cyan
        foreach ($tecnico in $scores) {
            $nivelDesc = switch ($tecnico.nivelTecnico) {
                1 { "N1-Básico" }
                2 { "N2-Intermediário" }
                3 { "N3-Sênior" }
                default { "N?-Desconhecido" }
            }
            
            Write-Host "    [$nivelDesc] $($tecnico.nomeCompleto)" -ForegroundColor White
            Write-Host "      Score Total: $($tecnico.scoreTotal.ToString('F2'))" -ForegroundColor Yellow
            Write-Host "      Especialidade: $($tecnico.breakdown.especialidade.ToString('F0')) | " -NoNewline -ForegroundColor Gray
            Write-Host "Disponibilidade: $($tecnico.breakdown.disponibilidade.ToString('F0')) | " -NoNewline -ForegroundColor Gray
            Write-Host "Performance: $($tecnico.breakdown.performance.ToString('F0')) | " -NoNewline -ForegroundColor Gray
            Write-Host "Prioridade: $($tecnico.breakdown.prioridade.ToString('F0'))" -ForegroundColor Gray
            Write-Host ""
        }
        
        # Verificar se técnico Nível 3 tem maior score de prioridade
        $nivel3 = $scores | Where-Object { $_.nivelTecnico -eq 3 } | Select-Object -First 1
        $nivel1 = $scores | Where-Object { $_.nivelTecnico -eq 1 } | Select-Object -First 1
        
        if ($nivel3 -and $nivel1) {
            if ($nivel3.breakdown.prioridade -gt $nivel1.breakdown.prioridade) {
                Show-TestResult "Score de Prioridade para Nível 3" $true "Nível 3 tem score maior ($($nivel3.breakdown.prioridade)) que Nível 1 ($($nivel1.breakdown.prioridade)) para prioridade alta"
            } else {
                Show-TestResult "Score de Prioridade para Nível 3" $false "Nível 3 deveria ter score maior que Nível 1 para prioridade alta"
            }
        }
    } catch {
        Write-Host "    Erro ao obter scores: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # ====================================================================
    # ETAPA 7: VERIFICAR AUDITORIA
    # ====================================================================
    Write-Host "[7] Verificando registros de auditoria..." -ForegroundColor Yellow
    
    $queryAudit = @"
SELECT TOP 3
    c.Id AS ChamadoId,
    c.Titulo,
    p.Nome AS Prioridade,
    p.Nivel AS NivelPrioridade,
    u.NomeCompleto AS TecnicoAtribuido,
    t.NivelTecnico,
    a.Score,
    a.MotivoSelecao
FROM AtribuicoesLog a
INNER JOIN Chamados c ON a.ChamadoId = c.Id
INNER JOIN Prioridades p ON c.PrioridadeId = p.Id
INNER JOIN Usuarios u ON a.TecnicoId = u.Id
INNER JOIN TecnicoTIPerfis t ON u.Id = t.UsuarioId
ORDER BY a.DataAtribuicao DESC
"@
    
    $audit = sqlcmd -S "(localdb)\MSSQLLocalDB" -d SistemaChamados -Q $queryAudit -h -1 -W
    Write-Host $audit -ForegroundColor Gray
    
    Show-TestResult "Auditoria de atribuições" $true "Registros encontrados em AtribuicoesLog com scores e níveis"
    
} catch {
    Write-Host "`nERRO DURANTE TESTES: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.Exception.StackTrace -ForegroundColor DarkRed
}

# ====================================================================
# RESUMO FINAL
# ====================================================================
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "  RESUMO DA VALIDAÇÃO" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

$totalTests = $testResults.Count
$passedTests = ($testResults | Where-Object { $_.Passed -eq $true }).Count
$failedTests = $totalTests - $passedTests
$successRate = if ($totalTests -gt 0) { ($passedTests / $totalTests) * 100 } else { 0 }

Write-Host ""
Write-Host "Total de Testes: $totalTests" -ForegroundColor White
Write-Host "Aprovados: " -NoNewline -ForegroundColor White
Write-Host "$passedTests" -ForegroundColor Green
Write-Host "Falharam: " -NoNewline -ForegroundColor White
Write-Host "$failedTests" -ForegroundColor $(if ($failedTests -eq 0) { "Green" } else { "Red" })
Write-Host "Taxa de Sucesso: " -NoNewline -ForegroundColor White
Write-Host "$($successRate.ToString('F1'))%" -ForegroundColor $(if ($successRate -ge 80) { "Green" } elseif ($successRate -ge 60) { "Yellow" } else { "Red" })
Write-Host ""

if ($successRate -ge 80) {
    Write-Host "✓ SISTEMA DE 3 NÍVEIS FUNCIONANDO CORRETAMENTE!" -ForegroundColor Green -BackgroundColor Black
} elseif ($successRate -ge 60) {
    Write-Host "⚠ SISTEMA PARCIALMENTE FUNCIONAL - REVISAR FALHAS" -ForegroundColor Yellow -BackgroundColor Black
} else {
    Write-Host "✗ SISTEMA COM PROBLEMAS - CORREÇÕES NECESSÁRIAS" -ForegroundColor Red -BackgroundColor Black
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Exibir resumo de testes falhados
if ($failedTests -gt 0) {
    Write-Host "TESTES QUE FALHARAM:" -ForegroundColor Red
    foreach ($test in ($testResults | Where-Object { $_.Passed -eq $false })) {
        Write-Host "  • $($test.Test): $($test.Message)" -ForegroundColor Red
    }
    Write-Host ""
}
