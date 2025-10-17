# 🤖 Configuração do Gemini AI - Sistema de Chamados

## ✅ O Que Foi Implementado

### 1. **Serviço Gemini Criado** (`Services/GeminiService.cs`)
- Integração direta com a API do Google Gemini
- Lê a chave `GEMINI_API_KEY` do arquivo `.env`
- Envia descrição do problema para análise
- Retorna categoria, prioridade, título sugerido e justificativa

### 2. **AIService Atualizado** (`Services/AIService.cs`)
- **ANTES:** Usava lógica de palavras-chave (simulação)
- **AGORA:** Chama obrigatoriamente o `GeminiService`
- Se o Gemini falhar, retorna erro 500 (não há fallback)
- Inclui atribuição automática de técnico especialista

### 3. **Controller Modificado** (`API/Controllers/ChamadosController.cs`)
- Endpoint `POST /api/chamados` **sempre usa Gemini AI**
- Categoria e Prioridade são **opcionais** no request
- Se não fornecidas, o Gemini decide automaticamente

### 4. **DTOs Atualizados**
- `CriarChamadoRequestDto`: CategoriaId e PrioridadeId agora são opcionais (`int?`)
- `AnaliseIADto`: Adicionados campos `TituloSugerido`, `Justificativa`, `TecnicoId`, `TecnicoNome`

### 5. **Configuração `.env`**
```
GEMINI_API_KEY="AIzaSyBcS7W8U_xIAYgnOTc9YyhrBTWKhsRj5eA"
```

### 6. **Registrado no `program.cs`**
```csharp
builder.Services.AddScoped<IOpenAIService, GeminiService>();
builder.Services.AddHttpClient<IOpenAIService, GeminiService>();
```

## 🔄 Fluxo Atual

```
1. Usuário cria chamado com Título e Descrição
   ↓
2. API chama AIService.AnalisarChamadoAsync()
   ↓
3. AIService chama GeminiService.AnalisarChamadoAsync()
   ↓
4. Gemini analisa o texto e retorna:
   - CategoriaId
   - PrioridadeId  
   - TituloSugerido
   - Justificativa
   ↓
5. HandoffService atribui técnico especialista
   ↓
6. Chamado é salvo com os dados da IA
```

## 🚨 Status Atual

### ❌ **Problema Identificado:**
- Erro 500 ao criar chamado
- Provável causa: Gemini Service não está conseguindo se comunicar com a API do Google
- Possíveis motivos:
  1. Chave da API inválida ou expirada
  2. Formato da requisição incorreto
  3. Modelo `gemini-pro` não disponível
  4. Problema de rede/firewall

### ✅ **O Que Está Funcionando:**
- Login
- Obtenção de JWT token
- Listagem de categorias/prioridades
- Estrutura do código está correta

## 📝 Próximos Passos para Resolver

### Opção 1: Verificar Logs da API
Na janela PowerShell onde a API está rodando, procure por:
```
fail: SistemaChamados.Services.GeminiService[0]
      Erro na API do Gemini: ...
```

### Opção 2: Testar Chave do Gemini Diretamente
```powershell
$apiKey = "AIzaSyBcS7W8U_xIAYgnOTc9YyhrBTWKhsRj5eA"
$url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey"
$body = @{
    contents = @(
        @{
            parts = @(
                @{ text = "Olá, você está funcionando?" }
            )
        }
    )
} | ConvertTo-Json -Depth 5

Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
```

### Opção 3: Adicionar Fallback Temporário
Se o Gemini continuar falhando, posso adicionar um fallback para usar lógica de palavras-chave enquanto resolve o problema da API.

## 🔑 Chave da API

**GEMINI_API_KEY atual:** `AIzaSyBcS7W8U_xIAYgnOTc9YyhrBTWKhsRj5eA`

Para obter/verificar sua chave:
1. Acesse: https://makersuite.google.com/app/apikey
2. Crie ou copie sua API Key
3. Atualize no arquivo `.env`

## 📋 Comandos Úteis

### Iniciar API:
```powershell
cd c:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade
Start-Process powershell -ArgumentList "-NoExit", "-Command", "dotnet run" -WindowStyle Normal
```

### Obter Token:
```powershell
.\ObterToken.ps1
```

### Criar Chamado (quando estiver funcionando):
```powershell
$token = "SEU_TOKEN_AQUI"
$headers = @{ Authorization = "Bearer $token" }
$body = @{
    Titulo = "Problema no computador"
    Descricao = "Meu computador não liga"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5246/api/chamados" -Method Post -Headers $headers -Body $body -ContentType "application/json"
```

## 🎯 Objetivo Final

Quando tudo estiver funcionando:
- ✅ Usuário cria chamado só com título e descrição
- ✅ Gemini AI analisa automaticamente
- ✅ Sistema atribui categoria, prioridade e técnico
- ✅ Tudo sem intervenção manual

---

**Última atualização:** 17/10/2025
**Status:** Aguardando validação da chave do Gemini AI
