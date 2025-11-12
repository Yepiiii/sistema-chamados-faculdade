# 🚀 Plano de Ação: API com ngrok

## 📋 Checklist de Execução

- [ ] **Etapa 1**: Instalar e configurar ngrok
- [ ] **Etapa 2**: Configurar CORS no Backend
- [ ] **Etapa 3**: Testar Backend localmente
- [ ] **Etapa 4**: Expor Backend com ngrok
- [ ] **Etapa 5**: Atualizar URL no Frontend
- [ ] **Etapa 6**: Testar integração completa

---

## 🎯 Etapa 1: Instalar e Configurar ngrok

### 1.1 Baixar ngrok
1. Acesse: https://ngrok.com/download
2. Faça o download para Windows
3. Extraia o arquivo `ngrok.exe` em uma pasta (ex: `C:\ngrok\`)

### 1.2 Criar conta e obter token
1. Acesse: https://dashboard.ngrok.com/signup
2. Faça cadastro (grátis)
3. Copie seu **Authtoken** em: https://dashboard.ngrok.com/get-started/your-authtoken

### 1.3 Autenticar ngrok
```powershell
# Navegar para a pasta do ngrok
cd C:\ngrok

# Autenticar (cole seu token)
.\ngrok config add-authtoken SEU_TOKEN_AQUI
```

### 1.4 Testar ngrok
```powershell
# Teste básico
.\ngrok http 5246
```

Se aparecer a tela do ngrok com URLs, está funcionando! ✅  
Pressione `Ctrl+C` para parar.

---

## 🔧 Etapa 2: Configurar CORS no Backend

### 2.1 Editar `Backend/program.cs`

Localize a seção de CORS e atualize:

```csharp
// Configuração de CORS - ANTES das rotas
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.WithOrigins(
            "http://localhost:8080",                                    // Desktop local
            "https://sistema-chamados-faculdade.vercel.app",           // Frontend Vercel
            "https://*.ngrok-free.app",                                 // Qualquer URL ngrok
            "https://*.ngrok.io",                                       // Formato antigo ngrok
            "https://*.ngrok.app"                                       // ngrok personalizado
        )
        .SetIsOriginAllowedToAllowWildcardSubdomains()                 // Permitir wildcard
        .AllowAnyHeader()
        .AllowAnyMethod()
        .AllowCredentials();
    });
});
```

### 2.2 Adicionar variável de ambiente para URLs dinâmicas (Opcional)

Edite `Backend/appsettings.json`:

```json
{
  "AllowedOrigins": [
    "http://localhost:8080",
    "https://sistema-chamados-faculdade.vercel.app"
  ]
}
```

E no `program.cs`, carregue dinamicamente:

```csharp
var allowedOrigins = builder.Configuration.GetSection("AllowedOrigins").Get<string[]>() 
    ?? new[] { "http://localhost:8080" };

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.WithOrigins(allowedOrigins)
            .SetIsOriginAllowedToAllowWildcardSubdomains()
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();
        
        // Permitir ngrok em desenvolvimento
        policy.SetIsOriginAllowed(origin => 
            origin.Contains("ngrok", StringComparison.OrdinalIgnoreCase) ||
            allowedOrigins.Contains(origin)
        );
    });
});
```

---

## ✅ Etapa 3: Testar Backend Localmente

### 3.1 Verificar banco de dados
```powershell
# Verificar se SQL Server está rodando
Get-Service -Name "MSSQL*"

# Se não estiver, iniciar
Start-Service -Name "MSSQL$SQLEXPRESS"  # Ajuste o nome se necessário
```

### 3.2 Compilar e rodar Backend
```powershell
cd Backend
dotnet build
dotnet run
```

### 3.3 Testar endpoints
Abra o navegador em:
- `http://localhost:5246/api/categorias`
- `http://localhost:5246/api/prioridades`

Deve retornar JSON com dados! ✅

---

## 🌐 Etapa 4: Expor Backend com ngrok

### 4.1 Em um NOVO terminal PowerShell
```powershell
cd C:\ngrok
.\ngrok http 5246
```

