# 📊 Mapeamento Completo: Front-End Desktop ↔ API/Banco de Dados

## Visão Geral

Este documento detalha **todas as requisições HTTP** que o front-end desktop faz para a API, quais dados são extraídos do banco de dados e como são utilizados na interface.

---

## 🔐 1. Autenticação e Usuários

### 1.1 Login (`POST /api/usuarios/login`)

**Arquivo:** `script-desktop.js` (linha 121)

**Requisição:**
```javascript
fetch(`${API_BASE}/api/usuarios/login`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    Email: "usuario@email.com",
    Senha: "senha123"
  })
})
```

**Resposta da API:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "tipoUsuario": 2,
  "nomeCompleto": "Pedro Silva",
  "email": "pedro.tecnico@neurohelp.com"
}
```

**Dados Extraídos do Banco:**
- ✅ `Usuarios.Id` (via JWT token)
- ✅ `Usuarios.Email`
- ✅ `Usuarios.SenhaHash` (verificado via BCrypt)
- ✅ `Usuarios.TipoUsuario` (1=Comum, 2=Técnico, 3=Admin)
- ✅ `Usuarios.NomeCompleto`
- ✅ `Usuarios.Ativo`

**Uso no Front-End:**
- Armazena `token` no `sessionStorage`
- Redireciona baseado em `tipoUsuario`:
  - 1 → `user-dashboard-desktop.html`
  - 2 → `tecnico-dashboard.html`
  - 3 → `admin-dashboard-desktop.html`

---

### 1.2 Esqueci Senha (`POST /api/usuarios/esqueci-senha`)

**Arquivo:** `script-desktop.js` (linha 200)

**Requisição:**
```javascript
fetch(`${API_BASE}/api/usuarios/esqueci-senha`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email: "usuario@email.com" })
})
```

**Dados Extraídos do Banco:**
- ✅ `Usuarios.Email`
- ✅ `Usuarios.Id`
- ⚡ Gera `PasswordResetToken` (GUID único)
- ⚡ Gera `ResetTokenExpires` (DateTime.UtcNow + 1 hora)

**Uso no Front-End:**
- Exibe mensagem de sucesso
- Instrui usuário a verificar email

---

### 1.3 Resetar Senha (`POST /api/usuarios/resetar-senha`)

**Arquivo:** `script-desktop.js` (linha 285)

**Requisição:**
```javascript
fetch(`${API_BASE}/api/usuarios/resetar-senha`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    token: "abc123-token-from-email",
    novaSenha: "novaSenha123"
  })
})
```

**Dados Extraídos/Atualizados:**
- ✅ Busca `Usuarios` por `PasswordResetToken`
- ✅ Valida `ResetTokenExpires` (não expirado)
- ⚡ Atualiza `SenhaHash` (BCrypt)
- ⚡ Limpa `PasswordResetToken` e `ResetTokenExpires`

---

### 1.4 Registrar Usuário Comum (`POST /api/usuarios/registrar`)

**Arquivo:** `script-desktop.js` (linha 351)

**Requisição:**
```javascript
fetch(`${API_BASE}/api/usuarios/registrar`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    nomeCompleto: "João Santos",
    email: "joao@email.com",
    senha: "senha123"
  })
})
```

**Dados Inseridos no Banco:**
- ⚡ Cria novo registro em `Usuarios`:
  - `NomeCompleto`
  - `Email`
  - `SenhaHash` (BCrypt)
  - `TipoUsuario = 1` (Usuário Comum)
  - `Ativo = true`
  - `DataCadastro = DateTime.UtcNow`

---

### 1.5 Registrar Técnico (`POST /api/usuarios/registrar-tecnico`)

**Arquivo:** `script-desktop.js` (linha 1688)

**Requisição:**
```javascript
fetch(`${API_BASE}/api/usuarios/registrar-tecnico`, {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    nomeCompleto: "Maria Técnica",
    email: "maria@neurohelp.com",
    senha: "senha123",
    especialidadeCategoriaId: 2
  })
})
```

**Dados Inseridos no Banco:**
- ⚡ Cria novo registro em `Usuarios`:
  - `NomeCompleto`
  - `Email`
  - `SenhaHash` (BCrypt)
  - `TipoUsuario = 2` (Técnico)
  - `EspecialidadeCategoriaId` (FK → `Categorias`)
  - `Ativo = true`
  - `DataCadastro = DateTime.UtcNow`

**Uso no Front-End:**
- Exibe mensagem de sucesso
- Recarrega lista de técnicos

---

### 1.6 Listar Técnicos (`GET /api/usuarios/tecnicos`)

**Arquivo:** `script-desktop.js` (linha 843)

**Requisição:**
```javascript
fetch(`${API_BASE}/api/usuarios/tecnicos`, {
  method: 'GET',
  headers: { 'Authorization': `Bearer ${token}` }
})
```

**Resposta da API:**
```json
{
  "$values": [
    {
      "id": 2,
      "nomeCompleto": "Pedro Silva - Tecnico Hardware",
      "email": "pedro.tecnico@neurohelp.com",
      "especialidadeCategoriaId": 1,
      "especialidadeCategoriaNome": "Hardware"
    }
  ]
}
```

**Dados Extraídos do Banco:**
- ✅ `Usuarios.Id`
- ✅ `Usuarios.NomeCompleto`
- ✅ `Usuarios.Email`
- ✅ `Usuarios.EspecialidadeCategoriaId`
- ✅ `Categorias.Nome` (JOIN)

**Uso no Front-End:**
- Popula dropdown "Atribuir Técnico" na página de detalhes
- Lista técnicos no admin dashboard

---

## 📋 2. Chamados (Tickets)

### 2.1 Listar Chamados (`GET /api/chamados`)

**Arquivo:** `script-desktop.js` (linha 408-442)

**Requisições Dinâmicas:**

**Admin (sem filtro):**
```javascript
fetch(`${API_BASE}/api/chamados`, {
  method: 'GET',
  headers: { 'Authorization': `Bearer ${token}` }
})
```

**Usuário Comum (filtrado por solicitante):**
```javascript
fetch(`${API_BASE}/api/chamados?solicitanteId=${userId}`, {
  method: 'GET',
  headers: { 'Authorization': `Bearer ${token}` }
})
```

**Técnico (filtrado por técnico):**
```javascript
// Implementação similar com tecnicoId
```

**Resposta da API:**
```json
{
  "$values": [
    {
      "id": 1,
      "titulo": "Problema com impressora",
      "descricao": "A impressora não está funcionando",
      "dataAbertura": "2025-11-04T10:30:00Z",
      "dataUltimaAtualizacao": "2025-11-04T14:20:00Z",
      "dataFechamento": null,
      "slaDataExpiracao": "2025-11-06T10:30:00Z",
      "categoriaNome": "Hardware",
      "statusNome": "Em Andamento",
      "prioridadeNome": "Alta",
      "solicitante": {
        "id": 1,
        "nomeCompleto": "Carlos Mendes",
        "email": "carlos.usuario@empresa.com"
      },
      "tecnico": {
        "id": 2,
        "nomeCompleto": "Pedro Silva",
        "email": "pedro.tecnico@neurohelp.com"
      },
      "fechadoPor": null,
      "historico": { "$values": [...] }
    }
  ]
}
```

**Dados Extraídos do Banco (Query com múltiplos JOINs):**

```sql
SELECT 
    c.Id, c.Titulo, c.Descricao, 
    c.DataAbertura, c.DataUltimaAtualizacao, c.DataFechamento,
    c.SlaDataExpiracao, c.StatusId, c.PrioridadeId, c.CategoriaId,
    c.SolicitanteId, c.TecnicoId, c.FechadoPorId,
    -- Categoria
    cat.Nome AS CategoriaNome,
    -- Status
    s.Nome AS StatusNome,
    -- Prioridade
    p.Nome AS PrioridadeNome,
    -- Solicitante (JOIN com Usuarios)
    sol.Id, sol.NomeCompleto, sol.Email,
    -- Técnico (LEFT JOIN - pode ser NULL)
    tec.Id, tec.NomeCompleto, tec.Email,
    -- FechadoPor (LEFT JOIN - pode ser NULL) ⭐ NOVA FEATURE
    fech.Id, fech.NomeCompleto, fech.Email
