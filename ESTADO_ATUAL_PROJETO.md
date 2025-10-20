# 📊 Estado Atual do Projeto - Sistema de Chamados

**Data de Atualização:** 20 de outubro de 2025  
**Versão:** 1.0  
**Status Geral:** ✅ Funcional e em Produção

---

## 🎯 Visão Geral

Sistema completo de gerenciamento de chamados técnicos para ambiente acadêmico, composto por:
- **Backend API**: ASP.NET Core 8 com autenticação JWT
- **Mobile App**: .NET MAUI multiplataforma (Android/iOS/Windows)
- **IA Integrada**: Classificação automática via Google Gemini API

---

## 📦 Repositório Git

### Branches Disponíveis
```
✅ master        - Código principal estável (backend)
✅ mobile-app    - Aplicativo mobile completo
✅ develop       - Branch de desenvolvimento
```

### Último Commit (master)
```
83c309f - mobile
7bda09c - docs: adiciona documentação e script de teste para restrição manual
6ea5f3a - feat(backend): adiciona restrição de classificação manual apenas para Admin
```

### Status do Repositório
- **Branch Atual:** master
- **Estado:** Clean (sem alterações pendentes)
- **Sincronização:** Up to date with origin/master

---

## 🏗️ Arquitetura do Sistema

### Backend (API - ASP.NET Core 8)

#### Estrutura de Pastas
```
sistema-chamados-faculdade/
├── API/
│   └── Controllers/
│       ├── ChamadosController.cs      ✅ CRUD de chamados + IA
│       ├── UsuariosController.cs      ✅ Autenticação e registro
│       ├── CategoriasController.cs    ✅ Gestão de categorias
│       ├── PrioridadesController.cs   ✅ Gestão de prioridades
│       └── StatusController.cs        ✅ Gestão de status
├── Application/
│   ├── DTOs/                          ✅ Data Transfer Objects
│   └── Services/
│       ├── ITokenService.cs           ✅ Interface JWT
│       └── TokenService.cs            ✅ Geração de tokens
├── Core/
│   └── Entities/
│       ├── Usuario.cs                 ✅ Entidade base de usuários
│       ├── AlunoPerfil.cs            ✅ Perfil de alunos
│       ├── ProfessorPerfil.cs        ✅ Perfil de professores
│       ├── Chamado.cs                ✅ Entidade de chamados
│       ├── Categoria.cs              ✅ Categorias de chamados
│       ├── Prioridade.cs             ✅ Prioridades
│       └── Status.cs                 ✅ Status dos chamados
├── Services/
│   ├── IAIService.cs                 ✅ Interface IA
│   ├── AIService.cs                  ✅ Orquestrador de IA
│   ├── IOpenAIService.cs             ✅ Interface OpenAI/Gemini
│   ├── GeminiService.cs              ✅ Integração Google Gemini
│   ├── OpenAIService.cs              ✅ Integração OpenAI
│   ├── IHandoffService.cs            ✅ Interface atribuição
│   ├── HandoffService.cs             ✅ Atribuição automática
│   ├── IEmailService.cs              ✅ Interface email
│   └── EmailService.cs               ✅ Envio de emails
├── Data/
│   └── ApplicationDbContext.cs       ✅ Contexto EF Core
├── Migrations/                        ✅ Migrações do banco
└── Configuration/
    └── EmailSettings.cs              ✅ Configurações SMTP
```

#### Tecnologias Backend
- **.NET 8.0** - Framework principal
- **Entity Framework Core 8.0** - ORM
- **SQL Server** - Banco de dados
- **BCrypt.Net-Next 4.0.3** - Hash de senhas
- **JWT Bearer Authentication** - Autenticação
- **Swashbuckle (Swagger)** - Documentação API

---

### Mobile (MAUI - .NET 8)

