# ========================================
#  CORREÇÃO AUTOMÁTICA DE PORTABILIDADE
# ========================================
# Corrige caminhos hardcoded e problemas de portabilidade
# Data: 27/10/2025

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CORREÇÃO DE PORTABILIDADE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$fixes = 0
$warnings = 0

# Backup antes de modificar
$backupFolder = ".\Backup_Portabilidade_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null
Write-Host "[INFO] Backup criado em: $backupFolder" -ForegroundColor Yellow
Write-Host ""

# ========================================
# 1. Corrigir IniciarWeb.ps1
# ========================================
Write-Host "[1/7] Corrigindo IniciarWeb.ps1..." -ForegroundColor Yellow

$file = ".\IniciarWeb.ps1"
if (Test-Path $file) {
    Copy-Item $file "$backupFolder\IniciarWeb.ps1.bak"
    
    $content = Get-Content $file -Raw
    $newContent = $content -replace 'Set-Location "C:\\Users\\opera\\sistema-chamados-faculdade\\sistema-chamados-faculdade\\Backend"', '$backendPath = Join-Path $PSScriptRoot "Backend"; Set-Location $backendPath'
    
    if ($content -ne $newContent) {
        Set-Content $file $newContent -NoNewline
        Write-Host "   ✅ Corrigido!" -ForegroundColor Green
        $fixes++
    } else {
        Write-Host "   ⚠️  Já estava correto" -ForegroundColor Gray
    }
} else {
    Write-Host "   ❌ Arquivo não encontrado" -ForegroundColor Red
}

# ========================================
# 2. Corrigir IniciarAmbienteMobile.ps1
# ========================================
Write-Host "[2/7] Corrigindo IniciarAmbienteMobile.ps1..." -ForegroundColor Yellow

$file = ".\IniciarAmbienteMobile.ps1"
if (Test-Path $file) {
    Copy-Item $file "$backupFolder\IniciarAmbienteMobile.ps1.bak"
    
    $content = Get-Content $file -Raw
    $newContent = $content -replace '\$apiPath = "C:\\Users\\opera\\sistema-chamados-faculdade\\sistema-chamados-faculdade\\Backend"', '$apiPath = Join-Path $PSScriptRoot "Backend"'
    $newContent = $newContent -replace '\$solutionPath = "C:\\Users\\opera\\sistema-chamados-faculdade\\sistema-chamados-faculdade\\SistemaChamados\.sln"', '$solutionPath = Join-Path $PSScriptRoot "SistemaChamados.sln"'
    
    if ($content -ne $newContent) {
        Set-Content $file $newContent -NoNewline
        Write-Host "   ✅ Corrigido!" -ForegroundColor Green
        $fixes++
    } else {
        Write-Host "   ⚠️  Já estava correto" -ForegroundColor Gray
    }
} else {
    Write-Host "   ⚠️  Arquivo não encontrado (opcional)" -ForegroundColor Yellow
    $warnings++
}

# ========================================
# 3. Corrigir Scripts\AbrirAppMobile.ps1
# ========================================
Write-Host "[3/7] Corrigindo Scripts\AbrirAppMobile.ps1..." -ForegroundColor Yellow

$file = ".\Scripts\AbrirAppMobile.ps1"
if (Test-Path $file) {
    Copy-Item $file "$backupFolder\AbrirAppMobile.ps1.bak"
    
    $content = Get-Content $file -Raw
    $newContent = $content -replace '\$mobileProjectPath = "C:\\Users\\opera\\sistema-chamados-faculdade\\SistemaChamados\.Mobile\\SistemaChamados\.Mobile\.csproj"', '$mobileProjectPath = Join-Path (Split-Path $PSScriptRoot -Parent) "SistemaChamados.Mobile\SistemaChamados.Mobile.csproj"'
    $newContent = $newContent -replace '\$solutionPath = "C:\\Users\\opera\\sistema-chamados-faculdade\\sistema-chamados-faculdade\\sistema-chamados-faculdade\.sln"', '$solutionPath = Join-Path $PSScriptRoot "..\SistemaChamados.sln"'
    
    if ($content -ne $newContent) {
        Set-Content $file $newContent -NoNewline
        Write-Host "   ✅ Corrigido!" -ForegroundColor Green
        $fixes++
    } else {
        Write-Host "   ⚠️  Já estava correto" -ForegroundColor Gray
    }
} else {
    Write-Host "   ⚠️  Arquivo não encontrado (opcional)" -ForegroundColor Yellow
    $warnings++
}

# ========================================
# 4. Corrigir Backend\start-api.ps1
# ========================================
Write-Host "[4/7] Corrigindo Backend\start-api.ps1..." -ForegroundColor Yellow

