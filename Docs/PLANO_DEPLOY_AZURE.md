# 📋 Plano de Ação: Deploy WebApp ASP.NET (wwwroot) no Azure Estudante

---

## 🎯 Objetivo Final
Sistema acessível em: `https://sistema-chamados-pim4.azurewebsites.net`

---

## ✅ FASE 1: Preparação do Ambiente Local

### **1.1 - Verificar Pré-requisitos**
```powershell
# Verificar .NET SDK instalado
dotnet --version
# Esperado: 8.0.x ou 9.0.x

# Verificar Git
git --version
```

**✅ Checklist:**
- [ ] .NET SDK 8.0+ instalado
- [ ] Git configurado
- [ ] Repositório atualizado (`git pull`)

---

### **1.2 - Criar Projeto ASP.NET WebApp**
```powershell
cd C:\Users\opera\sistema-chamados-faculdade\Frontend
dotnet new web -n WebApp
```

**Resultado esperado:**
```
Frontend/
├── Desktop/
├── wwwroot/
└── WebApp/        ← NOVO
    ├── Program.cs
    ├── WebApp.csproj
    └── appsettings.json
```

**✅ Checklist:**
- [ ] Pasta `Frontend/WebApp/` criada
- [ ] Arquivo `Program.cs` existe
- [ ] Arquivo `WebApp.csproj` existe

---

### **1.3 - Configurar Program.cs**
**Arquivo:** `Frontend/WebApp/Program.cs`

```csharp
var builder = WebApplication.CreateBuilder(args);

// Configurar wwwroot da pasta pai
builder.Environment.WebRootPath = 
    Path.Combine(builder.Environment.ContentRootPath, "..", "wwwroot");

var app = builder.Build();

// Servir arquivos estáticos
app.UseDefaultFiles();
app.UseStaticFiles();

// SPA Fallback
app.MapFallbackToFile("index.html");

app.Run();
```

**✅ Checklist:**
- [ ] `Program.cs` editado
- [ ] Aponta para `../wwwroot`
- [ ] Configurado SPA fallback

---

### **1.4 - Configurar appsettings.json**
**Arquivo:** `Frontend/WebApp/appsettings.json`

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Nota:** Porta será configurada pelo Azure automaticamente.

**✅ Checklist:**
- [ ] `appsettings.json` configurado
- [ ] `AllowedHosts` = "*"

---

### **1.5 - Testar Localmente**
```powershell
cd Frontend\WebApp
dotnet run
```

**Abrir navegador:** `http://localhost:5000` ou porta indicada

**✅ Checklist:**
- [ ] Aplicação inicia sem erros
- [ ] `index.html` carrega
- [ ] Login aparece na tela

---

### **1.6 - Atualizar Backend CORS (Preparar para Azure)**
**Arquivo:** `Backend/program.cs`

Localizar configuração CORS e adicionar:
```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend",
        policy =>
        {
            policy.WithOrigins(
                "http://localhost:8080",      // Desktop local
                "http://localhost:5000",      // WebApp local
                "https://sistema-chamados-pim4.azurewebsites.net"  // Azure
            )
            .AllowAnyHeader()
            .AllowAnyMethod();
        });
});
```

**✅ Checklist:**
- [ ] CORS atualizado com URL do Azure (placeholder por enquanto)
- [ ] Backend testado localmente

---

### **1.7 - Criar Script de Inicialização**
**Arquivo:** `Scripts/start-webapp.ps1`

```powershell
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Sistema de Chamados - WebApp" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$webAppPath = Join-Path (Join-Path $PSScriptRoot "..") "Frontend\WebApp"

Write-Host "Iniciando WebApp ASP.NET Core..." -ForegroundColor Yellow
Write-Host "Acesse: http://localhost:5000" -ForegroundColor Green
Write-Host ""

Set-Location $webAppPath
dotnet run
```

**Testar:**
```powershell
.\Scripts\start-webapp.ps1
```

**✅ Checklist:**
- [ ] Script criado
- [ ] WebApp inicia corretamente
- [ ] Acessível em `http://localhost:5000`

---

### **1.8 - Commit Local (Preparação)**
```powershell
git add Frontend/WebApp/ Scripts/start-webapp.ps1
git commit -m "Feat: Add ASP.NET Core WebApp for production deployment"
```

**NÃO fazer push ainda** - vamos testar deploy primeiro.

**✅ Checklist:**
- [ ] Mudanças commitadas localmente
- [ ] Git status limpo

---

## 🌐 FASE 2: Configuração do Azure