FROM Chamados c
INNER JOIN Categorias cat ON c.CategoriaId = cat.Id
INNER JOIN Status s ON c.StatusId = s.Id
INNER JOIN Prioridades p ON c.PrioridadeId = p.Id
INNER JOIN Usuarios sol ON c.SolicitanteId = sol.Id
LEFT JOIN Usuarios tec ON c.TecnicoId = tec.Id
LEFT JOIN Usuarios fech ON c.FechadoPorId = fech.Id  -- ⭐ RASTREAMENTO DE FECHAMENTO
ORDER BY c.DataAbertura DESC
```

**Campos Extraídos:**
- ✅ `Chamados.*` (todos os campos)
- ✅ `Categorias.Nome`
- ✅ `Status.Nome`
- ✅ `Prioridades.Nome`
- ✅ `Usuarios` (Solicitante) → `Id, NomeCompleto, Email`
- ✅ `Usuarios` (Técnico) → `Id, NomeCompleto, Email`
- ✅ `Usuarios` (FechadoPor) → `Id, NomeCompleto, Email` ⭐ **NOVO**

**Uso no Front-End (Tabela de Chamados):**
- Renderiza tabela com colunas:
  - **ID**: `#${chamado.id}`
  - **Título**: `chamado.titulo`
  - **Categoria**: `chamado.categoriaNome`
  - **Status**: Badge colorido com `chamado.statusNome`
  - **Prioridade**: `chamado.prioridadeNome`
  - **Ações**: Botão "Abrir"

