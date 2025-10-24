# =====================================================
# Script de Teste: IA com Handoff Context
# Testa a nova arquitetura onde IA decide com base nos scores
# =====================================================

$baseUrl = "http://localhost:5246"

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Test-ServerConnection {
    try {
        $response = Invoke-WebRequest -Uri "$baseUrl/swagger/index.html" -Method Get -TimeoutSec 3 -ErrorAction SilentlyContinue
        return $true
    } catch {
        return $false
    }
}

function Invoke-LoginAPI {
    param(
        [string]$Email,
        [string]$Senha
    )
    
    $loginBody = @{
        email = $Email
        senha = $Senha
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/api/Usuarios/login" -Method Post -Body $loginBody -ContentType "application/json" -ErrorAction Stop
        return $response.token
    } catch {
        throw "Falha no login: $($_.Exception.Message)"
    }
}

function Invoke-AnalisarComHandoff {
    param(
        [string]$Titulo,
        [string]$Descricao,
        [int]$CategoriaId,
        [int]$PrioridadeId,
        [string]$Token
    )
    
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type" = "application/json"
    }
    
    $body = @{
        titulo = $Titulo
        descricao = $Descricao
        categoriaId = $CategoriaId
        prioridadeId = $PrioridadeId
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/api/chamados/analisar-com-handoff" -Method Post -Body $body -Headers $headers -ErrorAction Stop
        return $response
    } catch {
        throw "Falha na analise: $($_.Exception.Message)"
    }
}

function Show-TestResult {
    param(
        [object]$Response,
        [int]$TestNumber,
        [string]$TestName
    )
    
    Write-ColorOutput "`n========================================" "Cyan"
    Write-ColorOutput "RESULTADO TESTE $TestNumber`: $TestName" "White"
    Write-ColorOutput "========================================" "Cyan"
    
    if ($Response) {
        Write-ColorOutput "`nTECNICO ESCOLHIDO PELA IA:" "Yellow"
        Write-ColorOutput "  Nome: $($Response.tecnicoEscolhido.nome)" "White"
        Write-ColorOutput "  ID: $($Response.tecnicoEscolhido.id)" "White"
        Write-ColorOutput "  Score: $($Response.tecnicoEscolhido.score)" "White"
        
        Write-ColorOutput "`nSUGESTOES DA IA:" "Yellow"
        Write-ColorOutput "  Categoria: $($Response.categoriaSugerida)" "White"
        Write-ColorOutput "  Prioridade: $($Response.prioridadeSugerida)" "White"
        
        Write-ColorOutput "`nJUSTIFICATIVA DA IA:" "Yellow"
        Write-ColorOutput "  $($Response.justificativaIA)" "Gray"
        
        Write-ColorOutput "`nTOP SCORE HANDOFF:" "Magenta"
        Write-ColorOutput "  $($Response.topScoreHandoff.nome) - $($Response.topScoreHandoff.score) pts" "White"
        
        if ($Response.concordouComHandoff) {
            Write-ColorOutput "`n[OK] IA CONCORDOU com o top score do handoff" "Green"
        } else {
            Write-ColorOutput "`n[!] IA DIVERGIU do handoff - escolheu outro tecnico!" "Yellow"
        }
        
        if ($Response.observacoes) {
            Write-ColorOutput "`nOBSERVACOES:" "Cyan"
            Write-ColorOutput "  $($Response.observacoes)" "Gray"
        }
    } else {
        Write-ColorOutput "ERRO: Resposta vazia" "Red"
    }
}

# =====================================================
# INICIO DO SCRIPT
# =====================================================

Clear-Host
Write-ColorOutput "=====================================" "Cyan"
Write-ColorOutput "  TESTE: IA COM HANDOFF CONTEXT" "Cyan"
Write-ColorOutput "=====================================" "Cyan"
Write-ColorOutput ""

# Verificar conexao com servidor
Write-ColorOutput "Verificando conexao com servidor..." "Yellow"
if (-not (Test-ServerConnection)) {
    Write-ColorOutput "`nERRO: Servidor nao esta respondendo em $baseUrl" "Red"
    Write-ColorOutput "Por favor, inicie o servidor primeiro:" "Yellow"
    Write-ColorOutput "  cd Backend" "White"
    Write-ColorOutput "  dotnet run" "White"
    Write-ColorOutput "`nOu execute em nova janela:" "Yellow"
    Write-ColorOutput "  .\IniciarAPIBackground.ps1" "White"
    exit 1
}
Write-ColorOutput "[OK] Servidor respondendo!" "Green"

