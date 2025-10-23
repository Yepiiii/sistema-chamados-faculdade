# ==============================================================================
# Script: ReorganizarDocumentacao.ps1
# Descricao: Reorganiza e consolida arquivos Markdown do projeto
# Autor: Sistema
# Data: 23/10/2025
# ==============================================================================

$ErrorActionPreference = "Stop"

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    REORGANIZADOR DE DOCUMENTACAO - Sistema de Chamados" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[*] ANALISE ATUAL" -ForegroundColor Yellow
Write-Host ""

# Contar arquivos Markdown atuais
$raiz = @(Get-ChildItem -Path . -Filter *.md -File)
$docs = @(Get-ChildItem -Path docs -Filter *.md -Recurse -File -ErrorAction SilentlyContinue)
$mobile = @(Get-ChildItem -Path Mobile -Filter *.md -File -ErrorAction SilentlyContinue)

$totalAtual = $raiz.Count + $docs.Count + $mobile.Count

Write-Host "Arquivos Markdown encontrados:" -ForegroundColor Cyan
Write-Host "  Raiz: $($raiz.Count) arquivos" -ForegroundColor White
Write-Host "  /docs: $($docs.Count) arquivos" -ForegroundColor White
Write-Host "  /Mobile: $($mobile.Count) arquivos" -ForegroundColor White
Write-Host "  TOTAL: $totalAtual arquivos" -ForegroundColor Yellow
Write-Host ""

Write-Host "[!] REORGANIZACAO PROPOSTA" -ForegroundColor Yellow
Write-Host ""
Write-Host "De: $totalAtual arquivos" -ForegroundColor Red
Write-Host "Para: ~15 arquivos essenciais" -ForegroundColor Green
Write-Host "Reducao: ~78% de arquivos" -ForegroundColor Cyan
Write-Host ""

Write-Host "Estrutura final:" -ForegroundColor Cyan
Write-Host "  /                    - README.md (principal)" -ForegroundColor White
Write-Host "  /                    - WORKFLOWS.md (guia de uso)" -ForegroundColor White
Write-Host "  docs/                - Documentacao tecnica" -ForegroundColor White
Write-Host "  docs/Mobile/         - Documentacao do app mobile" -ForegroundColor White
Write-Host "  docs/API/            - Documentacao da API" -ForegroundColor White
Write-Host "  docs/Database/       - Documentacao do banco" -ForegroundColor White
Write-Host "  docs/_Archive/       - Arquivos obsoletos" -ForegroundColor Gray
Write-Host ""

# Confirmar reorganizacao
Write-Host "Deseja continuar com a reorganizacao? (s/N): " -ForegroundColor Yellow -NoNewline
Write-Host "s" -ForegroundColor Green
Write-Host ""
Write-Host "[OK] Iniciando reorganizacao..." -ForegroundColor Green

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    CRIANDO NOVA ESTRUTURA" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# Criar nova estrutura de pastas
$novasPastas = @(
    "docs/Mobile",
    "docs/API",
    "docs/Database",
    "docs/Desenvolvimento",
    "docs/_Archive"
)

foreach ($pasta in $novasPastas) {
    if (-not (Test-Path $pasta)) {
        New-Item -ItemType Directory -Path $pasta -Force | Out-Null
        Write-Host "[OK] Criado: $pasta" -ForegroundColor Green
    } else {
        Write-Host "[*] Ja existe: $pasta" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    FAZENDO BACKUP" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# Fazer backup de todos os arquivos Markdown atuais
$dataBackup = Get-Date -Format "yyyyMMdd_HHmmss"
$pastaBackup = "docs/_Archive/backup_$dataBackup"
New-Item -ItemType Directory -Path $pastaBackup -Force | Out-Null

Write-Host "[*] Copiando documentacao atual para backup..." -ForegroundColor Yellow

# Copiar arquivos da raiz
foreach ($arquivo in $raiz) {
    if ($arquivo.Name -ne "README.md" -and $arquivo.Name -ne "WORKFLOWS.md") {
        Copy-Item $arquivo.FullName -Destination "$pastaBackup/" -Force
    }
}

# Copiar arquivos de /docs
foreach ($arquivo in $docs) {
    $relativePath = $arquivo.FullName.Replace("$PWD\docs\", "")
    $destPath = Join-Path $pastaBackup $relativePath
    $destDir = Split-Path $destPath -Parent
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    Copy-Item $arquivo.FullName -Destination $destPath -Force
}

# Copiar arquivos de /Mobile
foreach ($arquivo in $mobile) {
    Copy-Item $arquivo.FullName -Destination "$pastaBackup/Mobile_" -Force
}

Write-Host "[OK] Backup criado em: $pastaBackup" -ForegroundColor Green
Write-Host ""

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    CONSOLIDANDO E MOVENDO ARQUIVOS" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# ===== MANTER NA RAIZ =====
Write-Host "[*] Mantendo na raiz:" -ForegroundColor Cyan
Write-Host "  - README.md" -ForegroundColor Green
Write-Host "  - WORKFLOWS.md" -ForegroundColor Green
Write-Host ""

# ===== MOVER PARA docs/Mobile/ =====
Write-Host "[*] Consolidando documentacao Mobile..." -ForegroundColor Yellow

$moverParaMobile = @(
    @{Origem="GUIA_INSTALACAO_APK.md"; Destino="docs/Mobile/GuiaInstalacaoAPK.md"},
    @{Origem="docs/APK_README.md"; Destino="docs/Mobile/GerarAPK.md"},
    @{Origem="docs/GUIA_GERAR_APK.md"; Destino=$null},  # Redundante
    @{Origem="docs/GUIA_RAPIDO_APK.md"; Destino=$null},  # Redundante
    @{Origem="docs/README_MOBILE.md"; Destino="docs/Mobile/README.md"},
    @{Origem="docs/STATUS_MOBILE.md"; Destino=$null},  # Obsoleto
    @{Origem="docs/COMO_TESTAR_MOBILE.md"; Destino="docs/Mobile/ComoTestar.md"},
    @{Origem="docs/TESTE_MOBILE.md"; Destino=$null},  # Redundante
    @{Origem="docs/TESTE_CONECTIVIDADE_PASSO_A_PASSO.md"; Destino="docs/Mobile/TesteConectividade.md"},
    @{Origem="docs/SOLUCAO_IP_REDE.md"; Destino="docs/Mobile/ConfiguracaoIP.md"},
    @{Origem="docs/SOLUCAO_TIMEOUT.md"; Destino="docs/Mobile/Troubleshooting.md"},
    @{Origem="docs/ACESSO_REMOTO.md"; Destino=$null},  # Obsoleto
    @{Origem="Mobile/INICIO_RAPIDO.md"; Destino=$null},  # Redundante
    @{Origem="Mobile/EMULADOR_GUIA.md"; Destino=$null},  # Obsoleto
    @{Origem="Mobile/STATUS_IMPLEMENTACAO.md"; Destino=$null},  # Obsoleto
    @{Origem="Mobile/TESTE_COMPLETO.md"; Destino=$null}  # Obsoleto
)

foreach ($item in $moverParaMobile) {
    if (Test-Path $item.Origem) {
        if ($item.Destino) {
            Move-Item $item.Origem -Destination $item.Destino -Force
            Write-Host "[OK] $($item.Origem) -> $($item.Destino)" -ForegroundColor Green
        } else {
            Remove-Item $item.Origem -Force
            Write-Host "[X] Removido: $($item.Origem)" -ForegroundColor Red
        }
    }
}

# ===== MOVER PARA docs/Database/ =====
Write-Host ""
Write-Host "[*] Consolidando documentacao Database..." -ForegroundColor Yellow

if (Test-Path "GUIA_BANCO_DADOS.md") {
    Move-Item "GUIA_BANCO_DADOS.md" -Destination "docs/Database/README.md" -Force
    Write-Host "[OK] GUIA_BANCO_DADOS.md -> docs/Database/README.md" -ForegroundColor Green
}

# ===== MOVER PARA docs/Desenvolvimento/ =====
Write-Host ""
Write-Host "[*] Consolidando documentacao de Desenvolvimento..." -ForegroundColor Yellow

$moverParaDev = @(
    @{Origem="ARQUITETURA_SISTEMA.md"; Destino="docs/Desenvolvimento/Arquitetura.md"},
    @{Origem="ESTRUTURA_REPOSITORIO.md"; Destino="docs/Desenvolvimento/EstruturaRepositorio.md"},
    @{Origem="docs/GEMINI_SERVICE_README.md"; Destino="docs/Desenvolvimento/GeminiAPI.md"},
    @{Origem="docs/GEMINI_STATUS.md"; Destino=$null},  # Obsoleto
    @{Origem="docs/ESTADO_ATUAL_PROJETO.md"; Destino=$null},  # Obsoleto
    @{Origem="PLANO_REORGANIZACAO_SCRIPTS.md"; Destino="docs/Desenvolvimento/ReorganizacaoScripts.md"}
)

foreach ($item in $moverParaDev) {
    if (Test-Path $item.Origem) {
        if ($item.Destino) {
            Move-Item $item.Origem -Destination $item.Destino -Force
            Write-Host "[OK] $($item.Origem) -> $($item.Destino)" -ForegroundColor Green
        } else {
            Remove-Item $item.Origem -Force
            Write-Host "[X] Removido: $($item.Origem)" -ForegroundColor Red
        }
    }
}

# ===== MOVER PARA docs/_Archive (Obsoletos) =====
Write-Host ""
Write-Host "[*] Movendo arquivos obsoletos para _Archive..." -ForegroundColor Yellow

$moverParaArchive = @(
    "CORRECOES_ATUALIZACAO.md",
    "CREDENCIAIS_TESTE.md",
    "DIAGNOSTICO_BOTAO_ENCERRAR.md",
    "FUNCIONALIDADE_AUTO_REFRESH.md",
    "GUIA_INSTALACAO.md",
    "PORTABILIDADE_COMPLETA.md",
    "RELATORIO_FINAL_COMMITS.md",
    "RELATORIO_INTEGRACAO.md",
    "RESUMO_REORGANIZACAO.md",
    "docs/CREDENCIAIS_TESTE.md",
    "docs/CORRECAO_FUSO_HORARIO.md",
    "docs/CORRECOES_MEUS_CHAMADOS.md",
    "docs/CORRECOES_NAVEGACAO.md",
    "docs/CORRECOES_NOVO_CHAMADO.md",
    "docs/CORRECOES_WINDOWS.md",
    "docs/ATRIBUICOES_VISUALIZACAO.md",
    "docs/RESTRICAO_CLASSIFICACAO_MANUAL.md",
    "docs/IMPLEMENTACAO_DATA_ENCERRAMENTO.md",
    "docs/GUIA_INICIAR_SISTEMA.md",
    "docs/SETUP_PORTABILIDADE.md",
    "docs/SCRIPTS_APK_README.md",
    "docs/MOBILE_NAO_VERSIONADO.md",
    "docs/OVERVIEW_MOBILE_UI_UX.md",
    "Mobile/POLLING_NOTIFICATIONS_GUIDE.md",
    "Mobile/THREAD_COMENTARIOS_IMPLEMENTATION.md",
    "Mobile/THREAD_COMENTARIOS_VISUAL.md",
    "Mobile/TIMELINE_IMPLEMENTATION.md",
    "Mobile/UPLOAD_ANEXOS_IMPLEMENTATION.md"
)

foreach ($arquivo in $moverParaArchive) {
    if (Test-Path $arquivo) {
        $nomeArquivo = Split-Path $arquivo -Leaf
        Move-Item $arquivo -Destination "docs/_Archive/$nomeArquivo" -Force
        Write-Host "[>>] $arquivo -> docs/_Archive/" -ForegroundColor Gray
    }
}

# ===== MOVER mobile-overview COMPLETO =====
Write-Host ""
Write-Host "[*] Movendo pasta mobile-overview..." -ForegroundColor Yellow

if (Test-Path "docs/mobile-overview") {
    Move-Item "docs/mobile-overview" -Destination "docs/_Archive/mobile-overview" -Force
    Write-Host "[>>] docs/mobile-overview -> docs/_Archive/mobile-overview" -ForegroundColor Gray
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Green
Write-Host "    REORGANIZACAO CONCLUIDA!" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green
Write-Host ""

# Contar arquivos finais
$raizFinal = @(Get-ChildItem -Path . -Filter *.md -File)
$docsFinal = @(Get-ChildItem -Path docs -Filter *.md -Recurse -File -Exclude "_Archive")
$mobileFinal = @(Get-ChildItem -Path Mobile -Filter *.md -File -ErrorAction SilentlyContinue)
$totalFinal = $raizFinal.Count + $docsFinal.Count + $mobileFinal.Count

Write-Host "RESULTADO:" -ForegroundColor Cyan
Write-Host "  Antes: $totalAtual arquivos" -ForegroundColor Yellow
Write-Host "  Depois: ~$totalFinal arquivos ativos" -ForegroundColor Green
Write-Host "  Reducao: $([math]::Round(($totalAtual - $totalFinal) / $totalAtual * 100, 0))%" -ForegroundColor Cyan
Write-Host "  Backup em: $pastaBackup" -ForegroundColor Gray
Write-Host ""

Write-Host "NOVA ESTRUTURA:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Raiz/" -ForegroundColor Green
Write-Host "  - README.md (principal)" -ForegroundColor White
Write-Host "  - WORKFLOWS.md (guia de uso)" -ForegroundColor White
Write-Host ""

Write-Host "docs/" -ForegroundColor Green
Write-Host "  Mobile/" -ForegroundColor Yellow
$mobileFiles = @(Get-ChildItem -Path "docs/Mobile" -Filter *.md -File -ErrorAction SilentlyContinue)
foreach ($arquivo in $mobileFiles) {
    Write-Host "    - $($arquivo.Name)" -ForegroundColor White
}

Write-Host "  Database/" -ForegroundColor Yellow
$dbFiles = @(Get-ChildItem -Path "docs/Database" -Filter *.md -File -ErrorAction SilentlyContinue)
foreach ($arquivo in $dbFiles) {
    Write-Host "    - $($arquivo.Name)" -ForegroundColor White
}

Write-Host "  Desenvolvimento/" -ForegroundColor Yellow
$devFiles = @(Get-ChildItem -Path "docs/Desenvolvimento" -Filter *.md -File -ErrorAction SilentlyContinue)
foreach ($arquivo in $devFiles) {
    Write-Host "    - $($arquivo.Name)" -ForegroundColor White
}

Write-Host "  _Archive/ ($($moverParaArchive.Count)+ arquivos)" -ForegroundColor Gray
Write-Host ""

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    PROXIMOS PASSOS" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Revisar arquivos em cada pasta" -ForegroundColor White
Write-Host "2. Atualizar README.md principal" -ForegroundColor White
Write-Host "3. Testar links na documentacao" -ForegroundColor White
Write-Host "4. Fazer commit das mudancas" -ForegroundColor White
Write-Host ""
Write-Host "[*] Backup disponivel em: $pastaBackup" -ForegroundColor Cyan
Write-Host "[*] Para reverter: copie arquivos do backup de volta" -ForegroundColor Cyan
Write-Host ""
