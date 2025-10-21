# Sistema de Chamados - Faculdade# Sistema de Chamados - Faculdade# Sistema de Chamados - API



Sistema completo de gerenciamento de chamados técnicos com backend .NET 8 e aplicativo mobile multiplataforma (.NET MAUI).



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

- ❌ **Se não abrir** → Veja [Guia de Portabilidade](docs/SETUP_PORTABILIDADE.md)

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

- **[🚀 Guia de Portabilidade](docs/SETUP_PORTABILIDADE.md)** - Setup para qualquer PC/Android

- **[🔑 Credenciais de Teste](docs/CREDENCIAIS_TESTE.md)** - Usuários para testes## 📱 Gerar APK Android```

- **[📱 Overview Mobile](docs/OVERVIEW_MOBILE_UI_UX.md)** - Design e funcionalidades



### Documentação Técnica

```powershell#### Exemplo de Resposta (201 Created):

- **[Estrutura do Repositório](ESTRUTURA_REPOSITORIO.md)**

- **[Correção de Fuso Horário](docs/CORRECAO_FUSO_HORARIO.md)**cd Scripts```json

- **[Guia de Gerar APK](docs/GUIA_GERAR_APK.md)**

- **[Status Mobile](docs/STATUS_MOBILE.md)**.\GerarAPK.ps1{



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

- ✅ Correção automática de timezone (UTC → Local)- **[Guia de Inicialização](Docs/GUIA_INICIAR_SISTEMA.md)**}



### Mobile (.NET MAUI)- **[Credenciais de Teste](Docs/CREDENCIAIS_TESTE.md)**```



- ✅ **Multiplataforma**: Android, iOS, Windows- **[Overview Mobile](Docs/OVERVIEW_MOBILE_UI_UX.md)**

- ✅ **Material Design 3** com tema escuro

- ✅ **Bottom Navigation** (Dashboard, Chamados, Perfil)- **[Estrutura do Repositório](ESTRUTURA_REPOSITORIO.md)**## 🗄️ Banco de Dados

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

Veja mais em: [docs/CREDENCIAIS_TESTE.md](docs/CREDENCIAIS_TESTE.md)

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

- [🚀 Setup Completo](docs/SETUP_PORTABILIDADE.md)
- [📱 Gerar APK](docs/GUIA_GERAR_APK.md)
- [🔑 Credenciais](docs/CREDENCIAIS_TESTE.md)
- [🎨 UI/UX Mobile](docs/OVERVIEW_MOBILE_UI_UX.md)
- [📝 Estrutura](ESTRUTURA_REPOSITORIO.md)