### **2.1 - Criar Conta Azure Estudante**

**Acessar:** https://azure.microsoft.com/pt-br/free/students/

**Requisitos:**
- Email institucional (.edu) **OU**
- GitHub Student Developer Pack

**✅ Checklist:**
- [ ] Conta Azure criada
- [ ] Créditos de $100 USD disponíveis
- [ ] Login realizado

---

### **2.2 - Instalar Azure CLI**
```powershell
# Instalar Azure CLI
winget install Microsoft.AzureCLI

# Reiniciar PowerShell após instalação

# Verificar instalação
az --version
```

**✅ Checklist:**
- [ ] Azure CLI instalado
- [ ] Versão exibida corretamente

---

### **2.3 - Login no Azure via CLI**
```powershell
az login
```

**Ação:** Navegador abrirá automaticamente para login.

**Resultado esperado:**
```json
[
  {
    "name": "Azure para Estudantes",
    "id": "xxxx-xxxx-xxxx",
    "isDefault": true
  }
]
```

**✅ Checklist:**
- [ ] Login realizado
- [ ] Assinatura "Azure para Estudantes" ativa

---

### **2.4 - Criar Resource Group**
```powershell
az group create --name rg-sistema-chamados --location brazilsouth
```

**Por que Brazil South?** Menor latência para usuários no Brasil.

**✅ Checklist:**
- [ ] Resource Group criado
- [ ] Localização: brazilsouth

---

## 🚀 FASE 3: Deploy do Backend (API) no Azure

### **3.1 - Publicar Backend Localmente**
```powershell
cd C:\Users\opera\sistema-chamados-faculdade\Backend
dotnet publish -c Release -o ./publish
```

**✅ Checklist:**
- [ ] Pasta `Backend/publish/` criada
- [ ] DLLs e arquivos publicados

---

### **3.2 - Criar App Service para Backend**
```powershell
az webapp up `
  --name chamados-api-pim4 `
  --resource-group rg-sistema-chamados `
  --runtime "DOTNETCORE:8.0" `
  --location brazilsouth `
  --src-path ./publish
```

**Tempo estimado:** 3-5 minutos

**Resultado esperado:**
```
URL: https://chamados-api-pim4.azurewebsites.net
State: Running
```

**✅ Checklist:**
- [ ] Backend API online
- [ ] Acessível em `https://chamados-api-pim4.azurewebsites.net`
- [ ] Swagger acessível em `/swagger`

---

### **3.3 - Configurar Banco de Dados no Azure**

**Opção A: Azure SQL Database (Recomendado)**
```powershell
# Criar SQL Server
az sql server create `
  --name chamados-sqlserver-pim4 `
  --resource-group rg-sistema-chamados `
  --location brazilsouth `
  --admin-user sqladmin `
  --admin-password "SenhaSegura@2025"

# Criar Database
az sql db create `
  --name SistemaChamados `
  --server chamados-sqlserver-pim4 `
  --resource-group rg-sistema-chamados `
  --service-objective Basic

# Permitir acesso Azure Services
az sql server firewall-rule create `
  --server chamados-sqlserver-pim4 `
  --resource-group rg-sistema-chamados `
  --name AllowAzureServices `
  --start-ip-address 0.0.0.0 `
  --end-ip-address 0.0.0.0
```

**Opção B: Banco Local (Temporário)**
- Manter SQL Server local
- Abrir porta 1433 no firewall
- Configurar IP público

**✅ Checklist:**
- [ ] SQL Server criado no Azure **OU** local configurado
- [ ] Database `SistemaChamados` criada
- [ ] Firewall configurado

---

### **3.4 - Configurar Connection String no Backend**
```powershell
# Obter connection string
az sql db show-connection-string `
  --name SistemaChamados `
  --server chamados-sqlserver-pim4 `
  --client ado.net

# Configurar no App Service
az webapp config connection-string set `
  --name chamados-api-pim4 `
  --resource-group rg-sistema-chamados `
  --connection-string-type SQLAzure `
  --settings DefaultConnection="Server=tcp:chamados-sqlserver-pim4.database.windows.net,1433;Initial Catalog=SistemaChamados;Persist Security Info=False;User ID=sqladmin;Password=SenhaSegura@2025;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
```

**✅ Checklist:**
- [ ] Connection string configurada
- [ ] Backend conectado ao banco

---

### **3.5 - Executar Migrations no Azure**
```powershell
# Configurar connection string local apontando para Azure
# Editar Backend/appsettings.json temporariamente:
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=tcp:chamados-sqlserver-pim4.database.windows.net,1433;..."
  }
}

