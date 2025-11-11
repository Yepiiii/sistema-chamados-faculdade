# 🚀 Guia de Deploy - Sistema de Chamados

## Frontend Desktop no Vercel

### Passo 1: Preparação
✅ Arquivos já configurados:
- `Frontend/Desktop/vercel.json` - Configuração do Vercel
- `Frontend/Desktop/config.js` - Configuração de URLs da API
- `Frontend/Desktop/.gitignore` - Arquivos ignorados

### Passo 2: Deploy

#### Opção A: Via Interface Web (Mais Fácil)

1. **Acesse**: https://vercel.com
2. **Login**: Use sua conta GitHub
3. **Novo Projeto**:
   - Clique em "Add New" → "Project"
   - Selecione o repositório `sistema-chamados-faculdade`
4. **Configurar**:
   - **Root Directory**: `Frontend/Desktop` ← IMPORTANTE!
   - **Framework Preset**: Other
   - **Build Command**: (deixe vazio)
   - **Output Directory**: `.` ou (vazio)
5. **Deploy**: Clique em "Deploy"

#### Opção B: Via CLI

```bash
# Instalar Vercel CLI (se ainda não tiver)
npm i -g vercel

# Navegar para o diretório
cd Frontend/Desktop

# Login (primeira vez)
vercel login

# Deploy
vercel --prod
```

### Passo 3: Configurar URL do Backend

Após fazer deploy do backend (Azure, Railway, etc.), atualize a URL:

1. Abra `Frontend/Desktop/config.js`
2. Encontre a linha:
   ```javascript
   apiUrl: 'https://seu-backend.azurewebsites.net'
   ```
3. Substitua pela URL real do seu backend
4. Commit e push para atualizar

### Passo 4: CORS no Backend

⚠️ **IMPORTANTE**: Configure o CORS no backend para aceitar o domínio do Vercel.

No arquivo `Backend/program.cs`, adicione a URL do Vercel:

```csharp
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.WithOrigins(
            "http://localhost:8080",
            "https://seu-app.vercel.app"  // ← Adicione sua URL do Vercel aqui
        )
        .AllowAnyHeader()
        .AllowAnyMethod()
        .AllowCredentials();
    });
});
```

## Backend no Azure (ou outro provedor)

### Opção 1: Azure App Service

1. **Criar App Service**:
   ```bash
   az webapp create --resource-group seu-grupo --plan seu-plano --name seu-backend --runtime "DOTNETCORE:8.0"
   ```

2. **Deploy**:
   ```bash
   cd Backend
   dotnet publish -c Release
   az webapp deploy --resource-group seu-grupo --name seu-backend --src-path ./bin/Release/net8.0/publish.zip
   ```

### Opção 2: Railway

1. Acesse https://railway.app
2. Conecte seu repositório GitHub
3. Selecione a pasta `Backend`
4. Railway detectará automaticamente o .NET
5. Adicione as variáveis de ambiente necessárias

### Opção 3: Render

1. Acesse https://render.com
2. New → Web Service
3. Conecte o repositório
4. Configure:
   - **Root Directory**: `Backend`
   - **Build Command**: `dotnet publish -c Release`
   - **Start Command**: `dotnet ./bin/Release/net8.0/SistemaChamados.dll`

## Variáveis de Ambiente

### Backend (Azure/Railway/Render)

Configure estas variáveis:

```
ConnectionStrings__DefaultConnection=Server=...;Database=SistemaChamados;...
Jwt__Key=SUA_CHAVE_SECRETA_MINIMO_32_CARACTERES
Jwt__Issuer=SistemaChamadosAPI
Jwt__Audience=SistemaChamadosClients
OpenAI__ApiKey=sk-...
Email__SmtpServer=smtp.gmail.com
Email__Port=587
Email__SenderEmail=seu-email@gmail.com
Email__Password=sua-senha-app
```

### Frontend (Vercel)

Geralmente não precisa de variáveis de ambiente, mas se necessário:
- Vá em Settings → Environment Variables no painel do Vercel

## Banco de Dados

### Opção 1: Azure SQL Database
```bash
az sql server create --name seu-servidor --resource-group seu-grupo --location eastus --admin-user admin --admin-password SuaSenha123!
az sql db create --resource-group seu-grupo --server seu-servidor --name SistemaChamados --service-objective S0
```

### Opção 2: SQL Server em VM
- Use uma VM com SQL Server
- Configure firewall para aceitar conexões do Azure App Service

### Opção 3: PostgreSQL (se migrar)
- Render: Banco PostgreSQL gratuito
- Railway: Banco PostgreSQL gratuito com limite

## Checklist Final

- [ ] Backend deployado e funcionando
- [ ] Banco de dados criado e migrations aplicadas
- [ ] Variáveis de ambiente configuradas
- [ ] CORS configurado com URL do Vercel
- [ ] Frontend deployado no Vercel
- [ ] URL da API atualizada em `config.js`
- [ ] Testado login, criação de ticket, etc.
- [ ] SSL/HTTPS funcionando (automático no Vercel)

## URLs Exemplo

- **Frontend**: https://sistema-chamados.vercel.app
- **Backend**: https://sistema-chamados-api.azurewebsites.net
- **Banco**: servidor-sql.database.windows.net

## Troubleshooting

**Erro de CORS:**
```
Access to fetch at 'https://...' from origin 'https://...' has been blocked by CORS
```
→ Adicione o domínio do Vercel no CORS do backend

**API retorna 404:**
→ Verifique se a URL em `config.js` está correta

**Banco não conecta:**
→ Verifique string de conexão e firewall do banco

**Build falha no Vercel:**
→ Confirme que Root Directory está como `Frontend/Desktop`

## Suporte

- Vercel Docs: https://vercel.com/docs
- Azure Docs: https://docs.microsoft.com/azure
- Railway Docs: https://docs.railway.app