#### Estrutura de Pastas
```
SistemaChamados.Mobile/
├── Views/
│   ├── Auth/
│   │   ├── LoginPage.xaml            ✅ Tela de login
│   │   └── RegisterPage.xaml         ✅ Tela de registro
│   ├── Chamados/
│   │   ├── ChamadosListPage.xaml     ✅ Lista de chamados
│   │   ├── ChamadoDetailPage.xaml    ✅ Detalhes do chamado
│   │   ├── NovoChamadoPage.xaml      ✅ Criação de chamado
│   │   └── ChamadoConfirmacaoPage.xaml ✅ Confirmação
│   ├── Admin/                         ✅ Áreas administrativas
│   └── MainPage.xaml                  ✅ Dashboard principal
├── ViewModels/
│   ├── LoginViewModel.cs             ✅ Lógica de login
│   ├── MainViewModel.cs              ✅ Dashboard
│   ├── ChamadosListViewModel.cs      ✅ Lista de chamados
│   ├── ChamadoDetailViewModel.cs     ✅ Detalhes
│   ├── NovoChamadoViewModel.cs       ✅ Criação (com IA)
│   └── BaseViewModel.cs              ✅ Base para ViewModels
├── Services/
│   ├── Api/                          ✅ Cliente HTTP
│   ├── Auth/                         ✅ Autenticação
│   ├── Chamados/                     ✅ CRUD Chamados
│   ├── Categorias/                   ✅ Gestão Categorias
│   ├── Prioridades/                  ✅ Gestão Prioridades
│   └── Status/                       ✅ Gestão Status
├── Models/
│   ├── DTOs/                         ✅ Objetos de transferência
│   └── Entities/                     ✅ Entidades locais
├── Helpers/
│   ├── ApiResponse.cs                ✅ Wrapper de resposta API
│   ├── Constants.cs                  ✅ Constantes do app
│   ├── Settings.cs                   ✅ Persistência local
│   └── InvertedBoolConverter.cs      ✅ Conversor XAML
└── Platforms/
    ├── Android/                      ✅ Android específico
    ├── iOS/                          ✅ iOS específico
    ├── Windows/                      ✅ Windows específico
    └── MacCatalyst/                  ✅ Mac específico
```

#### Tecnologias Mobile
- **.NET MAUI 8.0** - Framework multiplataforma
- **CommunityToolkit.Mvvm 8.2.0** - MVVM helpers
- **Newtonsoft.Json 13.0.3** - Serialização JSON
- **Microsoft.Extensions.Http 8.0** - Cliente HTTP

#### Plataformas Suportadas
- ✅ **Android** (API 21+)
- ✅ **iOS** (11.0+)
- ✅ **Windows** (10.0.17763+)
- ✅ **macOS** (Catalyst 13.1+)

---

## 🔐 Sistema de Autenticação

### Tipos de Usuário

| Tipo | Código | Permissões |
|------|--------|------------|
| **Aluno** | 1 | ✅ Criar chamados (apenas IA)<br>✅ Ver próprios chamados<br>❌ Classificação manual<br>❌ Encerrar chamados |
| **Professor** | 2 | ✅ Criar chamados (apenas IA)<br>✅ Ver próprios chamados<br>✅ Ser atribuído como técnico<br>❌ Classificação manual<br>❌ Encerrar chamados |
| **Administrador** | 3 | ✅ TODAS as permissões<br>✅ Classificação manual<br>✅ Encerrar chamados<br>✅ Ver todos os chamados<br>✅ Gerenciar sistema |

### Credenciais de Teste

#### 👨‍🎓 Aluno
```
Email: aluno@sistema.com
Senha: Aluno@123
```

#### 👨‍🏫 Professor
```
Email: professor@sistema.com
Senha: Prof@123
```

#### 👨‍💼 Administrador
```
Email: admin@sistema.com
Senha: Admin@123
```

### Segurança Implementada
- ✅ JWT Bearer Authentication
- ✅ Senhas com BCrypt (fator 11)
- ✅ Claims baseadas em tipos de usuário
- ✅ Tokens com expiração de 24 horas
- ✅ HTTPS obrigatório em produção

---

## 🤖 Integração com IA

### Google Gemini API

**Status:** ✅ Ativo e funcional

**Funcionalidades:**
1. **Classificação Automática**
   - Analisa descrição do chamado
   - Determina categoria (Hardware, Software, Rede, etc.)
   - Define prioridade (Baixa, Média, Alta, Urgente)
   - Gera título sugerido

2. **Atribuição Inteligente**
   - Identifica técnico especializado
   - Baseado na categoria do chamado
   - Fallback para admin se nenhum técnico disponível

**Configuração:**
- Chave API armazenada em `.env` (não versionado)
- Modelo: `gemini-1.5-flash`
- Proteção: `.env` listado no `.gitignore`

