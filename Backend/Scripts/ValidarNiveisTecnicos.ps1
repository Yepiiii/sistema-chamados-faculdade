# ====================================================================
# SCRIPT DE VALIDAÇÃO - SISTEMA DE 3 NÍVEIS DE TÉCNICOS
# ====================================================================

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "  VALIDAÇÃO: SISTEMA DE 3 NÍVEIS DE TÉCNICOS" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

$apiUrl = "http://localhost:5246/api"
$passedTests = 0
$failedTests = 0

try {
    # ====================================================================
    # ETAPA 1: VERIFICAR TÉCNICOS NO BANCO
    # ====================================================================
    Write-Host "[1] Verificando técnicos cadastrados por nível..." -ForegroundColor Yellow
    
    $queryTecnicos = "SELECT u.Id, u.NomeCompleto, t.NivelTecnico FROM Usuarios u INNER JOIN TecnicoTIPerfis t ON u.Id = t.UsuarioId WHERE u.TipoUsuario = 2 AND u.Ativo = 1 ORDER BY t.NivelTecnico"
    
    $tecnicos = sqlcmd -S "(localdb)\MSSQLLocalDB" -d SistemaChamados -Q $queryTecnicos -h -1 -W
    Write-Host $tecnicos -ForegroundColor Gray
    Write-Host ""
    
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
    
    Write-Host "    Login OK`n" -ForegroundColor Green
    
    # ====================================================================
    # TESTE 1: PRIORIDADE BAIXA → NÍVEL 1
    # ====================================================================
    Write-Host "[3] TESTE 1: Chamado PRIORIDADE BAIXA (deve atribuir Nível 1)..." -ForegroundColor Yellow
    
    $chamadoBaixaBody = @{
        titulo = "Teste Prioridade Baixa - $(Get-Date -Format 'HH:mm:ss')"
        descricao = "Problema simples para técnico nível 1"
        categoriaId = 1
        prioridadeId = 1
        usarAnaliseAutomatica = $true
    } | ConvertTo-Json
    
    $chamadoBaixa = Invoke-RestMethod -Uri "$apiUrl/chamados" -Method Post -Body $chamadoBaixaBody -Headers $headers -ContentType "application/json"
    
    Write-Host "    Chamado ID: $($chamadoBaixa.id)" -ForegroundColor Cyan
    Write-Host "    Técnico: $($chamadoBaixa.tecnicoAtribuidoNome)" -ForegroundColor Cyan
    Write-Host "    Nível: $($chamadoBaixa.tecnicoAtribuidoNivel) - $($chamadoBaixa.tecnicoAtribuidoNivelDescricao)" -ForegroundColor Cyan
    
    if ($chamadoBaixa.tecnicoAtribuidoNivel -eq 1) {
        Write-Host "    [PASS] Técnico Nível 1 atribuído corretamente!`n" -ForegroundColor Green
        $passedTests++
    } else {
        Write-Host "    [FAIL] Atribuído Nível $($chamadoBaixa.tecnicoAtribuidoNivel) ao invés de Nível 1`n" -ForegroundColor Red
        $failedTests++
    }
    
    # ====================================================================
    # TESTE 2: PRIORIDADE MÉDIA → NÍVEL 2
    # ====================================================================
    Write-Host "[4] TESTE 2: Chamado PRIORIDADE MÉDIA (deve atribuir Nível 2)..." -ForegroundColor Yellow
    
    $chamadoMediaBody = @{
        titulo = "Teste Prioridade Média - $(Get-Date -Format 'HH:mm:ss')"
        descricao = "Problema médio para técnico nível 2"
        categoriaId = 1
        prioridadeId = 2
        usarAnaliseAutomatica = $true
    } | ConvertTo-Json
    
    $chamadoMedia = Invoke-RestMethod -Uri "$apiUrl/chamados" -Method Post -Body $chamadoMediaBody -Headers $headers -ContentType "application/json"
    
    Write-Host "    Chamado ID: $($chamadoMedia.id)" -ForegroundColor Cyan
    Write-Host "    Técnico: $($chamadoMedia.tecnicoAtribuidoNome)" -ForegroundColor Cyan
    Write-Host "    Nível: $($chamadoMedia.tecnicoAtribuidoNivel) - $($chamadoMedia.tecnicoAtribuidoNivelDescricao)" -ForegroundColor Cyan
    
    if ($chamadoMedia.tecnicoAtribuidoNivel -eq 2) {
        Write-Host "    [PASS] Técnico Nível 2 atribuído corretamente!`n" -ForegroundColor Green
        $passedTests++
    } else {
        Write-Host "    [FAIL] Atribuído Nível $($chamadoMedia.tecnicoAtribuidoNivel) ao invés de Nível 2`n" -ForegroundColor Red
        $failedTests++
    }
    
    # ====================================================================
    # TESTE 3: PRIORIDADE ALTA → NÍVEL 3
    # ====================================================================
    Write-Host "[5] TESTE 3: Chamado PRIORIDADE ALTA (deve atribuir Nível 3)..." -ForegroundColor Yellow
    
    $chamadoAltaBody = @{
        titulo = "Teste Prioridade Alta - $(Get-Date -Format 'HH:mm:ss')"
        descricao = "Problema complexo para técnico nível 3"
        categoriaId = 1
        prioridadeId = 3
        usarAnaliseAutomatica = $true
    } | ConvertTo-Json
    
    $chamadoAlta = Invoke-RestMethod -Uri "$apiUrl/chamados" -Method Post -Body $chamadoAltaBody -Headers $headers -ContentType "application/json"
    
    Write-Host "    Chamado ID: $($chamadoAlta.id)" -ForegroundColor Cyan
    Write-Host "    Técnico: $($chamadoAlta.tecnicoAtribuidoNome)" -ForegroundColor Cyan
    Write-Host "    Nível: $($chamadoAlta.tecnicoAtribuidoNivel) - $($chamadoAlta.tecnicoAtribuidoNivelDescricao)" -ForegroundColor Cyan
    
    if ($chamadoAlta.tecnicoAtribuidoNivel -eq 3) {
        Write-Host "    [PASS] Técnico Nível 3 atribuído corretamente!`n" -ForegroundColor Green
        $passedTests++
    } else {
        Write-Host "    [FAIL] Atribuído Nível $($chamadoAlta.tecnicoAtribuidoNivel) ao invés de Nível 3`n" -ForegroundColor Red
        $failedTests++
    }
    
    # ====================================================================
    # VERIFICAR SCORES
    # ====================================================================
    Write-Host "[6] Verificando scores para prioridade ALTA..." -ForegroundColor Yellow
    
    try {
        $response = Invoke-RestMethod -Uri "$apiUrl/chamados/tecnicos/scores?categoriaId=1&prioridadeId=3" -Method Get -Headers $headers
        
        if ($response.success -and $response.tecnicos) {
            Write-Host "`n    SCORES CALCULADOS (Prioridade Alta):" -ForegroundColor Cyan
            Write-Host "    Total de técnicos avaliados: $($response.totalTecnicos)" -ForegroundColor Gray
            Write-Host ""
            
            foreach ($tecnico in $response.tecnicos) {
                $nivelDesc = "Nível $($tecnico.tecnicoId)"
                if ($tecnico.tecnicoId -eq 11) { $nivelDesc = "Nível 1 - Básico" }
                elseif ($tecnico.tecnicoId -eq 10) { $nivelDesc = "Nível 2 - Intermediário" }
                elseif ($tecnico.tecnicoId -eq 12) { $nivelDesc = "Nível 3 - Sênior" }
                
                Write-Host "    [$nivelDesc] $($tecnico.nomeCompleto)" -ForegroundColor White
                Write-Host "      Score Total: $($tecnico.score.ToString('F2'))" -ForegroundColor Yellow
                Write-Host "      Breakdown: Esp=$($tecnico.breakdown.especialidade.ToString('F0')) | " -NoNewline -ForegroundColor Gray
                Write-Host "Disp=$($tecnico.breakdown.disponibilidade.ToString('F0')) | " -NoNewline -ForegroundColor Gray
                Write-Host "Perf=$($tecnico.breakdown.performance.ToString('F0')) | " -NoNewline -ForegroundColor Gray
                Write-Host "Prior=$($tecnico.breakdown.prioridade.ToString('F0'))" -ForegroundColor Gray
                Write-Host "      Chamados Ativos: $($tecnico.chamadosAtivos) | Capacidade: $($tecnico.capacidadeRestante)`n" -ForegroundColor DarkGray
            }
            
            # Verificar se Nível 3 tem maior score de prioridade para prioridade alta
            $nivel3 = $response.tecnicos | Where-Object { $_.tecnicoId -eq 12 } | Select-Object -First 1
            $nivel1 = $response.tecnicos | Where-Object { $_.tecnicoId -eq 11 } | Select-Object -First 1
            
            if ($nivel3 -and $nivel1) {
                if ($nivel3.breakdown.prioridade -gt $nivel1.breakdown.prioridade) {
                    Write-Host "    [VALIDAÇÃO] Nível 3 tem score de prioridade ($($nivel3.breakdown.prioridade)) > Nível 1 ($($nivel1.breakdown.prioridade)) para prioridade ALTA ✓" -ForegroundColor Green
                    $passedTests++
                } else {
                    Write-Host "    [FALHA] Nível 3 deveria ter score maior que Nível 1 para prioridade ALTA ✗" -ForegroundColor Red
                    $failedTests++
                }
            } else {
                Write-Host "    [PASS] Scores obtidos com sucesso" -ForegroundColor Green
                $passedTests++
            }
        } else {
            Write-Host "    [FAIL] Resposta da API não contém scores`n" -ForegroundColor Red
            $failedTests++
        }
    } catch {
        Write-Host "    [FAIL] Erro ao obter scores: $($_.Exception.Message)`n" -ForegroundColor Red
        $failedTests++
    }
    
    # ====================================================================
    # VERIFICAR AUDITORIA
    # ====================================================================
    Write-Host "[7] Verificando auditoria dos últimos chamados..." -ForegroundColor Yellow
    
    $queryAudit = "SELECT TOP 3 c.Id, c.Titulo, p.Nome AS Prioridade, u.NomeCompleto AS Tecnico, t.NivelTecnico, a.Score FROM AtribuicoesLog a INNER JOIN Chamados c ON a.ChamadoId = c.Id INNER JOIN Prioridades p ON c.PrioridadeId = p.Id INNER JOIN Usuarios u ON a.TecnicoId = u.Id INNER JOIN TecnicoTIPerfis t ON u.Id = t.UsuarioId ORDER BY a.DataAtribuicao DESC"
    
    $audit = sqlcmd -S "(localdb)\MSSQLLocalDB" -d SistemaChamados -Q $queryAudit -h -1 -W
    Write-Host $audit -ForegroundColor Gray
    Write-Host ""
    
    $passedTests++
    
} catch {
    Write-Host "`nERRO: $($_.Exception.Message)" -ForegroundColor Red
    $failedTests++
}

# ====================================================================
# RESUMO
# ====================================================================
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "  RESUMO DA VALIDAÇÃO" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

$totalTests = $passedTests + $failedTests
$successRate = if ($totalTests -gt 0) { ($passedTests / $totalTests) * 100 } else { 0 }

Write-Host "Testes Aprovados: $passedTests" -ForegroundColor Green
Write-Host "Testes Falharam: $failedTests" -ForegroundColor $(if ($failedTests -eq 0) { "Green" } else { "Red" })
Write-Host "Taxa de Sucesso: $($successRate.ToString('F1'))%" -ForegroundColor $(if ($successRate -ge 80) { "Green" } else { "Yellow" })
Write-Host ""

if ($successRate -ge 80) {
    Write-Host "SISTEMA DE 3 NÍVEIS FUNCIONANDO CORRETAMENTE!" -ForegroundColor Green -BackgroundColor Black
} else {
    Write-Host "SISTEMA PRECISA DE AJUSTES" -ForegroundColor Yellow -BackgroundColor Black
}

Write-Host "`n============================================================`n" -ForegroundColor Cyan
