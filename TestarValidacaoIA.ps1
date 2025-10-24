# Teste de Validacao - Correcao de Erros da IA

Write-Host ""
Write-Host "========================================================================" -ForegroundColor Red
Write-Host "    TESTE: Sistema de Correcao de Erros da IA Gemini" -ForegroundColor Red
Write-Host "========================================================================" -ForegroundColor Red
Write-Host ""
Write-Host "Este teste simula cenarios onde a IA classifica incorretamente" -ForegroundColor Yellow
Write-Host "e verifica se o sistema corrige automaticamente." -ForegroundColor Yellow
Write-Host ""
Start-Sleep -Seconds 2

$baseUrl = "http://localhost:5246/api/chamados/tecnicos/scores"
$totalTestes = 0
$testesCorretos = 0

function Test-ValidacaoIA {
    param(
        [string]$Cenario,
        [string]$Titulo,
        [string]$Descricao,
        [int]$PrioridadeIA,  # O que a IA classificou (ERRADO)
        [string]$TecnicoEsperado,
        [string]$Motivo
    )
    
    $script:totalTestes++
    
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "CENARIO: $Cenario" -ForegroundColor Cyan
    Write-Host "IA Classificou Como: Prioridade $PrioridadeIA" -ForegroundColor Yellow
    Write-Host "Expectativa: Sistema deve corrigir e atribuir para $TecnicoEsperado" -ForegroundColor White
    Write-Host "Motivo: $Motivo" -ForegroundColor Gray
    Write-Host "================================================" -ForegroundColor Cyan
    
    try {
        $tituloEnc = [uri]::EscapeDataString($Titulo)
        $descEnc = [uri]::EscapeDataString($Descricao)
        $url = "$baseUrl`?categoriaId=1`&prioridadeId=$PrioridadeIA`&titulo=$tituloEnc`&descricao=$descEnc"
        
        $response = Invoke-RestMethod -Uri $url -Method Get
        
        Write-Host ""
        foreach ($tec in $response.Tecnicos | Sort-Object -Property Score -Descending) {
            $simbolo = if ($tec.NomeCompleto -like "*$TecnicoEsperado*") { ">>>" } else { "   " }
            $cor = if ($tec.NomeCompleto -like "*$TecnicoEsperado*") { "Green" } else { "DarkGray" }
            
            Write-Host "$simbolo $($tec.NomeCompleto) - Score: $($tec.Score)" -ForegroundColor $cor
            Write-Host "    Bonus Complexidade: $($tec.Breakdown.BonusComplexidade)" -ForegroundColor Gray
        }
        
        $vencedor = $response.Tecnicos | Sort-Object -Property Score -Descending | Select-Object -First 1
        Write-Host ""
        if ($vencedor.NomeCompleto -like "*$TecnicoEsperado*") {
            Write-Host "SUCESSO: Sistema corrigiu erro da IA! $TecnicoEsperado atribuido." -ForegroundColor Green
            $script:testesCorretos++
        } else {
            Write-Host "FALHA: Sistema nao conseguiu corrigir. $($vencedor.NomeCompleto) foi atribuido." -ForegroundColor Red
        }
    } catch {
        Write-Host "ERRO: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "======================================================================" -ForegroundColor White
Write-Host "           CATEGORIA 1: IA SUBESTIMA PROBLEMA CRITICO" -ForegroundColor White
Write-Host "======================================================================" -ForegroundColor White

Test-ValidacaoIA `
    -Cenario "Servidor Caiu - IA classificou como BAIXA" `
    -Titulo "Servidor principal fora do ar" `
    -Descricao "O servidor principal esta fora do ar e todos os sistemas pararam" `
    -PrioridadeIA 1 `
    -TecnicoEsperado "Senior" `
    -Motivo "Palavras criticas: servidor, fora do ar, todos, pararam (deveria ser ALTA)"

Test-ValidacaoIA `
    -Cenario "Rede Caiu - IA classificou como MEDIA" `
    -Titulo "Rede da empresa caiu" `
    -Descricao "A rede caiu e ninguem consegue trabalhar, todos os computadores desconectaram" `
    -PrioridadeIA 2 `
    -TecnicoEsperado "Senior" `
    -Motivo "Palavras criticas: rede, caiu, todos (deveria ser ALTA)"

Test-ValidacaoIA `
    -Cenario "Banco de Dados Parou - IA classificou como MEDIA" `
    -Titulo "Banco de dados parou" `
    -Descricao "O banco de dados principal parou e o sistema ERP esta fora do ar" `
    -PrioridadeIA 2 `
    -TecnicoEsperado "Senior" `
    -Motivo "Palavras criticas: banco de dados, parou, fora do ar (deveria ser ALTA)"

Write-Host ""
Write-Host "======================================================================" -ForegroundColor White
Write-Host "          CATEGORIA 2: IA SUPERESTIMA PROBLEMA SIMPLES" -ForegroundColor White
Write-Host "======================================================================" -ForegroundColor White

Test-ValidacaoIA `
    -Cenario "Esqueci Senha - IA classificou como ALTA" `
    -Titulo "Esqueci minha senha" `
    -Descricao "Esqueci minha senha do sistema e preciso trocar" `
    -PrioridadeIA 3 `
    -TecnicoEsperado "Junior" `
    -Motivo "Palavras simples: esqueci, minha, senha, preciso, trocar (deveria ser BAIXA/MEDIA)"

Test-ValidacaoIA `
    -Cenario "Mouse Quebrado - IA classificou como ALTA" `
    -Titulo "Meu mouse nao funciona" `
    -Descricao "Meu mouse parou de funcionar e preciso de ajuda para trocar" `
    -PrioridadeIA 3 `
    -TecnicoEsperado "Junior" `
    -Motivo "Palavras simples: meu, mouse, preciso, ajuda, trocar (deveria ser BAIXA/MEDIA)"

Test-ValidacaoIA `
    -Cenario "Duvida Basica - IA classificou como ALTA" `
    -Titulo "Como faco para acessar meu email?" `
    -Descricao "Nao sei como configurar meu email no computador, preciso de ajuda" `
    -PrioridadeIA 3 `
    -TecnicoEsperado "Junior" `
    -Motivo "Palavras simples: como faco, nao sei, meu, email, preciso, ajuda (deveria ser BAIXA)"

Write-Host ""
Write-Host "======================================================================" -ForegroundColor White
Write-Host "          CATEGORIA 3: IA ACERTA (Sistema deve manter)" -ForegroundColor White
Write-Host "======================================================================" -ForegroundColor White

Test-ValidacaoIA `
    -Cenario "Problema Critico - IA classificou CORRETAMENTE como ALTA" `
    -Titulo "Sistema ERP esta fora do ar" `
    -Descricao "O sistema ERP caiu e esta afetando todos os departamentos" `
    -PrioridadeIA 3 `
    -TecnicoEsperado "Senior" `
    -Motivo "IA acertou, sistema deve manter prioridade ALTA"

Test-ValidacaoIA `
    -Cenario "Instalacao Simples - IA classificou CORRETAMENTE como MEDIA" `
    -Titulo "Preciso instalar Chrome" `
    -Descricao "Preciso instalar o navegador Chrome no meu computador" `
    -PrioridadeIA 2 `
    -TecnicoEsperado "Junior" `
    -Motivo "IA acertou, sistema deve manter e palavras-chave devem favorecer Junior"

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "                        RESUMO DOS TESTES" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total de cenarios testados: $totalTestes" -ForegroundColor White
Write-Host "Cenarios onde sistema corrigiu/manteve corretamente: $testesCorretos" -ForegroundColor Green
Write-Host "Cenarios com falha: $($totalTestes - $testesCorretos)" -ForegroundColor $(if ($testesCorretos -eq $totalTestes) { "Green" } else { "Red" })
Write-Host ""

$percentual = [math]::Round(($testesCorretos / $totalTestes) * 100, 2)
if ($percentual -eq 100) {
    Write-Host "RESULTADO: $percentual% - SISTEMA DE VALIDACAO PERFEITO!" -ForegroundColor Green
    Write-Host "O sistema corrige TODOS os erros da IA!" -ForegroundColor Green
} elseif ($percentual -ge 90) {
    Write-Host "RESULTADO: $percentual% - SISTEMA DE VALIDACAO MUITO BOM" -ForegroundColor Green
} elseif ($percentual -ge 70) {
    Write-Host "RESULTADO: $percentual% - SISTEMA DE VALIDACAO BOM" -ForegroundColor Yellow
} else {
    Write-Host "RESULTADO: $percentual% - SISTEMA DE VALIDACAO PRECISA AJUSTES" -ForegroundColor Red
}

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "CONCLUSAO:" -ForegroundColor Yellow
Write-Host "A IA Gemini e um assistente, mas o sistema tem multiplas camadas:" -ForegroundColor White
Write-Host "  1. Validacao de prioridade (corrige erros grosseiros)" -ForegroundColor White
Write-Host "  2. Analise de palavras-chave (independente da IA)" -ForegroundColor White
Write-Host "  3. Scoring dinamico (considera carga e performance)" -ForegroundColor White
Write-Host "  4. Bloqueios hard-coded (protecoes finais)" -ForegroundColor White
Write-Host ""
Write-Host "Mesmo que a IA erre, o sistema garante distribuicao correta!" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan
