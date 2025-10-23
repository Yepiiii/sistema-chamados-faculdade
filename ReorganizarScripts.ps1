# ==============================================================================
# Script: ReorganizarScripts.ps1
# Descricao: Reorganiza e consolida scripts PowerShell do projeto
# Autor: Sistema
# Data: 23/10/2025
# ==============================================================================

$ErrorActionPreference = "Stop"

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    REORGANIZADOR DE SCRIPTS - Sistema de Chamados" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[*] ANALISE ATUAL" -ForegroundColor Yellow
Write-Host ""

# Contar scripts atuais
$raiz = @(Get-ChildItem -Path . -Filter *.ps1 -File)
$scripts = @(Get-ChildItem -Path Scripts -Filter *.ps1 -File -ErrorAction SilentlyContinue)
$mobile = @(Get-ChildItem -Path Mobile -Filter *.ps1 -File -ErrorAction SilentlyContinue)

$totalAtual = $raiz.Count + $scripts.Count + $mobile.Count
$tamanhoAtual = ($raiz | Measure-Object -Property Length -Sum).Sum + 
                ($scripts | Measure-Object -Property Length -Sum).Sum + 
                ($mobile | Measure-Object -Property Length -Sum).Sum

Write-Host "Scripts encontrados:" -ForegroundColor Cyan
Write-Host "  Raiz: $($raiz.Count) arquivos" -ForegroundColor White
Write-Host "  /Scripts: $($scripts.Count) arquivos" -ForegroundColor White
Write-Host "  /Mobile: $($mobile.Count) arquivos" -ForegroundColor White
Write-Host "  TOTAL: $totalAtual arquivos ($([math]::Round($tamanhoAtual/1KB, 2)) KB)" -ForegroundColor Yellow
Write-Host ""

Write-Host "[!] REORGANIZACAO PROPOSTA" -ForegroundColor Yellow
Write-Host ""
Write-Host "De: $totalAtual scripts (~$([math]::Round($tamanhoAtual/1KB, 2)) KB)" -ForegroundColor Red
Write-Host "Para: 13 scripts (~85 KB)" -ForegroundColor Green
Write-Host "Reducao: $([math]::Round(($totalAtual - 13) / $totalAtual * 100, 0))% de arquivos" -ForegroundColor Cyan
Write-Host ""

Write-Host "Estrutura final:" -ForegroundColor Cyan
Write-Host "  Scripts/API/        - Iniciar API + Firewall" -ForegroundColor White
Write-Host "  Scripts/Mobile/     - Configurar IP + Gerar APK" -ForegroundColor White
Write-Host "  Scripts/Database/   - Banco de dados" -ForegroundColor White
Write-Host "  Scripts/Teste/      - Testes e demos" -ForegroundColor White
Write-Host "  Scripts/Dev/        - Setup desenvolvimento" -ForegroundColor White
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
$novaPastas = @(
    "Scripts/API",
    "Scripts/Mobile",
    "Scripts/Database",
    "Scripts/Teste",
    "Scripts/Dev",
    "Scripts/_Backup"
)

