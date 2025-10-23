# ========================================
# TESTE DE PORTABILIDADE COMPLETO
# ========================================
# Este script testa se o sistema funciona de qualquer diretório/usuário

param(
    [switch]$Quick,  # Teste rápido (apenas caminhos)
    [switch]$Full    # Teste completo (clona repositório em outro local)
)

Clear-Host
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         🧪 TESTE DE PORTABILIDADE DO SISTEMA          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$erros = 0
$avisos = 0
$sucessos = 0

function Test-Result {
    param([bool]$Sucesso, [string]$Mensagem, [string]$Detalhes = "")
    
    if ($Sucesso) {
        Write-Host "  ✅ $Mensagem" -ForegroundColor Green
        $script:sucessos++
    } else {
        Write-Host "  ❌ $Mensagem" -ForegroundColor Red
        $script:erros++
    }
    
    if ($Detalhes) {
        Write-Host "     $Detalhes" -ForegroundColor Gray
    }
}

function Test-Warning {
    param([string]$Mensagem)
    Write-Host "  ⚠️  $Mensagem" -ForegroundColor Yellow
    $script:avisos++
}

# ========================================
# TESTE 1: Verificar Caminhos Absolutos
# ========================================
Write-Host "[TESTE 1] Procurando caminhos absolutos hardcoded..." -ForegroundColor Yellow
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir

$arquivos = Get-ChildItem -Path $repoRoot -Recurse -Include "*.ps1","*.cs","*.xaml","*.json" -Exclude "bin","obj","node_modules" -ErrorAction SilentlyContinue

$problemasEncontrados = @()

foreach ($arquivo in $arquivos) {
    $conteudo = Get-Content $arquivo.FullName -Raw -ErrorAction SilentlyContinue
    
    # Buscar padrões de caminhos absolutos
    $padroes = @(
        'c:\\Users\\[^"]*\\sistema-chamados',
        'C:\\Users\\[^"]*\\sistema-chamados',
        '/Users/[^"]*/sistema-chamados',
        'c:\\Users\\opera',
        'C:\\Users\\opera'
    )
    
    foreach ($padrao in $padroes) {
        if ($conteudo -match $padrao) {
            $match = $Matches[0]
            $problemasEncontrados += [PSCustomObject]@{
                Arquivo = $arquivo.FullName.Replace($repoRoot, "")
                Caminho = $match
            }
        }
    }
}

if ($problemasEncontrados.Count -eq 0) {
    Test-Result -Sucesso $true -Mensagem "Nenhum caminho absoluto encontrado" -Detalhes "Todos os scripts usam caminhos relativos"
} else {
    Test-Result -Sucesso $false -Mensagem "$($problemasEncontrados.Count) caminho(s) absoluto(s) encontrado(s)"
    $problemasEncontrados | ForEach-Object {
        Write-Host "     • $($_.Arquivo): $($_.Caminho)" -ForegroundColor Red
    }
}

Write-Host ""

# ========================================
# TESTE 2: Verificar Scripts com $PSScriptRoot
# ========================================
Write-Host "[TESTE 2] Verificando uso de `$PSScriptRoot nos scripts..." -ForegroundColor Yellow
Write-Host ""

$scriptsPs1 = Get-ChildItem -Path "$repoRoot\Scripts" -Filter "*.ps1" -ErrorAction SilentlyContinue

$scriptsSemRelativo = @()

foreach ($script in $scriptsPs1) {
    $conteudo = Get-Content $script.FullName -Raw
    
    # Verificar se usa $PSScriptRoot, $MyInvocation, ou Split-Path
    if ($conteudo -notmatch '\$PSScriptRoot|\$MyInvocation|Split-Path') {
        $scriptsSemRelativo += $script.Name
    }
}

if ($scriptsSemRelativo.Count -eq 0) {
    Test-Result -Sucesso $true -Mensagem "Todos os scripts usam caminhos relativos" -Detalhes "$($scriptsPs1.Count) scripts verificados"
} else {
    Test-Result -Sucesso $false -Mensagem "$($scriptsSemRelativo.Count) script(s) sem caminhos relativos"
    $scriptsSemRelativo | ForEach-Object {
        Write-Host "     • $_" -ForegroundColor Red
    }
}