**Função:** `renderTicketsTable()` (linha 497-559)

---

### 2.2 Detalhes do Chamado (`GET /api/chamados/{id}`)

**Arquivo:** `script-desktop.js` (linha 640)

**Requisição:**
```javascript
fetch(`${API_BASE}/api/chamados/${ticketId}`, {
  method: 'GET',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
})
```

**Resposta da API (Objeto Completo):**
```json
{
  "id": 1,
  "titulo": "Problema com impressora",
  "descricao": "A impressora HP do 2º andar não está imprimindo.",
  "dataAbertura": "2025-11-04T10:30:00Z",
  "dataUltimaAtualizacao": "2025-11-04T14:20:00Z",
  "dataFechamento": "2025-11-04T16:30:00Z",
  "slaDataExpiracao": "2025-11-06T10:30:00Z",
  "categoria": {
    "id": 1,
    "nome": "Hardware",
    "descricao": "Problemas com peças físicas"
  },
  "prioridade": {
    "id": 3,
    "nome": "Alta",
    "nivel": 3
  },
  "status": {
    "id": 5,
    "nome": "Fechado"
  },
  "solicitante": {
    "id": 1,
    "nomeCompleto": "Carlos Mendes",
    "email": "carlos.usuario@empresa.com",
    "tipoUsuario": 1
  },
  "tecnico": {
    "id": 2,
    "nomeCompleto": "Pedro Silva",
    "email": "pedro.tecnico@neurohelp.com",
    "tipoUsuario": 2
  },
  "fechadoPor": {
    "id": 2,
    "nomeCompleto": "Pedro Silva",
    "email": "pedro.tecnico@neurohelp.com",
    "tipoUsuario": 2
  },
  "historico": {
    "$values": [
      {
        "acao": "Status alterado de 'Em Andamento' para 'Fechado'",
        "nomeUsuario": "Pedro Silva",
        "dataHora": "2025-11-04T16:30:00Z"
      }
    ]
  },
  "analise": null
}
```

**Dados Extraídos do Banco (Query com INCLUDES):**
```sql
SELECT TOP(1)
    c.*, 
    -- Categoria
    cat.Id, cat.Nome, cat.Descricao,
    -- Status
    s.Id, s.Nome, s.Descricao,
    -- Prioridade
    p.Id, p.Nome, p.Nivel, p.Descricao,
    -- Solicitante
    sol.Id, sol.NomeCompleto, sol.Email, sol.TipoUsuario,
    -- Técnico
    tec.Id, tec.NomeCompleto, tec.Email, tec.TipoUsuario,
    -- FechadoPor ⭐
    fech.Id, fech.NomeCompleto, fech.Email, fech.TipoUsuario,
    -- Comentários
    com.Id, com.Texto, com.DataCriacao, com.UsuarioId,
    comUsr.NomeCompleto
FROM Chamados c
INNER JOIN Categorias cat ON c.CategoriaId = cat.Id
INNER JOIN Status s ON c.StatusId = s.Id
INNER JOIN Prioridades p ON c.PrioridadeId = p.Id
INNER JOIN Usuarios sol ON c.SolicitanteId = sol.Id
LEFT JOIN Usuarios tec ON c.TecnicoId = tec.Id
LEFT JOIN Usuarios fech ON c.FechadoPorId = fech.Id  -- ⭐
LEFT JOIN Comentarios com ON c.Id = com.ChamadoId
LEFT JOIN Usuarios comUsr ON com.UsuarioId = comUsr.Id
WHERE c.Id = @id
```

**Uso no Front-End (Página de Detalhes):**

**HTML Renderizado:**
```javascript
$("#t-id").textContent = `#${chamado.id}`;
$("#t-title").textContent = chamado.titulo;
$("#t-category").textContent = chamado.categoria.nome;
$("#t-priority").textContent = chamado.prioridade.nome;
$("#t-solicitante").textContent = chamado.solicitante.nomeCompleto;
$("#t-tecnico").textContent = chamado.tecnico?.nomeCompleto ?? 'Não atribuído';
$("#t-status").innerHTML = `<span class="badge">${chamado.status.nome}</span>`;
$("#t-data-abertura").textContent = new Date(chamado.dataAbertura).toLocaleDateString('pt-BR');
$("#t-data-atualizacao").textContent = new Date(chamado.dataUltimaAtualizacao).toLocaleDateString('pt-BR');
$("#t-sla-expiracao").textContent = chamado.slaDataExpiracao 
  ? new Date(chamado.slaDataExpiracao).toLocaleDateString('pt-BR') 
  : 'N/A';
