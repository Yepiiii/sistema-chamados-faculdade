# ==============================================================================
# Script: ValidarScripts.ps1
# Descricao: Valida todos os scripts PowerShell do projeto
# Autor: Sistema
# Data: 23/10/2025
# ==============================================================================

$ErrorActionPreference = "Continue"

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    VALIDADOR DE SCRIPTS - Sistema de Chamados" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

$totalScripts = 0
$scriptsValidos = 0
$scriptsComErro = 0
$scriptsComAviso = 0

# Funcao para validar sintaxe de script
function Test-ScriptSyntax {
    param([string]$FilePath)
    
    $errors = $null
    $tokens = $null
    $null = [System.Management.Automation.Language.Parser]::ParseFile(
        $FilePath, 
        [ref]$tokens, 
        [ref]$errors
    )
    
    return @{
        Valid = ($errors.Count -eq 0)
        Errors = $errors
        Tokens = $tokens
    }
}

# Funcao para verificar dependencias do script
function Test-ScriptDependencies {
    param([string]$FilePath, [string]$Content)
    
    $issues = @()
    
    # Verificar referencias a arquivos
    if ($Content -match 'Test-Path\s+"?([^"]+)"?') {
        $paths = [regex]::Matches($Content, 'Test-Path\s+"?([^"\s]+)"?') | ForEach-Object { $_.Groups[1].Value }
        foreach ($path in $paths) {
            # Ignorar variaveis
            if ($path -notmatch '\$') {
                $fullPath = Join-Path (Split-Path $FilePath -Parent) $path
                if (-not (Test-Path $fullPath) -and $path -notmatch '\*') {
                    $issues += "Referencia a arquivo nao encontrado: $path"
                }
            }
        }
    }
    
    # Verificar se usa dotnet
    if ($Content -match 'dotnet\s+') {
        try {
            $null = dotnet --version 2>&1
        } catch {
            $issues += "Requer dotnet CLI (nao encontrado)"
        }
    }
    
    # Verificar se usa adb
    if ($Content -match '\badb\s+') {
        try {
            $null = adb version 2>&1
        } catch {
            $issues += "Requer ADB - Android Debug Bridge (opcional)"
        }
    }
    
    return $issues
}

Write-Host "[*] Iniciando validacao..." -ForegroundColor Yellow
Write-Host ""

# Categorias de scripts
$categorias = @{
    "API" = "Scripts/API"
    "Mobile" = "Scripts/Mobile"
    "Database" = "Scripts/Database"
    "Teste" = "Scripts/Teste"
    "Dev" = "Scripts/Dev"
}

