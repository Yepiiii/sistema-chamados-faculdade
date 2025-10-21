# 📖 Guia de Instalação - Sistema de Chamados

> **Versão:** 1.0  
> **Data:** Outubro 2025  
> **Ambiente:** Windows 10/11 com .NET 8

---

## 📋 Índice

1. [Pré-requisitos](#-pré-requisitos)
2. [Instalação do Backend](#-instalação-do-backend)
3. [Configuração do Mobile](#-configuração-do-mobile)
4. [Uso no Dia a Dia](#-uso-no-dia-a-dia)
5. [Solução de Problemas](#-solução-de-problemas)

---

## 🔧 Pré-requisitos

### Software Necessário

| Software | Versão | Link | Obrigatório |
|----------|--------|------|-------------|
| .NET SDK | 8.0+ | https://dotnet.microsoft.com/download | ✅ Sim |
| SQL Server LocalDB | 2019+ | Incluído no Visual Studio | ✅ Sim |
| PowerShell | 5.1+ | Incluído no Windows | ✅ Sim |
| Visual Studio 2022 | Community+ | https://visualstudio.microsoft.com | ⚠️ Recomendado |
| Android SDK | API 21+ | Via Visual Studio ou Android Studio | ⚠️ Para APK |
| Git | Qualquer | https://git-scm.com/ | ✅ Sim |

### Verificar Instalação

```powershell
# Verificar .NET
dotnet --version
# Deve mostrar: 8.0.x ou superior

# Verificar PowerShell
$PSVersionTable.PSVersion
# Deve mostrar: 5.1 ou superior

# Verificar SQL LocalDB
sqllocaldb v
# Deve mostrar: mssqllocaldb
```

---

## 🚀 Instalação do Backend

### Passo 1: Clonar Repositório

```powershell
# Escolha uma pasta (ex: C:\Projetos)
cd C:\Projetos

# Clonar do GitHub
git clone https://github.com/Yepiiii/sistema-chamados-faculdade.git

# Entrar na pasta
cd sistema-chamados-faculdade\sistema-chamados-faculdade
```

### Passo 2: Configurar Backend

```powershell
# Entrar na pasta Backend
cd Backend

# Criar arquivo de configuração (copiar do exemplo)
Copy-Item appsettings.example.json appsettings.json

# Editar appsettings.json e adicionar sua chave Gemini AI
notepad appsettings.json
```

**Conteúdo do `appsettings.json`:**

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=SistemaChamados;Trusted_Connection=True;"
  },
  "GeminiAI": {
    "ApiKey": "SUA_CHAVE_AQUI"
  },
  "Jwt": {
    "Key": "chave-super-secreta-para-jwt-com-minimo-32-caracteres",
    "Issuer": "SistemaChamados",
    "Audience": "SistemaChamadosUsers"
  }
}
```

**📝 Como obter chave Gemini AI:**
1. Acesse: https://makersuite.google.com/app/apikey
2. Faça login com conta Google
3. Clique em "Create API Key"
4. Copie e cole no `appsettings.json`

### Passo 3: Criar Banco de Dados

```powershell
# Restaurar dependências
dotnet restore

# Aplicar migrations (criar banco)
dotnet ef database update

# Verificar se banco foi criado
sqllocaldb info mssqllocaldb
```

### Passo 4: Popular Dados Iniciais

```powershell
# Voltar para Scripts
cd ..\Scripts

# Criar usuários de teste
.\SetupUsuariosTeste.ps1

# Criar chamados de demonstração (opcional)
.\CriarChamadosDemoCorrigido.ps1
```

**👥 Usuários Criados:**

| Tipo | Email | Senha |
|------|-------|-------|
| Aluno | aluno@sistema.com | Aluno@123 |
| Professor | professor@sistema.com | Prof@123 |
| Admin | admin@sistema.com | Admin@123 |

### Passo 5: Testar Backend

```powershell
# Iniciar API
.\IniciarAPI.ps1

# Em outro terminal, testar
.\TestarAPI.ps1
```

**✅ Se tudo estiver OK, você verá:**
- API rodando em: http://localhost:5246
- Swagger UI em: http://localhost:5246/swagger
- Testes passando

---

## 📱 Configuração do Mobile

### Passo 1: Configurar IP Local

**Este passo é necessário apenas para gerar APK para Android físico.**

```powershell
# Na pasta Scripts
cd Scripts

# Detectar e configurar IP automaticamente
.\ConfigurarIP.ps1
```

**O que esse script faz:**
- ✅ Detecta automaticamente seu IP local (ex: 192.168.0.18)
- ✅ Filtra redes virtuais (VirtualBox, VMware)
- ✅ Atualiza `Mobile\Helpers\Constants.cs`
- ✅ Cria backup automático

**Exemplo de saída:**
```
[OK] IP detectado: 192.168.0.18
    Interface: Wi-Fi
[OK] Constants.cs atualizado!
    Nova URL: http://192.168.0.18:5246/api/
```

### Passo 2: Gerar APK

```powershell
# Gerar APK assinado
.\GerarAPK.ps1
```

**O APK será criado em:**
```
APK/SistemaChamados-v1.0.apk
```

### Passo 3: Iniciar API para Rede

**Importante:** A API precisa aceitar conexões de outros dispositivos na rede.

```powershell
# Iniciar API em modo rede
.\IniciarAPIMobile.ps1
```

**Verificar conexão:**

No celular, abra o navegador:
```
http://SEU_IP:5246/swagger
```

Se abrir o Swagger UI, está funcionando! ✅

### Passo 4: Instalar APK

1. Copie o APK para o celular (via cabo USB, WhatsApp, email, etc)
2. No celular, permita instalação de fontes desconhecidas
3. Instale o APK
4. Abra o app e faça login

---

## 🎯 Uso no Dia a Dia

### Para Desenvolvimento Local (Windows)

```powershell
# Iniciar tudo de uma vez
.\IniciarSistemaWindows.ps1

# Ou iniciar separadamente
.\IniciarAPI.ps1        # Backend
.\IniciarApp.ps1        # Mobile app Windows
```

### Para Testar no Celular

**1ª vez ou após mudar de rede WiFi:**

```powershell
# 1. Configurar IP
.\ConfigurarIP.ps1

# 2. Gerar novo APK
.\GerarAPK.ps1

# 3. Instalar no celular
# (Copiar APK/SistemaChamados-v1.0.apk)

# 4. Iniciar API em modo rede
.\IniciarAPIMobile.ps1
```

**Uso diário (mesmo IP):**

```powershell
# Apenas iniciar API em modo rede
.\IniciarAPIMobile.ps1

# APK continua funcionando!
```

---

## ❓ Solução de Problemas

### 🔴 "API não inicia"

**Sintomas:** Erro ao executar `dotnet run` ou `IniciarAPI.ps1`

**Soluções:**

1. Verificar porta ocupada:
```powershell
netstat -ano | findstr :5246
# Se mostrar processo, matar:
taskkill /PID <numero_do_pid> /F
```

2. Verificar banco de dados:
```powershell
sqllocaldb start mssqllocaldb
dotnet ef database update
```

3. Verificar appsettings.json:
```powershell
# Deve existir e ter chave Gemini válida
Test-Path .\Backend\appsettings.json
```

### 🔴 "Celular não conecta na API"

**Sintomas:** App mostra "Erro de conexão" ou timeout

**Checklist:**

✅ **1. Celular e PC na mesma rede WiFi**
```powershell
# Ver seu IP:
ipconfig | Select-String "IPv4"

# No celular, testar no navegador:
# http://SEU_IP:5246/swagger
```

✅ **2. Firewall liberado**
```powershell
# Liberar porta 5246
New-NetFirewallRule -DisplayName "Sistema Chamados API" `
    -Direction Inbound -LocalPort 5246 -Protocol TCP -Action Allow
```

✅ **3. API rodando em modo rede**
```powershell
# NÃO usar: dotnet run
# USAR: .\IniciarAPIMobile.ps1
# Ou: dotnet run --urls="http://0.0.0.0:5246"
```

✅ **4. Constants.cs atualizado**
```powershell
# Ver IP configurado:
Get-Content .\Mobile\Helpers\Constants.cs | Select-String "BaseUrlPhysicalDevice"

# Deve mostrar: http://SEU_IP:5246/api/
# Se estiver errado: .\ConfigurarIP.ps1
```

### 🔴 "Falha ao gerar APK"

**Sintomas:** Erro ao executar `GerarAPK.ps1`

**Soluções:**

1. Instalar workload Android:
```powershell
dotnet workload install maui-android
```

2. Verificar SDK:
```powershell
dotnet workload list
# Deve mostrar: maui-android [Installed]
```

3. Limpar build anterior:
```powershell
cd Mobile
dotnet clean
dotnet build -f net8.0-android -c Release
```

### 🔴 "App crasha ao abrir"

**Sintomas:** App fecha imediatamente após abrir

**Soluções:**

1. Verificar logs do Android (via USB debugging):
```powershell
adb logcat | Select-String "SistemaChamados"
```

2. Reinstalar app:
```powershell
# Desinstalar completamente do celular
# Gerar novo APK
.\GerarAPK.ps1
# Instalar novamente
```

3. Verificar versão Android:
```
Mínimo: Android 5.0 (API 21)
Recomendado: Android 8.0+ (API 26+)
```

---

## 📊 Estrutura de Pastas

```
sistema-chamados-faculdade/
├── Backend/                    # API .NET 8
│   ├── API/                   # Controllers
│   ├── Application/           # Services e DTOs
│   ├── Core/                  # Entities
│   ├── Data/                  # DbContext
│   └── appsettings.json       # Configurações (não versionado)
│
├── Mobile/                     # App MAUI
│   ├── Helpers/               # Constants.cs (IP configurado aqui)
│   ├── Models/                # DTOs e Entities
│   ├── Services/              # API clients
│   ├── ViewModels/            # Lógica de apresentação
│   └── Views/                 # Telas XAML
│
├── Scripts/                    # Automação PowerShell
│   ├── ConfigurarIP.ps1       # ⭐ Detectar IP automaticamente
│   ├── GerarAPK.ps1           # ⭐ Gerar APK
│   ├── IniciarAPI.ps1         # Iniciar backend
│   ├── IniciarAPIMobile.ps1   # ⭐ Iniciar para rede
│   └── SetupUsuariosTeste.ps1 # Criar usuários
│
├── APK/                        # APKs gerados
│   └── SistemaChamados-v1.0.apk
│
├── docs/                       # Documentação adicional
│
└── GUIA_INSTALACAO.md         # ⭐ Este arquivo
```

---

## 🔒 Arquivos Ignorados no Git

**Estes arquivos NÃO são versionados (.gitignore):**

```
Backend/appsettings.json        # Contém chaves API
Mobile/Helpers/Constants.cs     # Contém IP local
myapp.keystore                   # Certificado Android
.env                            # Variáveis de ambiente
bin/, obj/                      # Builds
```

**Por isso, ao clonar em outro PC:**
1. ✅ Execute `ConfigurarIP.ps1` (cria Constants.cs com seu IP)
2. ✅ Crie `appsettings.json` (copie do exemplo)

---

## ✅ Checklist de Instalação

**Primeira vez em um PC:**

- [ ] .NET 8 instalado
- [ ] SQL LocalDB instalado
- [ ] Repositório clonado
- [ ] `appsettings.json` criado e configurado
- [ ] `dotnet ef database update` executado
- [ ] Usuários de teste criados (`SetupUsuariosTeste.ps1`)
- [ ] API testada (`IniciarAPI.ps1` + Swagger)

**Para gerar APK:**

- [ ] `ConfigurarIP.ps1` executado
- [ ] IP detectado corretamente (não é 192.168.56.x ou 192.168.137.x)
- [ ] `GerarAPK.ps1` executado com sucesso
- [ ] APK copiado para celular
- [ ] `IniciarAPIMobile.ps1` rodando
- [ ] Celular e PC na mesma WiFi
- [ ] Swagger acessível do celular (http://SEU_IP:5246/swagger)
- [ ] App instalado e funcionando

---

## 📞 Suporte

**Documentação adicional:**
- `CREDENCIAIS_TESTE.md` - Usuários e senhas
- `docs/SETUP_PORTABILIDADE.md` - Detalhes de portabilidade
- `docs/SOLUCAO_IP_REDE.md` - Troubleshooting de rede

**Logs úteis:**
- Backend: Console do PowerShell (`IniciarAPI.ps1`)
- Mobile Android: `adb logcat`
- Mobile Windows: Output do Visual Studio

---

**Última atualização:** Outubro 2025  
**Versão do guia:** 1.0  
**Compatível com:** Windows 10/11, .NET 8, Android 5.0+
