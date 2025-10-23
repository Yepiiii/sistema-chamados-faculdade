# � Sistema de Suporte Técnico - Empresa

> Sistema completo de gerenciamento de suporte técnico de TI com backend .NET 8, app mobile multiplataforma (.NET MAUI) e IA integrada (Google Gemini).

[![.NET](https://img.shields.io/badge/.NET-8.0-512BD4?logo=dotnet)](https://dotnet.microsoft.com/)
[![C#](https://img.shields.io/badge/C%23-12.0-239120?logo=csharp)](https://docs.microsoft.com/dotnet/csharp/)
[![MAUI](https://img.shields.io/badge/MAUI-8.0-512BD4?logo=dotnet)](https://dotnet.microsoft.com/apps/maui)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

---

## 📋 Índice

- [Sobre o Projeto](#-sobre-o-projeto)
- [Funcionalidades](#-funcionalidades)
- [Tecnologias](#-tecnologias)
- [Instalação Rápida](#-instalação-rápida)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Uso](#-uso)
- [Documentação](#-documentação)
- [Contribuindo](#-contribuindo)

---

## 🎯 Sobre o Projeto

Sistema desenvolvido para centralizar e otimizar o suporte técnico de TI empresarial, permitindo que colaboradores, técnicos de TI e administradores reportem e acompanhem problemas de infraestrutura (hardware, software, rede).

### ✨ Diferenciais

- 🤖 **IA Integrada**: Classificação automática de chamados usando Google Gemini AI
- 📱 **Cross-platform**: App mobile para Android, iOS e Windows
- 🔐 **Autenticação JWT**: Sistema seguro de autenticação e autorização
- 📊 **Dashboard Interativo**: Visualização de estatísticas em tempo real
- 🔔 **Notificações**: Sistema de notificações push para atualizações

---

## ⚡ Funcionalidades

### Para Colaboradores
- ✅ Criar chamados com descrição do problema técnico
- ✅ Classificação automática por IA (categoria + prioridade)
- ✅ Acompanhar status dos chamados
- ✅ Receber notificações de atualizações

### Para Técnicos de TI
- ✅ Todas as funcionalidades de colaboradores
- ✅ Atribuição automática de chamados (baseado em área de atuação)
- ✅ Atualizar status de chamados atribuídos
- ✅ Gerenciar fila de atendimentos

### Para Administradores
- ✅ Visualizar todos os chamados do sistema
- ✅ Atribuir técnicos manualmente
- ✅ Encerrar chamados
- ✅ Gerenciar categorias e prioridades
- ✅ Dashboard com estatísticas completas

---

## 🛠️ Tecnologias

### Backend
- **.NET 8** - Framework principal
- **ASP.NET Core Web API** - API RESTful
- **Entity Framework Core** - ORM
- **SQL Server LocalDB** - Banco de dados
- **JWT Bearer** - Autenticação
- **BCrypt.Net** - Hash de senhas
- **Google Gemini AI** - Classificação inteligente
- **Swagger/OpenAPI** - Documentação da API

### Mobile
- **.NET MAUI** - Framework multiplataforma
- **MVVM Pattern** - Arquitetura
- **CommunityToolkit.Mvvm** - Helpers MVVM
- **HttpClient** - Comunicação com API
- **Android Notifications** - Notificações nativas

### DevOps
- **PowerShell** - Scripts de automação
- **Git** - Controle de versão
- **GitHub Actions** - CI/CD (em desenvolvimento)

---

## 🚀 Instalação Rápida

### Pré-requisitos

| Software | Versão | Link |
|----------|--------|------|
| .NET SDK | 8.0+ | https://dotnet.microsoft.com/download |
| SQL Server LocalDB | 2019+ | Incluído no Visual Studio |
| PowerShell | 5.1+ | Incluído no Windows |

### Instalação em 5 Comandos

```powershell
# 1. Clonar repositório
git clone https://github.com/Yepiiii/sistema-chamados-faculdade.git
cd sistema-chamados-faculdade\sistema-chamados-faculdade

# 2. Configurar chave Gemini AI
cd Backend
# Edite appsettings.json e adicione sua chave Gemini em "GeminiAI.ApiKey"

# 3. Criar banco de dados
dotnet ef database update

# 4. Popular dados iniciais
cd ..\Scripts
.\SetupUsuariosTeste.ps1

# 5. Iniciar sistema
.\IniciarSistema.ps1
```

**📖 Guia Completo:** [](WORKFLOWS.md)

---

## 📁 Estrutura do Projeto

```
sistema-chamados-faculdade/
├── Backend/                    # 🔧 API .NET 8
│   ├── API/                   # Controllers REST
│   ├── Application/           # Services e DTOs
│   ├── Core/                  # Entities do domínio
│   ├── Data/                  # DbContext e Migrations
│   └── appsettings.json       # Configurações (não versionado)
│
├── Mobile/                     # 📱 App MAUI
│   ├── Helpers/               # Constants.cs (configuração de IP)
│   ├── Models/                # DTOs e Entities
│   ├── Services/              # Clients da API
│   ├── ViewModels/            # MVVM ViewModels
│   ├── Views/                 # Telas XAML
│   └── Platforms/             # Código específico de plataforma
│       └── Android/           # NotificationService.cs
│
├── Scripts/                    # ⚙️ Automação PowerShell
│   ├── ConfigurarIP.ps1       # ⭐ Detectar IP local automaticamente
│   ├── GerarAPK.ps1           # ⭐ Gerar APK Android
│   ├── IniciarAPI.ps1         # Iniciar backend
│   ├── IniciarAPIMobile.ps1   # ⭐ Iniciar API para rede local
│   ├── IniciarSistema.ps1     # Iniciar tudo de uma vez
│   └── SetupUsuariosTeste.ps1 # Criar usuários de teste
│
├── docs/                       # 📚 Documentação técnica
│   ├── SETUP_PORTABILIDADE.md
│   └── SOLUCAO_IP_REDE.md
│
├── APK/                        # 📦 APKs gerados (não versionado)
│
├── GUIA_INSTALACAO.md         # 📖 Guia completo de instalação
├── CREDENCIAIS_TESTE.md       # 🔐 Usuários de teste
└── README.md                  # Este arquivo
```

---

## 💻 Uso

### Desenvolvimento Local (Windows)

```powershell
# Iniciar backend e app Windows
.\Scripts\IniciarSistemaWindows.ps1

# Ou separadamente
.\Scripts\IniciarAPI.ps1        # Backend em http://localhost:5246
.\Scripts\IniciarApp.ps1        # App Windows
```

### Gerar APK para Android

```powershell
# 1. Detectar IP local automaticamente
.\Scripts\ConfigurarIP.ps1

# 2. Gerar APK assinado
.\Scripts\GerarAPK.ps1

# 3. Iniciar API em modo rede
.\Scripts\IniciarAPIMobile.ps1

# 4. Instalar APK no celular
# APK estará em: APK/SistemaChamados-v1.0.apk
```

### Usuários de Teste

| Tipo | Email | Senha |
|------|-------|-------|
| Aluno | aluno@sistema.com | Aluno@123 |
| Professor | professor@sistema.com | Prof@123 |
| Admin | admin@sistema.com | Admin@123 |

**📄 Detalhes:** [](docs/INDEX.md)

---

## 📚 Documentação

### Guias Principais
- **[](WORKFLOWS.md)** - Instalação completa passo a passo
- **[](docs/INDEX.md)** - Usuários e permissões
- **[](docs/INDEX.md)** - Portabilidade entre PCs

### API
- **Swagger UI:** http://localhost:5246/swagger
- **Endpoints:** Documentados no Swagger
- **Autenticação:** JWT Bearer Token

### Scripts PowerShell

| Script | Descrição |
|--------|-----------|
| `ConfigurarIP.ps1` | Detecta IP local e atualiza Constants.cs |
| `GerarAPK.ps1` | Gera APK Android assinado |
| `IniciarAPI.ps1` | Inicia backend em localhost |
| `IniciarAPIMobile.ps1` | Inicia backend para rede (0.0.0.0) |
| `IniciarSistema.ps1` | Inicia backend + mobile Windows |
| `SetupUsuariosTeste.ps1` | Cria 3 usuários de teste |
| `CriarChamadosDemoCorrigido.ps1` | Cria chamados de exemplo |

---

## 🔧 Configuração Avançada

### Chave Gemini AI

1. Obtenha uma chave em: https://makersuite.google.com/app/apikey
2. Edite `Backend/appsettings.json`:

```json
{
  "GeminiAI": {
    "ApiKey": "SUA_CHAVE_AQUI"
  }
}
```

### IP para Android Físico

O sistema detecta automaticamente o IP local. Se precisar ajustar manualmente:

```powershell
# Detectar IP
ipconfig | Select-String "IPv4"

# Configurar automaticamente
.\Scripts\ConfigurarIP.ps1
```

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Para contribuir:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/NovaFuncionalidade`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/NovaFuncionalidade`)
5. Abra um Pull Request

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 👥 Autores

- **Opera** - *Desenvolvimento inicial* - [Yepiiii](https://github.com/Yepiiii)

---

## 🙏 Agradecimentos

- Google Gemini AI pela API de classificação inteligente
- Comunidade .NET MAUI
- Contribuidores open-source

---

**⭐ Se este projeto te ajudou, considere dar uma estrela!**

---

**Última atualização:** Outubro 2025  
**Versão:** 1.0.0  
**Status:** ✅ Em produção




## 📁 Estrutura do ProjetoSistema completo de gerenciamento de chamados técnicos com backend .NET 8 e aplicativo mobile multiplataforma (.NET MAUI).API desenvolvida em ASP.NET Core 8 para gerenciamento de chamados de suporte técnico em ambiente acadêmico.



```

sistema-chamados-faculdade/

├── Backend/              # API REST ASP.NET Core 8## 📁 Estrutura do Projeto## 🏗️ Arquitetura

├── Mobile/               # App mobile .NET MAUI (Android, iOS, Windows)

├── Scripts/              # Scripts PowerShell de automação

├── docs/                 # Documentação técnica completa

├── APK/                  # Builds Android (gitignored)```O projeto segue uma arquitetura limpa com separação de responsabilidades:

└── SistemaChamados.sln  # Solution com ambos os projetos

```sistema-chamados-faculdade/



## 🚀 Início Rápido├── Backend/              # API REST ASP.NET Core 8```



### Pré-requisitos├── Mobile/               # App mobile .NET MAUI (Android, iOS, Windows)SistemaChamados/



- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)├── Scripts/              # Scripts PowerShell de automação├── Core/

- [SQL Server LocalDB](https://learn.microsoft.com/sql/database-engine/configure-windows/sql-server-express-localdb)

- [Git](https://git-scm.com/downloads)├── Docs/                 # Documentação técnica completa│   └── Entities/          # Entidades do domínio

- Para mobile: [.NET MAUI workload](https://learn.microsoft.com/dotnet/maui/get-started/installation)

├── APK/                  # Builds Android (gitignored)├── Application/

### Instalação (6 Passos)

└── SistemaChamados.sln  # Solution com ambos os projetos│   └── DTOs/              # Data Transfer Objects

```bash

# 1. Clone o repositório```├── API/

git clone https://github.com/Yepiiii/sistema-chamados-faculdade.git

cd sistema-chamados-faculdade│   └── Controllers/       # Controllers da API



# 2. Restaure dependências## 🚀 Início Rápido└── Data/                  # Contexto do Entity Framework

dotnet restore

```

# 3. Configure appsettings.json

cd Backend### Pré-requisitos

cp appsettings.example.json appsettings.json

# Edite appsettings.json com suas configurações## 🚀 Tecnologias Utilizadas



# 4. Execute migrations- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)

dotnet ef database update

cd ..- [Visual Studio 2022](https://visualstudio.microsoft.com/) ou [VS Code](https://code.visualstudio.com/)- **ASP.NET Core 8** - Framework web



# 5. Crie usuário admin- [SQL Server LocalDB](https://learn.microsoft.com/sql/database-engine/configure-windows/sql-server-express-localdb)- **Entity Framework Core** - ORM para acesso a dados

cd Scripts

.\CriarAdmin.ps1- Para mobile: [Android SDK](https://developer.android.com/studio)- **SQL Server** - Banco de dados



# 6. Inicie o sistema- **BCrypt.Net** - Hash seguro de senhas

.\IniciarSistema.ps1

```### Instalação (6 Passos)- **Swagger/OpenAPI** - Documentação da API



## 📱 Gerar APK para Android



### ⚡ Configuração Rápida (3 Passos)```bash## 📋 Funcionalidades Implementadas



Para dispositivos Android físicos:# 1. Clone o repositório



```powershellgit clone https://github.com/Yepiiii/sistema-chamados-faculdade.git### ✅ Registro de Usuário Admin

cd Scripts

cd sistema-chamados-faculdade

# 1. Detecta IP automaticamente e atualiza código

.\ConfigurarIP.ps1- **Endpoint**: `POST /api/usuarios/registrar-admin`



# 2. Gera APK (~65 MB)# 2. Restaure dependências- **Descrição**: Registra um novo usuário do tipo Administrador

.\GerarAPK.ps1

dotnet restore- **Validações**:

# 3. Inicia API para mobile

.\IniciarAPIMobile.ps1  - Email único no sistema

```

# 3. Configure connection string (Backend/appsettings.json)  - Campos obrigatórios

APK gerado em: `APK/SistemaChamados-v1.0.apk`

  - Formato de email válido

### ✅ Testar Conexão (Antes de Instalar APK)

# 4. Execute migrations  - Senha com mínimo de 6 caracteres

No navegador do celular, acesse:

```cd Backend- **Segurança**: Senha criptografada com BCrypt

http://SEU_IP:5246/swagger

```dotnet ef database update



- ✅ **Se abrir o Swagger** → Conexão OK! Instale o APKcd ..#### Exemplo de Requisição:

- ❌ **Se não abrir** → Veja [](docs/INDEX.md)

```json

### 📋 Requisitos Android

# 5. Inicie o sistema{

- ✅ PC e celular na **mesma rede Wi-Fi**

- ✅ Firewall liberado (porta 5246)cd Scripts  "nomeCompleto": "Administrador do Sistema",

- ✅ IP configurado em `Mobile/Helpers/Constants.cs`

.\IniciarSistema.ps1 -Plataforma windows  "email": "admin@faculdade.edu.br",

## 📚 Documentação Completa

```  "senha": "Admin123!"

### Guias Principais

}

- **[](docs/INDEX.md)** - Setup para qualquer PC/Android
- **[](docs/INDEX.md)** - Usar app de qualquer lugar (4G, internet)
- **[](docs/INDEX.md)** - Usuários para testes
- **[](docs/Mobile/README.md)** - Design e funcionalidades



### Documentação Técnica

```powershell#### Exemplo de Resposta (201 Created):

- **[](docs/Desenvolvimento/EstruturaRepositorio.md)**

- **[](docs/Database/README.md)**cd Scripts```json

- **[](docs/Mobile/GerarAPK.md)**

- **[](docs/Mobile/README.md)**.\GerarAPK.ps1{



## 🎯 Funcionalidades```  "id": 1,



### Backend (API REST)  "nomeCompleto": "Administrador do Sistema",



- ✅ Autenticação JWT com rolesAPK gerado em: `APK/SistemaChamados-v1.0.apk`  "email": "admin@faculdade.edu.br",

- ✅ CRUD completo de chamados

- ✅ Classificação automática (IA Gemini)  "tipoUsuario": 3,

- ✅ Upload de anexos (imagens)

- ✅ Sistema de comentários## 📚 Documentação  "dataCadastro": "2025-09-16T02:45:00.000Z",

- ✅ Histórico de alterações

- ✅ Notificações em tempo real  "ativo": true

- ✅ API REST documentada (Swagger)

- ✅ Correção automática de timezone (UTC → Local)- **[](WORKFLOWS.md)**}



### Mobile (.NET MAUI)- **[Credenciais de Teste](Docs/CREDENCIAIS_TESTE.md)**```



- ✅ **Multiplataforma**: Android, iOS, Windows- **[Overview Mobile](Docs/OVERVIEW_MOBILE_UI_UX.md)**

- ✅ **Material Design 3** com tema escuro

- ✅ **Bottom Navigation** (Dashboard, Chamados, Perfil)- **[](docs/Desenvolvimento/EstruturaRepositorio.md)**## 🗄️ Banco de Dados

- ✅ **Pull-to-refresh** em todas as listas

- ✅ **Filtros avançados** (status, prioridade, categoria)

- ✅ **Upload de imagens** com preview

- ✅ **Comentários** com avatar e timestamp## 🎯 Funcionalidades### Script de Criação

- ✅ **Timeline** de histórico visual

- ✅ **Notificações** push (Android/iOS)Execute o script `Scripts/CreateDatabase.sql` no SQL Server para criar todas as tabelas necessárias.

- ✅ **Polling automático** de atualizações

- ✅ **Timezone** automático (UTC → Local)### Backend

- ✅ **Cache** inteligente de dados

- ✅ Autenticação JWT### Estrutura das Tabelas

## 🛠️ Tecnologias

- ✅ CRUD de chamados

### Backend

- ✅ Classificação IA (Gemini)O projeto utiliza as seguintes entidades principais:

- **ASP.NET Core 8** - Framework web moderno

- **Entity Framework Core 8** - ORM para banco de dados- ✅ API REST documentada (Swagger)

- **SQL Server** - Banco de dados relacional

- **JWT Authentication** - Autenticação segura1. **Usuarios**: Informações básicas dos usuários do sistema

- **BCrypt.Net** - Hash de senhas

- **Swagger/OpenAPI** - Documentação automática### Mobile2. **AlunoPerfil**: Perfil específico para alunos (relacionamento 1:1 com Usuarios)

- **Google Gemini API** - IA para classificação

- ✅ Android, iOS, Windows3. **ProfessorPerfil**: Perfil específico para professores (relacionamento 1:1 com Usuarios)

### Mobile

- ✅ Material Design4. **Categorias**: Categorias para classificação dos chamados

- **.NET MAUI 8** - Framework multiplataforma

- **MVVM Pattern** - Arquitetura limpa- ✅ Filtros avançados5. **Chamados**: Chamados de suporte técnico

- **CommunityToolkit.MVVM** - Helpers MVVM

- **HttpClient** - Comunicação com API- ✅ Pull-to-refresh6. **HistoricoChamado**: Histórico de alterações nos chamados

- **Material Design** - Design system do Google

- ✅ Bottom navigation

## 📦 Scripts de Automação

- ✅ Timezone UTC → Local### Tipos de Usuário:

Todos os scripts usam **caminhos relativos** e funcionam em qualquer PC:

- `1` - Aluno

| Script | Função |

|--------|--------|## 🛠️ Tecnologias- `2` - Professor  

| `ConfigurarIP.ps1` | 🔧 Detecta IP e atualiza Constants.cs automaticamente |

| `GerarAPK.ps1` | 📱 Gera APK para Android |- `3` - Administrador

| `IniciarAPI.ps1` | ▶️ Inicia API (localhost apenas) |

| `IniciarAPIMobile.ps1` | 📡 Inicia API para rede (mobile) |**Backend:** ASP.NET Core 8 • EF Core 8 • SQL Server • JWT • Gemini API  

| `IniciarSistema.ps1` | 🚀 Inicia API + Mobile (Windows) |

| `ValidarConfigAPK.ps1` | ✅ Valida configuração antes de gerar APK |**Mobile:** .NET MAUI 8 • MVVM • HttpClient### Relacionamentos:

| `WorkflowAPK.ps1` | 🔄 Workflow completo (validar → gerar → iniciar) |

| `CriarAdmin.ps1` | 👤 Cria usuário admin no banco |- Usuario 1:1 AlunoPerfil (opcional)

| `TestarAPI.ps1` | 🧪 Testa endpoints da API |

| `TestarConectividadeMobile.ps1` | 📶 Testa conectividade mobile |## 📦 Scripts- Usuario 1:1 ProfessorPerfil (opcional)



## 🐛 Troubleshooting- Usuario 1:N Chamados (como solicitante)



### API não inicia| Script | Descrição |- Usuario 1:N Chamados (como atribuído)



```powershell|--------|-----------|- Categoria 1:N Chamados

# Verificar .NET 8 SDK instalado

dotnet --version| `IniciarSistema.ps1` | Inicia API + Mobile |- Chamado 1:N HistoricoChamado



# Verificar connection string| `GerarAPK.ps1` | Gera APK Android |

# Editar Backend/appsettings.json

```| `TestarAPI.ps1` | Testa endpoints |## ⚙️ Configuração



### Mobile não conecta| `CriarAdmin.ps1` | Cria usuário Admin |



```powershell### Pré-requisitos:

# 1. Verificar IP configurado

cd Scripts## 🐛 Troubleshooting- .NET 8 SDK

.\ValidarConfigAPK.ps1

- SQL Server (LocalDB ou instância completa)

# 2. Reconfigurar IP

.\ConfigurarIP.ps1**API não inicia:** Verifique connection string  



# 3. Regerar APK**Mobile não conecta:** Configure IP em `Mobile/appsettings.json`  ### String de Conexão:

.\GerarAPK.ps1

```**Timezone errado:** Sistema corrige UTC → Local automaticamenteConfigure no `appsettings.json`:



### Firewall bloqueando```json



```powershell## 📄 Licença{

# Executar como Admin:

New-NetFirewallRule -DisplayName "Sistema Chamados API" `  "ConnectionStrings": {

    -Direction Inbound `

    -LocalPort 5246 `MIT License    "DefaultConnection": "Server=localhost;Database=SistemaChamados;Trusted_Connection=true;TrustServerCertificate=true;"

    -Protocol TCP `

    -Action Allow  }

```

---}

### Timezone errado

```

✅ Sistema corrige automaticamente UTC → Local em todas as datas

**Desenvolvido com ❤️ usando .NET 8**  

## 🔒 Segurança

**Última atualização:** 21/10/2025 | **Versão:** 1.0.0### Executar o Projeto:

### Dados Sensíveis

```bash

Os seguintes arquivos **NÃO são commitados**:dotnet run

```

- `Backend/appsettings.json` (senhas, API keys)

- `Mobile/appsettings.json` (IPs específicos)A API estará disponível em:

- `*.apk` (builds Android)- HTTPS: `https://localhost:7000`

- HTTP: `http://localhost:5000`

### Arquivos de Template- Swagger UI: `https://localhost:7000/swagger`



Use os arquivos `.example.json`:## 🧪 Testes



- `Backend/appsettings.example.json`Use o arquivo `test-admin-register.http` para testar os endpoints com diferentes cenários:

- `Mobile/appsettings.example.json`- Registro bem-sucedido

- Email duplicado

## 🌐 Portabilidade- Dados inválidos



### ✅ O projeto funciona em:## 🔒 Segurança



- ✅ **Qualquer PC Windows** (após clonar e configurar)- **Hash de Senhas**: Utiliza BCrypt com salt automático

- ✅ **Qualquer celular Android** (mesma rede Wi-Fi)- **Validação de Entrada**: Data Annotations para validação

- ✅ **Emulador Android** (10.0.2.2:5246)- **CORS**: Configurado para desenvolvimento

- ✅ **Windows Desktop** (localhost:5246)- **HTTPS**: Redirecionamento automático



### 🔧 Scripts garantem:## 📝 Próximos Passos



- ✅ Caminhos relativos (sem `c:\Users\opera\...`)- [ ] Implementar autenticação JWT

- ✅ Detecção automática de IP- [ ] Adicionar endpoints para alunos e professores

- ✅ Configuração automática de firewall- [ ] Implementar sistema de chamados

- ✅ Validação de pré-requisitos- [ ] Adicionar testes unitários

- [ ] Configurar logging estruturado
## 📊 Estrutura do Banco de Dados

### Entidades Principais

1. **Usuarios** - Usuários do sistema (admin, professor, aluno)
2. **Chamados** - Tickets de suporte técnico
3. **Categorias** - Classificação de chamados
4. **Prioridades** - Níveis de urgência
5. **Status** - Estados do chamado
6. **Comentarios** - Interações em chamados
7. **Anexos** - Arquivos/imagens anexadas
8. **HistoricoChamado** - Auditoria de alterações

### Tipos de Usuário

- `1` - Aluno (pode criar e ver seus chamados)
- `2` - Professor (pode atribuir e responder chamados)
- `3` - Administrador (acesso total)

## 🎓 Credenciais de Teste

Após executar `CriarAdmin.ps1`:

```
Admin: admin@sistema.com / Admin@123
Aluno: aluno@sistema.com / Aluno@123
Prof:  professor@sistema.com / Prof@123
```

Veja mais em: [](docs/INDEX.md)

## 📈 Status do Projeto

- ✅ **Backend**: 100% completo
- ✅ **Mobile**: 100% completo
- ✅ **Documentação**: 100% completa
- ✅ **Testes**: Manuais realizados
- ✅ **Portabilidade**: Garantida

## 📄 Licença

MIT License

---

**Desenvolvido com ❤️ usando .NET 8**  
**Última atualização:** 21/10/2025 | **Versão:** 1.0.0

## 🔗 Links Rápidos

- [](docs/INDEX.md)
- [](docs/Mobile/GerarAPK.md)
- [](docs/INDEX.md)
- [](docs/Mobile/README.md)
- [](docs/Desenvolvimento/EstruturaRepositorio.md)