foreach ($pasta in $novaPastas) {
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

# Fazer backup de todos os scripts atuais
$dataBackup = Get-Date -Format "yyyyMMdd_HHmmss"
$pastaBackup = "Scripts/_Backup/$dataBackup"
New-Item -ItemType Directory -Path $pastaBackup -Force | Out-Null

Write-Host "[*] Copiando scripts atuais para backup..." -ForegroundColor Yellow

# Copiar scripts da raiz
foreach ($script in $raiz) {
    Copy-Item $script.FullName -Destination "$pastaBackup/" -Force
}

# Copiar scripts de /Scripts
foreach ($script in $scripts) {
    Copy-Item $script.FullName -Destination "$pastaBackup/" -Force
}

# Copiar scripts de /Mobile
foreach ($script in $mobile) {
    Copy-Item $script.FullName -Destination "$pastaBackup/Mobile_" -Force
}

Write-Host "[OK] Backup criado em: $pastaBackup" -ForegroundColor Green
Write-Host "[OK] Total: $totalAtual arquivos copiados" -ForegroundColor Green
Write-Host ""

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    MOVENDO E CONSOLIDANDO SCRIPTS" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Mover ConfigurarFirewall.ps1 para Scripts/API/
if (Test-Path "ConfigurarFirewall.ps1") {
    Move-Item "ConfigurarFirewall.ps1" -Destination "Scripts/API/" -Force
    Write-Host "[OK] ConfigurarFirewall.ps1 -> Scripts/API/" -ForegroundColor Green
}

# 2. Mover IniciarAPIRede.ps1 para Scripts/API/IniciarAPI.ps1
if (Test-Path "IniciarAPIRede.ps1") {
    Move-Item "IniciarAPIRede.ps1" -Destination "Scripts/API/IniciarAPI.ps1" -Force
    Write-Host "[OK] IniciarAPIRede.ps1 -> Scripts/API/IniciarAPI.ps1" -ForegroundColor Green
}

# 3. Mover GerarAPK.ps1 da raiz para Scripts/Mobile/
if (Test-Path "GerarAPK.ps1") {
    Move-Item "GerarAPK.ps1" -Destination "Scripts/Mobile/" -Force
    Write-Host "[OK] GerarAPK.ps1 -> Scripts/Mobile/" -ForegroundColor Green
}

# 4. Mover ConfigurarIPDispositivo.ps1 para Scripts/Mobile/ConfigurarIP.ps1
if (Test-Path "ConfigurarIPDispositivo.ps1") {
    Move-Item "ConfigurarIPDispositivo.ps1" -Destination "Scripts/Mobile/ConfigurarIP.ps1" -Force
    Write-Host "[OK] ConfigurarIPDispositivo.ps1 -> Scripts/Mobile/ConfigurarIP.ps1" -ForegroundColor Green
}

# 5. Mover InicializarBanco.ps1 para Scripts/Database/
if (Test-Path "InicializarBanco.ps1") {
    Move-Item "InicializarBanco.ps1" -Destination "Scripts/Database/" -Force
    Write-Host "[OK] InicializarBanco.ps1 -> Scripts/Database/" -ForegroundColor Green
}

# 6. Mover AnalisarBanco.ps1 para Scripts/Database/
if (Test-Path "AnalisarBanco.ps1") {
    Move-Item "AnalisarBanco.ps1" -Destination "Scripts/Database/" -Force
    Write-Host "[OK] AnalisarBanco.ps1 -> Scripts/Database/" -ForegroundColor Green
}

# 7. Consolidar scripts de limpar chamados
if (Test-Path "Scripts/LimparChamados.ps1") {
    Move-Item "Scripts/LimparChamados.ps1" -Destination "Scripts/Database/" -Force
    Write-Host "[OK] LimparChamados.ps1 -> Scripts/Database/" -ForegroundColor Green
}

# 8. Mover TestarGemini.ps1 para Scripts/Teste/
if (Test-Path "Scripts/TestarGemini.ps1") {
    Move-Item "Scripts/TestarGemini.ps1" -Destination "Scripts/Teste/" -Force
    Write-Host "[OK] TestarGemini.ps1 -> Scripts/Teste/" -ForegroundColor Green
}

# 9. Mover TestarAPI.ps1 para Scripts/Teste/
if (Test-Path "Scripts/TestarAPI.ps1") {
    Move-Item "Scripts/TestarAPI.ps1" -Destination "Scripts/Teste/" -Force
    Write-Host "[OK] TestarAPI.ps1 -> Scripts/Teste/" -ForegroundColor Green
}

# 10. Mover TestarMobile.ps1 para Scripts/Teste/
if (Test-Path "Scripts/TestarMobile.ps1") {
    Move-Item "Scripts/TestarMobile.ps1" -Destination "Scripts/Teste/" -Force
    Write-Host "[OK] TestarMobile.ps1 -> Scripts/Teste/" -ForegroundColor Green
}

# 11. Mover ReorganizarProjeto.ps1 para Scripts/Dev/
if (Test-Path "ReorganizarProjeto.ps1") {
    Move-Item "ReorganizarProjeto.ps1" -Destination "Scripts/Dev/" -Force
    Write-Host "[OK] ReorganizarProjeto.ps1 -> Scripts/Dev/" -ForegroundColor Green
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    REMOVENDO SCRIPTS REDUNDANTES" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# Lista de scripts redundantes para remover
$scriptsParaRemover = @(
    "CorrigirPermissoes.ps1",
    "PromoVerAdmin.ps1",
    "TestarMobileComLogs.ps1",
    "VerificarPermissoes.ps1",
    "Scripts/ConfigurarIPRemoto.ps1",
    "Scripts/CriarAdmin.ps1",
    "Scripts/CriarChamadosComIA.ps1",
    "Scripts/CriarChamadosDemo.ps1",
    "Scripts/CriarChamadosDemoCorrigido.ps1",
    "Scripts/CriarChamadosDemoV2.ps1",
    "Scripts/CriarChamadosDemo_API.ps1",
    "Scripts/CriarChamadosDemo_Final.ps1",
    "Scripts/GerarAPK.ps1",
    "Scripts/IniciarAPI.ps1",
    "Scripts/IniciarAPIComNgrok.ps1",
    "Scripts/IniciarAPIMobile.ps1",
    "Scripts/IniciarAmbiente.ps1",
    "Scripts/IniciarApp.ps1",
    "Scripts/IniciarSistema.ps1",
    "Scripts/IniciarSistemaWindows.ps1",
    "Scripts/IniciarTeste.ps1",
    "Scripts/LimparChamadosSimples.ps1",
    "Scripts/LimparTodosChamados.ps1",
    "Scripts/ObterToken.ps1",
    "Scripts/SetupUsuariosTeste.ps1",
    "Scripts/TestarChamados.ps1",
    "Scripts/TestarConectividadeMobile.ps1",
    "Scripts/TestarPortabilidade.ps1",
    "Scripts/TestarRegrasVisualizacao.ps1",
    "Scripts/TestarRestricaoManual.ps1",
    "Scripts/ValidarConfigAPK.ps1",
    "Scripts/WorkflowAPK.ps1",
    "Scripts/ConfigurarIP.ps1",
    "Mobile/AbrirVisualStudio.ps1",
    "Mobile/Executar.ps1",
    "Mobile/IniciarEmulador.ps1",
    "Mobile/TestarImplementacoesRecentes.ps1"
)

$removidos = 0
foreach ($script in $scriptsParaRemover) {
    if (Test-Path $script) {
        Remove-Item $script -Force
        Write-Host "[X] Removido: $script" -ForegroundColor Red
        $removidos++
    }
}

Write-Host ""
Write-Host "[OK] $removidos scripts redundantes removidos" -ForegroundColor Green
Write-Host ""

Write-Host "==================================================================" -ForegroundColor Green
Write-Host "    REORGANIZACAO CONCLUIDA!" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green
Write-Host ""

# Contar scripts finais
$scriptFinais = @(Get-ChildItem -Path Scripts -Filter *.ps1 -Recurse -File)

Write-Host "RESULTADO:" -ForegroundColor Cyan
Write-Host "  Antes: $totalAtual scripts ($([math]::Round($tamanhoAtual/1KB, 2)) KB)" -ForegroundColor Yellow
Write-Host "  Depois: $($scriptFinais.Count) scripts" -ForegroundColor Green
Write-Host "  Removidos: $removidos scripts" -ForegroundColor Red
Write-Host "  Backup em: $pastaBackup" -ForegroundColor Cyan
Write-Host ""

Write-Host "NOVA ESTRUTURA:" -ForegroundColor Cyan
Write-Host ""

# Mostrar estrutura final
Write-Host "Scripts/" -ForegroundColor Green
$subdirs = @("API", "Mobile", "Database", "Teste", "Dev")
foreach ($subdir in $subdirs) {
    $arquivos = @(Get-ChildItem -Path "Scripts/$subdir" -Filter *.ps1 -File -ErrorAction SilentlyContinue)
    if ($arquivos.Count -gt 0) {
        Write-Host "  $subdir/ ($($arquivos.Count) scripts)" -ForegroundColor Yellow
        foreach ($arquivo in $arquivos) {
            Write-Host "    - $($arquivo.Name)" -ForegroundColor White
        }
    }
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    PROXIMOS PASSOS" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Revisar scripts em cada pasta" -ForegroundColor White
Write-Host "2. Atualizar documentacao (README.md)" -ForegroundColor White
Write-Host "3. Testar workflows principais" -ForegroundColor White
Write-Host "4. Fazer commit das mudancas" -ForegroundColor White
Write-Host ""
Write-Host "[*] Backup disponivel em: $pastaBackup" -ForegroundColor Cyan
Write-Host "[*] Para reverter: copie arquivos do backup de volta" -ForegroundColor Cyan
Write-Host ""