### 4.2 Copiar a URL gerada
Você verá algo assim:
```
Session Status                online
Account                       seu-email@gmail.com
Forwarding                    https://abc123-45-67-89.ngrok-free.app -> http://localhost:5246
```

**Copie a URL**: `https://abc123-45-67-89.ngrok-free.app`

### 4.3 Testar ngrok
No navegador, acesse:
```
https://abc123-45-67-89.ngrok-free.app/api/categorias
```

Deve retornar os dados! ✅

**Nota**: Na primeira vez, o ngrok pode mostrar uma página de aviso. Clique em "Visit Site".

---

## 🎨 Etapa 5: Atualizar URL no Frontend

### 5.1 Editar `Frontend/Desktop/config.js`

Substitua a URL da produção pela URL do ngrok:

```javascript
// Configuração do ambiente
const config = {
  // Para desenvolvimento local
  development: {
    apiUrl: 'http://localhost:5246'
  },
  
  // Para produção (Vercel + ngrok)
  production: {
    apiUrl: 'https://abc123-45-67-89.ngrok-free.app'  // ← COLE A URL DO NGROK AQUI
  }
};
```

### 5.2 Commit e Push
```powershell
git add Frontend/Desktop/config.js
git commit -m "chore: Update production API URL to ngrok endpoint"
git push origin master
```

### 5.3 Aguardar deploy do Vercel
- Acesse: https://vercel.com/dashboard
- Aguarde o deploy automático (~30 segundos)
- Ou acesse: https://sistema-chamados-faculdade.vercel.app

---

## 🧪 Etapa 6: Testar Integração Completa

### 6.1 Verificar se tudo está rodando
- ✅ Backend rodando: `dotnet run` no terminal 1
- ✅ ngrok rodando: `ngrok http 5246` no terminal 2
- ✅ Frontend deployado: Vercel fez deploy automático

### 6.2 Testar no Frontend Vercel
1. Acesse: https://sistema-chamados-faculdade.vercel.app
2. Abra o DevTools (F12) → Console
3. Deve aparecer: `🌐 API URL: https://abc123-45-67-89.ngrok-free.app`

### 6.3 Testar Login
1. Tente fazer login com um usuário:
   - Email: `admin@neurohelp.com`
   - Senha: `Admin@123`

2. Se funcionar, você verá o dashboard! ✅

### 6.4 Testar criação de chamado
1. Crie um novo chamado
2. Verifique se a IA da OpenAI funciona
3. Confirme se salvou no banco

---

## 📝 Script Automatizado (Opcional)

Crie um arquivo `start-ngrok.ps1` na raiz do projeto:

```powershell
# start-ngrok.ps1
# Script para iniciar Backend + ngrok automaticamente

param(
    [string]$NgrokPath = "C:\ngrok\ngrok.exe"
)

Write-Host "🚀 Iniciando Sistema de Chamados com ngrok..." -ForegroundColor Cyan

# 1. Verificar se ngrok existe
if (-not (Test-Path $NgrokPath)) {
    Write-Host "❌ ngrok não encontrado em: $NgrokPath" -ForegroundColor Red
    Write-Host "   Baixe em: https://ngrok.com/download" -ForegroundColor Yellow
    exit 1
}

# 2. Verificar SQL Server
Write-Host "`n📊 Verificando SQL Server..." -ForegroundColor Yellow
$sqlService = Get-Service -Name "MSSQL*" -ErrorAction SilentlyContinue
if ($sqlService -and $sqlService.Status -ne 'Running') {
    Write-Host "   Iniciando SQL Server..." -ForegroundColor Yellow
    Start-Service $sqlService.Name
    Start-Sleep -Seconds 2
}

# 3. Iniciar Backend em background
Write-Host "`n🔧 Iniciando Backend..." -ForegroundColor Yellow
$backendJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD\Backend
    dotnet run
}

Write-Host "   Aguardando Backend inicializar..." -ForegroundColor Gray
Start-Sleep -Seconds 5

