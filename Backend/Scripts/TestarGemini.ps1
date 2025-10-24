# ═══════════════════════════════════════════════════════════════
# Script de Diagnóstico Completo da API Gemini
# ═══════════════════════════════════════════════════════════════

Write-Host "`n╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     🔍 DIAGNÓSTICO COMPLETO - GEMINI API                     ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# ============ TESTE 1: VERIFICAR ARQUIVO .ENV ============
Write-Host "📁 [TESTE 1] Verificando arquivo .env..." -ForegroundColor Yellow
$envPath = "$PSScriptRoot\..\.env"

if (Test-Path $envPath) {
    Write-Host "   ✅ Arquivo .env encontrado em: $envPath" -ForegroundColor Green
    
    $envContent = Get-Content $envPath -Raw
    if ($envContent -match 'GEMINI_API_KEY\s*=\s*"?([^"]+)"?') {
        $apiKey = $matches[1]
        Write-Host "   ✅ GEMINI_API_KEY encontrada" -ForegroundColor Green
        Write-Host "      Valor: $($apiKey.Substring(0, 10))***" -ForegroundColor Gray
        Write-Host "      Tamanho: $($apiKey.Length) caracteres" -ForegroundColor Gray
        
        if ($apiKey.StartsWith("AIza")) {
            Write-Host "      Formato: ✅ Válido (começa com AIza)" -ForegroundColor Green
        } else {
            Write-Host "      ⚠️ AVISO: Chave não começa com 'AIza' (formato suspeito)" -ForegroundColor Red
        }
    } else {
        Write-Host "   ❌ ERRO: GEMINI_API_KEY não encontrada no .env!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "   ❌ ERRO: Arquivo .env não encontrado!" -ForegroundColor Red
    Write-Host "      Caminho esperado: $envPath" -ForegroundColor Gray
    exit 1
}

# ============ TESTE 2: CONECTIVIDADE COM GOOGLE ============
Write-Host "`n🌐 [TESTE 2] Testando conectividade com Google..." -ForegroundColor Yellow

try {
    $googleTest = Invoke-WebRequest -Uri "https://www.google.com" -TimeoutSec 5 -UseBasicParsing
    Write-Host "   ✅ Conexão com Google OK (Status: $($googleTest.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   ❌ ERRO: Não foi possível conectar ao Google" -ForegroundColor Red
    Write-Host "      Mensagem: $($_.Exception.Message)" -ForegroundColor Gray
    Write-Host "      💡 Possível problema de rede ou firewall" -ForegroundColor Yellow
}

# ============ TESTE 3: DNS DA API GEMINI ============
Write-Host "`n🔍 [TESTE 3] Resolvendo DNS da API Gemini..." -ForegroundColor Yellow
$geminiHost = "generativelanguage.googleapis.com"

try {
    $dnsResult = Resolve-DnsName $geminiHost -ErrorAction Stop
    Write-Host "   ✅ DNS resolvido com sucesso!" -ForegroundColor Green
    Write-Host "      Host: $geminiHost" -ForegroundColor Gray
    $dnsResult | Where-Object { $_.Type -eq 'A' } | ForEach-Object {
        Write-Host "      IP: $($_.IPAddress)" -ForegroundColor Gray
    }
} catch {
    Write-Host "   ❌ ERRO: Falha ao resolver DNS!" -ForegroundColor Red
    Write-Host "      Mensagem: $($_.Exception.Message)" -ForegroundColor Gray
    Write-Host "      💡 Possível problema: DNS bloqueado ou firewall" -ForegroundColor Yellow
}

# ============ TESTE 4: REQUISIÇÃO REAL À API GEMINI ============
Write-Host "`n📡 [TESTE 4] Enviando requisição real à API Gemini..." -ForegroundColor Yellow

$testPrompt = "Teste de conectividade. Responda apenas: OK"
$requestBody = @{
    contents = @(
        @{
            parts = @(
                @{ text = $testPrompt }
            )
        }
    )
    generationConfig = @{
        temperature = 0.1
        topK = 1
        topP = 1
        maxOutputTokens = 50
    }
} | ConvertTo-Json -Depth 10

$geminiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$apiKey"

Write-Host "   Modelo: gemini-2.0-flash-exp" -ForegroundColor Gray
Write-Host "   Prompt: $testPrompt" -ForegroundColor Gray

try {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $response = Invoke-RestMethod -Uri $geminiUrl -Method POST -Body $requestBody -ContentType "application/json" -TimeoutSec 30
    $stopwatch.Stop()
    
    Write-Host "   ✅ Requisição bem-sucedida!" -ForegroundColor Green
    Write-Host "      Tempo de resposta: $($stopwatch.ElapsedMilliseconds)ms" -ForegroundColor Gray
    
    # Analisar resposta
    if ($response.candidates) {
        Write-Host "      Candidates: $($response.candidates.Count)" -ForegroundColor Gray
        
        $firstCandidate = $response.candidates[0]
        Write-Host "      Finish Reason: $($firstCandidate.finishReason)" -ForegroundColor Gray
        
        if ($firstCandidate.content.parts) {
            $texto = $firstCandidate.content.parts[0].text
            Write-Host "      ✅ Resposta recebida: $texto" -ForegroundColor Green
        } else {
            Write-Host "      ⚠️ AVISO: Parts vazio!" -ForegroundColor Yellow
        }
    } else {
        Write-Host "      ⚠️ AVISO: Nenhum candidate na resposta!" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "   ❌ ERRO na requisição!" -ForegroundColor Red
    $errorDetails = $_.Exception
    
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "      Status HTTP: $statusCode" -ForegroundColor Gray
        
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $errorBody = $reader.ReadToEnd() | ConvertFrom-Json
            
            Write-Host "      Código: $($errorBody.error.code)" -ForegroundColor Gray
            Write-Host "      Mensagem: $($errorBody.error.message)" -ForegroundColor Gray
            
            # Diagnóstico específico
            switch ($statusCode) {
                400 { Write-Host "      💡 Erro 400: Requisição malformada ou chave inválida" -ForegroundColor Yellow }
                403 { Write-Host "      💡 Erro 403: Chave sem permissão ou API não habilitada" -ForegroundColor Yellow }
                404 { Write-Host "      💡 Erro 404: Modelo não encontrado ou URL incorreta" -ForegroundColor Yellow }
                429 { Write-Host "      💡 Erro 429: Rate limit excedido (muitas requisições)" -ForegroundColor Yellow }
            }
        } catch {
            Write-Host "      Mensagem: $($_.Exception.Message)" -ForegroundColor Gray
        }
    } else {
        Write-Host "      Mensagem: $($errorDetails.Message)" -ForegroundColor Gray
        Write-Host "      💡 Possível timeout ou problema de rede" -ForegroundColor Yellow
    }
}

