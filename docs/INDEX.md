# 📚 ÍNDICE DA DOCUMENTAÇÃO

**Sistema de Chamados - Faculdade**  
Documentação organizada e consolidada

---

## 📁 ESTRUTURA

```
/
├── README.md                    # Documentação principal do projeto
├── WORKFLOWS.md                 # Guia de workflows e comandos
│
└── docs/
    ├── Mobile/                  # Documentação do aplicativo mobile
    │   ├── README.md
    │   ├── GuiaInstalacaoAPK.md
    │   ├── GerarAPK.md
    │   ├── ConfiguracaoIP.md
    │   ├── ComoTestar.md
    │   ├── TesteConectividade.md
    │   └── Troubleshooting.md
    │
    ├── Database/                # Documentação do banco de dados
    │   └── README.md
    │
    ├── Desenvolvimento/         # Documentação técnica
    │   ├── Arquitetura.md
    │   ├── EstruturaRepositorio.md
    │   ├── GeminiAPI.md
    │   └── ReorganizacaoScripts.md
    │
    └── _Archive/                # Arquivos obsoletos (backup)
        └── backup_YYYYMMDD_HHMMSS/
```

---

## 📖 GUIA DE LEITURA

### 🚀 INÍCIO RÁPIDO

**Para novos desenvolvedores:**
1. [README.md](../README.md) - Visão geral do projeto
2. [WORKFLOWS.md](../WORKFLOWS.md) - Como executar tarefas comuns
3. [docs/Desenvolvimento/Arquitetura.md](Desenvolvimento/Arquitetura.md) - Arquitetura do sistema

**Para gerar APK Mobile:**
1. [](docs/Mobile/README.md) - Visão geral do mobile
2. [docs/Mobile/GuiaInstalacaoAPK.md](Mobile/GuiaInstalacaoAPK.md) - Guia completo de instalação
3. [WORKFLOWS.md](../WORKFLOWS.md) - Comandos para gerar APK

---

## 📱 MOBILE

### Principais Documentos

| Arquivo | Descrição |
|---------|-----------|
| [](docs/Mobile/README.md) | Visão geral do app mobile |
| [GuiaInstalacaoAPK.md](Mobile/GuiaInstalacaoAPK.md) | Guia completo de instalação do APK |
| [GerarAPK.md](Mobile/GerarAPK.md) | Como compilar o APK |
| [ConfiguracaoIP.md](Mobile/ConfiguracaoIP.md) | Configurar IP para dispositivo físico |
| [ComoTestar.md](Mobile/ComoTestar.md) | Procedimentos de teste |
| [TesteConectividade.md](Mobile/TesteConectividade.md) | Testar conexão API ↔ Mobile |
| [Troubleshooting.md](Mobile/Troubleshooting.md) | Solução de problemas comuns |

### Workflows Mobile

**Gerar APK Completo:**
```powershell
.\Scripts\Mobile\ConfigurarIP.ps1
.\Scripts\Mobile\GerarAPK.ps1
```

**Testar Conectividade:**
- Navegador do celular: `http://192.168.1.XXX:5246/api/categorias`

---

## 💾 DATABASE

### Principais Documentos

| Arquivo | Descrição |
|---------|-----------|
| [README.md](Database/README.md) | Documentação do banco de dados |

### Workflows Database

**Inicializar Banco:**
```powershell
.\Scripts\Database\InicializarBanco.ps1
```

**Analisar Banco:**
```powershell
.\Scripts\Database\AnalisarBanco.ps1
```

**Limpar Chamados:**
```powershell
.\Scripts\Database\LimparChamados.ps1
```

---

## 👨‍💻 DESENVOLVIMENTO

### Principais Documentos

| Arquivo | Descrição |
|---------|-----------|
| [Arquitetura.md](Desenvolvimento/Arquitetura.md) | Arquitetura do sistema |
| [EstruturaRepositorio.md](Desenvolvimento/EstruturaRepositorio.md) | Estrutura de pastas e arquivos |
| [GeminiAPI.md](Desenvolvimento/GeminiAPI.md) | Integração com Google Gemini AI |
| [ReorganizacaoScripts.md](Desenvolvimento/ReorganizacaoScripts.md) | Histórico de reorganização |

### Tecnologias

**Backend:**
- ASP.NET Core 8
- Entity Framework Core
- SQL Server LocalDB
- Google Gemini AI

**Mobile:**
- .NET MAUI 8
- MVVM Pattern
- Android (net8.0-android)

---

## 🔧 SCRIPTS POWERSHELL

### Estrutura Organizada

```
Scripts/
├── API/
│   ├── IniciarAPI.ps1           # Inicia API com rede habilitada
│   └── ConfigurarFirewall.ps1   # Configura firewall Windows
│
├── Mobile/
│   ├── ConfigurarIP.ps1         # Detecta e configura IP Wi-Fi
│   └── GerarAPK.ps1             # Compila APK Android
│
├── Database/
│   ├── InicializarBanco.ps1     # Cria e popula banco
│   ├── AnalisarBanco.ps1        # Mostra estatísticas
│   └── LimparChamados.ps1       # Remove chamados
│
├── Teste/
│   ├── TestarAPI.ps1            # Testa endpoints
│   ├── TestarGemini.ps1         # Testa IA
│   └── TestarMobile.ps1         # Testa conectividade
│
└── Dev/
    └── ReorganizarProjeto.ps1   # Organiza estrutura
```

Ver [WORKFLOWS.md](../WORKFLOWS.md) para guia completo de uso.

---

## 📋 ARQUIVOS PRINCIPAIS NA RAIZ

| Arquivo | Descrição |
|---------|-----------|
| `README.md` | Documentação principal do projeto |
| `WORKFLOWS.md` | Guia de workflows e comandos |
| `appsettings.json` | Configurações da API |
| `SistemaChamados.csproj` | Projeto principal .NET |

---

## 🗂️ ARQUIVO (_Archive)

Documentos obsoletos e históricos foram movidos para `docs/_Archive/` incluindo:

- Relatórios de commits antigos
- Documentação de funcionalidades já implementadas
- Guias obsoletos de instalação
- Diagnósticos e correções históricas
- Documentação duplicada

**Backup completo em:** `docs/_Archive/backup_YYYYMMDD_HHMMSS/`

---

## 🔄 ATUALIZAÇÕES

**Última reorganização:** 23/10/2025

**Mudanças:**
- ✅ 69 arquivos → 15 arquivos ativos (78% de redução)
- ✅ Organização por categoria (Mobile, Database, Dev)
- ✅ Eliminação de duplicados
- ✅ Backup completo preservado
- ✅ Links atualizados

---

## 📞 CREDENCIAIS DE TESTE

```
Email: admin@teste.com
Senha: Admin123!
Tipo: Administrador (TipoUsuario=3)
```

---

## 🔗 LINKS ÚTEIS

- **GitHub:** https://github.com/Yepiiii/sistema-chamados-faculdade
- **Branch:** mobile-simplified
- **API Local:** http://localhost:5246
- **Swagger:** http://localhost:5246/swagger

---

**✨ Documentação mantida atualizada e organizada!**

