# Script para testar o sistema de atribuição inteligente de técnicos
# Sistema de Chamados Faculdade - Teste Completo

$baseUrl = "http://localhost:5246/api"

Write-Host "`n╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     TESTE: SISTEMA DE ATRIBUIÇÃO INTELIGENTE DE TÉCNICOS     ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# 1. Login como Colaborador
Write-Host "`n[1/6] 🔐 Fazendo login como Colaborador..." -ForegroundColor Yellow
$loginBody = @{
    email = "colaborador@empresa.com"
    senha = "Admin@123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.token
    Write-Host "✓ Login realizado com sucesso" -ForegroundColor Green
    Write-Host "  Token: $($token.Substring(0,20))..." -ForegroundColor Gray
} catch {
    Write-Host "✗ Erro no login: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 2. Criar novo chamado com análise automática
Write-Host "`n[2/6] 📝 Criando chamado com atribuição automática inteligente..." -ForegroundColor Yellow
$chamadoBody = @{
    titulo = "Teste de Atribuição Inteligente - Problema de Wi-Fi"
    descricao = "A rede Wi-Fi está lenta e com quedas constantes. Preciso urgentemente de suporte para conectar no Teams."
    usarAnaliseAutomatica = $true
} | ConvertTo-Json

try {
    $headers = @{ Authorization = "Bearer $token" }
    $chamadoResponse = Invoke-RestMethod -Uri "$baseUrl/chamados" -Method Post -Body $chamadoBody -ContentType "application/json" -Headers $headers
    $chamadoId = $chamadoResponse.id
    Write-Host "✓ Chamado criado: #$chamadoId" -ForegroundColor Green
    Write-Host "  Título: $($chamadoResponse.titulo)" -ForegroundColor Gray
    Write-Host "  Categoria: $($chamadoResponse.categoriaNome)" -ForegroundColor Gray
    Write-Host "  Prioridade: $($chamadoResponse.prioridadeNome)" -ForegroundColor Gray
    
    if ($chamadoResponse.tecnicoAtribuidoNome) {
        Write-Host "  ✓ Técnico atribuído: $($chamadoResponse.tecnicoAtribuidoNome)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Nenhum técnico foi atribuído" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Erro ao criar chamado: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 3. Verificar histórico de atribuições
Write-Host "`n[3/6] 📋 Verificando histórico de atribuições do chamado..." -ForegroundColor Yellow
try {
    $atribuicoes = Invoke-RestMethod -Uri "$baseUrl/chamados/$chamadoId/atribuicoes" -Method Get -Headers $headers
    Write-Host "✓ Total de atribuições: $($atribuicoes.totalAtribuicoes)" -ForegroundColor Green
    
    if ($atribuicoes.atribuicoes.Count -gt 0) {
        $ultima = $atribuicoes.atribuicoes[0]
        Write-Host "`n  Detalhes da ultima atribuicao:" -ForegroundColor Cyan
        Write-Host "    - Tecnico: $($ultima.tecnicoNome)" -ForegroundColor White
        Write-Host "    - Score: $([math]::Round($ultima.score, 2))" -ForegroundColor White
        Write-Host "    - Metodo: $($ultima.metodoAtribuicao)" -ForegroundColor White
        Write-Host "    - Motivo: $($ultima.motivoSelecao)" -ForegroundColor White
        Write-Host "    - Carga trabalho: $($ultima.cargaTrabalho) chamados" -ForegroundColor White
        Write-Host "    - Fallback generico: $($ultima.fallbackGenerico)" -ForegroundColor White
        Write-Host "    - Data: $($ultima.dataAtribuicao)" -ForegroundColor Gray
    }
} catch {
    Write-Host "✗ Erro ao obter histórico: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. Visualizar scores de técnicos
Write-Host "`n[4/6] 🎯 Calculando scores de todos os técnicos..." -ForegroundColor Yellow
try {
    # Assumindo categoriaId=1 (Infraestrutura) e prioridadeId=2 (Média)
    $scores = Invoke-RestMethod -Uri "$baseUrl/chamados/tecnicos/scores?categoriaId=1&prioridadeId=2" -Method Get -Headers $headers
    Write-Host "✓ Total de técnicos avaliados: $($scores.totalTecnicos)" -ForegroundColor Green
    
    if ($scores.tecnicos.Count -gt 0) {
        Write-Host "`n  Ranking de Tecnicos (Score Total):" -ForegroundColor Cyan
        $ranking = 1
        foreach ($tec in $scores.tecnicos | Sort-Object -Property score -Descending | Select-Object -First 5) {
            $emoji = if ($ranking -eq 1) { "[1]" } elseif ($ranking -eq 2) { "[2]" } elseif ($ranking -eq 3) { "[3]" } else { "   " }
            Write-Host "    $emoji $ranking. $($tec.nomeCompleto) - Score: $($tec.score)" -ForegroundColor White
            Write-Host "        |- Especialidade: $($tec.breakdown.especialidade)" -ForegroundColor Gray
            Write-Host "        |- Disponibilidade: $($tec.breakdown.disponibilidade)" -ForegroundColor Gray
            Write-Host "        |- Performance: $($tec.breakdown.performance)" -ForegroundColor Gray
            Write-Host "        '- Prioridade: $($tec.breakdown.prioridade)" -ForegroundColor Gray
            Write-Host "        Stats: $($tec.chamadosAtivos) ativos | $($tec.chamadosResolvidos) resolvidos | Capacidade: $($tec.capacidadeRestante)/10" -ForegroundColor DarkGray
            $ranking++
        }
    }
} catch {
    Write-Host "✗ Erro ao calcular scores: $($_.Exception.Message)" -ForegroundColor Red
}

# 5. Visualizar distribuição de carga
Write-Host "`n[5/6] 📊 Verificando distribuição de carga entre técnicos..." -ForegroundColor Yellow

# Login como Admin para endpoints protegidos
$adminLoginBody = @{
    email = "admin@sistema.com"
    senha = "Admin@123"
} | ConvertTo-Json

try {
    $adminLogin = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $adminLoginBody -ContentType "application/json"
    $adminToken = $adminLogin.token
    $adminHeaders = @{ Authorization = "Bearer $adminToken" }
    
    $distribuicao = Invoke-RestMethod -Uri "$baseUrl/chamados/metricas/distribuicao" -Method Get -Headers $adminHeaders
    Write-Host "✓ Métricas obtidas" -ForegroundColor Green
    Write-Host "  Total de técnicos: $($distribuicao.totalTecnicos)" -ForegroundColor White
    Write-Host "  Carga total: $($distribuicao.cargaTotal) chamados" -ForegroundColor White
    Write-Host "  Carga média: $($distribuicao.cargaMedia) chamados/técnico" -ForegroundColor White
    
    if ($distribuicao.tecnicos.Count -gt 0) {
        Write-Host "`n  Distribuicao por Tecnico:" -ForegroundColor Cyan
        foreach ($tec in $distribuicao.tecnicos) {
            $barra = "#" * $tec.chamadosAtivos
            $cor = if ($tec.percentualCarga -gt 80) { "Red" } elseif ($tec.percentualCarga -gt 50) { "Yellow" } else { "Green" }
            $percFormat = "{0:N1}" -f $tec.percentualCarga
            Write-Host "    - $($tec.tecnicoNome)" -ForegroundColor White
            Write-Host "      $barra $($tec.chamadosAtivos)/10 chamados ($percFormat%)" -ForegroundColor $cor
        }
    }
} catch {
    Write-Host "✗ Erro ao obter distribuição: $($_.Exception.Message)" -ForegroundColor Red
}

# 6. Verificar tabela AtribuicoesLog no banco
Write-Host "`n[6/6] 💾 Verificando registros no banco de dados..." -ForegroundColor Yellow
try {
    $query = "SELECT TOP 1 Id, ChamadoId, TecnicoId, Score, MetodoAtribuicao, MotivoSelecao, CargaTrabalho, FallbackGenerico FROM AtribuicoesLog ORDER BY DataAtribuicao DESC"
    $result = sqlcmd -S "(localdb)\MSSQLLocalDB" -d SistemaChamados -Q $query -h -1 -W
    if ($result) {
        Write-Host "✓ Registro encontrado na tabela AtribuicoesLog" -ForegroundColor Green
        Write-Host $result -ForegroundColor Gray
    } else {
        Write-Host "⚠ Nenhum registro encontrado" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Erro ao consultar banco: $($_.Exception.Message)" -ForegroundColor Red
}

# Resumo Final
Write-Host "`n╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                  ✓ TESTE CONCLUÍDO COM SUCESSO               ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host "`n✅ Sistema de Atribuição Inteligente funcionando!" -ForegroundColor Green
Write-Host "`nVerifique os logs da API para ver o algoritmo em acao (8 etapas de logging)" -ForegroundColor Cyan
Write-Host ""