# ============ TESTE 5: TESTAR CLASSIFICAÇÃO REAL ============
Write-Host "`n🤖 [TESTE 5] Testando classificação de chamado..." -ForegroundColor Yellow

$chamadoTeste = "Meu notebook não está conectando no Wi-Fi da empresa"
Write-Host "   Problema: $chamadoTeste" -ForegroundColor Gray

$classificationPrompt = "Voce e um sistema de classificacao de chamados de TI. Analise e retorne JSON puro.

PROBLEMA: $chamadoTeste

CATEGORIAS:
ID 1, Nome: Infraestrutura, Descricao: Equipamentos rede e hardware
ID 2, Nome: Sistemas Academicos, Descricao: Erro ou acesso em portais
ID 3, Nome: Conta e Acesso, Descricao: Senha e-mail institucional

PRIORIDADES:
ID 1, Nome: Baixa, Nivel: 1
ID 2, Nome: Media, Nivel: 2
ID 3, Nome: Alta, Nivel: 3

Responda apenas com JSON no formato:
{CategoriaId: numero, CategoriaNome: texto, PrioridadeId: numero, PrioridadeNome: texto, TituloSugerido: texto, Justificativa: texto}"

$classificationBody = @{
    contents = @(
        @{
            parts = @(
                @{ text = $classificationPrompt }
            )
        }
    )
    generationConfig = @{
        temperature = 0.1
        topK = 1
        topP = 1
        maxOutputTokens = 1024
    }
    safetySettings = @(
        @{ category = "HARM_CATEGORY_HARASSMENT"; threshold = "BLOCK_NONE" }
        @{ category = "HARM_CATEGORY_HATE_SPEECH"; threshold = "BLOCK_NONE" }
        @{ category = "HARM_CATEGORY_SEXUALLY_EXPLICIT"; threshold = "BLOCK_NONE" }
        @{ category = "HARM_CATEGORY_DANGEROUS_CONTENT"; threshold = "BLOCK_NONE" }
    )
} | ConvertTo-Json -Depth 10