$("#t-desc").textContent = chamado.descricao;

// ⭐ NOVO - Informações de fechamento
if (chamado.fechadoPor) {
  $("#t-fechado-por").textContent = chamado.fechadoPor.nomeCompleto;
  $("#t-data-fechamento").textContent = new Date(chamado.dataFechamento).toLocaleDateString('pt-BR');
}
```

**Elementos Exibidos na Página:**
1. **Informações Básicas:**
   - ID do Chamado
   - Título
   - Categoria
   - Prioridade
   - Status (com badge colorido)

2. **Pessoas Envolvidas:**
   - Solicitante (nome)
   - Técnico Atribuído (nome ou "Não atribuído")
   - **⭐ Fechado Por** (nome do usuário que fechou) - **NOVO**

3. **Datas:**
   - Data de Abertura
   - Data da Última Atualização
   - Data de Expiração do SLA
   - **⭐ Data de Fechamento** - **NOVO**

4. **Descrição:**
   - Texto completo do problema

5. **Histórico:**
   - Lista de ações (gerado dinamicamente)

6. **Comentários:**
   - Lista de comentários com autor e data

---

### 2.3 Criar Chamado (`POST /api/chamados/analisar`)

**Arquivo:** `script-desktop.js` (linha 586)

**Requisição:**
```javascript
fetch(`${API_BASE}/api/chamados/analisar`, {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    titulo: "Problema com impressora",
    descricao: "A impressora não está funcionando. Preciso imprimir documentos urgentes.",
    categoriaId: 1,
    prioridadeId: 2
  })
})
```

**Dados Inseridos no Banco:**

1. **Tabela `Chamados`:**
   - ⚡ `Titulo`
   - ⚡ `Descricao`
   - ⚡ `CategoriaId` (FK → `Categorias`)
   - ⚡ `PrioridadeId` (FK → `Prioridades`)
   - ⚡ `SolicitanteId` (do JWT token)
   - ⚡ `StatusId = 1` (Aberto)
   - ⚡ `TecnicoId = NULL` (não atribuído)
   - ⚡ `FechadoPorId = NULL`
   - ⚡ `DataAbertura = DateTime.UtcNow`
   - ⚡ `DataUltimaAtualizacao = DateTime.UtcNow`
   - ⚡ `DataFechamento = NULL`
   - ⚡ `SlaDataExpiracao` (calculado pela IA com base na prioridade)

**Resposta da API (Inclui Análise da IA):**
```json
{
  "id": 123,
  "titulo": "Problema com impressora",
  "analise": {
    "categoriaId": 1,
    "categoriaNome": "Hardware",
    "prioridadeId": 3,
    "prioridadeNome": "Alta",
    "motivoCategoria": "Problema relacionado a equipamento físico (impressora)",
    "motivoPrioridade": "Impacto em produtividade com urgência mencionada",
    "slaHoras": 24,
    "recomendacoes": [
      "Verificar cabo de alimentação",
      "Reiniciar impressora",
      "Verificar fila de impressão"
    ]
  }
}
```

**Uso no Front-End:**
- Exibe análise da IA
- Redireciona para dashboard
- Mostra toast de sucesso

---

### 2.4 Atualizar Chamado (`PUT /api/chamados/{id}`)

**Arquivo:** `script-desktop.js` (linha 794 e 902)

**Requisições Diferentes:**

**Atualizar Status:**
```javascript
fetch(`${API_BASE}/api/chamados/${ticketId}`, {
  method: 'PUT',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    statusId: 5  // Fechado
  })
})
```

**Atribuir Técnico:**
```javascript
fetch(`${API_BASE}/api/chamados/${ticketId}`, {
  method: 'PUT',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    tecnicoId: 2
  })
})
```

**Dados Atualizados no Banco:**
- ⚡ `StatusId` (se fornecido)
- ⚡ `TecnicoId` (se fornecido)
- ⚡ `DataUltimaAtualizacao = DateTime.UtcNow` (sempre)
- ⚡ **Se StatusId == 5 (Fechado):**
  - `FechadoPorId = userId` (do JWT) ⭐ **NOVO**
  - `DataFechamento = DateTime.UtcNow` ⭐
- ⚡ **Se StatusId != 5 (Reaberto):**
  - `FechadoPorId = NULL`
  - `DataFechamento = NULL`

**Lógica no Controller (Backend):**
```csharp
// Verifica se o novo status é 'Fechado' (StatusId = 5)
if (request.StatusId == 5 && chamado.StatusId != 5) 
{
    // Registra data e usuário que fechou o chamado
    chamado.DataFechamento = DateTime.UtcNow;
    
    // Captura o usuário autenticado
    var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int userId))
    {
        chamado.FechadoPorId = userId;  // ⭐ RASTREAMENTO
    }
}
else if (request.StatusId != 5)
{
    // Limpa se chamado for reaberto
    chamado.DataFechamento = null;
    chamado.FechadoPorId = null;
}
```

**Uso no Front-End:**
- Atualiza interface em tempo real
- Exibe toast de sucesso
- Recarrega dados do chamado

---

### 2.5 Adicionar Comentário (`POST /api/chamados/{id}/comentarios`)

**Arquivo:** `script-desktop.js` (linha 756)

**Requisição:**
```javascript
fetch(`${API_BASE}/api/chamados/${ticketId}/comentarios`, {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    texto: "Problema resolvido. Impressora estava desligada da tomada."
  })
})
```

**Dados Inseridos no Banco:**

**Tabela `Comentarios`:**
- ⚡ `ChamadoId` (FK → `Chamados`)
- ⚡ `UsuarioId` (do JWT token)
- ⚡ `Texto`
- ⚡ `DataCriacao = DateTime.UtcNow`

**Uso no Front-End:**
- Adiciona comentário na lista
- Limpa campo de texto
- Atualiza historico visual

---

### 2.6 Listar Comentários (`GET /api/chamados/{id}/comentarios`)

**Arquivo:** `script-desktop.js` (linha 1320)

**Requisição:**
```javascript
fetch(`${API_BASE}/api/chamados/${ticketId}/comentarios`, {
  method: 'GET',
  headers: { 'Authorization': `Bearer ${token}` }
})
```

**Resposta da API:**
```json
{
  "$values": [
    {
      "id": 1,
      "texto": "Verifiquei o problema. Parece ser cabo de rede.",
      "dataCriacao": "2025-11-04T11:00:00Z",
      "usuario": {
        "id": 2,
        "nomeCompleto": "Pedro Silva",
        "email": "pedro.tecnico@neurohelp.com"
      }
    }
  ]
}
```

**Dados Extraídos do Banco:**
```sql
SELECT 
    c.Id, c.Texto, c.DataCriacao, c.UsuarioId,
    u.NomeCompleto, u.Email
