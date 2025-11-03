# Sistema de Chamados - NeuroHelp

Sistema completo de gerenciamento de chamados de suporte técnico, desenvolvido com ASP.NET Core 8 (Backend) e .NET MAUI (Mobile).

## 📱 INTEGRAÇÃO MOBILE CONCLUÍDA

**🎉 Status:** Totalmente funcional e pronto para uso!

A integração completa entre o aplicativo mobile e o backend foi concluída com sucesso. Todas as inconsistências foram corrigidas e o controle de acesso foi implementado.

### 📚 Documentação Completa
👉 **[DOCUMENTACAO_INTEGRACAO_MOBILE.md](DOCUMENTACAO_INTEGRACAO_MOBILE.md)** - Documento consolidado com:
- ✅ Análise de todas as inconsistências encontradas
- ✅ Soluções implementadas (5 correções críticas)
- ✅ Restrição de acesso por tipo de usuário
- ✅ Guia de testes e validação
- ✅ Configuração completa do ambiente

### 🔒 Controle de Acesso
- ✅ **Usuários (tipo 1):** Acesso completo ao mobile
- ❌ **Técnicos (tipo 2):** Bloqueados - devem usar web/desktop
- ❌ **Admins (tipo 3):** Bloqueados - devem usar web/desktop

### 📄 Outras Documentações
- **[CREDENCIAIS_TESTE.md](CREDENCIAIS_TESTE.md)** - Credenciais para testes
- **[GEMINI_SERVICE_README.md](GEMINI_SERVICE_README.md)** - Configuração IA Gemini
- **[INTEGRACAO_README.md](INTEGRACAO_README.md)** - Guia de integração
- **[MOBILE_INTEGRACAO.md](MOBILE_INTEGRACAO.md)** - Detalhes técnicos mobile

---

## 🏗️ Arquitetura

O projeto segue uma arquitetura limpa com separação de responsabilidades:

```
SistemaChamados/
├── Core/
│   └── Entities/          # Entidades do domínio
├── Application/
│   └── DTOs/              # Data Transfer Objects
├── API/
│   └── Controllers/       # Controllers da API
└── Data/                  # Contexto do Entity Framework
```

## 🚀 Tecnologias Utilizadas

- **ASP.NET Core 8** - Framework web
- **Entity Framework Core** - ORM para acesso a dados
- **SQL Server** - Banco de dados
- **BCrypt.Net** - Hash seguro de senhas
- **Swagger/OpenAPI** - Documentação da API

## 📋 Funcionalidades Implementadas

### ✅ Registro de Usuário Admin

- **Endpoint**: `POST /api/usuarios/registrar-admin`
- **Descrição**: Registra um novo usuário do tipo Administrador
- **Validações**:
  - Email único no sistema
  - Campos obrigatórios
  - Formato de email válido
  - Senha com mínimo de 6 caracteres
- **Segurança**: Senha criptografada com BCrypt

#### Exemplo de Requisição:
```json
{
  "nomeCompleto": "Administrador do Sistema",
  "email": "admin@faculdade.edu.br",
  "senha": "Admin123!"
}
```

#### Exemplo de Resposta (201 Created):
```json
{
  "id": 1,
  "nomeCompleto": "Administrador do Sistema",
  "email": "admin@faculdade.edu.br",
  "tipoUsuario": 3,
  "dataCadastro": "2025-09-16T02:45:00.000Z",
  "ativo": true
}
```

### ✅ Registro de Usuário Padrão

- **Endpoint**: `POST /api/usuarios/registrar`
- **Descrição**: Cria um usuário padrão (TipoUsuario = 1) sem necessidade de autenticação prévia
- **Regras**: Mesmo conjunto de validações do endpoint de administrador
- **Resposta**: Estrutura idêntica ao exemplo anterior, alterando `tipoUsuario` para `1`

```json
{
  "nomeCompleto": "Aluno Teste",
  "email": "aluno@faculdade.edu.br",
  "senha": "Aluno123!"
}
```

### ✅ Registro de Técnico

