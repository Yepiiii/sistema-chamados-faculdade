# Script de Reorganizacao do Repositorio
# Sistema de Chamados - Monorepo

param(
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Reorganizacao do Repositorio" -ForegroundColor Cyan
Write-Host "  Sistema de Chamados" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "[MODO DRY-RUN] Simulando sem executar mudancas" -ForegroundColor Yellow
    Write-Host ""
}

# Verificar se esta na pasta correta
$currentPath = Get-Location
if (!(Test-Path ".git")) {
    Write-Host "[ERRO] Execute este script na raiz do repositorio Git!" -ForegroundColor Red
    Write-Host "       Pasta atual: $currentPath" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Repositorio Git detectado" -ForegroundColor Green
Write-Host "     Pasta: $currentPath" -ForegroundColor Cyan
Write-Host ""

# Verificar se ha mudancas nao commitadas
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "[AVISO] Ha mudancas nao commitadas:" -ForegroundColor Yellow
    Write-Host $gitStatus -ForegroundColor Gray
    Write-Host ""
    
    if (!$Force) {
        $continuar = Read-Host "Deseja continuar mesmo assim? (S/N)"
        if ($continuar -ne "S" -and $continuar -ne "s") {
            Write-Host "[CANCELADO] Commit suas mudancas antes de reorganizar" -ForegroundColor Yellow
            exit 0
        }
    }
}

# Criar backup
$backupDate = Get-Date -Format "yyyyMMdd_HHmmss"
$backupPath = "c:\Users\opera\Backup_SistemaChamados_$backupDate"

Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  PASSO 1: BACKUP" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

if (!$DryRun) {
    Write-Host "Criando backup em: $backupPath" -ForegroundColor Cyan
    Copy-Item $currentPath -Destination $backupPath -Recurse -Force
    Write-Host "[OK] Backup criado!" -ForegroundColor Green
} else {
    Write-Host "[DRY-RUN] Criaria backup em: $backupPath" -ForegroundColor Gray
}
Write-Host ""

# Verificar se projeto mobile existe
$mobileSourcePath = "c:\Users\opera\sistema-chamados-faculdade\SistemaChamados.Mobile"
if (!(Test-Path $mobileSourcePath)) {
    Write-Host "[ERRO] Projeto mobile nao encontrado em:" -ForegroundColor Red
    Write-Host "       $mobileSourcePath" -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] Projeto mobile encontrado" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  PASSO 2: CRIAR ESTRUTURA DE PASTAS" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

$newFolders = @("Backend", "Mobile", "Scripts", "Docs", "APK")

