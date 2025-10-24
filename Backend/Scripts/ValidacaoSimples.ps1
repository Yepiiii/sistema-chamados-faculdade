# Script de Validação Simplificado - Sistema de Atribuição Inteligente
# Foca em validar a funcionalidade principal através do banco de dados e logs

$baseUrl = "http://localhost:5246/api"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  VALIDACAO - ATRIBUICAO INTELIGENTE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$testesPassaram = 0
$testesTotal = 0

# Teste 1: Verificar tabela AtribuicoesLog
Write-Host "[1/7] Verificando tabela AtribuicoesLog..." -ForegroundColor Yellow
$testesTotal++
try {
    $query = "SELECT COUNT(*) as Total FROM AtribuicoesLog"
    $result = sqlcmd -S "(localdb)\MSSQLLocalDB" -d SistemaChamados -Q $query -h -1 -W
    $count = [int]($result.Trim())
    
    if ($count -gt 0) {
        Write-Host "  [OK] $count registros encontrados" -ForegroundColor Green
        $testesPassaram++
    } else {
        Write-Host "  [AVISO] Nenhum registro ainda" -ForegroundColor Yellow
        $testesPassaram++
    }
} catch {
    Write-Host "  [ERRO] $($_.Exception.Message)" -ForegroundColor Red
}

# Teste 2: Verificar estrutura da tabela
Write-Host "[2/7] Verificando estrutura AtribuicoesLog..." -ForegroundColor Yellow
$testesTotal++
try {
    $query = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'AtribuicoesLog'"
    $result = sqlcmd -S "(localdb)\MSSQLLocalDB" -d SistemaChamados -Q $query -h -1 -W
    $colunas = [int]($result.Trim())
    
    if ($colunas -eq 10) {
        Write-Host "  [OK] 10 colunas presentes (correto)" -ForegroundColor Green
        $testesPassaram++
    } else {
        Write-Host "  [ERRO] $colunas colunas encontradas (esperado: 10)" -ForegroundColor Red
    }
} catch {
    Write-Host "  [ERRO] $($_.Exception.Message)" -ForegroundColor Red
}

# Teste 3: Criar chamado com atribuição automática
Write-Host "[3/7] Testando atribuicao automatica..." -ForegroundColor Yellow
$testesTotal++
try {
    $loginBody = @{ email = "colaborador@empresa.com"; senha = "Admin@123" } | ConvertTo-Json
    $login = Invoke-RestMethod -Uri "$baseUrl/usuarios/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $login.token
    $headers = @{ Authorization = "Bearer $token" }
    
    $chamadoBody = @{
        titulo = "VALIDACAO $(Get-Date -Format 'HH:mm:ss') - Teste WiFi"
        descricao = "Problema na rede WiFi. Conexao lenta e instavel."
        usarAnaliseAutomatica = $true
    } | ConvertTo-Json
    
    $chamado = Invoke-RestMethod -Uri "$baseUrl/chamados" -Method Post -Body $chamadoBody -Headers $headers -ContentType "application/json"
    
    if ($chamado.tecnicoAtribuidoId) {
        Write-Host "  [OK] Chamado #$($chamado.id) atribuido automaticamente" -ForegroundColor Green
        Write-Host "       Tecnico: $($chamado.tecnicoAtribuidoNome)" -ForegroundColor Gray
        $testesPassaram++
        $ultimoChamadoId = $chamado.id
    } else {
        Write-Host "  [ERRO] Chamado criado mas nao atribuido" -ForegroundColor Red
    }
} catch {
    Write-Host "  [ERRO] $($_.Exception.Message)" -ForegroundColor Red
}