**Fallback:**
- Sistema suporta OpenAI como alternativa
- Interfaces abstratas para fácil troca

---

## 🎨 Funcionalidades Principais

### 1. Gestão de Chamados

#### Criar Chamado
- **Aluno/Professor:** Apenas com IA (descrição → IA classifica)
- **Admin:** Pode escolher entre IA ou classificação manual
- **Mobile:** UI adaptativa por tipo de usuário
- **Validação:** Backend rejeita manual de não-admins (403 Forbidden)

#### Listar Chamados
- **Aluno/Professor:** Vê apenas seus próprios chamados
- **Admin:** Vê todos os chamados do sistema
- **Filtros:** Por status, prioridade, categoria
- **Ordenação:** Data de criação, prioridade

#### Detalhes do Chamado
- Visualização completa de informações
- Histórico de alterações
- Técnico atribuído
- Timeline de status

#### Atualizar Chamado
- **Admin:** Pode alterar qualquer campo
- **Técnico Atribuído:** Pode mudar status
- **Solicitante:** Pode adicionar comentários

#### Encerrar Chamado
- **Restrição:** Apenas administradores
- **Backend:** Validação de permissão
- **Mobile:** Botão visível apenas para admin

---

### 2. Gestão de Usuários

#### Registro
- Autoregistro para alunos/professores
- Admin cria outros admins via endpoint específico
- Validação de email único
- Perfis diferenciados (AlunoPerfil, ProfessorPerfil)

#### Login
- Autenticação via JWT
- Retorna token + dados do usuário
- Mobile persiste token em Preferences
- Logout automático a cada execução do app

#### Recuperação de Senha
- **Endpoint:** `/api/usuarios/esqueci-senha`
- Email com link de redefinição
- Token temporário com expiração
- Reset via `/api/usuarios/resetar-senha`

---

### 3. Categorias e Prioridades

#### Categorias Padrão
1. Hardware
2. Software
3. Rede
4. Sistema
5. Outros

#### Prioridades Padrão
1. Baixa
2. Média
3. Alta
4. Urgente

#### Gestão
- CRUD completo via API
- Listagem pública (sem auth)
- Criação/Edição/Exclusão apenas admin

---

## 📝 Documentação Disponível

### Principais Documentos

| Arquivo | Conteúdo |
|---------|----------|
| `README.md` | Documentação geral da API |
| `README_MOBILE.md` | Documentação do app mobile |
| `CREDENCIAIS_TESTE.md` | Usuários e senhas de teste |
| `RESTRICAO_CLASSIFICACAO_MANUAL.md` | Restrições de classificação manual |
| `GEMINI_SERVICE_README.md` | Integração com Gemini |
| `COMO_TESTAR_MOBILE.md` | Guia de testes mobile |
| `STATUS_MOBILE.md` | Status do desenvolvimento mobile |
| `ATRIBUICOES_VISUALIZACAO.md` | Regras de visualização |
| `PERMISSOES.md` | Matriz completa de permissões |

### Scripts PowerShell

| Script | Função |
|--------|--------|
| `IniciarAPI.ps1` | Inicia a API em terminal separado |
| `IniciarSistema.ps1` | Inicia API + Mobile |
| `IniciarTeste.ps1` | Ambiente de testes |
| `SetupUsuariosTeste.ps1` | Cria usuários de teste |
| `TestarRestricaoManual.ps1` | Testa restrições de classificação |
| `TestarMobile.ps1` | Testes do app mobile |
| `LimparTodosChamados.ps1` | Remove todos os chamados |

---

## 🗃️ Banco de Dados

### SQL Server

**Configuração:**
```
Servidor: localhost
Database: SistemaChamados
Autenticação: Windows (Trusted_Connection)
```

### Tabelas Principais

1. **Usuarios**
   - Id, NomeCompleto, Email, SenhaHash
   - TipoUsuario (1=Aluno, 2=Professor, 3=Admin)
   - DataCadastro, Ativo

2. **AlunoPerfis**
   - UsuarioId (FK), Matricula, Curso

3. **ProfessorPerfis**
   - UsuarioId (FK), CursoMinistrado, EspecialidadeCategoriaId