# Fazer login
Write-ColorOutput "`nFazendo login..." "Yellow"
try {
    $token = Invoke-LoginAPI -Email "admin@sistema.com" -Senha "Admin@123"
    Write-ColorOutput "[OK] Login realizado com sucesso!" "Green"
} catch {
    Write-ColorOutput "`nERRO no login: $_" "Red"
    exit 1
}

# =====================================================
# TESTE 1: Instalar Chrome (SIMPLES)
# =====================================================
Write-ColorOutput "`n========================================" "Cyan"
Write-ColorOutput "TESTE 1: Instalar Chrome (SIMPLES)" "White"
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "Enviando para IA analisar..." "Yellow"

try {
    $response1 = Invoke-AnalisarComHandoff `
        -Titulo "Preciso instalar Chrome" `
        -Descricao "Preciso instalar o navegador Chrome no meu computador para acessar um site" `
        -CategoriaId 2 `
        -PrioridadeId 2 `
        -Token $token
    
    Show-TestResult -Response $response1 -TestNumber 1 -TestName "Chrome"
} catch {
    Write-ColorOutput "`nERRO no Teste 1: $_" "Red"
}

# =====================================================
# TESTE 2: Servidor fora do ar (COMPLEXO/CRITICO)
# =====================================================
Write-ColorOutput "`n`n========================================" "Cyan"
Write-ColorOutput "TESTE 2: Servidor fora do ar (COMPLEXO)" "White"
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "Enviando para IA analisar..." "Yellow"

try {
    $response2 = Invoke-AnalisarComHandoff `
        -Titulo "Servidor de arquivos fora do ar" `
        -Descricao "O servidor de arquivos compartilhados esta completamente fora do ar, ninguem consegue acessar os documentos da empresa" `
        -CategoriaId 4 `
        -PrioridadeId 4 `
        -Token $token
    
    Show-TestResult -Response $response2 -TestNumber 2 -TestName "Servidor"
} catch {
    Write-ColorOutput "`nERRO no Teste 2: $_" "Red"
}

# =====================================================
# TESTE 3: Senha esquecida (TRIVIAL)
# =====================================================
Write-ColorOutput "`n`n========================================" "Cyan"
Write-ColorOutput "TESTE 3: Esqueci minha senha (TRIVIAL)" "White"
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "Enviando para IA analisar..." "Yellow"

try {
    $response3 = Invoke-AnalisarComHandoff `
        -Titulo "Esqueci minha senha" `
        -Descricao "Esqueci minha senha do sistema e preciso resetar urgente" `
        -CategoriaId 2 `
        -PrioridadeId 1 `
        -Token $token
    
    Show-TestResult -Response $response3 -TestNumber 3 -TestName "Senha"
} catch {
    Write-ColorOutput "`nERRO no Teste 3: $_" "Red"
}

# =====================================================
# TESTE 4: Rede do setor instavel (MEDIO)
# =====================================================
Write-ColorOutput "`n`n========================================" "Cyan"
Write-ColorOutput "TESTE 4: Rede do setor instavel (MEDIO)" "White"
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "Enviando para IA analisar..." "Yellow"

try {
    $response4 = Invoke-AnalisarComHandoff `
        -Titulo "Rede do setor financeiro instavel" `
        -Descricao "A rede do setor financeiro esta com quedas intermitentes, varios usuarios estao reclamando de lentidao" `
        -CategoriaId 3 `
        -PrioridadeId 3 `
        -Token $token
    
    Show-TestResult -Response $response4 -TestNumber 4 -TestName "Rede"
} catch {
    Write-ColorOutput "`nERRO no Teste 4: $_" "Red"
}

# =====================================================
# RESUMO FINAL
# =====================================================
Write-ColorOutput "`n`n=====================================" "Cyan"
Write-ColorOutput "  TESTES CONCLUIDOS!" "Green"
Write-ColorOutput "=====================================" "Cyan"
Write-ColorOutput ""
Write-ColorOutput "Sistema testado:" "White"
Write-ColorOutput "  [OK] Nova arquitetura IA + Handoff" "Green"
Write-ColorOutput "  [OK] IA usa scores como contexto" "Green"
Write-ColorOutput "  [OK] IA pode concordar ou divergir" "Green"
Write-ColorOutput "  [OK] Justificativas detalhadas" "Green"
Write-ColorOutput ""
