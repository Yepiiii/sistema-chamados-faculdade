# 📱 Integração Mobile - GuiNRB Develop Branch

## 🎯 Objetivo
Integrar o aplicativo mobile MAUI com o backend original do GuiNRB, mantendo suas características.

---

## 🏗️ Arquitetura do Backend (GuiNRB)

### Características Principais:
- **Autenticação:** Microsoft Entra ID (Azure AD)
- **IA:** OpenAI (não Gemini)
- **Banco de Dados:** SQL Server Local (`localhost\DEV-CHAMADOSUNI`)
- **CORS:** Política `AllowAll` (aberta para todas as origens)
- **Port:** Padrão ASP.NET Core (verificar em Properties/launchSettings.json)

---

## 📋 Passos de Integração

### 1. Configurar Backend do GuiNRB

#### a) Resolver Conflitos no appsettings.json
O arquivo tem conflitos de merge. Escolha uma API Key válida:

```json
{
  "OpenAI": {
    "ApiKey": "SUA_CHAVE_OPENAI_AQUI"
  }
}
```

#### b) Verificar SQL Server
Certifique-se que o SQL Server está rodando com a instância `DEV-CHAMADOSUNI`:

```powershell
# Testar conexão
sqlcmd -S localhost\DEV-CHAMADOSUNI -Q "SELECT @@VERSION"
```

Se não existir, altere para `localhost`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=SistemaChamados;Integrated Security=True;TrustServerCertificate=True;"
  }
}
```

---

### 2. Configurar Projeto Mobile

#### a) Estrutura Atual
```
../SistemaChamados.Mobile/
  ├── Resources/
  ├── ViewModels/
  ├── Views/
  ├── appsettings.json
  └── SistemaChamados.Mobile.csproj
```

#### b) Ajustar appsettings.json do Mobile
O mobile precisa apontar para a API do GuiNRB:

```json
{
  "ApiSettings": {
    "BaseUrl": "http://localhost:5246", // Verificar porta correta
    "Timeout": 30
  }
}
```

**Como descobrir a porta:**
```powershell
# Verificar launchSettings.json
cat Properties/launchSettings.json | Select-String "applicationUrl"
```

---

### 3. Diferenças entre Branches

| Aspecto | Master (Sua Versão) | GuiNRB Develop |
|---------|-------------------|---------------|
| **Autenticação** | JWT Manual | Azure AD (Entra ID) |
| **IA** | Gemini | OpenAI |
| **Handoff** | 2 Níveis (N2/N3) | Básico |
| **Frontend** | Web (HTML) | Desktop (WPF?) |
| **DB** | SQL Server 2022 | SQL Server Local |
| **Mobile** | ✅ MAUI | ❌ Não existe |

---

### 4. Adaptações Necessárias no Mobile

#### a) Sistema de Autenticação
O GuiNRB usa Azure AD. O mobile precisará:

**Opção 1: Adicionar JWT ao Backend do GuiNRB**
- Criar endpoint `/api/Usuarios/login` que retorne JWT
- Manter Azure AD para o frontend desktop
- Usar JWT apenas no mobile

**Opção 2: Integrar Azure AD no Mobile**
- Adicionar Microsoft.Identity.Client (MSAL)
- Configurar autenticação interativa
- Mais complexo, mas mantém padrão

**Recomendação:** Opção 1 (JWT adicional)

#### b) Endpoints da API
Verificar se os endpoints do GuiNRB são compatíveis:

```csharp
// Endpoints esperados pelo mobile:
GET    /api/Categorias
GET    /api/Prioridades
GET    /api/Status
GET    /api/Chamados
POST   /api/Chamados
PUT    /api/Chamados/{id}
POST   /api/Usuarios/login  // PRECISA ADICIONAR
GET    /api/Usuarios/me
```

---

### 5. Scripts de Inicialização

#### a) Iniciar Backend do GuiNRB
```powershell
# Na raiz do projeto
dotnet run

# Ou com hot reload
dotnet watch run
```

#### b) Iniciar Mobile
```powershell
# Android
dotnet build -t:Run -f net8.0-android

# Windows
dotnet build -t:Run -f net8.0-windows10.0.19041.0
```

#### c) Script Integrado (criar)
`IniciarAmbienteMobile.ps1`:
```powershell
# Inicia backend em janela separada
Start-Process powershell -ArgumentList "-NoExit", "-Command", "dotnet run"

# Aguarda backend inicializar
Start-Sleep -Seconds 10

# Inicia mobile
Write-Host "Backend rodando! Iniciando mobile..." -ForegroundColor Green
dotnet build -t:Run -f net8.0-android
```

---

### 6. Checklist de Integração

- [ ] Resolver conflitos no appsettings.json
- [ ] Verificar/ajustar connection string do banco
- [ ] Confirmar porta da API (launchSettings.json)
- [ ] Copiar pasta SistemaChamados.Mobile para o workspace
- [ ] Atualizar appsettings.json do mobile com URL correta
- [ ] Adicionar endpoint JWT de login (se necessário)
- [ ] Testar conexão backend ↔ mobile
- [ ] Verificar CORS (deve permitir todas as origens)
- [ ] Testar criação de chamado via mobile
- [ ] Documentar usuários de teste

---

### 7. Usuários de Teste

**A definir:** Verificar se o GuiNRB já tem usuários seed ou criar script SQL.

Estrutura esperada:
```sql
-- Admin
INSERT INTO Usuarios (NomeCompleto, Email, SenhaHash, TipoUsuario)
VALUES ('Admin Sistema', 'admin@sistema.com', 'hash_aqui', 3);

-- Aluno/Colaborador
INSERT INTO Usuarios (NomeCompleto, Email, SenhaHash, TipoUsuario)
VALUES ('Aluno Teste', 'aluno@teste.com', 'hash_aqui', 1);
```

---

### 8. Troubleshooting

#### Backend não inicia:
```powershell
# Verificar se porta está ocupada
netstat -ano | findstr :5246

# Limpar e rebuildar
dotnet clean
dotnet build
```

#### Mobile não conecta:
```powershell
# Android: Usar 10.0.2.2 em vez de localhost
# No appsettings.json do mobile:
"BaseUrl": "http://10.0.2.2:5246"  # Para emulador Android
"BaseUrl": "http://192.168.X.X:5246"  # Para dispositivo físico (usar IP da máquina)
```

#### Erro de autenticação:
- Verificar se JWT está implementado
- Verificar se token é enviado no header: `Authorization: Bearer {token}`
- Verificar validade do token (expiração)

---

### 9. Próximos Passos

1. ✅ Criar branch `guinrb-develop`
2. ✅ Configurar remotes
3. ⏳ Resolver conflitos do appsettings.json
4. ⏳ Copiar projeto mobile para workspace
5. ⏳ Ajustar configurações do mobile
6. ⏳ Adicionar endpoint JWT (se necessário)
7. ⏳ Testar integração completa
8. ⏳ Documentar processo

---

**Data:** 27/10/2025  
**Status:** Em Progresso
