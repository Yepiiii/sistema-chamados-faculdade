# Script de teste expandido - Sistema refinado de atribuicao

Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "         TESTES COMPLETOS: Sistema Refinado de Atribuicao" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Aguardando API inicializar..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

$baseUrl = "http://localhost:5246/api/chamados/tecnicos/scores"
$totalTestes = 0
$testesCorretos = 0

function Test-Cenario {
    param(
        [string]$Numero,
        [string]$Nome,
        [string]$Titulo,
        [string]$Descricao,
        [int]$PrioridadeId,
        [string]$CorTitulo,
        [string]$TecnicoEsperado,
        [string]$Justificativa
    )
    
    $script:totalTestes++
    
    Write-Host ""
    Write-Host "========================================================================" -ForegroundColor $CorTitulo
    Write-Host "TESTE $Numero`: $Nome" -ForegroundColor $CorTitulo
    Write-Host "Expectativa: $TecnicoEsperado" -ForegroundColor $CorTitulo
    Write-Host "Motivo: $Justificativa" -ForegroundColor Gray
    Write-Host "========================================================================" -ForegroundColor $CorTitulo
    
    try {
        $tituloEnc = [uri]::EscapeDataString($Titulo)
        $descEnc = [uri]::EscapeDataString($Descricao)
        $url = "$baseUrl`?categoriaId=1`&prioridadeId=$PrioridadeId`&titulo=$tituloEnc`&descricao=$descEnc"
        
        $response = Invoke-RestMethod -Uri $url -Method Get
        
        Write-Host ""
        foreach ($tec in $response.Tecnicos | Sort-Object -Property Score -Descending) {
            $simbolo = if ($tec.NomeCompleto -like "*$TecnicoEsperado*") { ">>>" } else { "   " }
            $cor = if ($tec.NomeCompleto -like "*$TecnicoEsperado*") { $CorTitulo } else { "DarkGray" }
            
            Write-Host "$simbolo $($tec.NomeCompleto) - Score Total: $($tec.Score)" -ForegroundColor $cor
            Write-Host "    Esp:$($tec.Breakdown.Especialidade) | Disp:$($tec.Breakdown.Disponibilidade) | Perf:$($tec.Breakdown.Performance) | Prior:$($tec.Breakdown.Prioridade) | Bonus:$($tec.Breakdown.BonusComplexidade)" -ForegroundColor Gray
        }
        
        $vencedor = $response.Tecnicos | Sort-Object -Property Score -Descending | Select-Object -First 1
        Write-Host ""
        if ($vencedor.NomeCompleto -like "*$TecnicoEsperado*") {
            Write-Host "RESULTADO: OK - $TecnicoEsperado atribuido conforme esperado" -ForegroundColor Green
            $script:testesCorretos++
        } else {
            Write-Host "FALHA: Esperado $TecnicoEsperado mas foi atribuido $($vencedor.NomeCompleto)" -ForegroundColor Red
        }
    } catch {
        Write-Host "ERRO: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "======================================================================" -ForegroundColor White
Write-Host "                    CATEGORIA: PROBLEMAS SIMPLES" -ForegroundColor White
Write-Host "                (Devem ir para Tecnico Junior/Basico)" -ForegroundColor White
Write-Host "======================================================================" -ForegroundColor White

Test-Cenario `
    -Numero "1" `
    -Nome "Instalacao de Software Individual" `
    -Titulo "Preciso instalar Chrome no meu computador" `
    -Descricao "Gostaria de instalar o navegador Chrome no meu computador para acessar um site especifico" `
    -PrioridadeId 2 `
    -CorTitulo "Green" `
    -TecnicoEsperado "Junior" `
    -Justificativa "Instalacao simples, uso de 'meu', 'preciso', 'instalar'"

Test-Cenario `
    -Numero "2" `
    -Nome "Recuperacao de Senha Individual" `
    -Titulo "Esqueci minha senha do sistema" `
    -Descricao "Esqueci minha senha do sistema e preciso trocar urgente para acessar" `
    -PrioridadeId 1 `
    -CorTitulo "Blue" `
    -TecnicoEsperado "Junior" `
    -Justificativa "Procedimento padrao, uso de 'minha', 'senha', 'esqueci', 'trocar'"

Test-Cenario `
    -Numero "3" `
    -Nome "Problema com Mouse/Teclado" `
    -Titulo "Meu mouse parou de funcionar" `
    -Descricao "O mouse do meu computador parou de funcionar de repente, preciso de ajuda" `
    -PrioridadeId 2 `
    -CorTitulo "Green" `
    -TecnicoEsperado "Junior" `
    -Justificativa "Hardware basico, uso de 'meu', 'mouse', 'preciso'"

Test-Cenario `
    -Numero "4" `
    -Nome "Duvida sobre Sistema" `
    -Titulo "Como faco para configurar meu email?" `
    -Descricao "Nao sei como configurar meu email no Outlook, preciso de ajuda" `
    -PrioridadeId 1 `
    -CorTitulo "Blue" `
    -TecnicoEsperado "Junior" `
    -Justificativa "Duvida simples, uso de 'como faco', 'nao sei', 'meu', 'preciso'"

Test-Cenario `
    -Numero "5" `
    -Nome "Solicitacao de Acesso Individual" `
    -Titulo "Solicito acesso ao sistema financeiro" `
    -Descricao "Preciso de acesso ao sistema financeiro para fazer minhas atividades" `
    -PrioridadeId 2 `
    -CorTitulo "Green" `
    -TecnicoEsperado "Junior" `
    -Justificativa "Solicitacao simples, uso de 'solicito', 'preciso', 'minhas'"

Write-Host ""
Write-Host "======================================================================" -ForegroundColor White
Write-Host "                   CATEGORIA: PROBLEMAS COMPLEXOS" -ForegroundColor White
Write-Host "                  (Devem ir para Tecnico Senior)" -ForegroundColor White
Write-Host "======================================================================" -ForegroundColor White

Test-Cenario `
    -Numero "6" `
    -Nome "Problema em Recurso Compartilhado" `
    -Titulo "Pasta compartilhada do setor esta lenta" `
    -Descricao "A pasta compartilhada que todos do setor usam esta muito lenta e travando constantemente" `
    -PrioridadeId 2 `
    -CorTitulo "Magenta" `
    -TecnicoEsperado "Senior" `
    -Justificativa "Afeta multiplos usuarios, uso de 'compartilhado', 'setor', 'todos'"

Test-Cenario `
    -Numero "7" `
    -Nome "Servidor Principal Indisponivel" `
    -Descricao "O servidor principal da empresa esta fora do ar e ninguem consegue acessar os sistemas criticos" `
    -Titulo "Servidor principal fora do ar" `
    -PrioridadeId 3 `
    -CorTitulo "Red" `
    -TecnicoEsperado "Senior" `
    -Justificativa "Problema critico, uso de 'servidor', 'fora do ar', 'critico'"

Test-Cenario `
    -Numero "8" `
    -Nome "Problema de Rede Geral" `
    -Titulo "Rede do departamento esta instavel" `
    -Descricao "A rede do departamento inteiro esta com problemas, todos os computadores estao desconectando" `
    -PrioridadeId 3 `
    -CorTitulo "Red" `
    -TecnicoEsperado "Senior" `
    -Justificativa "Infraestrutura critica, uso de 'rede', 'departamento', 'todos'"

Test-Cenario `
    -Numero "9" `
    -Nome "Sistema ERP Parado" `
    -Titulo "Sistema ERP parou de funcionar" `
    -Descricao "O sistema ERP parou de funcionar e esta afetando todos os setores da empresa" `
    -PrioridadeId 3 `
    -CorTitulo "Red" `
    -TecnicoEsperado "Senior" `
    -Justificativa "Sistema critico empresarial, uso de 'ERP', 'parou', 'todos', 'empresa'"

Test-Cenario `
    -Numero "10" `
    -Nome "Problema no Firewall/VPN" `
    -Titulo "VPN da empresa nao conecta" `
    -Descricao "A VPN da empresa esta com problemas criticos e ninguem consegue acessar remotamente" `
    -PrioridadeId 3 `
    -CorTitulo "Red" `
    -TecnicoEsperado "Senior" `
    -Justificativa "Infraestrutura de seguranca, uso de 'VPN', 'empresa', 'critico'"

Write-Host ""
Write-Host "======================================================================" -ForegroundColor White
Write-Host "                CATEGORIA: CASOS INTERMEDIARIOS" -ForegroundColor White
Write-Host "         (Sistema deve decidir baseado em palavras-chave)" -ForegroundColor White
Write-Host "======================================================================" -ForegroundColor White

Test-Cenario `
    -Numero "11" `
    -Nome "Impressora Pessoal com Problema" `
    -Titulo "Minha impressora nao esta imprimindo" `
    -Descricao "A impressora do meu computador nao esta imprimindo os documentos que preciso" `
    -PrioridadeId 2 `
    -CorTitulo "Green" `
    -TecnicoEsperado "Junior" `
    -Justificativa "Equipamento individual, uso de 'minha', 'impressora', 'meu', 'preciso'"

Test-Cenario `
    -Numero "12" `
    -Nome "Impressora do Setor com Problema" `
    -Titulo "Impressora compartilhada do setor parou" `
    -Descricao "A impressora que todos do setor usam parou de funcionar e esta travando os trabalhos" `
    -PrioridadeId 2 `
    -CorTitulo "Magenta" `
    -TecnicoEsperado "Senior" `
    -Justificativa "Equipamento compartilhado, uso de 'compartilhada', 'setor', 'todos'"

Test-Cenario `
    -Numero "13" `
    -Nome "Software Individual Travando" `
    -Titulo "Excel no meu computador esta travando" `
    -Descricao "O Excel instalado no meu computador esta travando quando abro planilhas grandes" `
    -PrioridadeId 2 `
    -CorTitulo "Green" `
    -TecnicoEsperado "Junior" `
    -Justificativa "Problema individual, uso de 'meu', 'computador'"

Test-Cenario `
    -Numero "14" `
    -Nome "Software Corporativo com Problema" `
    -Titulo "Sistema corporativo apresentando erros" `
    -Descricao "O sistema corporativo esta apresentando erros criticos e afetando o departamento inteiro" `
    -PrioridadeId 3 `
    -CorTitulo "Red" `
    -TecnicoEsperado "Senior" `
    -Justificativa "Sistema corporativo, uso de 'corporativo', 'criticos', 'departamento', 'inteiro'"

Test-Cenario `
    -Numero "15" `
    -Nome "Configuracao de Email Corporativo" `
    -Titulo "Preciso configurar email corporativo no celular" `
    -Descricao "Gostaria de configurar meu email corporativo no meu celular para acessar remotamente" `
    -PrioridadeId 2 `
    -CorTitulo "Green" `
    -TecnicoEsperado "Junior" `
    -Justificativa "Configuracao simples individual, uso de 'preciso', 'meu', 'meu'"

Write-Host ""
Write-Host "======================================================================" -ForegroundColor White
Write-Host "                    CATEGORIA: CASOS ESPECIAIS" -ForegroundColor White
Write-Host "           (Testar edge cases e palavras-chave especificas)" -ForegroundColor White
Write-Host "======================================================================" -ForegroundColor White

Test-Cenario `
    -Numero "16" `
    -Nome "Banco de Dados com Problema" `
    -Titulo "Banco de dados esta apresentando lentidao" `
    -Descricao "O banco de dados principal esta muito lento e afetando todos os sistemas da empresa" `
    -PrioridadeId 3 `
    -CorTitulo "Red" `
    -TecnicoEsperado "Senior" `
    -Justificativa "Infraestrutura critica, uso de 'banco de dados', 'todos', 'empresa'"

Test-Cenario `
    -Numero "17" `
    -Nome "Trocar Perifericos Simples" `
    -Titulo "Preciso trocar meu teclado" `
    -Descricao "Meu teclado esta com teclas quebradas e preciso trocar por um novo" `
    -PrioridadeId 1 `
    -CorTitulo "Blue" `
    -TecnicoEsperado "Junior" `
    -Justificativa "Tarefa simples, uso de 'preciso', 'trocar', 'meu', 'teclado'"

Test-Cenario `
    -Numero "18" `
    -Nome "Sistema Caiu para Todos" `
    -Titulo "Sistema financeiro caiu" `
    -Descricao "O sistema financeiro caiu e ninguem da empresa inteira consegue acessar" `
    -PrioridadeId 3 `
    -CorTitulo "Red" `
    -TecnicoEsperado "Senior" `
    -Justificativa "Sistema critico caido, uso de 'sistema caiu', 'empresa inteira'"

Test-Cenario `
    -Numero "19" `
    -Nome "Ajuda com Duvida Basica" `
    -Titulo "Nao sei como usar o sistema novo" `
    -Descricao "Nao sei como usar o sistema novo que foi instalado, preciso de ajuda basica" `
    -PrioridadeId 1 `
    -CorTitulo "Blue" `
    -TecnicoEsperado "Junior" `
    -Justificativa "Duvida simples, uso de 'nao sei', 'ajuda', 'preciso'"

Test-Cenario `
    -Numero "20" `
    -Nome "Problema Urgente mas Individual" `
    -Titulo "Urgente - preciso acessar minha conta" `
    -Descricao "Urgente - preciso acessar minha conta do sistema mas esqueci a senha" `
    -PrioridadeId 2 `
    -CorTitulo "Green" `
    -TecnicoEsperado "Junior" `
    -Justificativa "Urgencia individual simples, uso de 'minha', 'preciso', 'esqueci', 'senha'"

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "                        RESUMO DOS TESTES" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total de testes executados: $totalTestes" -ForegroundColor White
Write-Host "Testes bem-sucedidos: $testesCorretos" -ForegroundColor Green
Write-Host "Testes com falha: $($totalTestes - $testesCorretos)" -ForegroundColor $(if ($testesCorretos -eq $totalTestes) { "Green" } else { "Red" })
Write-Host ""

$percentual = [math]::Round(($testesCorretos / $totalTestes) * 100, 2)
if ($percentual -eq 100) {
    Write-Host "RESULTADO: $percentual% - SISTEMA PERFEITO!" -ForegroundColor Green
} elseif ($percentual -ge 90) {
    Write-Host "RESULTADO: $percentual% - SISTEMA MUITO BOM" -ForegroundColor Green
} elseif ($percentual -ge 75) {
    Write-Host "RESULTADO: $percentual% - SISTEMA BOM, necessita ajustes" -ForegroundColor Yellow
} else {
    Write-Host "RESULTADO: $percentual% - SISTEMA PRECISA DE REVISAO" -ForegroundColor Red
}

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
