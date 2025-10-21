# Sistema de Chamados - Faculdade# Sistema de Chamados - API



Sistema completo de gerenciamento de chamados técnicos com backend .NET 8 e aplicativo mobile multiplataforma (.NET MAUI).API desenvolvida em ASP.NET Core 8 para gerenciamento de chamados de suporte técnico em ambiente acadêmico.



## 📁 Estrutura do Projeto## 🏗️ Arquitetura



```O projeto segue uma arquitetura limpa com separação de responsabilidades:

sistema-chamados-faculdade/

├── Backend/              # API REST ASP.NET Core 8```

├── Mobile/               # App mobile .NET MAUI (Android, iOS, Windows)SistemaChamados/

├── Scripts/              # Scripts PowerShell de automação├── Core/

├── Docs/                 # Documentação técnica completa│   └── Entities/          # Entidades do domínio

├── APK/                  # Builds Android (gitignored)├── Application/

└── SistemaChamados.sln  # Solution com ambos os projetos│   └── DTOs/              # Data Transfer Objects

```├── API/

│   └── Controllers/       # Controllers da API

## 🚀 Início Rápido└── Data/                  # Contexto do Entity Framework

```

### Pré-requisitos

## 🚀 Tecnologias Utilizadas

- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)

- [Visual Studio 2022](https://visualstudio.microsoft.com/) ou [VS Code](https://code.visualstudio.com/)- **ASP.NET Core 8** - Framework web

- [SQL Server LocalDB](https://learn.microsoft.com/sql/database-engine/configure-windows/sql-server-express-localdb)- **Entity Framework Core** - ORM para acesso a dados

- Para mobile: [Android SDK](https://developer.android.com/studio)- **SQL Server** - Banco de dados

- **BCrypt.Net** - Hash seguro de senhas

### Instalação (6 Passos)- **Swagger/OpenAPI** - Documentação da API



```bash## 📋 Funcionalidades Implementadas

# 1. Clone o repositório

git clone https://github.com/Yepiiii/sistema-chamados-faculdade.git### ✅ Registro de Usuário Admin

cd sistema-chamados-faculdade

- **Endpoint**: `POST /api/usuarios/registrar-admin`

# 2. Restaure dependências- **Descrição**: Registra um novo usuário do tipo Administrador

dotnet restore- **Validações**:

  - Email único no sistema

# 3. Configure connection string (Backend/appsettings.json)  - Campos obrigatórios

  - Formato de email válido

# 4. Execute migrations  - Senha com mínimo de 6 caracteres

cd Backend- **Segurança**: Senha criptografada com BCrypt

dotnet ef database update

cd ..#### Exemplo de Requisição:

```json

# 5. Inicie o sistema{

cd Scripts  "nomeCompleto": "Administrador do Sistema",

.\IniciarSistema.ps1 -Plataforma windows  "email": "admin@faculdade.edu.br",

```  "senha": "Admin123!"

}

## 📱 Gerar APK Android```



```powershell#### Exemplo de Resposta (201 Created):

cd Scripts```json

.\GerarAPK.ps1{

```  "id": 1,

  "nomeCompleto": "Administrador do Sistema",

APK gerado em: `APK/SistemaChamados-v1.0.apk`  "email": "admin@faculdade.edu.br",

  "tipoUsuario": 3,

## 📚 Documentação  "dataCadastro": "2025-09-16T02:45:00.000Z",

  "ativo": true

- **[Guia de Inicialização](Docs/GUIA_INICIAR_SISTEMA.md)**}

- **[Credenciais de Teste](Docs/CREDENCIAIS_TESTE.md)**```

- **[Overview Mobile](Docs/OVERVIEW_MOBILE_UI_UX.md)**

- **[Estrutura do Repositório](ESTRUTURA_REPOSITORIO.md)**## 🗄️ Banco de Dados



## 🎯 Funcionalidades### Script de Criação

Execute o script `Scripts/CreateDatabase.sql` no SQL Server para criar todas as tabelas necessárias.

### Backend

- ✅ Autenticação JWT### Estrutura das Tabelas

- ✅ CRUD de chamados

- ✅ Classificação IA (Gemini)O projeto utiliza as seguintes entidades principais:

- ✅ API REST documentada (Swagger)

1. **Usuarios**: Informações básicas dos usuários do sistema

### Mobile2. **AlunoPerfil**: Perfil específico para alunos (relacionamento 1:1 com Usuarios)

- ✅ Android, iOS, Windows3. **ProfessorPerfil**: Perfil específico para professores (relacionamento 1:1 com Usuarios)

- ✅ Material Design4. **Categorias**: Categorias para classificação dos chamados

- ✅ Filtros avançados5. **Chamados**: Chamados de suporte técnico

- ✅ Pull-to-refresh6. **HistoricoChamado**: Histórico de alterações nos chamados

- ✅ Bottom navigation

- ✅ Timezone UTC → Local### Tipos de Usuário:

- `1` - Aluno

## 🛠️ Tecnologias- `2` - Professor  

- `3` - Administrador

**Backend:** ASP.NET Core 8 • EF Core 8 • SQL Server • JWT • Gemini API  

**Mobile:** .NET MAUI 8 • MVVM • HttpClient### Relacionamentos:

- Usuario 1:1 AlunoPerfil (opcional)

## 📦 Scripts- Usuario 1:1 ProfessorPerfil (opcional)

- Usuario 1:N Chamados (como solicitante)

| Script | Descrição |- Usuario 1:N Chamados (como atribuído)

|--------|-----------|- Categoria 1:N Chamados

| `IniciarSistema.ps1` | Inicia API + Mobile |- Chamado 1:N HistoricoChamado

| `GerarAPK.ps1` | Gera APK Android |

| `TestarAPI.ps1` | Testa endpoints |## ⚙️ Configuração

| `CriarAdmin.ps1` | Cria usuário Admin |

### Pré-requisitos:

## 🐛 Troubleshooting- .NET 8 SDK

- SQL Server (LocalDB ou instância completa)

**API não inicia:** Verifique connection string  

**Mobile não conecta:** Configure IP em `Mobile/appsettings.json`  ### String de Conexão:

**Timezone errado:** Sistema corrige UTC → Local automaticamenteConfigure no `appsettings.json`:

```json

## 📄 Licença{

  "ConnectionStrings": {

MIT License    "DefaultConnection": "Server=localhost;Database=SistemaChamados;Trusted_Connection=true;TrustServerCertificate=true;"

  }

---}

```

**Desenvolvido com ❤️ usando .NET 8**  

**Última atualização:** 21/10/2025 | **Versão:** 1.0.0### Executar o Projeto:

```bash
dotnet run
```

A API estará disponível em:
- HTTPS: `https://localhost:7000`
- HTTP: `http://localhost:5000`
- Swagger UI: `https://localhost:7000/swagger`

## 🧪 Testes

Use o arquivo `test-admin-register.http` para testar os endpoints com diferentes cenários:
- Registro bem-sucedido
- Email duplicado
- Dados inválidos

## 🔒 Segurança

- **Hash de Senhas**: Utiliza BCrypt com salt automático
- **Validação de Entrada**: Data Annotations para validação
- **CORS**: Configurado para desenvolvimento
- **HTTPS**: Redirecionamento automático

## 📝 Próximos Passos

- [ ] Implementar autenticação JWT
- [ ] Adicionar endpoints para alunos e professores
- [ ] Implementar sistema de chamados
- [ ] Adicionar testes unitários
- [ ] Configurar logging estruturado