$file = ".\Backend\start-api.ps1"
if (Test-Path $file) {
    Copy-Item $file "$backupFolder\start-api.ps1.bak"
    
    $content = Get-Content $file -Raw
    $newContent = $content -replace 'Set-Location "c:\\Users\\opera\\sistema-chamados-faculdade\\sistema-chamados-faculdade\\Backend"', 'Set-Location $PSScriptRoot'
    
    if ($content -ne $newContent) {
        Set-Content $file $newContent -NoNewline
        Write-Host "   ✅ Corrigido!" -ForegroundColor Green
        $fixes++
    } else {
        Write-Host "   ⚠️  Já estava correto" -ForegroundColor Gray
    }
} else {
    Write-Host "   ⚠️  Arquivo não encontrado (opcional)" -ForegroundColor Yellow
    $warnings++
}

# ========================================
# 5. Corrigir IniciarAPIBackground.ps1
# ========================================
Write-Host "[5/7] Corrigindo IniciarAPIBackground.ps1..." -ForegroundColor Yellow

$file = ".\IniciarAPIBackground.ps1"
if (Test-Path $file) {
    Copy-Item $file "$backupFolder\IniciarAPIBackground.ps1.bak"
    
    $content = Get-Content $file -Raw
    $newContent = $content -replace 'Set-Location "C:\\Users\\opera\\sistema-chamados-faculdade\\sistema-chamados-faculdade\\Backend"', '$backendPath = Join-Path $PSScriptRoot "Backend"; Set-Location $backendPath'
    
    if ($content -ne $newContent) {
        Set-Content $file $newContent -NoNewline
        Write-Host "   ✅ Corrigido!" -ForegroundColor Green
        $fixes++
    } else {
        Write-Host "   ⚠️  Já estava correto" -ForegroundColor Gray
    }
} else {
    Write-Host "   ⚠️  Arquivo não encontrado (opcional)" -ForegroundColor Yellow
    $warnings++
}

# ========================================
# 6. Corrigir Scripts\Database\InicializarBanco.ps1
# ========================================
Write-Host "[6/7] Corrigindo Scripts\Database\InicializarBanco.ps1..." -ForegroundColor Yellow

$file = ".\Scripts\Database\InicializarBanco.ps1"
if (Test-Path $file) {
    Copy-Item $file "$backupFolder\InicializarBanco.ps1.bak"
    
    $content = Get-Content $file -Raw
    $newContent = $content -replace '\$backendPath = "c:\\Users\\opera\\sistema-chamados-faculdade\\sistema-chamados-faculdade\\Backend"', '$backendPath = Join-Path (Split-Path $PSScriptRoot -Parent | Split-Path -Parent) "Backend"'
    
    if ($content -ne $newContent) {
        Set-Content $file $newContent -NoNewline
        Write-Host "   ✅ Corrigido!" -ForegroundColor Green
        $fixes++
    } else {
        Write-Host "   ⚠️  Já estava correto" -ForegroundColor Gray
    }
} else {
    Write-Host "   ⚠️  Arquivo não encontrado (opcional)" -ForegroundColor Yellow
    $warnings++
}

# ========================================
# 7. Verificar .env e .gitignore
# ========================================
Write-Host "[7/7] Verificando segurança do .env..." -ForegroundColor Yellow

$envFile = ".\Backend\.env"
$gitignoreFile = ".\.gitignore"

if (Test-Path $envFile) {
    if (Test-Path $gitignoreFile) {
        $gitignoreContent = Get-Content $gitignoreFile -Raw
        if ($gitignoreContent -match "\.env") {
            Write-Host "   ✅ .env está protegido no .gitignore" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  AVISO: .env não está no .gitignore" -ForegroundColor Yellow
            $warnings++
        }
    }
    
    $envContent = Get-Content $envFile -Raw
    if ($envContent -match "GEMINI_API_KEY") {
        Write-Host "   ✅ Chave Gemini encontrada no .env" -ForegroundColor Green
    }
} else {
    Write-Host "   ⚠️  .env não encontrado (use .env.example)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  CORREÇÃO CONCLUÍDA!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "📊 Estatísticas:" -ForegroundColor Cyan
Write-Host "   ✅ Arquivos corrigidos: $fixes" -ForegroundColor Green
Write-Host "   ⚠️  Avisos: $warnings" -ForegroundColor Yellow
Write-Host ""

Write-Host "📁 Backup salvo em:" -ForegroundColor Cyan
Write-Host "   $backupFolder" -ForegroundColor White
Write-Host ""

if ($fixes -gt 0) {
    Write-Host "✨ Scripts agora são portáteis!" -ForegroundColor Green
    Write-Host ""
}

Write-Host "Para mais detalhes, leia: .\PORTABILIDADE.md" -ForegroundColor Cyan
Write-Host ""