try {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $response = Invoke-RestMethod -Uri $geminiUrl -Method POST -Body $classificationBody -ContentType "application/json" -TimeoutSec 30
    $stopwatch.Stop()
    
    if ($response.candidates -and $response.candidates[0].content.parts) {
        $texto = $response.candidates[0].content.parts[0].text
        
        Write-Host "   ✅ Classificação recebida!" -ForegroundColor Green
        Write-Host "      Tempo: $($stopwatch.ElapsedMilliseconds)ms" -ForegroundColor Gray
        Write-Host "      Finish Reason: $($response.candidates[0].finishReason)" -ForegroundColor Gray
        Write-Host "`n   📋 Resposta do Gemini:" -ForegroundColor Cyan
        Write-Host "   $($texto.Replace("`n", "`n   "))" -ForegroundColor White
        
        # Tentar parsear JSON
        try {
            $textoLimpo = $texto -replace '```json', '' -replace '```', '' | Out-String | ForEach-Object { $_.Trim() }
            $analise = $textoLimpo | ConvertFrom-Json
            
            Write-Host "`n   ✅ JSON parseado com sucesso!" -ForegroundColor Green
            Write-Host "      Categoria: $($analise.CategoriaNome) (ID: $($analise.CategoriaId))" -ForegroundColor Gray
            Write-Host "      Prioridade: $($analise.PrioridadeNome) (ID: $($analise.PrioridadeId))" -ForegroundColor Gray
            Write-Host "      Título: $($analise.TituloSugerido)" -ForegroundColor Gray
            Write-Host "      Justificativa: $($analise.Justificativa)" -ForegroundColor Gray
        } catch {
            Write-Host "   ⚠️ AVISO: Falha ao parsear JSON!" -ForegroundColor Yellow
            Write-Host "      Mensagem: $($_.Exception.Message)" -ForegroundColor Gray
        }
    } else {
        Write-Host "   ⚠️ AVISO: Resposta vazia ou inválida!" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "   ❌ ERRO na classificação!" -ForegroundColor Red
    Write-Host "      Mensagem: $($_.Exception.Message)" -ForegroundColor Gray
}

# ============ RESUMO FINAL ============
Write-Host "`n╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    📊 RESUMO DO DIAGNÓSTICO                   ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`n✅ Testes concluídos!" -ForegroundColor Green
Write-Host "`nPara testar via API .NET, execute:" -ForegroundColor Yellow
Write-Host "   POST http://localhost:5246/api/chamados" -ForegroundColor White
Write-Host "   Body: { `"titulo`": `"Teste`", `"descricao`": `"Problema com Wi-Fi`", `"usarIA`": true }" -ForegroundColor Gray

Write-Host "`nVerifique os logs detalhados da API em tempo real." -ForegroundColor Cyan
Write-Host ""