# 4. Iniciar ngrok
Write-Host "`n🌐 Iniciando ngrok..." -ForegroundColor Yellow
Write-Host "   Pressione Ctrl+C para parar tudo" -ForegroundColor Gray
Write-Host ""

& $NgrokPath http 5246

# Cleanup quando pressionar Ctrl+C
Write-Host "`n🛑 Parando serviços..." -ForegroundColor Red
Stop-Job -Job $backendJob
Remove-Job -Job $backendJob
Write-Host "✅ Tudo parado!" -ForegroundColor Green
```

### Para usar o script:
```powershell
.\start-ngrok.ps1
```

---

## ⚠️ Troubleshooting

### Problema: "ERR_CONNECTION_REFUSED"
**Solução**: Verifique se o Backend está rodando:
```powershell
netstat -ano | findstr :5246
```

### Problema: "ngrok não reconhecido"
**Solução**: Adicione ngrok ao PATH ou use caminho completo:
```powershell
C:\ngrok\ngrok.exe http 5246
```

### Problema: CORS bloqueado
**Solução**: Verifique se adicionou as URLs do ngrok no CORS (Etapa 2).

### Problema: URL do ngrok mudou
**Solução**: Isso é normal no plano grátis. A cada reinício:
1. Copie a nova URL do ngrok
2. Atualize `Frontend/Desktop/config.js`
3. Commit e push

**Alternativa**: Use ngrok pago ($8/mês) para URL fixa:
```powershell
ngrok http 5246 --domain=sua-api-fixa.ngrok.app
```

### Problema: "Invalid Host Header"
**Solução**: No `Backend/Properties/launchSettings.json`, adicione:
```json
{
  "profiles": {
    "http": {
      "applicationUrl": "http://0.0.0.0:5246"  // ← Mude de localhost para 0.0.0.0
    }
  }
}
```

---

## 🎯 Checklist Final

Antes de considerar concluído, verifique:

- [ ] ngrok instalado e autenticado
- [ ] Backend compilando sem erros
- [ ] CORS configurado com URLs do ngrok
- [ ] Backend rodando em `http://localhost:5246`
- [ ] ngrok expondo em `https://xyz.ngrok-free.app`
- [ ] Endpoints da API acessíveis via ngrok
- [ ] `config.js` atualizado com URL do ngrok
- [ ] Commit e push realizados
- [ ] Vercel fez deploy automático
- [ ] Frontend no Vercel conectando com backend ngrok
- [ ] Login funcionando
- [ ] Criação de chamados funcionando

---

## 📊 Monitoramento

### ngrok Web Interface
Acesse `http://localhost:4040` enquanto ngrok está rodando para ver:
- Todas as requisições HTTP
- Request/Response headers
- Payload das requisições
- Tempo de resposta

### Manter ngrok sempre rodando
Para ambientes de desenvolvimento contínuo:

**Opção 1: Usar `tmux` ou `screen` (Linux/Mac)**  
**Opção 2: Criar um serviço Windows** (avançado)  
**Opção 3: Usar o script `start-ngrok.ps1` acima**

---

## 💡 Dicas Extras

1. **Salvar a URL do ngrok**: Anote em algum lugar para não precisar atualizar sempre
2. **Usar ngrok pago**: Se for usar por muito tempo, vale a pena a URL fixa
3. **Monitorar logs**: Deixe os logs do Backend visíveis para debugar
4. **Backup**: Sempre faça backup do banco antes de testes
5. **Variáveis de ambiente**: Use `.env` para configurações sensíveis

---

## 🎉 Conclusão

Após seguir este plano, você terá:
- ✅ Backend acessível de qualquer lugar via ngrok
- ✅ Frontend no Vercel conectando com backend
- ✅ Sistema funcionando end-to-end
- ✅ Fácil de demonstrar para qualquer pessoa

**Tempo estimado**: 30-45 minutos (primeira vez)  
**Tempo após configurado**: 2 minutos (apenas rodar Backend + ngrok)

Boa sorte! 🚀
