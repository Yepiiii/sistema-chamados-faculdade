# ========================================
# Workflow Completo - APK Mobile
# ========================================
# Script master para preparar e usar APK

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("validar", "gerar", "iniciar", "tudo")]
    [string]$Acao = "tudo"
)

function Show-Header {
    param([string]$Title)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Step {
    param([string]$Step)
    Write-Host $Step -ForegroundColor Yellow
}

function Show-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Show-Error {
    param([string]$Message)
    Write-Host "[ERRO] $Message" -ForegroundColor Red
}

function Show-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

# Banner inicial
Clear-Host
Write-Host ""
Write-Host "  ██████╗ ██╗███████╗████████╗███████╗███╗   ███╗ █████╗ " -ForegroundColor Cyan
Write-Host " ██╔════╝ ██║██╔════╝╚══██╔══╝██╔════╝████╗ ████║██╔══██╗" -ForegroundColor Cyan
Write-Host " ╚█████╗  ██║███████╗   ██║   █████╗  ██╔████╔██║███████║" -ForegroundColor Cyan
Write-Host "  ╚═══██╗██║╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║██╔══██║" -ForegroundColor Cyan
Write-Host " ██████╔╝██║███████║   ██║   ███████╗██║ ╚═╝ ██║██║  ██║" -ForegroundColor Cyan
Write-Host " ╚═════╝ ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "           Sistema de Chamados - APK Mobile" -ForegroundColor White
Write-Host "                    Versão 1.0" -ForegroundColor Gray
Write-Host ""

# Detectar caminhos relativos
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$backendPath = Join-Path $repoRoot "Backend"
$apkFolder = Join-Path $repoRoot "APK"
$scriptsPath = $scriptDir

# Caminho do projeto
$projectPath = $backendPath
Set-Location $projectPath

# Executar ações
switch ($Acao) {
    "validar" {
        Show-Header "VALIDAR CONFIGURAÇÃO"
        $validateScript = Join-Path $scriptDir "ValidarConfigAPK.ps1"
        & $validateScript
        $validationCode = $LASTEXITCODE
        
        if ($validationCode -eq 0) {
            Write-Host ""
            Show-Success "Validação concluída com sucesso!"
            Write-Host ""
            Write-Host "Próximo passo: .\WorkflowAPK.ps1 gerar" -ForegroundColor Cyan
        }
    }
    
    "gerar" {
        Show-Header "GERAR APK ANDROID"
        
        Show-Step "Verificando configuração..."
        $validateScript = Join-Path $scriptDir "ValidarConfigAPK.ps1"
        & $validateScript
        
        if ($LASTEXITCODE -ne 0) {
            Show-Error "Validação falhou! Corrija os erros antes de gerar APK."
            exit 1
        }
        
        Write-Host ""
        Show-Step "Iniciando geração do APK..."
        Write-Host ""
        
        $gerarScript = Join-Path $scriptDir "GerarAPK.ps1"
        & $gerarScript
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Show-Success "APK gerado com sucesso!"
            Write-Host ""
            Write-Host "Próximo passo: .\WorkflowAPK.ps1 iniciar" -ForegroundColor Cyan
        }
    }
    
    "iniciar" {
        Show-Header "INICIAR API PARA MOBILE"
        
        Show-Step "Verificando APK..."
        $apkPath = Join-Path $apkFolder "SistemaChamados-v1.0.apk"
        
        if (-not (Test-Path $apkPath)) {
            Show-Error "APK não encontrado!"
            Show-Info "Execute primeiro: .\WorkflowAPK.ps1 gerar"
            exit 1
        }
        
        Show-Success "APK encontrado"
        Write-Host ""
        
        Show-Step "Iniciando API..."
        Write-Host ""
        
        $iniciarScript = Join-Path $scriptDir "IniciarAPIMobile.ps1"
        & $iniciarScript
    }
    
    "tudo" {
        Show-Header "WORKFLOW COMPLETO - APK MOBILE"
        
        Write-Host "Este workflow irá:" -ForegroundColor White
        Write-Host "  1. Validar configuração" -ForegroundColor Cyan
        Write-Host "  2. Gerar APK (se necessário)" -ForegroundColor Cyan
        Write-Host "  3. Iniciar API para mobile" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Pressione qualquer tecla para continuar ou Ctrl+C para cancelar..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Write-Host ""
        
        # 1. Validar
        Show-Header "ETAPA 1/3 - VALIDAÇÃO"
        $validateScript = Join-Path $scriptDir "ValidarConfigAPK.ps1"
        & $validateScript
        
        if ($LASTEXITCODE -ne 0) {
            Show-Error "Validação falhou! Corrija os erros antes de continuar."
            exit 1
        }
        
        Write-Host ""
        Show-Success "Validação OK!"
        Start-Sleep -Seconds 2
        
        # 2. Verificar se APK existe
        Show-Header "ETAPA 2/3 - VERIFICAR APK"
        $apkPath = Join-Path $apkFolder "SistemaChamados-v1.0.apk"
        
        if (Test-Path $apkPath) {
            Show-Success "APK já existe"
            Write-Host ""
            Write-Host "Deseja regerar o APK? (s/N): " -ForegroundColor Yellow -NoNewline
            $resposta = Read-Host
            
            if ($resposta -eq "s" -or $resposta -eq "S") {
                Write-Host ""
                Show-Step "Gerando novo APK..."
                $gerarScript = Join-Path $scriptDir "GerarAPK.ps1"
                & $gerarScript
                
                if ($LASTEXITCODE -ne 0) {
                    Show-Error "Falha ao gerar APK!"
                    exit 1
                }
            }
        } else {
            Show-Info "APK não encontrado, gerando..."
            $gerarScript = Join-Path $scriptDir "GerarAPK.ps1"
            & $gerarScript
            
            if ($LASTEXITCODE -ne 0) {
                Show-Error "Falha ao gerar APK!"
                exit 1
            }
        }
        
        Write-Host ""
        Show-Success "APK pronto!"
        Start-Sleep -Seconds 2
        
        # 3. Iniciar API
        Show-Header "ETAPA 3/3 - INICIAR API"
        Write-Host "A API será iniciada para aceitar conexões do mobile..." -ForegroundColor White
        Write-Host ""
        Write-Host "Pressione qualquer tecla para iniciar..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Write-Host ""
        
        $iniciarScript = Join-Path $scriptDir "IniciarAPIMobile.ps1"
        & $iniciarScript
    }
}

Write-Host ""
Write-Host "Workflow concluído!" -ForegroundColor Green
Write-Host ""
