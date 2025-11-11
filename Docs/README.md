# 🎫 Sistema de Chamados - Faculdade

Sistema completo de gerenciamento de chamados para suporte técnico, com aplicações Desktop (Web), Mobile (MAUI) e Backend (.NET 8).

---

## 📁 Estrutura do Projeto

```
sistema-chamados-faculdade/
├── � Backend/                   # API REST (.NET 8)
│   ├── API/                      # Controllers
│   ├── Application/              # DTOs
│   ├── Configuration/            # Settings
│   ├── Core/                     # Entities
│   ├── Data/                     # DbContext
│   ├── Migrations/               # Database Migrations
│   ├── Properties/               # Project Properties
│   ├── Services/                 # Business Logic
│   ├── appsettings.json          # Configuration
│   ├── program.cs                # Entry Point
│   └── SistemaChamados.csproj    # Project File
│
├── �️ Frontend/                  # Aplicação Web (HTML/CSS/JS)
│   └── Desktop/                  # Páginas e assets
│
├── � Mobile/                    # Aplicação Mobile (.NET MAUI)
│   ├── Converters/
│   ├── Helpers/
│   ├── Models/
│   ├── Services/
│   ├── ViewModels/
│   ├── Views/
│   └── SistemaChamados.Mobile.csproj
│
├── 📜 Scripts/                   # Scripts SQL e utilitários
└── � APK/                       # Builds Android
```

---

## 🚀 Tecnologias Utilizadas

### Backend (.NET 8)
- **ASP.NET Core 8** - Framework web
- **Entity Framework Core** - ORM para acesso a dados
- **SQL Server** - Banco de dados
- **JWT Authentication** - Autenticação via tokens
- **OpenAI API** - Classificação automática de chamados

### Frontend Desktop
- **HTML5/CSS3/JavaScript** - Aplicação web SPA
- **Fetch API** - Comunicação com backend
- **LocalStorage** - Cache local de dados

### Mobile (.NET MAUI)
- **.NET MAUI** - Framework multiplataforma
- **MVVM Pattern** - Arquitetura Model-View-ViewModel
- **CommunityToolkit.Mvvm** - Helpers MVVM
- **Newtonsoft.Json** - Serialização JSON

---

## 🏗️ Arquitetura

### Camadas do Backend

```
┌─────────────────────────────────────┐
│          API Controllers            │  ← Endpoints REST
├─────────────────────────────────────┤
│       Application (DTOs)            │  ← Transferência de dados
├─────────────────────────────────────┤
│          Services                   │  ← Lógica de negócio
├─────────────────────────────────────┤
│       Core (Entities)               │  ← Modelos do domínio
├─────────────────────────────────────┤
│      Data (DbContext)               │  ← Acesso a dados
├─────────────────────────────────────┤
│         SQL Server                  │  ← Persistência
└─────────────────────────────────────┘
```

### Fluxo de Dados

```
Desktop/Mobile → API → Services → Data → Database
                  ↓
            JWT Auth + Validações
```

---

## ⚙️ Configuração e Instalação

### Pré-requisitos

- ✅ .NET 8 SDK
- ✅ SQL Server (LocalDB ou Express)
- ✅ Visual Studio 2022 ou VS Code
- ✅ Node.js (opcional, para ferramentas de build)

### 1️⃣ Configurar Banco de Dados

```bash
# Navegar para pasta Backend
cd Backend

# Atualizar connection string em appsettings.json
# Executar migrations
dotnet ef database update
```

### 2️⃣ Configurar Backend

```bash
# Navegar para pasta Backend
cd Backend

# Restaurar pacotes
dotnet restore

# Compilar
dotnet build

# Executar
dotnet run
```

A API estará disponível em: `http://localhost:5246`

### 3️⃣ Configurar Frontend

1. Abra `Frontend/Desktop/login-desktop.html` em um navegador
2. Certifique-se que a API está rodando
3. Utilize as credenciais padrão (ver seção de Usuários)

### 4️⃣ Configurar Mobile

```bash
# Navegar para pasta mobile
cd Mobile

# Restaurar pacotes
dotnet restore

# Executar no Android
dotnet build -t:Run -f net8.0-android

# Executar no Windows
dotnet build -t:Run -f net8.0-windows10.0.19041.0
```

---

## 👥 Usuários Padrão

| Tipo | Email | Senha | Permissões |
|------|-------|-------|------------|
| **Admin** | admin@h2o.com | 123 | Gerenciar técnicos, visualizar todos os chamados |
| **Técnico** | tecnico@h2o.com | 123 | Atender chamados, atualizar status |
| **Usuário** | demo@h2o.com | 123 | Criar e visualizar próprios chamados |

---

## 📡 API Endpoints

### Autenticação
- `POST /api/usuarios/login` - Login
- `POST /api/usuarios/registrar` - Cadastro de usuário
- `POST /api/usuarios/esqueci-senha` - Recuperação de senha
- `POST /api/usuarios/resetar-senha` - Redefinir senha

### Chamados
- `GET /api/chamados` - Listar chamados (com filtros)
- `GET /api/chamados/{id}` - Detalhes de um chamado
- `POST /api/chamados` - Criar chamado
- `POST /api/chamados/analisar` - Criar chamado com análise IA
- `PUT /api/chamados/{id}` - Atualizar chamado
- `GET /api/chamados/{id}/comentarios` - Listar comentários
- `POST /api/chamados/{id}/comentarios` - Adicionar comentário

### Recursos Auxiliares
- `GET /api/status` - Listar status disponíveis
- `GET /api/prioridades` - Listar prioridades
- `GET /api/categorias` - Listar categorias
- `GET /api/usuarios/tecnicos` - Listar técnicos

---

## 🔐 Segurança

- **JWT Bearer Tokens** - Autenticação stateless
- **Password Hashing** - Senhas nunca armazenadas em texto plano
- **Role-Based Access** - Autorização por tipo de usuário
- **HTTPS** - Recomendado para produção
- **CORS** - Configurado para permitir apenas origens confiáveis

---

## 🐛 Problemas Conhecidos

### ⚠️ Issues Críticas Identificadas

Consulte o arquivo `ANALISE_INCONSISTENCIAS_DETALHADA.md` para lista completa de bugs e inconsistências entre Desktop e Mobile.

**Principais:**
1. **Conflito de StatusId "Fechado"** - Mobile usa ID 5, Backend espera ID 4
2. **Status hardcoded** - Ambas apps usam nomes ao invés de IDs
3. **Funcionalidade ausente** - Mobile não tem opção de "assumir chamado"

---

## 📊 Documentação Adicional

- 📋 `ANALISE_INCONSISTENCIAS_DETALHADA.md` - Análise de divergências Desktop vs Mobile
- 🔍 `PLANO_ACAO_CORRECOES.md` - Plano de correção de bugs
- ✅ `TESTE_INTEGRACAO.md` - Testes de integração
- 📱 `Mobile/README.md` - Documentação específica do mobile (se existir)
- 📦 `APK/README.md` - Instruções de instalação APK

---

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

---

## 📝 Licença

Este projeto é de uso educacional para a faculdade.

---

## 👨‍💻 Autores

- **GuiNRB** - Desenvolvimento principal
- Equipe de desenvolvimento da faculdade

---

## 🆘 Suporte

Para reportar bugs ou solicitar features:
- 📧 Email: suporte@sistematickets.com
- 🐛 Issues: [GitHub Issues](https://github.com/GuiNRB/sistema-chamados-faculdade/issues)

---

**Última atualização:** 10/11/2025