4. **Chamados**
   - Id, Titulo, Descricao
   - SolicitanteId (FK), AtribuidoParaId (FK)
   - CategoriaId (FK), PrioridadeId (FK), StatusId (FK)
   - DataCriacao, DataAtualizacao, DataEncerramento

5. **Categorias**
   - Id, Nome, Descricao

6. **Prioridades**
   - Id, Nome, Nivel

7. **Status**
   - Id, Nome, Tipo

8. **HistoricoChamado**
   - Id, ChamadoId (FK), UsuarioId (FK)
   - Acao, Descricao, DataRegistro

### Migrações
```
✅ 20250916055117_FinalCorrectMigration
✅ 20250919050750_AdicionaTabelasDeChamados
✅ 20250929155628_AdicionaEspecialidadeCategoriaId
```

---

## 🚀 Como Executar

### Backend (API)

#### Opção 1: PowerShell Script
```powershell
cd c:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade
.\IniciarAPI.ps1
```

#### Opção 2: Comando direto
```powershell
cd c:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade
dotnet run --project SistemaChamados.csproj
```

**URLs:**
- HTTP: http://localhost:5246
- Swagger: http://localhost:5246/swagger

---

### Mobile (MAUI)

#### Windows
```powershell
cd c:\Users\opera\sistema-chamados-faculdade\SistemaChamados.Mobile
dotnet build -f net8.0-windows10.0.19041.0
dotnet run -f net8.0-windows10.0.19041.0
```

#### Android (via Visual Studio)
1. Abra o projeto no Visual Studio
2. Selecione target Android
3. Escolha emulador ou dispositivo
4. F5 para executar

---

## 🔧 Configuração de Ambiente

### Variáveis de Ambiente (.env)
```env
GEMINI_API_KEY=sua_chave_aqui
```

**⚠️ IMPORTANTE:** Arquivo `.env` está no `.gitignore` e NÃO é versionado!