foreach ($folder in $newFolders) {
    if (!$DryRun) {
        if (!(Test-Path $folder)) {
            New-Item -ItemType Directory -Name $folder -Force | Out-Null
            Write-Host "[OK] Criada: $folder\" -ForegroundColor Green
        } else {
            Write-Host "[AVISO] Ja existe: $folder\" -ForegroundColor Yellow
        }
    } else {
        Write-Host "[DRY-RUN] Criaria: $folder\" -ForegroundColor Gray
    }
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  PASSO 3: MOVER ARQUIVOS DO BACKEND" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

$backendItems = @(
    "API", "Application", "Core", "Data", "Configuration", "Migrations", 
    "Properties", "Services", "bin", "obj",
    "SistemaChamados.csproj", "SistemaChamados.csproj.user",
    "appsettings.json", "appsettings.Development.json", 
    "program.cs", "temp_query.cs"
)

foreach ($item in $backendItems) {
    if (Test-Path $item) {
        if (!$DryRun) {
            Move-Item $item -Destination "Backend\" -Force -ErrorAction SilentlyContinue
            Write-Host "[OK] Movido: $item -> Backend\" -ForegroundColor Green
        } else {
            Write-Host "[DRY-RUN] Moveria: $item -> Backend\" -ForegroundColor Gray
        }
    }
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  PASSO 4: COPIAR PROJETO MOBILE" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

if (!$DryRun) {
    Write-Host "Copiando projeto mobile..." -ForegroundColor Cyan
    Copy-Item "$mobileSourcePath\*" -Destination "Mobile\" -Recurse -Force
    Write-Host "[OK] Projeto Mobile copiado para Mobile\" -ForegroundColor Green
} else {
    Write-Host "[DRY-RUN] Copiaria: $mobileSourcePath -> Mobile\" -ForegroundColor Gray
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  PASSO 5: MOVER SCRIPTS" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

$scripts = Get-ChildItem -Filter "*.ps1" | Where-Object { $_.Name -ne "ReorganizarProjeto.ps1" }
foreach ($script in $scripts) {
    if (!$DryRun) {
        Move-Item $script.FullName -Destination "Scripts\" -Force -ErrorAction SilentlyContinue
        Write-Host "[OK] Movido: $($script.Name) -> Scripts\" -ForegroundColor Green
    } else {
        Write-Host "[DRY-RUN] Moveria: $($script.Name) -> Scripts\" -ForegroundColor Gray
    }
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  PASSO 6: MOVER DOCUMENTACAO" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

$docs = Get-ChildItem -Filter "*.md" | Where-Object { 
    $_.Name -ne "README.md" -and 
    $_.Name -ne "ESTRUTURA_REPOSITORIO.md" -and
    $_.Name -ne "RESUMO_REORGANIZACAO.md"
}
foreach ($doc in $docs) {
    if (!$DryRun) {
        Move-Item $doc.FullName -Destination "Docs\" -Force -ErrorAction SilentlyContinue
        Write-Host "[OK] Movido: $($doc.Name) -> Docs\" -ForegroundColor Green
    } else {
        Write-Host "[DRY-RUN] Moveria: $($doc.Name) -> Docs\" -ForegroundColor Gray
    }
}

if (Test-Path "docs\mobile-overview") {
    if (!$DryRun) {
        Move-Item "docs\mobile-overview" -Destination "Docs\" -Force -ErrorAction SilentlyContinue
        Write-Host "[OK] Movido: docs\mobile-overview -> Docs\" -ForegroundColor Green
    } else {
        Write-Host "[DRY-RUN] Moveria: docs\mobile-overview -> Docs\" -ForegroundColor Gray
    }
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  PASSO 7: ATUALIZAR SOLUTION" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

if (!$DryRun) {
    if (Test-Path "sistema-chamados-faculdade.sln") {
        Remove-Item "sistema-chamados-faculdade.sln" -Force
        Write-Host "[OK] Solution antiga removida" -ForegroundColor Green
    }
    
    dotnet new sln -n SistemaChamados -o . --force | Out-Null
    Write-Host "[OK] Nova solution criada: SistemaChamados.sln" -ForegroundColor Green
    
    dotnet sln add "Backend\SistemaChamados.csproj" | Out-Null
    Write-Host "[OK] Backend adicionado a solution" -ForegroundColor Green
    
    dotnet sln add "Mobile\SistemaChamados.Mobile.csproj" | Out-Null
    Write-Host "[OK] Mobile adicionado a solution" -ForegroundColor Green
} else {
    Write-Host "[DRY-RUN] Criaria nova solution com ambos os projetos" -ForegroundColor Gray
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  PASSO 8: CRIAR .gitkeep NO APK" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

if (!$DryRun) {
    New-Item -ItemType File -Path "APK\.gitkeep" -Force | Out-Null
    Write-Host "[OK] Criado APK\.gitkeep" -ForegroundColor Green
} else {
    Write-Host "[DRY-RUN] Criaria APK\.gitkeep" -ForegroundColor Gray
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "  REORGANIZACAO CONCLUIDA!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

if (!$DryRun) {
    Write-Host "Backup salvo em: $backupPath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "PROXIMOS PASSOS:" -ForegroundColor Yellow
    Write-Host "1. Revisar mudancas: git status" -ForegroundColor White
    Write-Host "2. Atualizar scripts com caminhos relativos" -ForegroundColor White
    Write-Host "3. Criar README.md principal" -ForegroundColor White
    Write-Host "4. Atualizar .gitignore" -ForegroundColor White
    Write-Host "5. Testar: dotnet restore" -ForegroundColor White
    Write-Host "6. Commit e push das mudancas" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "[DRY-RUN] Execute sem -DryRun para aplicar mudancas" -ForegroundColor Yellow
    Write-Host ""
}