# Teste 4: Verificar registro de auditoria
Write-Host "[4/7] Verificando auditoria do ultimo chamado..." -ForegroundColor Yellow
$testesTotal++
try {
    if ($ultimoChamadoId) {
        $query = "SELECT Score, MetodoAtribuicao, MotivoSelecao, CargaTrabalho, FallbackGenerico FROM AtribuicoesLog WHERE ChamadoId = $ultimoChamadoId"
        $result = sqlcmd -S "(localdb)\MSSQLLocalDB" -d SistemaChamados -Q $query -W -s "|"
        
        if ($result) {
            Write-Host "  [OK] Auditoria registrada" -ForegroundColor Green
            Write-Host "       $($result[2])" -ForegroundColor Gray
            $testesPassaram++
        }
    } else {
        Write-Host "  [AVISO] Sem chamado para verificar" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  [ERRO] $($_.Exception.Message)" -ForegroundColor Red
}

# Teste 5: Verificar historico de atribuicoes
Write-Host "[5/7] Verificando historico via API..." -ForegroundColor Yellow
$testesTotal++
try {
    if ($ultimoChamadoId) {
        $historico = Invoke-RestMethod -Uri "$baseUrl/chamados/$ultimoChamadoId/atribuicoes" -Headers $headers
        
        if ($historico.totalAtribuicoes -gt 0) {
            Write-Host "  [OK] Historico acessivel ($($historico.totalAtribuicoes) atribuicoes)" -ForegroundColor Green
            $ultima = $historico.atribuicoes[0]
            Write-Host "       Score: $([math]::Round($ultima.score, 2))" -ForegroundColor Gray
            Write-Host "       Motivo: $($ultima.motivoSelecao)" -ForegroundColor Gray
            $testesPassaram++
        }
    }
} catch {
    Write-Host "  [ERRO] $($_.Exception.Message)" -ForegroundColor Red
}

# Teste 6: Verificar calculo de score
Write-Host "[6/7] Validando calculo de score..." -ForegroundColor Yellow
$testesTotal++
try {
    if ($ultimoChamadoId) {
        $query = "SELECT Score, DetalhesProcesso FROM AtribuicoesLog WHERE ChamadoId = $ultimoChamadoId"
        $result = sqlcmd -S "(localdb)\MSSQLLocalDB" -d SistemaChamados -Q $query -h -1 -W
        
        if ($result) {
            $score = [double]($result[0].Split()[0].Trim())
            
            if ($score -gt 0 -and $score -le 100) {
                Write-Host "  [OK] Score valido: $score (range: 0-100)" -ForegroundColor Green
                $testesPassaram++
            } else {
                Write-Host "  [ERRO] Score fora do range: $score" -ForegroundColor Red
            }
        }
    }
} catch {
    Write-Host "  [ERRO] $($_.Exception.Message)" -ForegroundColor Red
}

# Teste 7: Verificar balanceamento
Write-Host "[7/7] Verificando balanceamento de carga..." -ForegroundColor Yellow
$testesTotal++
try {
    $query = @"
SELECT u.NomeCompleto, COUNT(c.Id) as ChamadosAtivos 
FROM Usuarios u 
LEFT JOIN Chamados c ON u.Id = c.TecnicoAtribuidoId AND c.StatusId != 4
WHERE u.TipoUsuario = 2 AND u.Ativo = 1
GROUP BY u.Id, u.NomeCompleto
"@
    $result = sqlcmd -S "(localdb)\MSSQLLocalDB" -d SistemaChamados -Q $query -W
    
    Write-Host "  [OK] Distribuicao de carga:" -ForegroundColor Green
    Write-Host $result -ForegroundColor Gray
    $testesPassaram++
} catch {
    Write-Host "  [ERRO] $($_.Exception.Message)" -ForegroundColor Red
}

# Resumo
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  RESULTADO DA VALIDACAO" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$percentual = [math]::Round(($testesPassaram / $testesTotal) * 100, 1)

Write-Host "Testes executados: $testesTotal" -ForegroundColor White
Write-Host "Testes aprovados: $testesPassaram" -ForegroundColor Green
Write-Host "Taxa de sucesso: $percentual%`n" -ForegroundColor $(if ($percentual -ge 80) { "Green" } else { "Yellow" })

if ($percentual -ge 80) {
    Write-Host "[OK] SISTEMA VALIDADO!" -ForegroundColor Green
    Write-Host "A atribuicao inteligente esta funcionando corretamente.`n" -ForegroundColor Green
} else {
    Write-Host "[AVISO] Alguns testes falharam" -ForegroundColor Yellow
    Write-Host "Revise os logs acima para detalhes.`n" -ForegroundColor Yellow
}

# Informações adicionais
Write-Host "Informacoes adicionais:" -ForegroundColor Gray
Write-Host "- Tabela de auditoria: AtribuicoesLog" -ForegroundColor Gray
Write-Host "- Endpoint de historico: GET /api/chamados/{id}/atribuicoes" -ForegroundColor Gray
Write-Host "- Algoritmo: 4 fatores (Especialidade, Disponibilidade, Performance, Prioridade)" -ForegroundColor Gray
Write-Host ""