# Executar migrations
cd Backend
dotnet ef database update

# OU usar script SQL direto no Azure Portal
```

**✅ Checklist:**
- [ ] Migrations executadas
- [ ] Tabelas criadas no Azure SQL
- [ ] Seed data inserido (usuários padrão)

---

### **3.6 - Testar Backend no Azure**

**Abrir:** `https://chamados-api-pim4.azurewebsites.net/swagger`

**Testar endpoint:**
```powershell
curl https://chamados-api-pim4.azurewebsites.net/api/status
```

**✅ Checklist:**
- [ ] Swagger carrega
- [ ] Endpoints respondem
- [ ] Login funciona

---

## 🌐 FASE 4: Deploy do Frontend (WebApp) no Azure

### **4.1 - Publicar WebApp Localmente**
```powershell
cd C:\Users\opera\sistema-chamados-faculdade\Frontend\WebApp
dotnet publish -c Release -o ./publish
```

**✅ Checklist:**
- [ ] Pasta `Frontend/WebApp/publish/` criada
- [ ] Arquivos publicados

---

### **4.2 - Criar App Service para Frontend**
```powershell
az webapp up `
  --name sistema-chamados-pim4 `
  --resource-group rg-sistema-chamados `
  --runtime "DOTNETCORE:8.0" `
  --location brazilsouth `
  --src-path ./publish
```

**Resultado esperado:**
```
URL: https://sistema-chamados-pim4.azurewebsites.net
State: Running
```

**✅ Checklist:**
- [ ] Frontend online
- [ ] Acessível em `https://sistema-chamados-pim4.azurewebsites.net`

---

### **4.3 - Atualizar API_BASE no Frontend**

**Problema:** `script-desktop.js` aponta para `http://localhost:5246`

**Solução 1: Variável de Ambiente (Recomendado)**

Criar `Frontend/wwwroot/config.js`:
```javascript
const API_BASE = window.location.hostname === 'localhost' 
  ? 'http://localhost:5246'
  : 'https://chamados-api-pim4.azurewebsites.net';
```

Adicionar em todos os HTMLs **antes** de `script-desktop.js`:
```html
<script src="config.js"></script>
<script src="script-desktop.js"></script>
```

**Solução 2: Build Condicional (Mais complexo)**
- Manter dois arquivos `config.js` (dev e prod)
- Substituir durante `dotnet publish`

**✅ Checklist:**
- [ ] `config.js` criado
- [ ] Incluído nos HTMLs
- [ ] `API_BASE` dinâmico

---

### **4.4 - Republicar Frontend com Mudanças**
```powershell
cd Frontend\WebApp
dotnet publish -c Release -o ./publish

az webapp up `
  --name sistema-chamados-pim4 `
  --resource-group rg-sistema-chamados `
  --runtime "DOTNETCORE:8.0" `
  --src-path ./publish
```

**✅ Checklist:**
- [ ] Frontend republicado
- [ ] `config.js` presente

---

### **4.5 - Atualizar CORS no Backend (Azure)**
```powershell
az webapp cors add `
  --name chamados-api-pim4 `
  --resource-group rg-sistema-chamados `
  --allowed-origins https://sistema-chamados-pim4.azurewebsites.net
```

**✅ Checklist:**
- [ ] CORS configurado no Azure
- [ ] Frontend pode chamar API

---

## ✅ FASE 5: Testes Finais

### **5.1 - Teste Completo de Funcionalidades**

**Acessar:** `https://sistema-chamados-pim4.azurewebsites.net`

**Testar:**
- [ ] Página de login carrega
- [ ] Login com `admin@neurohelp.com.br` / `Admin@123`
- [ ] Dashboard carrega
- [ ] Criar novo chamado
- [ ] Comentar em chamado
- [ ] Logout

---

### **5.2 - Teste de Performance**
```powershell
# Testar latência
curl -w "@curl-format.txt" -o /dev/null -s https://sistema-chamados-pim4.azurewebsites.net
```

**Esperado:** < 500ms para Brazil South

**✅ Checklist:**
- [ ] Tempo de resposta aceitável
- [ ] Sem erros 500/404

---

### **5.3 - Teste Mobile**

**Atualizar APK:**
```
Mobile/appsettings.json:
{
  "ApiBaseUrl": "https://chamados-api-pim4.azurewebsites.net"
}
```

**Rebuildar APK e testar:**
- [ ] Login mobile funciona
- [ ] Criar chamado mobile funciona

---

## 📝 FASE 6: Documentação e Versionamento