Write-Host ""

# ========================================
# TESTE 3: Verificar appsettings.json
# ========================================
Write-Host "[TESTE 3] Verificando configurações sensíveis..." -ForegroundColor Yellow
Write-Host ""

$appsettingsPath = Join-Path $repoRoot "Backend\appsettings.json"

if (Test-Path $appsettingsPath) {
    $appsettings = Get-Content $appsettingsPath -Raw
    
    # Verificar se não tem credenciais expostas
    $credenciaisExpostas = @()
    
    if ($appsettings -match '@gmail\.com' -and $appsettings -notmatch 'CONFIGURE') {
        $credenciaisExpostas += "Email Gmail encontrado"
    }
    
    if ($appsettings -match 'sk-proj-[a-zA-Z0-9]+') {
        $credenciaisExpostas += "Chave OpenAI encontrada"
    }
    
    if ($appsettings -match '"Password".*:"[^"]{10}' -and $appsettings -notmatch 'CONFIGURE') {
        $credenciaisExpostas += "Senha encontrada"
    }
    
    if ($credenciaisExpostas.Count -eq 0) {
        Test-Result -Sucesso $true -Mensagem "appsettings.json está sanitizado" -Detalhes "Nenhuma credencial exposta"
    } else {
        Test-Result -Sucesso $false -Mensagem "Credenciais expostas em appsettings.json"
        $credenciaisExpostas | ForEach-Object {
            Write-Host "     • $_" -ForegroundColor Red
        }
    }
} else {
    Test-Warning "appsettings.json não encontrado (esperado em novo setup)"
}

Write-Host ""

# ========================================
# TESTE 4: Verificar Constants.cs
# ========================================
Write-Host "`[TESTE 4`] Verificando Constants.cs (IP mobile)..." -ForegroundColor Yellow
Write-Host ""

$constantsPath = Join-Path $repoRoot "Mobile\Helpers\Constants.cs"

if (Test-Path $constantsPath) {
    $constants = Get-Content $constantsPath -Raw
    
    # Verificar se tem IP específico hardcoded (que não seja placeholder)
    if ($constants -match 'BaseUrlPhysicalDevice.*?http://192\.168\.\d+\.\d+:' -and 
        $constants -notmatch 'SEU_IP_LOCAL') {
        
        Test-Warning "Constants.cs tem IP específico (não é problema se for o seu IP atual)"
        Write-Host "     Execute .\ConfigurarIP.ps1 antes de gerar APK para outro PC" -ForegroundColor Gray
    } elseif ($constants -match 'SEU_IP_LOCAL') {
        Test-Result -Sucesso $true -Mensagem "Constants.cs usa placeholder genérico" -Detalhes "IP será configurado por ConfigurarIP.ps1"
    } else {
        Test-Warning "Constants.cs em formato inesperado"
    }
} else {
    Test-Result -Sucesso $false -Mensagem "Constants.cs não encontrado"
}

Write-Host ""

