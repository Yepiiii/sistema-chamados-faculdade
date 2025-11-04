# 📱 Mapeamento de Extração de Dados - App Mobile (.NET MAUI)

> **Documento gerado em:** 2024-11-04  
> **Propósito:** Documentar TODAS as requisições HTTP, dados extraídos do banco de dados, e fluxo de dados no aplicativo mobile

---

## 📋 Índice

1. [Visão Geral da Arquitetura](#visão-geral-da-arquitetura)
2. [Autenticação e Gerenciamento de Usuários](#autenticação-e-gerenciamento-de-usuários)
3. [Operações de Chamados](#operações-de-chamados)
4. [Dados de Suporte (Categorias, Prioridades, Status)](#dados-de-suporte)
5. [Comentários](#comentários)
6. [Rastreabilidade de Fechamento ⭐](#rastreabilidade-de-fechamento)
7. [Comparação: Desktop vs Mobile](#comparação-desktop-vs-mobile)
8. [ViewModels e Uso de Dados](#viewmodels-e-uso-de-dados)
9. [Checklist de Implementação](#checklist-de-implementação)

---

## 🏗️ Visão Geral da Arquitetura

### Estrutura de Camadas

```
┌─────────────────────────────────────┐
│         Views (XAML Pages)          │
│   - LoginPage.xaml                  │
│   - ChamadosListPage.xaml           │
│   - ChamadoDetailPage.xaml          │
│   - DashboardPage.xaml              │
└─────────────────────────────────────┘
                 ↕
┌─────────────────────────────────────┐
│       ViewModels (MVVM)             │
│   - LoginViewModel                  │
│   - ChamadosListViewModel           │
│   - ChamadoDetailViewModel          │
│   - DashboardViewModel              │
└─────────────────────────────────────┘
                 ↕
┌─────────────────────────────────────┐
│          Services Layer             │
│   - AuthService                     │
│   - ChamadoService                  │
│   - CategoriaService                │
│   - PrioridadeService               │
│   - StatusService                   │
│   - ComentarioService               │
└─────────────────────────────────────┘
                 ↕
┌─────────────────────────────────────┐
│          ApiService (HTTP)          │
│   - HttpClient wrapper              │
│   - JWT token management            │
│   - Error handling                  │
│   - JSON serialization              │
└─────────────────────────────────────┘
                 ↕
┌─────────────────────────────────────┐
│       Backend API REST              │
│   http://192.168.1.132:5246/api/    │
└─────────────────────────────────────┘
                 ↕
┌─────────────────────────────────────┐
│       SQL Server Database           │
│   - Usuarios                        │
│   - Chamados                        │
│   - Categorias                      │
│   - Prioridades                     │
│   - Status                          │
│   - Comentarios                     │
└─────────────────────────────────────┘
```

### Configuração de Rede

- **BaseUrl:** `http://192.168.1.132:5246/api/`
- **Timeout:** 60 segundos
- **Charset:** UTF-8
- **Autenticação:** JWT Bearer Token
- **Serialização:** Newtonsoft.Json com `ReferenceLoopHandling.Ignore`

### Restrições do Mobile

⚠️ **IMPORTANTE:** O app mobile possui restrições de acesso:

1. **Apenas usuários comuns** (TipoUsuario = 1) podem fazer login
2. **Admins e Técnicos** são bloqueados no login
3. Usuários veem **apenas seus próprios chamados** (filtrados por SolicitanteId)

---

## 🔐 Autenticação e Gerenciamento de Usuários

### 1. Login

**Service:** `AuthService.cs`  
**Método:** `Login(LoginDto dto)`

#### HTTP Request
```http
POST http://192.168.1.132:5246/api/usuarios/login
Content-Type: application/json

{
  "email": "usuario@exemplo.com",
  "senha": "senha123"
}
```

#### Processamento Backend

```sql
-- Controller: UsuariosController.Login()
SELECT 
    u.Id,
    u.Nome,
    u.Email,
    u.Senha, -- verificado com BCrypt
    u.TipoUsuario
FROM Usuarios u
WHERE u.Email = @Email
  AND u.Ativo = 1;
```

#### Response
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "email": "usuario@exemplo.com",
  "tipoUsuario": 1
}
```

#### JWT Token Payload
```json
{
  "sub": "usuario@exemplo.com",
  "nameid": "42",  // ← EXTRAI USERID AQUI
  "email": "usuario@exemplo.com",
  "role": "Usuario",
  "exp": 1699200000
}
```

#### Validação Mobile

```csharp
// AuthService.cs - Linha ~50
if (response.TipoUsuario != 1)
{
    throw new ApiException(
        HttpStatusCode.Unauthorized,
        "Apenas usuários comuns podem acessar o aplicativo móvel.",
        null
    );
}

// Extração do UserId do token JWT
var userId = TryExtractUserId(response.Token);
```

#### Dados Armazenados Localmente

```csharp
Settings.Token = response.Token;           // JWT completo
Settings.TipoUsuario = response.TipoUsuario; // 1 (fixo)
Settings.Email = response.Email;            // Email do usuário
Settings.UserId = userId;                   // Extraído do JWT claim "nameid"
```

#### Extração do UserId do JWT

```csharp
// AuthService.cs - TryExtractUserId()
// Decodifica Base64 do payload JWT
var payload = parts[1]; // Entre os dois pontos do JWT
var json = Encoding.UTF8.GetString(WebEncoders.Base64UrlDecode(payload));

// Busca pelo claim "nameid"
var jobj = JObject.Parse(json);
var nameIdClaim = jobj.Properties()
    .FirstOrDefault(p => p.Name.Contains("nameid", StringComparison.OrdinalIgnoreCase));

return nameIdClaim?.Value?.ToString();
```

---

### 2. Cadastro de Novo Usuário

**Método:** `Cadastrar(CadastroDto dto)`

#### HTTP Request
```http
POST http://192.168.1.132:5246/api/usuarios/registrar
Content-Type: application/json

{
  "nome": "Novo Usuário",
  "email": "novo@exemplo.com",
  "senha": "senha123",
  "tipoUsuario": 1
}
```

#### Processamento Backend

```sql
-- Controller: UsuariosController.Registrar()
INSERT INTO Usuarios (Nome, Email, Senha, TipoUsuario, Ativo, DataCadastro)
VALUES (
    @Nome,
    @Email,
    @SenhaHash, -- BCrypt hash
    1,          -- Fixo: usuário comum
    1,          -- Ativo
    GETDATE()
);
```

#### Response
```json
{
  "message": "Usuário cadastrado com sucesso!"
}
```

---

### 3. Solicitação de Reset de Senha

**Método:** `SolicitarResetSenhaAsync(string email)`

#### HTTP Request
```http
POST http://192.168.1.132:5246/api/usuarios/esqueci-senha
Content-Type: application/json

{
  "email": "usuario@exemplo.com"
}
```

#### Processamento Backend

```sql
-- Verifica existência do usuário
SELECT Id, Email, Nome
FROM Usuarios
WHERE Email = @Email AND Ativo = 1;

-- Gera token único e armazena
UPDATE Usuarios
SET 
    TokenResetSenha = @Token,
    TokenResetSenhaExpiracao = DATEADD(hour, 24, GETDATE())
WHERE Id = @UserId;
```

#### Response
```json
{
  "message": "E-mail enviado com sucesso! Verifique sua caixa de entrada."
}
```

---

### 4. Reset de Senha

**Método:** `ResetarSenhaAsync(ResetSenhaDto dto)`

#### HTTP Request
```http
POST http://192.168.1.132:5246/api/usuarios/resetar-senha
Content-Type: application/json

{
  "token": "abc123...",
  "novaSenha": "novaSenha123"
}
```

#### Processamento Backend

```sql
-- Valida token e expiracao
SELECT Id
FROM Usuarios
WHERE TokenResetSenha = @Token
  AND TokenResetSenhaExpiracao > GETDATE()
  AND Ativo = 1;

-- Atualiza senha
UPDATE Usuarios
SET 
    Senha = @NovoHash, -- BCrypt hash
    TokenResetSenha = NULL,
    TokenResetSenhaExpiracao = NULL
WHERE Id = @UserId;
```

#### Response
```json
{
  "message": "Senha alterada com sucesso!"
}
```

---

## 📋 Operações de Chamados

### 5. Listar Meus Chamados

**Service:** `ChamadoService.cs`  
**Método:** `GetMeusChamados()`

#### HTTP Request
```http
GET http://192.168.1.132:5246/api/chamados?solicitanteId=42
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Processamento Backend

```sql
-- Controller: ChamadosController.GetAll(int? solicitanteId)
SELECT 
    c.Id,
    c.Titulo,
    c.Descricao,
    c.DataCriacao,
    c.DataAtualizacao,
    c.DataFechamento,
    c.SolicitanteId,
    c.ResponsavelId,
    c.StatusId,
    c.CategoriaId,
    c.PrioridadeId,
    c.FechadoPorId,  -- ⭐ NOVA COLUNA
    -- Solicitante
    s.Id AS Solicitante_Id,
    s.Nome AS Solicitante_Nome,
    s.Email AS Solicitante_Email,
    -- Responsavel
    r.Id AS Responsavel_Id,
    r.Nome AS Responsavel_Nome,
    -- Status
    st.Id AS Status_Id,
    st.Nome AS Status_Nome,
    st.Cor AS Status_Cor,
    -- Categoria
    cat.Id AS Categoria_Id,
    cat.Nome AS Categoria_Nome,
    -- Prioridade
    p.Id AS Prioridade_Id,
    p.Nome AS Prioridade_Nome,
    p.Nivel AS Prioridade_Nivel,
    -- Fechado Por ⭐
    fp.Id AS FechadoPor_Id,
    fp.Nome AS FechadoPor_Nome,
    fp.Email AS FechadoPor_Email
FROM Chamados c
LEFT JOIN Usuarios s ON c.SolicitanteId = s.Id
LEFT JOIN Usuarios r ON c.ResponsavelId = r.Id
LEFT JOIN Status st ON c.StatusId = st.Id
LEFT JOIN Categorias cat ON c.CategoriaId = cat.Id
LEFT JOIN Prioridades p ON c.PrioridadeId = p.Id
LEFT JOIN Usuarios fp ON c.FechadoPorId = fp.Id  -- ⭐ NOVA JOIN
WHERE c.SolicitanteId = @SolicitanteId  -- Filtro obrigatório no mobile
ORDER BY c.DataCriacao DESC;
```

#### Response
```json
[
  {
    "id": 1,
    "titulo": "Computador não liga",
    "descricao": "O computador do laboratório 3 não está ligando",
    "dataCriacao": "2024-11-01T10:00:00Z",
    "dataAtualizacao": "2024-11-04T14:30:00Z",
    "dataFechamento": "2024-11-04T14:30:00Z",
    "solicitante": {
      "id": 42,
      "nome": "João Silva",
      "email": "joao@exemplo.com"
    },
    "responsavel": {
      "id": 5,
      "nome": "Técnico Carlos",
      "email": "carlos@exemplo.com"
    },
    "status": {
      "id": 5,
      "nome": "Fechado",
      "cor": "#28a745"
    },
    "categoria": {
      "id": 2,
      "nome": "Hardware"
    },
    "prioridade": {
      "id": 3,
      "nome": "Alta",
      "nivel": 3
    },
    "fechadoPor": {  // ⭐ DADOS DE RASTREAMENTO
      "id": 5,
      "nome": "Técnico Carlos",
      "email": "carlos@exemplo.com"
    }
  }
]
```

#### Uso no Mobile
- **ViewModel:** `ChamadosListViewModel.cs`
- **View:** `ChamadosListPage.xaml`
- **Exibição:** Lista de chamados do usuário logado

---

### 6. Detalhes de um Chamado

**Método:** `GetById(int id)`

#### HTTP Request
```http
GET http://192.168.1.132:5246/api/chamados/123
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Processamento Backend

```sql
-- Controller: ChamadosController.GetById(int id)
SELECT 
    c.Id,
    c.Titulo,
    c.Descricao,
    c.DataCriacao,
    c.DataAtualizacao,
    c.DataFechamento,
    c.SolicitanteId,
    c.ResponsavelId,
    c.StatusId,
    c.CategoriaId,
    c.PrioridadeId,
    c.FechadoPorId,  -- ⭐
    -- Todos os JOINs (igual ao GetAll)
    s.Nome AS Solicitante_Nome,
    r.Nome AS Responsavel_Nome,
    st.Nome AS Status_Nome,
    cat.Nome AS Categoria_Nome,
    p.Nome AS Prioridade_Nome,
    fp.Nome AS FechadoPor_Nome,  -- ⭐
    fp.Email AS FechadoPor_Email -- ⭐
FROM Chamados c
LEFT JOIN Usuarios s ON c.SolicitanteId = s.Id
LEFT JOIN Usuarios r ON c.ResponsavelId = r.Id
LEFT JOIN Status st ON c.StatusId = st.Id
LEFT JOIN Categorias cat ON c.CategoriaId = cat.Id
LEFT JOIN Prioridades p ON c.PrioridadeId = p.Id
LEFT JOIN Usuarios fp ON c.FechadoPorId = fp.Id  -- ⭐
WHERE c.Id = @Id;
```

#### Response
```json
{
  "id": 123,
  "titulo": "Impressora travada",
  "descricao": "A impressora do 2º andar está travando papel",
  "dataCriacao": "2024-11-03T09:15:00Z",
  "dataAtualizacao": "2024-11-04T16:20:00Z",
  "dataFechamento": "2024-11-04T16:20:00Z",
  "solicitante": {
    "id": 42,
    "nome": "João Silva"
  },
  "responsavel": {
    "id": 7,
    "nome": "Técnico Ana"
  },
  "status": {
    "id": 5,
    "nome": "Fechado",
    "cor": "#28a745"
  },
  "categoria": {
    "id": 2,
    "nome": "Hardware"
  },
  "prioridade": {
    "id": 2,
    "nome": "Média"
  },
  "fechadoPor": {  // ⭐ RASTREAMENTO DE FECHAMENTO
    "id": 7,
    "nome": "Técnico Ana",
    "email": "ana@exemplo.com"
  }
}
```

#### Uso no Mobile
- **ViewModel:** `ChamadoDetailViewModel.cs`
- **View:** `ChamadoDetailPage.xaml`
- **Exibição:** Detalhes completos do chamado

---

### 7. Criar Chamado com Análise Automática (IA)

**Método:** `CreateComAnaliseAutomatica(CriarChamadoComAnaliseDto dto)`

#### HTTP Request
```http
POST http://192.168.1.132:5246/api/chamados/analisar
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "titulo": "Tela azul no computador",
  "descricao": "O computador está apresentando tela azul com erro CRITICAL_PROCESS_DIED",
  "solicitanteId": 42
}
```

#### Processamento Backend

```sql
-- 1. Análise de IA (OpenAIService)
-- Chama GPT-4 para analisar e sugerir:
-- - Categoria (Hardware, Software, Rede, etc.)
-- - Prioridade (Baixa, Média, Alta, Urgente)

-- 2. Inserção do Chamado
INSERT INTO Chamados (
    Titulo,
    Descricao,
    SolicitanteId,
    CategoriaId,    -- ⬅ Sugerido pela IA
    PrioridadeId,   -- ⬅ Sugerido pela IA
    StatusId,       -- 1 = "Aberto"
    DataCriacao,
    DataAtualizacao
)
VALUES (
    @Titulo,
    @Descricao,
    @SolicitanteId,
    @CategoriaIdSugerida,
    @PrioridadeIdSugerida,
    1,
    GETDATE(),
    GETDATE()
);

-- 3. Retorna chamado criado com todos os JOINs
SELECT 
    c.Id,
    c.Titulo,
    -- ... todos os campos
    cat.Nome AS Categoria_Nome,
    p.Nome AS Prioridade_Nome
FROM Chamados c
LEFT JOIN Categorias cat ON c.CategoriaId = cat.Id
LEFT JOIN Prioridades p ON c.PrioridadeId = p.Id
WHERE c.Id = @NovoId;
```

#### Response
```json
{
  "chamado": {
    "id": 456,
    "titulo": "Tela azul no computador",
    "descricao": "O computador está apresentando tela azul...",
    "status": {
      "id": 1,
      "nome": "Aberto"
    },
    "categoria": {
      "id": 2,
      "nome": "Hardware"  // ⬅ Sugerido pela IA
    },
    "prioridade": {
      "id": 3,
      "nome": "Alta"      // ⬅ Sugerido pela IA
    }
  },
  "analiseIA": {
    "categoriaSugerida": "Hardware",
    "prioridadeSugerida": "Alta",
    "justificativa": "Erro CRITICAL_PROCESS_DIED indica falha crítica..."
  }
}
```

#### Uso no Mobile
- **ViewModel:** `NovoChamadoViewModel.cs`
- **View:** `NovoChamadoPage.xaml`
- **Feature:** Criação inteligente com sugestões automáticas

---

### 8. Atualizar Chamado

**Método:** `Update(int id, AtualizarChamadoDto dto)`

#### HTTP Request
```http
PUT http://192.168.1.132:5246/api/chamados/123
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "titulo": "Impressora travada - RESOLVIDO",
  "descricao": "Problema resolvido após limpeza",
  "categoriaId": 2,
  "prioridadeId": 1,
  "statusId": 5
}
```

#### Processamento Backend

```sql
-- Controller: ChamadosController.Update(int id)
UPDATE Chamados
SET 
    Titulo = @Titulo,
    Descricao = @Descricao,
    CategoriaId = @CategoriaId,
    PrioridadeId = @PrioridadeId,
    StatusId = @StatusId,
    DataAtualizacao = GETDATE(),
    -- Se StatusId = 5 (Fechado), atualiza:
    DataFechamento = CASE WHEN @StatusId = 5 THEN GETDATE() ELSE DataFechamento END,
    FechadoPorId = CASE WHEN @StatusId = 5 THEN @UsuarioLogadoId ELSE FechadoPorId END  -- ⭐ RASTREAMENTO
WHERE Id = @Id;

-- Retorna chamado atualizado
SELECT c.*, s.Nome, r.Nome, st.Nome, cat.Nome, p.Nome, fp.Nome  -- ⭐ Inclui FechadoPor
FROM Chamados c
-- ... JOINs
WHERE c.Id = @Id;
```

#### Response
```json
{
  "id": 123,
  "titulo": "Impressora travada - RESOLVIDO",
  "status": {
    "id": 5,
    "nome": "Fechado"
  },
  "dataFechamento": "2024-11-04T16:45:00Z",
  "fechadoPor": {  // ⭐ AUTOMATICAMENTE PREENCHIDO
    "id": 42,
    "nome": "João Silva",
    "email": "joao@exemplo.com"
  }
}
```

---

### 9. Fechar Chamado

**Método:** `Close(int id)`

#### HTTP Request
```http
PUT http://192.168.1.132:5246/api/chamados/123
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "statusId": 5  // 5 = "Fechado"
}
```

#### Processamento Backend

```sql
-- ⭐ RASTREAMENTO AUTOMÁTICO DE FECHAMENTO
UPDATE Chamados
SET 
    StatusId = 5,
    DataFechamento = GETDATE(),
    FechadoPorId = @UsuarioLogadoId,  -- ⭐ ID DO USUÁRIO QUE FECHOU
    DataAtualizacao = GETDATE()
WHERE Id = @Id;

-- Retorna chamado com informações de fechamento
SELECT 
    c.*,
    fp.Id AS FechadoPor_Id,
    fp.Nome AS FechadoPor_Nome,
    fp.Email AS FechadoPor_Email
FROM Chamados c
LEFT JOIN Usuarios fp ON c.FechadoPorId = fp.Id
WHERE c.Id = @Id;
```

#### Response
```json
{
  "id": 123,
  "status": {
    "id": 5,
    "nome": "Fechado",
    "cor": "#28a745"
  },
  "dataFechamento": "2024-11-04T17:00:00Z",
  "fechadoPor": {  // ⭐ QUEM FECHOU O CHAMADO
    "id": 42,
    "nome": "João Silva",
    "email": "joao@exemplo.com"
  }
}
```

#### Uso no Mobile
- **ViewModel:** `ChamadoDetailViewModel.cs`
- **Action:** Botão "Fechar Chamado"
- **Resultado:** Chamado fechado com rastreamento automático

---

## 📦 Dados de Suporte

### 10. Listar Categorias

**Service:** `CategoriaService.cs`  
**Método:** `GetAll()`

#### HTTP Request
```http
GET http://192.168.1.132:5246/api/categorias
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Processamento Backend

```sql
-- Controller: CategoriasController.GetAll()
SELECT 
    Id,
    Nome,
    Descricao,
    Ativo
FROM Categorias
WHERE Ativo = 1
ORDER BY Nome;
```

#### Response
```json
[
  { "id": 1, "nome": "Software", "descricao": "Problemas relacionados a software" },
  { "id": 2, "nome": "Hardware", "descricao": "Problemas relacionados a hardware" },
  { "id": 3, "nome": "Rede", "descricao": "Problemas de conectividade" },
  { "id": 4, "nome": "Acesso", "descricao": "Problemas de login e permissões" }
]
```

#### Uso no Mobile
- **ViewModel:** `NovoChamadoViewModel.cs`, `ChamadoDetailViewModel.cs`
- **View:** Picker/ComboBox de seleção de categoria

---

### 11. Listar Prioridades

**Service:** `PrioridadeService.cs`  
**Método:** `GetAll()`

#### HTTP Request
```http
GET http://192.168.1.132:5246/api/prioridades
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Processamento Backend

```sql
-- Controller: PrioridadesController.GetAll()
SELECT 
    Id,
    Nome,
    Nivel,
    Ativo
FROM Prioridades
WHERE Ativo = 1
ORDER BY Nivel;
```

#### Response
```json
[
  { "id": 1, "nome": "Baixa", "nivel": 1 },
  { "id": 2, "nome": "Média", "nivel": 2 },
  { "id": 3, "nome": "Alta", "nivel": 3 },
  { "id": 4, "nome": "Urgente", "nivel": 4 }
]
```

#### Uso no Mobile
- **ViewModel:** `NovoChamadoViewModel.cs`, `ChamadoDetailViewModel.cs`
- **View:** Picker/ComboBox de seleção de prioridade

---

### 12. Listar Status

**Service:** `StatusService.cs`  
**Método:** `GetAll()`

#### HTTP Request
```http
GET http://192.168.1.132:5246/api/status
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkjXVCJ9...
```

#### Processamento Backend

```sql
-- Controller: StatusController.GetAll()
SELECT 
    Id,
    Nome,
    Cor,
    Ativo
FROM Status
WHERE Ativo = 1
ORDER BY Id;
```

#### Response
```json
[
  { "id": 1, "nome": "Aberto", "cor": "#007bff" },
  { "id": 2, "nome": "Em Andamento", "cor": "#ffc107" },
  { "id": 3, "nome": "Aguardando", "cor": "#6c757d" },
  { "id": 4, "nome": "Resolvido", "cor": "#28a745" },
  { "id": 5, "nome": "Fechado", "cor": "#28a745" }
]
```

#### Uso no Mobile
- **ViewModel:** `ChamadoDetailViewModel.cs`
- **View:** Indicador de status com cor

---

## 💬 Comentários

### 13. Listar Comentários de um Chamado

**Service:** `ComentarioService.cs`  
**Método:** `GetComentarios(int chamadoId)`

#### HTTP Request
```http
GET http://192.168.1.132:5246/api/chamados/123/comentarios
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Processamento Backend

```sql
-- Controller: ChamadosController.GetComentarios(int chamadoId)
SELECT 
    co.Id,
    co.Texto,
    co.DataCriacao,
    co.ChamadoId,
    co.UsuarioId,
    u.Id AS Usuario_Id,
    u.Nome AS Usuario_Nome,
    u.Email AS Usuario_Email,
    u.TipoUsuario AS Usuario_TipoUsuario
FROM Comentarios co
INNER JOIN Usuarios u ON co.UsuarioId = u.Id
WHERE co.ChamadoId = @ChamadoId
ORDER BY co.DataCriacao ASC;
```

#### Response
```json
[
  {
    "id": 1,
    "texto": "Estou verificando o problema",
    "dataCriacao": "2024-11-03T10:30:00Z",
    "usuario": {
      "id": 5,
      "nome": "Técnico Carlos",
      "email": "carlos@exemplo.com",
      "tipoUsuario": 2
    }
  },
  {
    "id": 2,
    "texto": "Problema identificado: placa de vídeo com defeito",
    "dataCriacao": "2024-11-03T14:15:00Z",
    "usuario": {
      "id": 5,
      "nome": "Técnico Carlos",
      "email": "carlos@exemplo.com",
      "tipoUsuario": 2
    }
  }
]
```

#### Uso no Mobile
- **ViewModel:** `ChamadoDetailViewModel.cs`
- **View:** Lista de comentários na página de detalhes

---

### 14. Adicionar Comentário

**Método:** `AdicionarComentarioAsync(int chamadoId, CriarComentarioRequestDto dto)`

#### HTTP Request
```http
POST http://192.168.1.132:5246/api/chamados/123/comentarios
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "texto": "Obrigado pelo atendimento!"
}
```

#### Processamento Backend

```sql
-- Controller: ChamadosController.AdicionarComentario()
INSERT INTO Comentarios (
    Texto,
    ChamadoId,
    UsuarioId,
    DataCriacao
)
VALUES (
    @Texto,
    @ChamadoId,
    @UsuarioLogadoId,  -- ⬅ Do JWT token
    GETDATE()
);

-- Retorna comentário criado
SELECT 
    co.Id,
    co.Texto,
    co.DataCriacao,
    u.Nome AS Usuario_Nome
FROM Comentarios co
INNER JOIN Usuarios u ON co.UsuarioId = u.Id
WHERE co.Id = @NovoId;
```

#### Response
```json
{
  "id": 15,
  "texto": "Obrigado pelo atendimento!",
  "dataCriacao": "2024-11-04T17:30:00Z",
  "usuario": {
    "id": 42,
    "nome": "João Silva"
  }
}
```

---

## ⭐ Rastreabilidade de Fechamento

### 🎯 Feature Implementada: Quem Fechou o Chamado

**Status:** ✅ **Implementado no Backend** | ⚠️ **Pendente UI no Mobile**

#### Dados Disponíveis na API

Todos os endpoints que retornam chamados agora incluem:

```json
{
  "fechadoPor": {
    "id": 42,
    "nome": "João Silva",
    "email": "joao@exemplo.com"
  },
  "dataFechamento": "2024-11-04T17:00:00Z"
}
```

#### Quando é Preenchido?

O campo `FechadoPorId` é automaticamente preenchido quando:

1. **Status muda para 5 (Fechado)** via qualquer operação PUT
2. **Método `Close()` é chamado** no `ChamadoService`
3. **Usuário atualiza chamado** com `StatusId = 5`

**Lógica no Backend (Controller):**
```csharp
if (dto.StatusId == 5 && chamado.StatusId != 5)
{
    chamado.DataFechamento = DateTime.UtcNow;
    chamado.FechadoPorId = User.GetUserId(); // ⬅ ID do token JWT
}
```

#### Estrutura do Banco de Dados

```sql
-- Tabela: Chamados
ALTER TABLE Chamados
ADD FechadoPorId INT NULL;

ALTER TABLE Chamados
ADD CONSTRAINT FK_Chamados_FechadoPor
FOREIGN KEY (FechadoPorId) REFERENCES Usuarios(Id);
```

**Migration:** `20251104184208_AdicionarFechadoPorChamado.cs`

---

## 🔄 Comparação: Desktop vs Mobile

### Principais Diferenças

| Aspecto | Desktop (HTML/JS) | Mobile (.NET MAUI) |
|---------|-------------------|-------------------|
| **Tecnologia** | HTML, CSS, JavaScript, Fetch API | C#, XAML, .NET MAUI |
| **Autenticação** | JWT Bearer Token | JWT Bearer Token (idêntico) |
| **Acesso** | Todos os tipos de usuário | ⚠️ Apenas TipoUsuario = 1 |
| **Filtro de Chamados** | Pode ver todos (se admin) | Apenas `solicitanteId={userId}` |
| **Base URL** | `http://localhost:5246/api/` | `http://192.168.1.132:5246/api/` |
| **Gestão de Usuários** | Sim (CRUD completo) | Não (apenas auto-cadastro) |
| **Gestão de Técnicos** | Sim (atribuir responsável) | Não |
| **Relatórios** | Sim (Dashboard com gráficos) | Básico (contadores) |
| **Edição de Chamados** | Sim (título, descrição, categoria, etc.) | ⚠️ Limitado |
| **IA (Análise Automática)** | Não | ✅ Sim (`CreateComAnaliseAutomatica`) |
| **FechadoPor Display** | ✅ Implementado | ⚠️ Pendente UI |

### Endpoints Exclusivos do Desktop

```
GET  /api/usuarios           - Listar todos os usuários
POST /api/usuarios           - Criar usuário (admin)
PUT  /api/usuarios/{id}      - Editar usuário
DELETE /api/usuarios/{id}    - Desativar usuário
GET  /api/relatorios         - Dashboard com estatísticas
GET  /api/chamados           - Ver TODOS os chamados (sem filtro)
PUT  /api/chamados/{id}/atribuir - Atribuir técnico
```

### Endpoints Exclusivos do Mobile

```
POST /api/chamados/analisar  - Criar chamado com análise de IA
POST /api/usuarios/registrar - Auto-cadastro de usuários
```

---

## 📱 ViewModels e Uso de Dados

### Mapeamento ViewModel → Service → API

#### 1. LoginViewModel

**Service:** `AuthService`

```csharp
// LoginViewModel.cs
public async Task Login()
{
    var dto = new LoginDto 
    { 
        Email = Email, 
        Senha = Senha 
    };
    
    var response = await _authService.Login(dto);
    // ✅ Armazena: Token, UserId, TipoUsuario, Email
    
    await Shell.Current.GoToAsync("//main");
}
```

**APIs Chamadas:**
- POST `/api/usuarios/login`

**Dados Extraídos:**
- Token JWT
- UserId (claim "nameid")
- TipoUsuario (validado = 1)
- Email

---

#### 2. ChamadosListViewModel

**Service:** `ChamadoService`

```csharp
// ChamadosListViewModel.cs
public async Task LoadChamados()
{
    var chamados = await _chamadoService.GetMeusChamados();
    // ✅ Filtrado por Settings.UserId automaticamente
    
    Chamados = new ObservableCollection<ChamadoDto>(chamados);
}
```

**APIs Chamadas:**
- GET `/api/chamados?solicitanteId={userId}`

**Dados Extraídos:**
- Lista de chamados do usuário
- Solicitante, Responsável, Status, Categoria, Prioridade
- ⭐ **FechadoPor** (se StatusId = 5)

---

#### 3. ChamadoDetailViewModel

**Services:** `ChamadoService`, `ComentarioService`

```csharp
// ChamadoDetailViewModel.cs
public async Task LoadChamado(int id)
{
    Chamado = await _chamadoService.GetById(id);
    // ✅ Detalhes completos incluindo FechadoPor
    
    Comentarios = await _comentarioService.GetComentarios(id);
    // ✅ Histórico de comentários
}

public async Task FecharChamado()
{
    await _chamadoService.Close(Chamado.Id);
    // ✅ Fecha e registra FechadoPorId automaticamente
}

public async Task AdicionarComentario(string texto)
{
    var dto = new CriarComentarioRequestDto { Texto = texto };
    await _comentarioService.AdicionarComentarioAsync(Chamado.Id, dto);
}
```

**APIs Chamadas:**
- GET `/api/chamados/{id}`
- GET `/api/chamados/{id}/comentarios`
- PUT `/api/chamados/{id}` (para fechar)
- POST `/api/chamados/{id}/comentarios`

**Dados Extraídos:**
- Detalhes completos do chamado
- Lista de comentários com autores
- ⭐ **FechadoPor** após fechamento

---

#### 4. DashboardViewModel

**Service:** `ChamadoService`

```csharp
// DashboardViewModel.cs
public async Task LoadDashboard()
{
    var chamados = await _chamadoService.GetMeusChamados();
    
    TotalChamados = chamados.Count();
    ChamadosAbertos = chamados.Count(c => c.Status.Id == 1);
    ChamadosEmAndamento = chamados.Count(c => c.Status.Id == 2);
    ChamadosFechados = chamados.Count(c => c.Status.Id == 5);
}
```

**APIs Chamadas:**
- GET `/api/chamados?solicitanteId={userId}`

**Dados Extraídos:**
- Contadores por status
- Estatísticas básicas

---

#### 5. NovoChamadoViewModel

**Services:** `ChamadoService`, `CategoriaService`, `PrioridadeService`

```csharp
// NovoChamadoViewModel.cs
public async Task Initialize()
{
    Categorias = await _categoriaService.GetAll();
    Prioridades = await _prioridadeService.GetAll();
}

public async Task CriarComIA()
{
    var dto = new CriarChamadoComAnaliseDto
    {
        Titulo = Titulo,
        Descricao = Descricao,
        SolicitanteId = Settings.UserId
    };
    
    var response = await _chamadoService.CreateComAnaliseAutomatica(dto);
    // ✅ IA sugere categoria e prioridade automaticamente
}
```

**APIs Chamadas:**
- GET `/api/categorias`
- GET `/api/prioridades`
- POST `/api/chamados/analisar`

**Dados Extraídos:**
- Lista de categorias disponíveis
- Lista de prioridades disponíveis
- Sugestões automáticas da IA

---

## ✅ Checklist de Implementação

### Backend (✅ Completo)

- [x] Adicionar coluna `FechadoPorId` em `Chamados`
- [x] Criar FK para `Usuarios`
- [x] Atualizar `Chamado.cs` entity
- [x] Atualizar `ChamadoDTO.cs`
- [x] Modificar `ChamadosController.Update()` para rastrear fechamento
- [x] Adicionar `.Include(c => c.FechadoPor)` em todas as queries
- [x] Aplicar migration

### Mobile - Data Layer (✅ Completo)

- [x] `ChamadoService` recebe FechadoPor na resposta
- [x] `AuthService` implementado com JWT
- [x] `CategoriaService`, `PrioridadeService`, `StatusService` funcionais
- [x] `ComentarioService` implementado
- [x] `ApiService` com tratamento de erros

### Mobile - UI (⚠️ Pendente)

- [ ] **Atualizar `ChamadoDetailPage.xaml`**
  - [ ] Adicionar seção "Informações de Fechamento"
  - [ ] Exibir `FechadoPor.Nome`
  - [ ] Exibir `DataFechamento` formatada
  - [ ] Usar `IsVisible` para mostrar apenas se fechado

- [ ] **Atualizar `ChamadoDetailViewModel.cs`**
  - [ ] Adicionar propriedades:
    - `bool IsFechado`
    - `string FechadoPorNome`
    - `string DataFechamentoFormatada`
  - [ ] Mapear de `Chamado.FechadoPor` e `Chamado.DataFechamento`

- [ ] **Atualizar `ChamadosListPage.xaml` (opcional)**
  - [ ] Mostrar ícone/badge "Fechado por: {nome}" em chamados fechados

### Testes

- [ ] Testar login com usuário comum (TipoUsuario = 1)
- [ ] Verificar lista de chamados filtrada por solicitanteId
- [ ] Abrir detalhes de chamado fechado
- [ ] Verificar se `FechadoPor` aparece corretamente
- [ ] Fechar um chamado e confirmar rastreamento
- [ ] Adicionar comentário e verificar autor
- [ ] Criar chamado com IA e validar sugestões

---

## 📄 Exemplo de Código - Update UI

### ChamadoDetailPage.xaml (Adicionar)

```xml
<!-- Seção de Fechamento -->
<StackLayout 
    IsVisible="{Binding IsFechado}"
    Padding="15"
    BackgroundColor="#F0F8FF"
    Margin="0,10,0,0">
    
    <Label 
        Text="📋 Informações de Fechamento" 
        FontSize="16" 
        FontAttributes="Bold"
        TextColor="#007BFF" />
    
    <BoxView HeightRequest="1" Color="#DEE2E6" Margin="0,5,0,10"/>
    
    <Grid ColumnDefinitions="Auto,*" RowSpacing="8">
        <Label 
            Grid.Row="0" Grid.Column="0"
            Text="Fechado por:" 
            FontAttributes="Bold"
            VerticalOptions="Center"/>
        <Label 
            Grid.Row="0" Grid.Column="1"
            Text="{Binding FechadoPorNome}" 
            Margin="10,0,0,0"
            VerticalOptions="Center"/>
        
        <Label 
            Grid.Row="1" Grid.Column="0"
            Text="Data:" 
            FontAttributes="Bold"
            VerticalOptions="Center"/>
        <Label 
            Grid.Row="1" Grid.Column="1"
            Text="{Binding DataFechamentoFormatada}" 
            Margin="10,0,0,0"
            VerticalOptions="Center"/>
    </Grid>
</StackLayout>
```

### ChamadoDetailViewModel.cs (Adicionar)

```csharp
// Propriedades
public bool IsFechado => Chamado?.Status?.Id == 5;

public string FechadoPorNome => Chamado?.FechadoPor?.Nome ?? "Desconhecido";

public string DataFechamentoFormatada
{
    get
    {
        if (Chamado?.DataFechamento == null)
            return "-";
        
        return Chamado.DataFechamento.Value.ToLocalTime().ToString("dd/MM/yyyy HH:mm");
    }
}

// No método LoadChamado, notificar mudanças
private async Task LoadChamado(int id)
{
    Chamado = await _chamadoService.GetById(id);
    
    OnPropertyChanged(nameof(IsFechado));
    OnPropertyChanged(nameof(FechadoPorNome));
    OnPropertyChanged(nameof(DataFechamentoFormatada));
}
```

---

## 📊 Resumo de Dados Extraídos

### Tabelas Acessadas pelo Mobile

| Tabela | Leitura | Escrita | Filtros Aplicados |
|--------|---------|---------|-------------------|
| **Usuarios** | ✅ Login | ✅ Cadastro | Email, Ativo=1, TipoUsuario=1 |
| **Chamados** | ✅ Lista + Detalhes | ✅ Criar/Atualizar/Fechar | SolicitanteId={userId} |
| **Categorias** | ✅ Lista | ❌ | Ativo=1 |
| **Prioridades** | ✅ Lista | ❌ | Ativo=1 |
| **Status** | ✅ Lista | ❌ | Ativo=1 |
| **Comentarios** | ✅ Por ChamadoId | ✅ Adicionar | ChamadoId |

### Campos Novos (Rastreabilidade)

| Campo | Tabela | Tipo | Quando Preenche | Quem Preenche |
|-------|--------|------|-----------------|---------------|
| **FechadoPorId** | Chamados | int? | Status → 5 | Backend (UserId do JWT) |
| **FechadoPor** (Navigation) | Chamados | Usuario | - | EF Core Include |

---

## 🎯 Próximos Passos

1. **Implementar UI de FechadoPor no Mobile** (estimativa: 30 min)
   - Atualizar `ChamadoDetailPage.xaml`
   - Atualizar `ChamadoDetailViewModel.cs`
   - Testar em device físico

2. **Melhorar Dashboard Mobile** (opcional)
   - Adicionar gráficos de chamados por categoria
   - Mostrar últimos chamados fechados com autores

3. **Notificações Push** (futuro)
   - Notificar quando chamado é fechado
   - Incluir nome do técnico que fechou

4. **Histórico de Alterações** (futuro)
   - Registrar todas as mudanças de status
   - Mostrar timeline completa no mobile

---

**Documento Criado:** 2024-11-04  
**Última Atualização:** 2024-11-04  
**Status:** ✅ Backend Completo | ⚠️ UI Mobile Pendente
