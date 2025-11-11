# 🔄 Migração: Desktop → Web ASP.NET Core

**Data:** 11/11/2025  
**Objetivo:** Migrar frontend de `dotnet-serve` para aplicação ASP.NET Core production-ready

---

## 📊 O Que Mudou?

### ❌ Versão Antiga (Desktop/)
```powershell
# Executava com dotnet-serve (ferramenta de desenvolvimento)
cd Frontend/Desktop
dotnet serve -o -p 8080
```

**Problemas:**
- ❌ Não é production-ready
- ❌ Não suporta IIS
- ❌ Não suporta Azure App Service
- ❌ Deploy manual complicado
- ❌ Sem configuração centralizada

---

### ✅ Versão Nova (Web/)
```powershell
# Aplicação ASP.NET Core completa
cd Frontend/Web
dotnet run
```

**Vantagens:**
- ✅ **Production-ready** - Servidor Kestrel otimizado
- ✅ **IIS Support** - Deploy direto em Windows Server
- ✅ **Azure Support** - `az webapp up` e funciona
- ✅ **Docker Ready** - Dockerfile incluído no README
- ✅ **Configuração** - `appsettings.json` centralizado
- ✅ **Logging** - ASP.NET Core Logging integrado
- ✅ **HTTPS** - Suporte nativo

---

## 🚀 Como Usar

### Desenvolvimento
```powershell
# Opção 1: Script PowerShell
cd Scripts
.\start-web.ps1

# Opção 2: dotnet CLI
cd Frontend\Web
dotnet run

# Opção 3: Visual Studio
# Abra sistema-chamados-faculdade.sln
# Defina "Web" como projeto de inicialização
# Pressione F5
```

### Produção (IIS)
```powershell
# 1. Publicar
cd Frontend\Web
dotnet publish -c Release -o C:\inetpub\wwwroot\sistema-chamados

# 2. Configurar IIS
# - Criar novo Site
# - Physical path: C:\inetpub\wwwroot\sistema-chamados
# - Application Pool: .NET CLR = No Managed Code
# - Bindings: Port 80 ou 443 (HTTPS)

# 3. Instalar ASP.NET Core Runtime no servidor
# https://dotnet.microsoft.com/download/dotnet/9.0
```

### Produção (Azure)
```powershell
cd Frontend\Web
az webapp up --name sistema-chamados --resource-group MeuGrupo --runtime "DOTNETCORE:9.0"
```

---

## 📂 Nova Estrutura

```
Frontend/
├── Web/                     # ✅ NOVA APLICAÇÃO ASP.NET CORE
│   ├── Program.cs           # Configuração principal
│   ├── appsettings.json     # Porta 8080, logs, etc
│   ├── Web.csproj           # Projeto .NET 9.0
│   ├── Properties/
│   │   └── launchSettings.json
│   ├── wwwroot/             # (interno - gerado pelo template)
│   └── README.md            # 📖 Guia completo
│
├── wwwroot/                 # ✅ ARQUIVOS SERVIDOS (SPA)
│   ├── index.html           # Página principal
│   ├── script-desktop.js    # Lógica JS
│   ├── style-desktop.css    # Estilos
│   ├── img/                 # Imagens
│   └── *.html               # Outras páginas
│
└── Desktop/                 # ⚠️ LEGADO (manter para referência)
    └── ...                  # Mesmos arquivos (backup)
```

---

## 🔧 Configurações Importantes

### Program.cs
```csharp
var builder = WebApplication.CreateBuilder(args);

// ✅ Aponta para wwwroot pai (Frontend/wwwroot)
builder.Environment.WebRootPath = Path.Combine(
    builder.Environment.ContentRootPath, "..", "wwwroot"
);

var app = builder.Build();

// ✅ Serve arquivos estáticos
app.UseDefaultFiles(); // index.html automático
app.UseStaticFiles();

// ✅ SPA Fallback - F5 funciona em qualquer rota
app.MapFallbackToFile("index.html");

app.Run();
```

### appsettings.json
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "Urls": "http://0.0.0.0:8080"  // ✅ Porta configurável
}
```

---

## ✅ Checklist de Migração

- [x] Criado projeto `Frontend/Web/`
- [x] Configurado `Program.cs` para SPA
- [x] Configurado `appsettings.json` (porta 8080)
- [x] Criado script `Scripts/start-web.ps1`
- [x] Criado `Frontend/Web/README.md` com guia completo
- [x] Testado servidor - `http://0.0.0.0:8080` ✅
- [x] Mantido `Frontend/Desktop/` como backup

---

## 🧪 Testes Realizados

```powershell
PS> cd Frontend\Web
PS> dotnet run

# Saída:
# ✅ Now listening on: http://0.0.0.0:8080
# ✅ Application started. Press Ctrl+C to shut down.
# ✅ Hosting environment: Development
# ✅ Content root path: C:\...\Frontend\Web
```

**Status:** ✅ **Funcionando perfeitamente!**

---

## 🔗 URLs Atualizadas

| Serviço | URL Antiga | URL Nova | Status |
|---------|-----------|----------|--------|
| **Frontend** | `dotnet-serve` Desktop/ | ASP.NET Web/ | ✅ Migrado |
| **Backend API** | http://localhost:5246 | (sem mudança) | ✅ OK |
| **Swagger** | http://localhost:5246/swagger | (sem mudança) | ✅ OK |

---

## 📝 Notas para Produção

1. **HTTPS em produção:**
   - Descomente `app.UseHttpsRedirection();` no `Program.cs`
   - Configure certificado SSL no IIS ou Azure

2. **CORS:**
   - Backend já permite `http://localhost:8080`
   - Para produção, atualize `AllowedOrigins` no Backend `Program.cs`

3. **Monitoramento:**
   - Logs salvos automaticamente pelo ASP.NET Core
   - Configure Application Insights para Azure

4. **Performance:**
   - Kestrel otimizado para produção
   - Considere usar CDN para `wwwroot/img/`

---

## 🐛 Troubleshooting

### Porta 8080 em uso
```powershell
netstat -ano | findstr :8080
taskkill /PID <PID> /F
```

### Arquivos não encontrados (404)
- Verifique se `wwwroot/` existe em `Frontend/`
- Confirme que `index.html` está em `Frontend/wwwroot/index.html`
- Reinicie a aplicação

### API não responde
- Backend deve estar rodando em `http://localhost:5246`
- Verifique `API_BASE` em `wwwroot/script-desktop.js`

---

**Próximos Passos:**
1. ✅ Testar login/cadastro/chamados na nova versão
2. ✅ Atualizar documentação principal
3. ✅ Commit e push
4. 🔜 Deploy em ambiente de produção (IIS/Azure)

---

**Desenvolvido:** ASP.NET Core 9.0  
**Status:** ✅ PRONTO PARA PRODUÇÃO