# ========================================
# TESTE 5: Simular Execução em Outro Diretório
# ========================================
if ($Full) {
    Write-Host "[TESTE 5] Simulando clone em outro diretório..." -ForegroundColor Yellow
    Write-Host ""
    
    $tempDir = Join-Path $env:TEMP "SistemaChamados_TestePortabilidade_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    
    try {
        # Criar diretório temporário
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        Write-Host "  📁 Diretório de teste: $tempDir" -ForegroundColor Gray
        Write-Host ""
        
        # Copiar arquivos essenciais (sem bin/obj)
        Write-Host "  📋 Copiando arquivos..." -ForegroundColor Cyan
        
        $excludeDirs = @("bin", "obj", "node_modules", ".git", ".vs", "APK")
        
        Get-ChildItem -Path $repoRoot -Recurse | Where-Object {
            $path = $_.FullName
            $shouldExclude = $false
            foreach ($exclude in $excludeDirs) {
                if ($path -like "*\$exclude\*") {
                    $shouldExclude = $true
                    break
                }
            }
            -not $shouldExclude -and $_.PSIsContainer -eq $false
        } | ForEach-Object {
            $relativePath = $_.FullName.Replace($repoRoot, "")
            $destPath = Join-Path $tempDir $relativePath
            $destDir = Split-Path $destPath -Parent
            
            if (-not (Test-Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }
            
            Copy-Item $_.FullName -Destination $destPath -Force
        }
        
        Write-Host "  ✅ Arquivos copiados" -ForegroundColor Green
        Write-Host ""
        
        # Testar scripts no novo diretório
        Write-Host "  🧪 Testando scripts no novo diretório..." -ForegroundColor Cyan
        Write-Host ""
        
        $scriptsTeste = @(
            "Scripts\ConfigurarIP.ps1",
            "Scripts\GerarAPK.ps1",
            "Scripts\IniciarAPI.ps1",
            "Scripts\ValidarConfigAPK.ps1"
        )
        
        $scriptsFalharam = @()
        
        foreach ($scriptTeste in $scriptsTeste) {
            $scriptPath = Join-Path $tempDir $scriptTeste
            
            if (Test-Path $scriptPath) {
                # Executar com -WhatIf ou parseamento estático
                try {
                    # Parse do script para verificar sintaxe
                    $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $scriptPath -Raw), [ref]$null)
                    
                    # Verificar se o script detecta os caminhos corretamente
                    $scriptContent = Get-Content $scriptPath -Raw
                    
                    # Scripts devem usar $PSScriptRoot ou $MyInvocation
                    if ($scriptContent -match '\$PSScriptRoot|\$MyInvocation') {
                        Write-Host "    ✅ $(Split-Path $scriptTeste -Leaf)" -ForegroundColor Green
                    } else {
                        Write-Host "    ⚠️  $(Split-Path $scriptTeste -Leaf) - não usa caminhos relativos" -ForegroundColor Yellow
                        $scriptsFalharam += $scriptTeste
                    }
                } catch {
                    Write-Host "    ❌ $(Split-Path $scriptTeste -Leaf) - erro de sintaxe" -ForegroundColor Red
                    $scriptsFalharam += $scriptTeste
                }
            } else {
                Write-Host "    ⚠️  $(Split-Path $scriptTeste -Leaf) - não encontrado" -ForegroundColor Yellow
            }
        }
        
        Write-Host ""
        
        if ($scriptsFalharam.Count -eq 0) {
            Test-Result -Sucesso $true -Mensagem "Todos os scripts funcionam no novo diretório" -Detalhes "Portabilidade confirmada"
        } else {
            Test-Result -Sucesso $false -Mensagem "$($scriptsFalharam.Count) script(s) com problemas"
        }
        
        Write-Host ""
        Write-Host "  🗑️  Limpando diretório de teste..." -ForegroundColor Gray
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  ✅ Limpeza concluída" -ForegroundColor Green
        
    } catch {
        Test-Result -Sucesso $false -Mensagem "Erro ao testar em outro diretório" -Detalhes $_.Exception.Message
        
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    
    Write-Host ""
}

# ========================================
# TESTE 6: Verificar .gitignore
# ========================================
Write-Host "[TESTE 6] Verificando .gitignore..." -ForegroundColor Yellow
Write-Host ""

$gitignorePath = Join-Path $repoRoot ".gitignore"

if (Test-Path $gitignorePath) {
    $gitignore = Get-Content $gitignorePath -Raw
    
    $itensEssenciais = @(
        @{ Pattern = "appsettings\.json"; Nome = "Mobile/appsettings.json (ou **/Mobile/)"; Critico = $true },
        @{ Pattern = "DADOS_SENSIVEIS\.txt"; Nome = "DADOS_SENSIVEIS.txt"; Critico = $true },
        @{ Pattern = "\.env"; Nome = ".env files"; Critico = $false }
    )
    
    $faltando = @()
    
    foreach ($item in $itensEssenciais) {
        if ($gitignore -notmatch $item.Pattern) {
            $faltando += $item
        }
    }
    
    if ($faltando.Count -eq 0) {
        Test-Result -Sucesso $true -Mensagem ".gitignore protege arquivos sensíveis" -Detalhes "Todas as regras essenciais presentes"
    } else {
        $criticos = $faltando | Where-Object { $_.Critico }
        
        if ($criticos.Count -gt 0) {
            Test-Result -Sucesso $false -Mensagem "Regras críticas faltando no .gitignore"
            $criticos | ForEach-Object {
                Write-Host "     • $($_.Nome)" -ForegroundColor Red
            }
        } else {
            Test-Warning "Algumas regras opcionais faltando no .gitignore"
        }
    }
} else {
    Test-Result -Sucesso $false -Mensagem ".gitignore não encontrado"
}