FROM Comentarios c
INNER JOIN Usuarios u ON c.UsuarioId = u.Id
WHERE c.ChamadoId = @chamadoId
ORDER BY c.DataCriacao ASC
```

**Uso no Front-End:**
```javascript
comentarios.forEach(com => {
  const li = document.createElement("li");
  li.innerHTML = `
    <strong>${com.usuario.nomeCompleto}</strong>
    <span class="date">${new Date(com.dataCriacao).toLocaleDateString('pt-BR')}</span>
    <p>${com.texto}</p>
  `;
  list.appendChild(li);
});
```

---

## 📊 3. Dados de Referência (Lookup Tables)

### 3.1 Status (`GET /api/status`)

**Arquivo:** `script-desktop.js` (linha 714, 1430)

**Requisição:**
```javascript
fetch(`${API_BASE}/api/status`, {
  headers: { 'Authorization': `Bearer ${token}` }
})
```

**Resposta da API:**
```json
{
  "$values": [
    { "id": 1, "nome": "Aberto", "descricao": "Chamado recém criado" },
    { "id": 2, "nome": "Em Andamento", "descricao": "Técnico trabalhando" },
    { "id": 3, "nome": "Aguardando Resposta", "descricao": "Aguardando usuário" },
    { "id": 5, "nome": "Fechado", "descricao": "Chamado resolvido" },
    { "id": 8, "nome": "Violado", "descricao": "SLA excedido" }
  ]
}
```

**Dados Extraídos do Banco:**
```sql
SELECT Id, Nome, Descricao, Ativo, DataCadastro
FROM Status
WHERE Ativo = 1
ORDER BY Id
```

**Uso no Front-End:**
- Popula dropdown "Alterar Status" na página de detalhes
- Usado para filtros em dashboards

---

### 3.2 Prioridades (`GET /api/prioridades`)

**Arquivo:** `script-desktop.js` (linha 1444)

**Requisição:**
```javascript
fetch(`${API_BASE}/api/prioridades`, {
  headers: { 'Authorization': `Bearer ${token}` }
})
```

**Resposta da API:**
```json
{
  "$values": [
    { "id": 1, "nome": "Baixa", "nivel": 1, "descricao": "Resolver quando possível" },
    { "id": 2, "nome": "Média", "nivel": 2, "descricao": "Prioridade normal" },
    { "id": 3, "nome": "Alta", "nivel": 3, "descricao": "Resolver com urgência" }
  ]
}
```

**Dados Extraídos do Banco:**
```sql
SELECT Id, Nome, Nivel, Descricao, Ativo, DataCadastro
FROM Prioridades
WHERE Ativo = 1
ORDER BY Nivel ASC
```

**Uso no Front-End:**
- Popula dropdown "Prioridade" no formulário de novo chamado
- Usado para ordenação e filtros

---

### 3.3 Categorias (`GET /api/categorias`)

**Arquivo:** `script-desktop.js` (linha 1602)

**Requisição:**
```javascript
fetch(`${API_BASE}/api/categorias`, {
  headers: { 'Authorization': `Bearer ${token}` }
})
```

**Resposta da API:**
```json
{
  "$values": [
    { "id": 1, "nome": "Hardware", "descricao": "Problemas com peças físicas" },
    { "id": 2, "nome": "Software", "descricao": "Problemas com programas" },
    { "id": 3, "nome": "Rede", "descricao": "Problemas de conexão" },
    { "id": 4, "nome": "Acesso/Login", "descricao": "Problemas de senha" }
  ]
}
```

**Dados Extraídos do Banco:**
```sql
SELECT Id, Nome, Descricao, Ativo, DataCadastro
FROM Categorias
WHERE Ativo = 1
ORDER BY Nome
```

**Uso no Front-End:**
- Popula dropdown "Categoria" no formulário de novo chamado
- Popula dropdown "Especialidade" no cadastro de técnico
- Usado para filtros

---

## 📈 4. KPIs e Dashboard

### 4.1 Cálculo de KPIs (Front-End)

**Arquivo:** `script-desktop.js` (função `atualizarKPIs`)

**Processamento no Front-End:**
```javascript
function atualizarKPIs(chamados) {
  const total = chamados.length;
  const abertos = chamados.filter(c => c.statusNome === 'Aberto').length;
  const emAndamento = chamados.filter(c => c.statusNome === 'Em Andamento').length;
  const fechados = chamados.filter(c => c.statusNome === 'Fechado').length;
  const violados = chamados.filter(c => c.statusNome === 'Violado').length;
  
  // Atualiza HTML
  $("#kpi-total").textContent = total;
  $("#kpi-abertos").textContent = abertos;
  $("#kpi-em-andamento").textContent = emAndamento;
  $("#kpi-fechados").textContent = fechados;
  $("#kpi-violados").textContent = violados;
}
```

**Dados Utilizados:**
- ✅ Array completo de chamados (da API)
- ✅ Filtragem por `statusNome`
- ✅ Contagem client-side

**Exibição:**
- Cards de KPI no dashboard
- Gráficos (se implementados)

---

## 🔄 5. Fluxo Completo: Criar e Fechar Chamado

### 📝 Passo 1: Usuário Cria Chamado

1. **Front-End:** Formulário preenchido
2. **Requisição:** `POST /api/chamados/analisar`
3. **Backend:** 
   - IA analisa descrição (Gemini)
   - Cria registro em `Chamados`
   - `StatusId = 1` (Aberto)
   - `SolicitanteId = userId` (do token)
   - `TecnicoId = NULL`
   - `FechadoPorId = NULL`
4. **Banco de Dados:**
   ```sql
   INSERT INTO Chamados (
     Titulo, Descricao, CategoriaId, PrioridadeId, 
     SolicitanteId, StatusId, DataAbertura, 
     DataUltimaAtualizacao, SlaDataExpiracao
   ) VALUES (...)
   ```

### 👤 Passo 2: Admin Atribui Técnico

1. **Front-End:** Dropdown "Atribuir Técnico" selecionado
2. **Requisição:** `PUT /api/chamados/{id}`
   ```json
   { "tecnicoId": 2 }
   ```
3. **Backend:**
   - Atualiza `TecnicoId = 2`
   - Atualiza `DataUltimaAtualizacao`
4. **Banco de Dados:**
   ```sql
   UPDATE Chamados 
   SET TecnicoId = 2, 
       DataUltimaAtualizacao = GETUTCDATE()
   WHERE Id = @id
   ```

### 🔧 Passo 3: Técnico Trabalha no Chamado

1. **Front-End:** Botão "Assumir Chamado"
2. **Requisição:** `PUT /api/chamados/{id}`
   ```json
   { "statusId": 2, "tecnicoId": 2 }
   ```
3. **Backend:**
   - Atualiza `StatusId = 2` (Em Andamento)
   - Confirma `TecnicoId`
4. **Front-End:** Adiciona comentário
   - `POST /api/chamados/{id}/comentarios`
5. **Banco de Dados:**
   ```sql
   INSERT INTO Comentarios (ChamadoId, UsuarioId, Texto, DataCriacao)
   VALUES (@id, @userId, 'Iniciando diagnóstico', GETUTCDATE())
   ```

### ✅ Passo 4: Técnico Fecha o Chamado ⭐ **COM RASTREAMENTO**

1. **Front-End:** Dropdown "Status" alterado para "Fechado"
2. **Requisição:** `PUT /api/chamados/{id}`
   ```json
   { "statusId": 5 }
   ```
3. **Backend (NOVO - Rastreamento):**
   ```csharp
   if (request.StatusId == 5 && chamado.StatusId != 5) {
       chamado.DataFechamento = DateTime.UtcNow;
       chamado.FechadoPorId = userId; // Do JWT ⭐
   }
   chamado.StatusId = 5;
   chamado.DataUltimaAtualizacao = DateTime.UtcNow;
   ```
4. **Banco de Dados:**
   ```sql
   UPDATE Chamados 
   SET 
     StatusId = 5,
     DataFechamento = GETUTCDATE(),
     FechadoPorId = @userId,  -- ⭐ NOVO
     DataUltimaAtualizacao = GETUTCDATE()
   WHERE Id = @id
   ```

### 👀 Passo 5: Usuário Visualiza Chamado Fechado

1. **Front-End:** Clica em "Ver Detalhes"
2. **Requisição:** `GET /api/chamados/{id}`
3. **Backend:** Retorna objeto completo com **FechadoPor** ⭐
4. **Resposta:**
   ```json
   {
     "id": 1,
     "status": { "nome": "Fechado" },
     "dataFechamento": "2025-11-04T16:30:00Z",
     "fechadoPor": {
       "id": 2,
       "nomeCompleto": "Pedro Silva",
       "email": "pedro.tecnico@neurohelp.com"
     }
   }
   ```
5. **Front-End Exibe:**
   ```
   Status: Fechado
   Fechado por: Pedro Silva
   Data de Fechamento: 04/11/2025 às 16:30
   ```

---

## 📊 6. Resumo de Dados Extraídos por Tabela

| Tabela | Campos Extraídos | Usado Em |
|--------|------------------|----------|
| **Usuarios** | Id, NomeCompleto, Email, SenhaHash, TipoUsuario, Ativo, EspecialidadeCategoriaId | Login, Dashboards, Atribuição, Comentários, **Rastreamento de Fechamento** ⭐ |
| **Chamados** | Id, Titulo, Descricao, DataAbertura, DataUltimaAtualizacao, DataFechamento, SlaDataExpiracao, StatusId, PrioridadeId, CategoriaId, SolicitanteId, TecnicoId, **FechadoPorId** ⭐ | Todas as páginas de chamados |
| **Status** | Id, Nome, Descricao | Badges, Dropdowns, Filtros |
| **Prioridades** | Id, Nome, Nivel, Descricao | Formulários, Ordenação, Filtros |
| **Categorias** | Id, Nome, Descricao | Formulários, Filtros, Especialidade |
| **Comentarios** | Id, Texto, DataCriacao, UsuarioId, ChamadoId | Página de detalhes, Histórico |

---

## 🔑 7. Dados do JWT Token

**Campos Decodificados pelo Front-End:**

```javascript
function decodeJWT(token) {
  const payload = JSON.parse(atob(token.split('.')[1]));
  return payload;
}
```

**Claims Extraídos:**
- ✅ `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier` → **userId**
- ✅ `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress` → **email**
- ✅ `TipoUsuario` → **1, 2 ou 3**
- ✅ `exp` → Data de expiração

**Uso:**
- Filtrar chamados por `solicitanteId`
- Identificar **quem fechou** um chamado ⭐
- Redirecionamento de dashboards
- Autorização de ações

---

## ⭐ 8. NOVIDADE: Rastreamento de Fechamento

### O que foi implementado?

Quando um chamado é **fechado** (StatusId = 5), o sistema agora registra automaticamente:

1. **Quem fechou**: `FechadoPorId` → ID do usuário autenticado
2. **Quando fechou**: `DataFechamento` → Timestamp UTC

### Como funciona?

**Backend (ChamadosController.cs):**
```csharp
// Detecta mudança para "Fechado"
if (request.StatusId == 5 && chamado.StatusId != 5) 
{
    chamado.DataFechamento = DateTime.UtcNow;
    
    // Captura usuário do JWT
    var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    if (int.TryParse(userIdClaim, out int userId))
    {
        chamado.FechadoPorId = userId;  // ⭐ Rastreamento
    }
}
```

**Query de Busca (atualizada):**
```sql
SELECT ...
FROM Chamados c
...
LEFT JOIN Usuarios fech ON c.FechadoPorId = fech.Id  -- ⭐ JOIN com FechadoPor
```

**Resposta da API:**
```json
{
  "fechadoPor": {
    "id": 2,
    "nomeCompleto": "Pedro Silva",
    "email": "pedro.tecnico@neurohelp.com"
  },
  "dataFechamento": "2025-11-04T16:30:00Z"
}
```

### Onde aparece no Front-End?

**Atualmente:** Os dados já são retornados pela API, mas **não estão sendo exibidos** no HTML.

**Para implementar a exibição, adicionar em `ticket-detalhes-desktop.html`:**

```html
<!-- Seção de Fechamento (se chamado estiver fechado) -->
<div id="secao-fechamento" style="display: none;">
  <h3>📋 Informações de Fechamento</h3>
  <p><strong>Fechado por:</strong> <span id="t-fechado-por">N/A</span></p>
  <p><strong>Data de Fechamento:</strong> <span id="t-data-fechamento">N/A</span></p>
