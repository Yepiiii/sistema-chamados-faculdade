# 🚀 Guia de Portabilidade - Sistema de Chamados

Este guia garante que o projeto funcione em **qualquer PC** e **qualquer celular Android**.

## 📋 Índice

- [Setup em Novo PC](#setup-em-novo-pc)
- [Configuração para Android Físico](#configuração-para-android-físico)
- [Solução de Problemas](#solução-de-problemas)
- [Checklist de Portabilidade](#checklist-de-portabilidade)

---

## 💻 Setup em Novo PC

### 1. Pré-requisitos

Instale as seguintes ferramentas:

- **.NET 8 SDK** → [Download](https://dotnet.microsoft.com/download/dotnet/8.0)
- **SQL Server LocalDB** → [Download](https://learn.microsoft.com/sql/database-engine/configure-windows/sql-server-express-localdb)
- **Git** → [Download](https://git-scm.com/downloads)
- **Visual Studio 2022** (opcional) → [Download](https://visualstudio.microsoft.com/)

### 2. Clonar Repositório

```powershell
git clone https://github.com/Yepiiii/sistema-chamados-faculdade.git
cd sistema-chamados-faculdade
```

### 3. Configurar Backend

#### 3.1. Criar appsettings.json

```powershell
cd Backend
cp appsettings.example.json appsettings.json
```

#### 3.2. Editar appsettings.json

Abra `Backend/appsettings.json` e configure:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=SistemaChamados;Trusted_Connection=True;Encrypt=False;"
  },
  "Jwt": {
    "Key": "GERE-UMA-CHAVE-ALEATORIA-COM-32-CARACTERES-MINIMO",
    "Issuer": "SistemaChamados",
    "Audience": "SistemaChamados"
  },
  "EmailSettings": {
    "SmtpServer": "smtp.gmail.com",
    "Port": 587,
    "SenderName": "Suporte Sistema",
    "SenderEmail": "seu-email@gmail.com",
    "Password": "sua-senha-de-app-do-gmail"
  },
  "OpenAI": {
    "ApiKey": "sk-proj-SUA-CHAVE-OPENAI"
  }
}
```

**⚠️ IMPORTANTE**: 
- Nunca commite `appsettings.json` com dados sensíveis!
- Use senhas de app do Gmail (não a senha da conta)
- Gere chave JWT aleatória (min. 32 caracteres)

#### 3.3. Criar Banco de Dados

```powershell
# Dentro de Backend/
dotnet restore
dotnet ef database update
```

#### 3.4. Criar Usuário Admin

```powershell
cd ..\Scripts
.\CriarAdmin.ps1
```

### 4. Configurar Mobile

```powershell
cd ..\Mobile
cp appsettings.example.json appsettings.json
```

O arquivo Mobile/appsettings.json é usado apenas para desenvolvimento Windows. Para Android, use o script de configuração automática (próxima seção).

### 5. Testar Localmente (Windows)

```powershell
cd ..\Scripts
.\IniciarSistema.ps1
```

Isso abrirá:
- API: http://localhost:5246
- Swagger: http://localhost:5246/swagger
- App Mobile (Windows)

---

## 📱 Configuração para Android Físico

### Passo 1: Detectar e Configurar IP Automaticamente

O script `ConfigurarIP.ps1` detecta automaticamente o IP da sua rede e atualiza o código Mobile:

```powershell
cd Scripts
.\ConfigurarIP.ps1
```

**O script faz:**
1. ✅ Detecta IP da rede local (ex: 192.168.0.18)
2. ✅ Atualiza `Mobile/Helpers/Constants.cs` com o IP correto
3. ✅ Cria backup do arquivo original
4. ✅ Mostra instruções para próximos passos

**Saída esperada:**
```
========================================
  Configurador de IP - Mobile APK
========================================

[1/3] Detectando IP da rede local...
[OK] IP detectado: 192.168.0.18

[2/3] Atualizando Constants.cs...
[OK] Constants.cs atualizado com IP: 192.168.0.18

[3/3] Configuração concluída!

========================================
  INFORMAÇÕES DE CONEXÃO
========================================

IP configurado: 192.168.0.18
URL da API: http://192.168.0.18:5246/api/
```

### Passo 2: Gerar APK

```powershell
.\GerarAPK.ps1
```

O APK será gerado em: `APK/SistemaChamados-v1.0.apk` (~65 MB)

### Passo 3: Configurar Firewall e Iniciar API

```powershell
.\IniciarAPIMobile.ps1
```

**O script faz:**
1. ✅ Cria regra de firewall (porta 5246)
2. ✅ Detecta IP da rede
3. ✅ Inicia API escutando em `0.0.0.0:5246` (aceita conexões externas)
4. ✅ Mostra credenciais de teste

### Passo 4: Testar Conexão (Antes de Instalar APK)

**No navegador do celular**, acesse:
```
http://SEU_IP:5246/swagger
```

✅ **Se abrir o Swagger** = Conexão OK! Pode instalar APK  
❌ **Se não abrir** = Problema de rede/firewall (veja [Solução de Problemas](#solução-de-problemas))

### Passo 5: Instalar APK no Celular

1. Copie `APK/SistemaChamados-v1.0.apk` para o celular (via USB, WhatsApp, email, etc.)
2. No celular, ative **"Fontes desconhecidas"** em Configurações → Segurança
3. Abra o APK e toque em **"Instalar"**
4. Abra o app e faça login com credenciais de teste

---

## 🔧 Solução de Problemas

### Problema: Celular não conecta na API

**Sintomas:**
- App mostra erro de conexão
- Swagger não abre no navegador do celular

**Soluções:**

#### 1. Verificar se celular está na mesma Wi-Fi
```powershell
# No PC, executar:
ipconfig
# Procurar por "Adaptador de Rede sem Fio" e anotar IP
```

No celular:
- Configurações → Wi-Fi → Nome da rede conectada
- Deve ser a **mesma rede** do PC

#### 2. Verificar Firewall do Windows

```powershell
# Verificar regra existe:
Get-NetFirewallRule -DisplayName "Sistema Chamados API"

# Se não existir, criar manualmente (como Admin):
New-NetFirewallRule -DisplayName "Sistema Chamados API" `
    -Direction Inbound `
    -LocalPort 5246 `
    -Protocol TCP `
    -Action Allow
```

#### 3. Verificar API está escutando na rede

```powershell
# Verificar porta 5246:
netstat -ano | findstr :5246
```

Deve mostrar: `0.0.0.0:5246` (escuta todas interfaces)

#### 4. IP Mudou (Wi-Fi diferente)

Se você conectou em uma **nova rede Wi-Fi**, o IP mudou!

**Solução:**
```powershell
cd Scripts
.\ConfigurarIP.ps1  # Detecta novo IP
.\GerarAPK.ps1      # Regera APK com novo IP
```

### Problema: Erro ao criar banco de dados

**Sintoma:**
```
Unable to connect to database...
```

**Soluções:**

1. Verificar SQL Server LocalDB instalado:
```powershell
sqllocaldb info
```

2. Criar instância se não existir:
```powershell
sqllocaldb create MSSQLLocalDB
sqllocaldb start MSSQLLocalDB
```

3. Testar conexão:
```powershell
cd Backend
dotnet ef database update
```

### Problema: Erro de compilação Mobile

**Sintoma:**
```
Error: Workload 'maui' not installed
```

**Solução:**
```powershell
dotnet workload install maui
```

---

## ✅ Checklist de Portabilidade

Use este checklist ao configurar o projeto em um **novo PC**:

### Backend
- [ ] .NET 8 SDK instalado
- [ ] SQL Server LocalDB instalado
- [ ] `appsettings.json` criado (copiar de `.example.json`)
- [ ] Connection String configurada
- [ ] JWT Key configurada (min. 32 caracteres)
- [ ] Email configurado (senha de app Gmail)
- [ ] OpenAI API Key configurada (opcional)
- [ ] `dotnet restore` executado
- [ ] `dotnet ef database update` executado
- [ ] Usuário admin criado (`CriarAdmin.ps1`)
- [ ] API inicia sem erros (`dotnet run`)

### Mobile (Windows)
- [ ] .NET MAUI workload instalado
- [ ] `appsettings.json` criado (copiar de `.example.json`)
- [ ] App compila sem erros

### Mobile (Android Físico)
- [ ] PC e celular na **mesma rede Wi-Fi**
- [ ] `ConfigurarIP.ps1` executado (detecta IP)
- [ ] `GerarAPK.ps1` executado (gera APK)
- [ ] Firewall configurado (porta 5246 liberada)
- [ ] `IniciarAPIMobile.ps1` executado (API rodando)
- [ ] Swagger acessível no navegador do celular
- [ ] APK instalado no celular
- [ ] App conecta na API e faz login

---

## 🌐 Compatibilidade de Rede

### Cenários Suportados

| Cenário | Configuração |
|---------|-------------|
| **Windows Desktop** | `http://localhost:5246/api/` |
| **Emulador Android** | `http://10.0.2.2:5246/api/` |
| **Celular Físico (mesma Wi-Fi)** | `http://SEU_IP:5246/api/` |

### Como o App Detecta a Plataforma

O arquivo `Mobile/Helpers/Constants.cs` usa compilação condicional:

```csharp
public static string BaseUrl
{
    get
    {
#if ANDROID
        // Celular físico
        return BaseUrlPhysicalDevice; // http://192.168.0.18:5246/api/
#elif WINDOWS
        return BaseUrlWindows; // http://localhost:5246/api/
#else
        return BaseUrlWindows;
#endif
    }
}
```

**Para Android Físico**, o IP é atualizado automaticamente pelo script `ConfigurarIP.ps1`.

---

## 📝 Scripts de Automação

Todos os scripts usam **caminhos relativos** e funcionam em qualquer PC:

| Script | Função |
|--------|--------|
| `ConfigurarIP.ps1` | Detecta IP e atualiza Constants.cs |
| `GerarAPK.ps1` | Gera APK para Android |
| `IniciarAPI.ps1` | Inicia API (localhost) |
| `IniciarAPIMobile.ps1` | Inicia API para mobile (rede) |
| `IniciarSistema.ps1` | Inicia API + Mobile (Windows) |
| `ValidarConfigAPK.ps1` | Valida configuração antes de gerar APK |
| `WorkflowAPK.ps1` | Workflow completo (validar → gerar → iniciar) |
| `CriarAdmin.ps1` | Cria usuário admin no banco |

---

## 🔐 Segurança

### Dados Sensíveis NÃO Commitados

Os seguintes arquivos contêm dados sensíveis e **NÃO devem ser commitados**:

- `Backend/appsettings.json` (senhas, API keys, connection strings)
- `Mobile/appsettings.json` (IPs específicos)
- `Mobile/Helpers/Constants.cs.backup` (backup automático)

**Arquivos de exemplo** (podem ser commitados):
- `Backend/appsettings.example.json`
- `Mobile/appsettings.example.json`

### .gitignore

O projeto já possui `.gitignore` configurado:

```gitignore
**/appsettings.json
**/appsettings.Development.json
*.backup
*.apk
```

---

## 🎯 Resumo: 3 Passos para Novo PC

```powershell
# 1. Clonar e configurar
git clone https://github.com/Yepiiii/sistema-chamados-faculdade.git
cd sistema-chamados-faculdade
cd Backend
cp appsettings.example.json appsettings.json
# Editar appsettings.json com suas configurações

# 2. Criar banco e admin
dotnet restore
dotnet ef database update
cd ..\Scripts
.\CriarAdmin.ps1

# 3. Iniciar sistema
.\IniciarSistema.ps1
```

## 📱 Resumo: Gerar APK para Celular

```powershell
cd Scripts

# 1. Configurar IP automaticamente
.\ConfigurarIP.ps1

# 2. Gerar APK
.\GerarAPK.ps1

# 3. Iniciar API para mobile
.\IniciarAPIMobile.ps1

# 4. Testar no celular (navegador)
# http://SEU_IP:5246/swagger

# 5. Instalar APK no celular
# APK/SistemaChamados-v1.0.apk
```

---

## 📞 Suporte

Se encontrar problemas:

1. Verifique o [Checklist de Portabilidade](#checklist-de-portabilidade)
2. Consulte [Solução de Problemas](#solução-de-problemas)
3. Verifique a documentação em `docs/`
4. Abra uma issue no GitHub

---

**Última atualização**: 21/10/2025  
**Versão**: 1.0