### **6.1 - Atualizar README Principal**

Adicionar seção:
```markdown
## 🌐 Deploy em Produção

**URLs:**
- Frontend: https://sistema-chamados-pim4.azurewebsites.net
- Backend API: https://chamados-api-pim4.azurewebsites.net
- Swagger: https://chamados-api-pim4.azurewebsites.net/swagger

**Credenciais de Teste:**
- Admin: admin@neurohelp.com.br / Admin@123
- Técnico: tecnico1@neurohelp.com.br / Tecnico@123
- Cliente: user1@email.com / User@123
```

**✅ Checklist:**
- [ ] README atualizado com URLs

---

### **6.2 - Commit e Push Final**
```powershell
git add .
git commit -m "Deploy: WebApp and API deployed to Azure

- Frontend: https://sistema-chamados-pim4.azurewebsites.net
- Backend: https://chamados-api-pim4.azurewebsites.net
- Database: Azure SQL Database
- Resource Group: rg-sistema-chamados
- Location: brazilsouth"

git push origin Sistema-PIM4
```

**✅ Checklist:**
- [ ] Código commitado
- [ ] Push realizado
- [ ] GitHub atualizado

---

## 🎓 FASE 7: Apresentação

### **7.1 - Preparar Demonstração**

**Criar documento com:**
- [ ] URLs de acesso
- [ ] Credenciais de teste
- [ ] Fluxo de demonstração (login → criar chamado → comentar → fechar)
- [ ] Screenshots

---

### **7.2 - QR Code para Acesso Fácil**

Gerar QR Code para: `https://sistema-chamados-pim4.azurewebsites.net`

Incluir nos slides da apresentação.

**✅ Checklist:**
- [ ] QR Code gerado
- [ ] Slides preparados

---

## 💰 FASE 8: Monitoramento de Custos

### **8.1 - Configurar Budget Alert**
```powershell
az consumption budget create `
  --budget-name "sistema-chamados-budget" `
  --amount 50 `
  --time-grain Monthly `
  --resource-group rg-sistema-chamados
```

**✅ Checklist:**
- [ ] Budget configurado ($50/mês)
- [ ] Email de alerta cadastrado

---

### **8.2 - Verificar Tier Gratuito**

**Recursos Gratuitos (Azure Estudante):**
- App Service: F1 (Free) - 1GB RAM, 60min/dia CPU
- SQL Database: Basic ($5/mês) - 2GB storage
- **Total estimado:** $5-10/mês (coberto pelos $100 de crédito)

**✅ Checklist:**
- [ ] Plano Free/Basic confirmado
- [ ] Dentro do budget estudante

---

## 📊 Resumo de URLs Finais

| Serviço | URL | Uso |
|---------|-----|-----|
| **Frontend Web** | `https://sistema-chamados-pim4.azurewebsites.net` | Acesso Desktop |
| **Backend API** | `https://chamados-api-pim4.azurewebsites.net` | API REST |
| **Swagger** | `.../swagger` | Documentação API |
| **SQL Database** | `chamados-sqlserver-pim4.database.windows.net` | Banco de dados |

---

## ⏱️ Tempo Estimado Total

| Fase | Tempo |
|------|-------|
| Fase 1: Preparação Local | 30-45 min |
| Fase 2: Config Azure | 15 min |
| Fase 3: Deploy Backend | 20-30 min |
| Fase 4: Deploy Frontend | 15-20 min |
| Fase 5: Testes | 20 min |
| Fase 6: Documentação | 15 min |
| **TOTAL** | **~2-3 horas** |

---

## 🆘 Troubleshooting Comum

### Backend não conecta ao banco:
```powershell
az sql server firewall-rule create --name MeuIP --start-ip-address SEU_IP --end-ip-address SEU_IP
```

### Frontend não chama API (CORS):
```powershell
az webapp cors add --allowed-origins https://sistema-chamados-pim4.azurewebsites.net
```

### App Service frio (demora para iniciar):
- Normal em Free Tier
- Primeiro acesso após 20min pode demorar ~10s
- Considerar upgrade para Basic ($13/mês) se for crítico

---

## 📚 Recursos Adicionais

- **Azure para Estudantes:** https://azure.microsoft.com/pt-br/free/students/
- **Documentação ASP.NET Core:** https://docs.microsoft.com/aspnet/core
- **Azure CLI Referência:** https://docs.microsoft.com/cli/azure
- **GitHub Student Pack:** https://education.github.com/pack

---

**Data de Criação:** 11/11/2025  
**Versão:** 1.0  
**Status:** Pronto para execução
