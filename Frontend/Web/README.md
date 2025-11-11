# 🌐 Frontend Web ASP.NET Core

Aplicação ASP.NET Core configurada para servir o frontend Desktop como **Single Page Application (SPA)**.

---

## 📋 Características

- **ASP.NET Core 9.0** com servidor Kestrel
- Serve arquivos estáticos do `wwwroot` pai
- **SPA Fallback** - todas as rotas retornam `index.html`
- Porta configurada: `http://0.0.0.0:8080`
- **Pronto para deploy** em IIS, Azure, Docker

---

## 🚀 Como Executar

### Opção 1: Script PowerShell (Recomendado)
```powershell
cd Scripts
.\start-web.ps1
```

### Opção 2: dotnet CLI
```powershell
cd Frontend\Web
dotnet run
```

### Opção 3: Visual Studio
1. Abra `sistema-chamados-faculdade.sln`
2. Defina `Web` como projeto de inicialização
3. Pressione F5

---

## 🔧 Configuração

### Porta e URL
Editável em `appsettings.json`:
```json
{
  "Urls": "http://0.0.0.0:8080"
}
```

### Caminho do wwwroot
O `Program.cs` está configurado para usar `../wwwroot`:
```csharp
builder.Environment.WebRootPath = Path.Combine(
    builder.Environment.ContentRootPath, "..", "wwwroot"
);
```

---

## 📂 Estrutura

```
Frontend/
├── Web/                    # Aplicação ASP.NET Core
│   ├── Program.cs          # Configuração principal
│   ├── appsettings.json    # Porta e configurações
│   └── Web.csproj          # Projeto .NET
│
├── wwwroot/                # Arquivos estáticos (SERVIDOS PELA WEB)
│   ├── index.html          # Página de login
│   ├── script-desktop.js   # Lógica JavaScript
│   ├── style-desktop.css   # Estilos
│   ├── img/                # Imagens e logos
│   └── *.html              # Outras páginas
│
└── Desktop/                # VERSÃO ANTIGA (dotnet-serve)
    └── ...                 # Não usar mais!
```

---

## 🌍 Deploy em Produção

### IIS (Windows Server)
1. Publique o projeto:
   ```powershell
   dotnet publish -c Release -o C:\inetpub\wwwroot\sistema-chamados
   ```

2. Configure o IIS:
   - Crie um novo Site
   - Aponte para a pasta publicada
   - Configure o Application Pool (.NET CLR = No Managed Code)

3. Instale o **ASP.NET Core Runtime** no servidor

### Azure App Service
```powershell
# Publique direto para Azure
dotnet publish -c Release
az webapp up --name sistema-chamados --resource-group MeuGrupo
```

### Docker
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY ["Frontend/Web/Web.csproj", "Frontend/Web/"]
RUN dotnet restore "Frontend/Web/Web.csproj"
COPY . .
WORKDIR "/src/Frontend/Web"
RUN dotnet build "Web.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Web.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Web.dll"]
```

---

## ⚙️ Diferenças vs dotnet-serve (Desktop/)

| Aspecto | **dotnet-serve (antigo)** | **ASP.NET Web (novo)** |
|---------|--------------------------|------------------------|
| **Servidor** | Servidor simples | Kestrel completo |
| **Produção** | ❌ Não recomendado | ✅ Production-ready |
| **HTTPS** | Manual | Suporte nativo |
| **IIS** | ❌ Não suporta | ✅ Suporta |
| **Azure** | ❌ Não suporta | ✅ Deploy direto |
| **Docker** | ❌ Difícil | ✅ Fácil |
| **Configuração** | Linha de comando | `appsettings.json` |
| **Logging** | Básico | ASP.NET Core Logging |

---

## 🔗 URLs Importantes

- **Aplicação Web:** http://localhost:8080
- **Backend API:** http://localhost:5246
- **Swagger (API):** http://localhost:5246/swagger

---

## 📝 Notas

1. ✅ **Pronto para produção** - Use esta versão para deploy
2. ✅ **Desktop/ é legado** - Mantido apenas para referência
3. ✅ **CORS configurado** - Backend permite requisições de localhost:8080
4. ✅ **SPA Routing** - Refresh funciona em qualquer rota

---

## 🐛 Troubleshooting

### Porta 8080 já em uso
```powershell
# Windows: Encontrar e matar processo
netstat -ano | findstr :8080
taskkill /PID <PID> /F

# Ou mudar a porta em appsettings.json
```

### Erro 404 em arquivos estáticos
- Verifique se `wwwroot` existe em `Frontend/`
- Confirme que `index.html` está em `Frontend/wwwroot/`

### API não responde
- Verifique se Backend está rodando em `http://localhost:5246`
- Confirme `API_BASE` em `script-desktop.js` (deve ser `http://localhost:5246`)

---

**Desenvolvido com:** ASP.NET Core 9.0 + Kestrel  
**Compatível com:** Windows, Linux, macOS, Docker, Azure, IIS