### appsettings.json (Backend)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=SistemaChamados;Trusted_Connection=true;TrustServerCertificate=true;"
  },
  "Jwt": {
    "Key": "sua_chave_secreta_jwt_aqui",
    "Issuer": "SistemaChamados",
    "Audience": "SistemaChamados"
  },
  "Email": {
    "SmtpHost": "smtp.gmail.com",
    "SmtpPort": 587,
    "Username": "seu_email@gmail.com",
    "Password": "sua_senha_app"
  }
}
```

### appsettings.json (Mobile)
```json
{
  "ApiSettings": {
    "BaseUrl": "http://localhost:5246"
  }
}
```

---

## 📊 Estatísticas do Projeto

### Linhas de Código (Estimativa)
- **Backend:** ~5.000 linhas (C#)
- **Mobile:** ~3.000 linhas (C# + XAML)
- **Scripts:** ~500 linhas (PowerShell)
- **Documentação:** ~2.000 linhas (Markdown)
- **Total:** ~10.500 linhas

### Commits
- **Total:** 35+ commits
- **Último:** 17/10/2025
- **Contribuidores:** 2 (GuiNRB, Yepiiii)

### Arquivos
- **Backend:** ~50 arquivos .cs
- **Mobile:** ~60 arquivos (.cs, .xaml)
- **Documentação:** 12 arquivos .md
- **Scripts:** 7 arquivos .ps1

---

## ✅ Status de Funcionalidades

### Backend API

| Funcionalidade | Status | Observações |
|----------------|--------|-------------|
| Autenticação JWT | ✅ Completo | Tokens 24h |
| Registro de Usuários | ✅ Completo | 3 tipos |
| CRUD Chamados | ✅ Completo | Com IA |
| Classificação IA | ✅ Completo | Gemini |
| Atribuição Automática | ✅ Completo | Por especialidade |
| Recuperação de Senha | ✅ Completo | Via email |
| Envio de Emails | ✅ Completo | Gmail SMTP |
| Gestão Categorias | ✅ Completo | CRUD |
| Gestão Prioridades | ✅ Completo | CRUD |
| Gestão Status | ✅ Completo | CRUD |
| Histórico Chamados | ✅ Completo | Timeline |
| Validação Permissões | ✅ Completo | Por tipo |
| Documentação Swagger | ✅ Completo | OpenAPI |

### Mobile App

| Funcionalidade | Status | Observações |
|----------------|--------|-------------|
| Login | ✅ Completo | Persiste token |
| Registro | ✅ Completo | Aluno/Professor |
| Dashboard | ✅ Completo | Por tipo |
| Lista Chamados | ✅ Completo | Filtros |
| Detalhes Chamado | ✅ Completo | Completo |
| Criar Chamado (IA) | ✅ Completo | Todos usuários |
| Criar Chamado (Manual) | ✅ Completo | Apenas admin |
| Atualizar Chamado | ✅ Completo | Com permissões |
| Encerrar Chamado | ✅ Completo | Apenas admin |
| UI Adaptativa | ✅ Completo | Por tipo |
| Notificações | ⏳ Pendente | Futuro |
| Modo Offline | ⏳ Pendente | Futuro |

---

## 🐛 Problemas Conhecidos

### Resolvidos
- ✅ API travando em terminal do VS Code (resolvido: usar terminal externo)
- ✅ Não-admins conseguiam classificação manual (resolvido: validação backend + UI)
- ✅ Mobile não versionado (resolvido: branch mobile-app)
- ✅ Emojis em scripts PowerShell (resolvido: texto simples)

### Pendentes
- ⚠️ Performance com muitos chamados (>1000) não testada
- ⚠️ Notificações push ainda não implementadas
- ⚠️ Modo offline do mobile não implementado

---

## 🔮 Próximos Passos Sugeridos

### Curto Prazo
1. ⏳ Implementar testes unitários (backend)
2. ⏳ Implementar testes de integração (API)
3. ⏳ Adicionar notificações push (mobile)
4. ⏳ Melhorar UI/UX do mobile
5. ⏳ Adicionar filtros avançados de busca

### Médio Prazo
1. ⏳ Implementar modo offline (mobile)
2. ⏳ Sistema de comentários em chamados
3. ⏳ Anexos de arquivos/imagens
4. ⏳ Dashboard com gráficos (admin)
5. ⏳ Relatórios de produtividade

### Longo Prazo
1. ⏳ Integração com Active Directory
2. ⏳ Sistema de chat em tempo real
3. ⏳ App web (Blazor/React)
4. ⏳ API pública para integrações
5. ⏳ Machine Learning para previsão de tempo de resolução

---

## 🤝 Colaboradores

- **GuiNRB** - Desenvolvimento inicial e arquitetura
- **Yepiiii** (opera) - Implementações recentes e mobile

---

## 📞 Suporte

### Recursos de Ajuda
- 📄 Documentação: Ver arquivos `*.md` no repositório
- 🔧 Scripts: Ver pasta `Scripts/` e arquivos `*.ps1`
- 🐛 Issues: GitHub Issues do repositório
- 📧 Email: Contatar mantenedores

### Troubleshooting Rápido

**API não inicia:**
```powershell
# Verificar se porta está em uso
netstat -ano | findstr :5246
# Matar processo se necessário
taskkill /PID <pid> /F
```

**Mobile não conecta:**
1. Verificar se API está rodando
2. Confirmar URL em `appsettings.json`
3. Android: usar `10.0.2.2:5246` no emulador

**Erro de autenticação:**
1. Verificar se token não expirou
2. Relogar no app
3. Verificar credenciais em `CREDENCIAIS_TESTE.md`

---

## 🎓 Licença e Uso

**Projeto Acadêmico**
- ✅ Uso educacional
- ✅ Contribuições bem-vindas
- ⚠️ Não usar Gemini API key em produção sem custo previsto

---

**Última Atualização:** 20/10/2025  
**Versão do Documento:** 1.0  
**Gerado por:** GitHub Copilot

---

## 📌 Checklist de Implantação

### Ambiente de Desenvolvimento
- [x] .NET 8 SDK instalado
- [x] SQL Server rodando
- [x] Banco de dados criado
- [x] Migrations aplicadas
- [x] Usuários de teste criados
- [x] Gemini API key configurada
- [x] API funcionando localmente
- [x] Mobile buildando

### Ambiente de Produção (Futuro)
- [ ] Servidor configurado
- [ ] SQL Server em produção
- [ ] SSL/TLS configurado
- [ ] Variáveis de ambiente setadas
- [ ] Backups automatizados
- [ ] Monitoramento configurado
- [ ] CI/CD pipeline
- [ ] App publicado nas lojas

---

**✅ PROJETO ESTÁ FUNCIONAL E PRONTO PARA USO!**