- **Endpoint**: `POST /api/usuarios/registrar-tecnico`
- **Autorização**: Requer token JWT de um administrador (`Authorization: Bearer {token}`)
- **Campos adicionais**: `especialidadeCategoriaId` define a categoria em que o técnico é especialista
- **Resposta**: Mesmo contrato de `UsuarioResponseDto`

```json
{
  "nomeCompleto": "Técnico Nível 1",
  "email": "tecnico@faculdade.edu.br",
  "senha": "Tecnico123!",
  "especialidadeCategoriaId": 2
}
```

### ✅ Autenticação (Login)

- **Endpoint**: `POST /api/usuarios/login`
- **Descrição**: Autentica o usuário e retorna o token JWT gerado com as *claims* de perfil
- **Resposta**:

```json
{
  "token": "{jwt}",
  "tipoUsuario": 3
}
```

### ✅ Recuperação de Senha

- `POST /api/usuarios/esqueci-senha` — Envia email com link de redefinição (resposta sempre `200 OK` por segurança)
- `POST /api/usuarios/resetar-senha` — Válida o token e grava a nova senha criptografada

### ✅ Gestão de Chamados

- `GET /api/chamados` — Retorna projeção `ChamadoDto` com histórico, suporta filtros (`statusId`, `tecnicoId`, `solicitanteId`, `prioridadeId`, `termoBusca`) e, para administradores, `incluirTodos=true`
- `GET /api/chamados/{id}` — Retorna o chamado com as relações carregadas
- `POST /api/chamados` — Cria chamado para o usuário autenticado e retorna `ChamadoDto`
- `PUT /api/chamados/{id}` — Atualiza status/técnico e devolve `ChamadoDto`
- `POST /api/chamados/{id}/fechar` — Força o fechamento do chamado com carimbo de data
- `POST /api/chamados/analisar` — Cria um chamado sugerido pela IA a partir da descrição
- `GET /api/chamados/{id}/comentarios` / `POST /api/chamados/{id}/comentarios` — Histórico e inclusão de comentários vinculados ao chamado

## 🗄️ Banco de Dados

### Script de Criação
Execute o script `Scripts/CreateDatabase.sql` no SQL Server para criar todas as tabelas necessárias.

### Estrutura das Tabelas

O projeto utiliza as seguintes entidades principais:

1. **Usuarios**: Informações básicas dos usuários do sistema
2. **AlunoPerfil**: Perfil específico para alunos (relacionamento 1:1 com Usuarios)
3. **ProfessorPerfil**: Perfil específico para professores (relacionamento 1:1 com Usuarios)
4. **Categorias**: Categorias para classificação dos chamados
5. **Chamados**: Chamados de suporte técnico
6. **HistoricoChamado**: Histórico de alterações nos chamados

### Tipos de Usuário:
- `1` - Aluno
- `2` - Professor  
- `3` - Administrador

### Relacionamentos:
- Usuario 1:1 AlunoPerfil (opcional)
- Usuario 1:1 ProfessorPerfil (opcional)
- Usuario 1:N Chamados (como solicitante)
- Usuario 1:N Chamados (como atribuído)
- Categoria 1:N Chamados
- Chamado 1:N HistoricoChamado

## ⚙️ Configuração

### Pré-requisitos:
- .NET 8 SDK
- SQL Server (LocalDB ou instância completa)

### String de Conexão:
Configure no `appsettings.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=SistemaChamados;Trusted_Connection=true;TrustServerCertificate=true;"
  }
}
```

### Executar o Projeto:
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

- **Autenticação**: JWT Bearer Token emitido em `POST /api/usuarios/login`
- **Autorização**: Políticas baseadas em `TipoUsuario`; o cadastro de técnicos exige perfil administrativo
- **Hash de Senhas**: BCrypt com salt automático para todos os fluxos de registro/reset
- **Validação de Entrada**: Data Annotations protegem os DTOs de entrada
- **CORS**: Configuração liberada para desenvolvimento
- **HTTPS**: Redirecionamento automático habilitado

## 📝 Próximos Passos

- [ ] Automatizar testes de integração dos fluxos autenticados
- [ ] Documentar o consumo dos tokens de redefinição de senha no front-end
- [ ] Publicar exemplos de uso da API de comentários e fechamento
- [ ] Configurar logging estruturado e monitoramento de SLA