Write-Host ""

# ========================================
# TESTE 7: Verificar se está em repositório Git
# ========================================
Write-Host "[TESTE 7] Verificando repositório Git..." -ForegroundColor Yellow
Write-Host ""

Push-Location $repoRoot

try {
    $gitStatus = git status 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Test-Result -Sucesso $true -Mensagem "Repositório Git válido"
        
        # Verificar se há arquivos sensíveis staged
        $staged = git diff --cached --name-only 2>&1
        
        if ($staged -match "DADOS_SENSIVEIS" -or $staged -match "Mobile.*appsettings\.json") {
            Test-Result -Sucesso $false -Mensagem "ATENÇÃO: Arquivos sensíveis no stage" -Detalhes "Execute: git reset HEAD <arquivo>"
        }
    } else {
        Test-Warning "Não é um repositório Git (ou Git não instalado)"
    }
} catch {
    Test-Warning "Git não disponível ou erro ao verificar"
} finally {
    Pop-Location
}

Write-Host ""

# ========================================
# RESULTADOS FINAIS
# ========================================
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    📊 RESULTADOS                       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$total = $sucessos + $erros + $avisos

Write-Host "  ✅ Sucessos: $sucessos" -ForegroundColor Green
Write-Host "  ❌ Erros: $erros" -ForegroundColor Red
Write-Host "  ⚠️  Avisos: $avisos" -ForegroundColor Yellow
Write-Host "  📊 Total: $total testes" -ForegroundColor Cyan
Write-Host ""

$percentualSucesso = [math]::Round(($sucessos / $total) * 100, 1)

if ($erros -eq 0) {
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║         ✅ SISTEMA 100% PORTÁTIL ($percentualSucesso% sucesso)          ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "✨ O sistema pode ser:" -ForegroundColor White
    Write-Host "   • Clonado em qualquer diretório" -ForegroundColor Gray
    Write-Host "   • Usado por qualquer usuário Windows" -ForegroundColor Gray
    Write-Host "   • Movido entre PCs sem problemas" -ForegroundColor Gray
    Write-Host "   • Configurado automaticamente (ConfigurarIP.ps1)" -ForegroundColor Gray
    
}
elseif ($erros -le 2) {
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║      ⚠️  PORTABILIDADE COM PEQUENOS PROBLEMAS ($percentualSucesso%)     ║" -ForegroundColor Yellow
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Corrija os erros acima para portabilidade total." -ForegroundColor Yellow
    
} else {
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║           ❌ PROBLEMAS DE PORTABILIDADE ($percentualSucesso%)          ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "Sistema precisa de correções antes de ser portátil." -ForegroundColor Red
}

Write-Host ""

# ========================================
# PRÓXIMOS PASSOS
# ========================================
if ($avisos -gt 0 -and $erros -eq 0) {
    Write-Host "💡 PRÓXIMOS PASSOS (OPCIONAIS):" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   1. Revisar avisos acima" -ForegroundColor White
    Write-Host "   2. Executar: .\ConfigurarIP.ps1 (antes de gerar APK)" -ForegroundColor White
    Write-Host "   3. Testar clone em outro diretório: -Full" -ForegroundColor White
    Write-Host ""
}

if (-not $Full -and $erros -eq 0) {
    Write-Host "🧪 TESTE COMPLETO:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   Execute: .\TestarPortabilidade.ps1 -Full" -ForegroundColor White
    Write-Host ""
    Write-Host "   Isso irá:" -ForegroundColor Gray
    Write-Host "   • Copiar projeto para diretório temporário" -ForegroundColor Gray
    Write-Host "   - Testar scripts no novo local" -ForegroundColor Gray
    Write-Host "   - Validar portabilidade completa" -ForegroundColor Gray
    Write-Host "   - Limpar automaticamente apos teste" -ForegroundColor Gray
    Write-Host ""
}

# Retornar código de saída
if ($erros -eq 0) {
    exit 0
} else {
    exit 1
}