</div>
```

**E no JavaScript (`script-desktop.js`):**

```javascript
// Após preencher os outros campos do chamado
if (chamado.statusNome === 'Fechado' && chamado.fechadoPor) {
  $("#secao-fechamento").style.display = 'block';
  $("#t-fechado-por").textContent = chamado.fechadoPor.nomeCompleto;
  $("#t-data-fechamento").textContent = 
    new Date(chamado.dataFechamento).toLocaleDateString('pt-BR');
}
```

---

## 📋 9. Checklist de Implementação

### ✅ Backend (Completo)
- [x] Coluna `FechadoPorId` adicionada à tabela `Chamados`
- [x] Migration criada e aplicada
- [x] Entidade `Chamado` atualizada com `FechadoPor` navigation
- [x] DTO `ChamadoDTO` inclui campo `FechadoPor`
- [x] Controller detecta fechamento e registra `FechadoPorId`
- [x] Queries incluem `.Include(c => c.FechadoPor)`
- [x] API retorna informações de `fechadoPor` nos endpoints

### ⏳ Front-End Desktop (Parcial)
- [x] API já retorna dados de `fechadoPor`
- [ ] **TODO:** Adicionar HTML para exibir "Fechado por" na página de detalhes
- [ ] **TODO:** Adicionar JavaScript para renderizar informações de fechamento
- [ ] **TODO:** Adicionar filtro "Fechados por mim" no dashboard

### ⏳ Mobile App (Pendente)
- [ ] Atualizar `ChamadoDetailPage.xaml` para exibir `FechadoPor`
- [ ] Verificar se `ViewModel` mapeia `FechadoPor` corretamente
- [ ] Testar exibição no aplicativo físico

---

## 🔧 10. Como Testar a Feature de Rastreamento

### Teste Manual:

1. **Login como Técnico:**
   - Email: `pedro.tecnico@neurohelp.com`
   - Senha: `senha123`

2. **Abrir um chamado existente**

3. **Alterar status para "Fechado"**

4. **Verificar no banco de dados:**
   ```sql
   SELECT 
     c.Id, c.Titulo, c.StatusId, 
     c.FechadoPorId, 
     u.NomeCompleto AS FechadoPor,
     c.DataFechamento
   FROM Chamados c
   LEFT JOIN Usuarios u ON c.FechadoPorId = u.Id
   WHERE c.StatusId = 5
   ```

5. **Verificar resposta da API:**
   - Abra Developer Tools (F12)
   - Aba Network → Veja a resposta de `GET /api/chamados/{id}`
   - Confirme que `fechadoPor` está presente

---

## 📝 Conclusão

O front-end desktop extrai **todos os dados essenciais** do banco de dados através da API REST:

✅ **Autenticação completa** (login, reset de senha, registro)  
✅ **Gerenciamento de chamados** (criar, listar, atualizar, comentar)  
✅ **Dados de referência** (status, prioridades, categorias)  
✅ **Informações de usuários** (solicitantes, técnicos, admins)  
✅ **⭐ Rastreamento de fechamento** (quem fechou, quando fechou) - **NOVO**

A nova funcionalidade de **rastreamento de fechamento** está **funcionando no backend** e os dados estão sendo retornados pela API. O próximo passo é **atualizar a interface do front-end** para exibir essas informações ao usuário.

---

**Documento criado em:** 04/11/2025  
**Última atualização:** 04/11/2025  
**Feature destacada:** ⭐ Rastreamento de Fechamento de Chamados  