foreach ($catNome in $categorias.Keys) {
    $catPath = $categorias[$catNome]
    
    if (-not (Test-Path $catPath)) {
        Write-Host "[!] Categoria $catNome nao encontrada: $catPath" -ForegroundColor Yellow
        continue
    }
    
    $scripts = Get-ChildItem -Path $catPath -Filter *.ps1 -File
    
    if ($scripts.Count -eq 0) {
        Write-Host "[!] Nenhum script encontrado em $catNome" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host "  CATEGORIA: $catNome ($($scripts.Count) scripts)" -ForegroundColor Yellow
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($script in $scripts) {
        $totalScripts++
        Write-Host "[$totalScripts] Validando: $($script.Name)" -ForegroundColor Cyan
        
        # Teste 1: Sintaxe
        Write-Host "    [1/3] Sintaxe..." -NoNewline
        $syntaxResult = Test-ScriptSyntax -FilePath $script.FullName
        
        if ($syntaxResult.Valid) {
            Write-Host " OK" -ForegroundColor Green
        } else {
            Write-Host " ERRO" -ForegroundColor Red
            $scriptsComErro++
            foreach ($error in $syntaxResult.Errors) {
                Write-Host "        - $($error.Message)" -ForegroundColor Red
            }
            continue
        }
        
        # Teste 2: Dependencias
        Write-Host "    [2/3] Dependencias..." -NoNewline
        $content = Get-Content $script.FullName -Raw
        $depIssues = Test-ScriptDependencies -FilePath $script.FullName -Content $content
        
        if ($depIssues.Count -eq 0) {
            Write-Host " OK" -ForegroundColor Green
        } else {
            Write-Host " AVISOS ($($depIssues.Count))" -ForegroundColor Yellow
            $scriptsComAviso++
            foreach ($issue in $depIssues) {
                Write-Host "        - $issue" -ForegroundColor Yellow
            }
        }
        
        # Teste 3: Estrutura basica
        Write-Host "    [3/3] Estrutura..." -NoNewline
        $temCabecalho = $content -match '#\s*(==+|--+)'
        $temDescricao = $content -match 'Descricao:|Description:'
        $temWriteHost = $content -match 'Write-Host'
        
        $estruturaOk = $temCabecalho -and $temDescricao -and $temWriteHost
        
        if ($estruturaOk) {
            Write-Host " OK" -ForegroundColor Green
            $scriptsValidos++
        } else {
            Write-Host " AVISOS" -ForegroundColor Yellow
            if (-not $temCabecalho) { Write-Host "        - Falta cabecalho" -ForegroundColor Yellow }
            if (-not $temDescricao) { Write-Host "        - Falta descricao" -ForegroundColor Yellow }
            if (-not $temWriteHost) { Write-Host "        - Nao usa Write-Host (sem output)" -ForegroundColor Yellow }
        }
        
        Write-Host ""
    }
}

# Resumo final
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    RESUMO DA VALIDACAO" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Total de scripts: $totalScripts" -ForegroundColor White
Write-Host "  Validos: $scriptsValidos" -ForegroundColor Green
Write-Host "  Com avisos: $scriptsComAviso" -ForegroundColor Yellow
Write-Host "  Com erros: $scriptsComErro" -ForegroundColor Red
Write-Host ""

if ($scriptsComErro -eq 0) {
    Write-Host "==================================================================" -ForegroundColor Green
    Write-Host "    TODOS OS SCRIPTS PASSARAM NA VALIDACAO!" -ForegroundColor Green
    Write-Host "==================================================================" -ForegroundColor Green
} else {
    Write-Host "==================================================================" -ForegroundColor Red
    Write-Host "    ALGUNS SCRIPTS PRECISAM DE CORRECAO" -ForegroundColor Red
    Write-Host "==================================================================" -ForegroundColor Red
}

Write-Host ""

# Testes funcionais sugeridos
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    TESTES FUNCIONAIS RECOMENDADOS" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Para garantir que os scripts funcionam corretamente:" -ForegroundColor White
Write-Host ""

Write-Host "1. API:" -ForegroundColor Cyan
Write-Host "   .\Scripts\API\IniciarAPI.ps1" -ForegroundColor Gray
Write-Host "   (Deve iniciar a API em nova janela)" -ForegroundColor DarkGray
Write-Host ""

Write-Host "2. Mobile:" -ForegroundColor Cyan
Write-Host "   .\Scripts\Mobile\ConfigurarIP.ps1" -ForegroundColor Gray
Write-Host "   (Deve detectar IP e atualizar Constants.cs)" -ForegroundColor DarkGray
Write-Host ""

Write-Host "3. Database:" -ForegroundColor Cyan
Write-Host "   .\Scripts\Database\AnalisarBanco.ps1" -ForegroundColor Gray
Write-Host "   (Deve mostrar estatisticas do banco)" -ForegroundColor DarkGray
Write-Host ""

Write-Host "4. Teste:" -ForegroundColor Cyan
Write-Host "   .\Scripts\Teste\TestarAPI.ps1" -ForegroundColor Gray
Write-Host "   (Requer API rodando)" -ForegroundColor DarkGray
Write-Host ""

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""
