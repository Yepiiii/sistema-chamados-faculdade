# 📋 Análise Detalhada de Inconsistências: Desktop vs Mobile

**Data:** 10/11/2025  
**Objetivo:** Identificar divergências críticas entre o aplicativo Desktop (JavaScript) e Mobile (C#/.NET MAUI)

---

## 🔴 1. INCONSISTÊNCIAS NOS MODELOS DE DADOS (DTOs)

### 1.1. Estrutura de Comentários

**❌ PROBLEMA CRÍTICO**

#### Desktop (Desktop/script-desktop.js)
```javascript
// Linha 1378-1379
const autor = comentario.usuarioNome || 'Usuário';
const data = new Date(comentario.dataCriacao).toLocaleString('pt-BR');
```

**Desktop espera:**
- `usuarioNome` (string simples)
- `dataCriacao` (DateTime)

#### Mobile (ComentarioDto.cs)
```csharp
public class ComentarioDto
{
    public int Id { get; set; }
    public int ChamadoId { get; set; }
    public string Texto { get; set; } = string.Empty;
    public DateTime DataCriacao { get; set; }
    public DateTime DataHora { get; set; }  // ⚠️ Campo extra!
    public UsuarioResumoDto? Usuario { get; set; }  // ⚠️ Objeto aninhado!
    public int UsuarioId { get; set; }
    public string UsuarioNome { get; set; } = string.Empty;
    public bool IsInterno { get; set; }
}
```

**Mobile possui:**
- `Usuario` (objeto `UsuarioResumoDto` aninhado)
- `UsuarioNome` (string redundante)
- `DataHora` (campo adicional para compatibilidade de timezone)
- `IsInterno` (flag para comentários internos)

#### Backend (Application/DTOs/ComentarioResponseDto.cs)
```csharp
public class ComentarioResponseDto
{
    public int Id { get; set; }
    public string Texto { get; set; } = string.Empty;
    public DateTime DataCriacao { get; set; }
    public int UsuarioId { get; set; }
    public string UsuarioNome { get; set; } = string.Empty;  // ✅ Compatível com Desktop
    public int ChamadoId { get; set; }
}
```

**✅ IMPACTO:** Desktop funciona corretamente. Mobile possui campos redundantes que não são usados pela API.

---

### 1.2. Estrutura de Chamados

**⚠️ INCONSISTÊNCIA MODERADA**

#### Desktop
```javascript
// Linha 508-511 (renderTicketsTable)
const statusNome = chamado?.statusNome ?? 'N/A';
const categoriaNome = chamado?.categoriaNome ?? 'N/A';
const prioridadeNome = chamado?.prioridadeNome ?? 'N/A';

// Linha 672-677 (initTicketDetails)
const statusNome = chamado?.status?.nome ?? 'N/A';
$("#t-category").textContent = chamado?.categoria?.nome ?? 'N/A';
$("#t-priority").textContent = chamado?.prioridade?.nome ?? 'N/A';
```

**Desktop usa DOIS formatos diferentes:**
1. **Listagem (ChamadoListDto):** Propriedades simples (`statusNome`, `categoriaNome`)
2. **Detalhes (GET /chamados/{id}):** Objetos aninhados (`status.nome`, `categoria.nome`)

#### Mobile (ChamadoDto.cs)
```csharp
public class ChamadoDto
{
    public int Id { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string Descricao { get; set; } = string.Empty;
    
    // ✅ SEMPRE usa objetos aninhados
    public CategoriaDto? Categoria { get; set; }
    public PrioridadeDto? Prioridade { get; set; }
    public StatusDto? Status { get; set; }
    public UsuarioResumoDto? Solicitante { get; set; }
    public UsuarioResumoDto? Tecnico { get; set; }
    
    // ⚠️ Campos extras para compatibilidade
    public int? TecnicoAtribuidoId { get; set; }
    public string? TecnicoAtribuidoNome { get; set; }
}
```

**✅ IMPACTO:** Ambos funcionam, mas Desktop é inconsistente consigo mesmo. Mobile é mais robusto.

---

### 1.3. Datas e Timestamps

**⚠️ INCONSISTÊNCIA DE NOMENCLATURA**

#### Desktop
```javascript
// Linha 686 (initTicketDetails)
$("#t-data-abertura").textContent = new Date(chamado.dataAbertura).toLocaleDateString('pt-BR');

// Linha 1149 (renderTabelaFila)
const dataAbertura = 'Hoje'; // TODO: Adicionar ao DTO quando disponível
```

**Desktop espera:**
- `dataAbertura` (camelCase)
- `dataUltimaAtualizacao` (camelCase)
- Campo de data não disponível em listagens (usa placeholder "Hoje")

#### Mobile (ChamadoDto.cs)
```csharp
public DateTime DataAbertura { get; set; }  // PascalCase
public DateTime? DataUltimaAtualizacao { get; set; }
public DateTime? DataFechamento { get; set; }
```

#### Backend (Entities/Chamado.cs)
```csharp
// mobile-app-nosso/Models/Entities/Chamado.cs linha 10
public DateTime DataCriacao { get; set; }  // ⚠️ Nome diferente!
```

**❌ PROBLEMA:** Mobile usa `DataCriacao` internamente, mas a API retorna `DataAbertura`.

---

## 🔴 2. LÓGICA DE NEGÓCIO DIVERGENTE

### 2.1. Tratamento de Status

**❌ PROBLEMA CRÍTICO: Valores Hardcoded vs API**

#### Desktop
```javascript
// Linha 390-394 (atualizarKPIs)
const abertos = chamados.filter(c => c.statusNome.toLowerCase() === 'aberto').length;
const emAndamento = chamados.filter(c => c.statusNome.toLowerCase() === 'em andamento').length;
const resolvidos = chamados.filter(c => 
    c.statusNome.toLowerCase() === 'fechado' || 
    c.statusNome.toLowerCase() === 'resolvido'  // ⚠️ Aceita dois nomes!
).length;
const pendentes = chamados.filter(c => c.statusNome.toLowerCase() === 'aguardando resposta').length;
const violados = chamados.filter(c => c.statusNome.toLowerCase() === 'violado').length;
```

**Desktop assume nomes fixos:** 'aberto', 'em andamento', 'fechado', 'resolvido', 'violado'

#### Mobile (DashboardViewModel.cs)
```csharp
// Linha 84-86
static string NormalizeStatus(ChamadoDto chamado) => 
    string.IsNullOrWhiteSpace(chamado.Status?.Nome)
        ? string.Empty
        : chamado.Status.Nome.Trim().ToLowerInvariant();

TotalAbertos = listaUsuario.Count(c => NormalizeStatus(c) == "aberto");
TotalEmAndamento = listaUsuario.Count(c => NormalizeStatus(c) == "em andamento");
TotalEncerrados = listaUsuario.Count(c => NormalizeStatus(c) == "fechado");  // ⚠️ Apenas "fechado"
TotalViolados = listaUsuario.Count(c => NormalizeStatus(c) == "violado");
```

**Mobile assume nomes fixos:** 'aberto', 'em andamento', 'fechado', 'violado' (NÃO aceita 'resolvido')

**❌ IMPACTO CRÍTICO:**
- Se o banco tiver status "Resolvido", Desktop conta como resolvido, Mobile não
- Ambos quebram se os nomes no banco mudarem
- **Solução:** Usar IDs ao invés de nomes (statusId == 1, 2, 3, etc.)

---

### 2.2. Fechamento de Chamados

**⚠️ MÉTODOS DIFERENTES**

#### Desktop
```javascript
// NÃO HÁ função específica para fechar chamados
// Desktop usa atualização genérica de status:
const updateResponse = await fetch(`${API_BASE}/api/chamados/${ticketId}`, {
    method: 'PUT',
    headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({
        statusId: parseInt(novoStatusId),  // ⚠️ ID do status "Fechado"
        tecnicoId: tecnicoId
    })
});
```

#### Mobile (ChamadoService.cs)
```csharp
// Linha 76-82
public Task<ChamadoDto?> Close(int id)
{
    // ⚠️ FIX: Backend não tem endpoint /fechar
    // Usa PUT /chamados/{id} com StatusId = 5 (Fechado)
    var atualizacao = new AtualizarChamadoDto
    {
        StatusId = 5  // ⚠️ Hardcoded!
    };
    return _api.PutAsync<AtualizarChamadoDto, ChamadoDto>($"chamados/{id}", atualizacao);
}
```

**❌ PROBLEMA:**
- Mobile assume que StatusId = 5 é "Fechado" (hardcoded)
- Desktop não hardcoda, mas depende do usuário escolher o status correto
- Nenhum valida se o status de destino é realmente "Fechado"

#### Backend (ChamadosController.cs)
```csharp
// Linha 237-246
if (request.StatusId == 4)  // ⚠️ ID 4 é "Fechado"!
{
    chamado.DataFechamento = DateTime.UtcNow;
}
else
{
    chamado.DataFechamento = null;
}
```

**❌ CONFLITO CRÍTICO:**
- Backend assume StatusId = 4 é "Fechado"
- Mobile assume StatusId = 5 é "Fechado"
- **ISSO VAI CAUSAR BUGS!**

---

### 2.3. Atribuição de Técnicos

**⚠️ FLUXOS DIFERENTES**

#### Desktop - Assumir Chamado (Técnico)
```javascript
// Linha 1234-1276 (assumirChamado)
async function assumirChamado(chamadoId) {
    // 1. Decodifica JWT para pegar ID do técnico
    const idDoTecnicoLogado = payload[nameIdentifierClaim];
    
    // 2. Define status como "Em Andamento" (ID 2)
    const novoStatusId = 2;
    
    // 3. Envia PUT
    const response = await fetch(`${API_BASE}/api/chamados/${chamadoId}`, {
        method: 'PUT',
        body: JSON.stringify({
            statusId: novoStatusId,
            tecnicoId: parseInt(idDoTecnicoLogado)
        })
    });
}
```

**Desktop:**
- Técnico "assume" chamado via PUT com StatusId=2 + TecnicoId
- Muda status automaticamente para "Em Andamento"

#### Desktop - Reatribuir (Admin)
```javascript
// Linha 895-916 (btnAtualizarTecnico)
const novoTecnicoId = $("#t-tecnico-select").value;
const statusIdAtual = chamado.status.id;  // ⚠️ Mantém status atual

const response = await fetch(`${API_BASE}/api/chamados/${ticketId}`, {
    method: 'PUT',
    body: JSON.stringify({
        statusId: parseInt(statusIdAtual),  // Não muda status
        tecnicoId: parseInt(novoTecnicoId)
    })
});
```

**Desktop Admin:**
- Admin reatribui técnico sem mudar status
- Usa o mesmo endpoint PUT /chamados/{id}

#### Mobile
```csharp
// Mobile NÃO TEM funcionalidade de "assumir chamado"!
// Apenas Update genérico via AtualizarChamadoDto
```

**❌ IMPACTO:**
- Mobile não permite técnicos assumirem chamados (funcionalidade ausente)
- Desktop tem 2 fluxos (técnico assume, admin reatribui)
- Ambos usam o mesmo endpoint, mas com lógicas diferentes

---

## 🔴 3. DIFERENÇAS NO CONSUMO DA API

### 3.1. Criação de Chamados

**✅ CONSISTENTE**

#### Desktop
```javascript
const response = await fetch(`${API_BASE}/api/chamados/analisar`, {
    method: 'POST',
    body: JSON.stringify({ descricaoProblema: descricao })
});
```

#### Mobile
```csharp
public Task<ChamadoDto?> CreateComAnaliseAutomatica(string descricaoProblema)
{
    var request = new AnalisarChamadoRequestDto { DescricaoProblema = descricaoProblema };
    return _api.PostAsync<AnalisarChamadoRequestDto, ChamadoDto>("chamados/analisar", request);
}
```

**✅ Ambos usam POST /chamados/analisar corretamente**

---

### 3.2. Filtros de Chamados

**⚠️ IMPLEMENTAÇÕES DIFERENTES**

#### Desktop
```javascript
// Linha 419-437 (initDashboard)
let url = `${API_BASE}/api/chamados`;  // Admin vê tudo

// Usuário comum: filtra por solicitante
if (path.endsWith("user-dashboard-desktop.html")) {
    url = `${API_BASE}/api/chamados?solicitanteId=${userId}`;
}

// Técnico: filtra por técnico atribuído
// Linha 1094
const urlMeus = `${API_BASE}/api/chamados?tecnicoId=${tecnicoId}`;

// Fila (não atribuídos)
const urlFila = `${API_BASE}/api/chamados?tecnicoId=0&statusId=1`;
```

**Desktop usa query strings manuais:**
- `?solicitanteId={id}` para usuários
- `?tecnicoId={id}` para técnicos
- `?tecnicoId=0&statusId=1` para fila

#### Mobile (ChamadoService.cs)
```csharp
// Linha 31-48
public Task<IEnumerable<ChamadoDto>?> GetMeusChamados(ChamadoQueryParameters? parameters = null)
{
    var effectiveParams = parameters?.Clone() ?? new ChamadoQueryParameters();
    var userId = Settings.UserId;
    var tipoUsuario = Settings.TipoUsuario;

    if (tipoUsuario == 1 && userId > 0 && !effectiveParams.SolicitanteId.HasValue)
    {
        effectiveParams.SolicitanteId = userId;  // Usuário comum
    }
    else if (tipoUsuario == 3 && !effectiveParams.IncluirTodos.HasValue)
    {
        effectiveParams.IncluirTodos = true;  // Admin
    }

    return GetChamados(effectiveParams);
}
```

**Mobile usa classe `ChamadoQueryParameters`:**
- Encapsula lógica de filtro
- Gera query string automaticamente via `ToQueryString()`
- Mais robusto e type-safe

**⚠️ IMPACTO:** Desktop é mais propenso a erros de digitação, mas ambos funcionam.

---

### 3.3. Comentários

**✅ CONSISTENTE**

#### Desktop
```javascript
// POST /api/chamados/{ticketId}/comentarios
const postResponse = await fetch(`${API_BASE}/api/chamados/${ticketId}/comentarios`, {
    method: 'POST',
    body: JSON.stringify({ Texto: textoComentário })
});

// GET /api/chamados/{ticketId}/comentarios
const response = await fetch(`${API_BASE}/api/chamados/${ticketId}/comentarios`, {
    method: 'GET',
});
```

#### Mobile (via API Service)
```csharp
// Usa IApiService genérico
_api.PostAsync<CriarComentarioRequestDto, ComentarioDto>($"chamados/{id}/comentarios", dto);
_api.GetAsync<IEnumerable<ComentarioDto>>($"chamados/{id}/comentarios");
```

**✅ Ambos usam os mesmos endpoints corretamente**

---

## 📊 RESUMO DAS INCONSISTÊNCIAS

| # | Tipo | Gravidade | Desktop | Mobile | Impacto |
|---|------|-----------|---------|--------|---------|
| 1 | **DTO - Comentários** | 🟡 Baixa | `usuarioNome` (string) | `Usuario` (objeto) + `usuarioNome` | Mobile tem redundância, mas funciona |
| 2 | **DTO - Chamados** | 🟡 Baixa | Usa 2 formatos (lista vs detalhes) | Sempre objetos aninhados | Desktop inconsistente, ambos funcionam |
| 3 | **DTO - Datas** | 🟡 Baixa | `dataAbertura` (camelCase) | `DataAbertura` (PascalCase) | JSON é case-insensitive, funciona |
| 4 | **Status - Nomes Hardcoded** | 🔴 Alta | 'fechado' OU 'resolvido' | Apenas 'fechado' | Quebra se nomes mudarem no BD |
| 5 | **Status - ID Fechado** | 🔴 **CRÍTICA** | Não hardcoda | StatusId = **5** | Backend usa **4**! |
| 6 | **Lógica - Fechar Chamado** | 🔴 **CRÍTICA** | PUT com status manual | `Close()` assume ID=5 | **CONFLITO DIRETO** |
| 7 | **Lógica - Assumir Chamado** | 🟠 Média | Técnico assume via PUT | **Não implementado** | Mobile não tem feature |
| 8 | **API - Filtros** | 🟡 Baixa | Query strings manuais | `ChamadoQueryParameters` | Ambos funcionam, mobile mais robusto |

---

## 🚨 BUGS CONFIRMADOS

### BUG #1: Conflito de StatusId "Fechado"
**Local:**
- `mobile-app-nosso/Services/Chamados/ChamadoService.cs` (linha 80): `StatusId = 5`
- `API/Controllers/ChamadosController.cs` (linha 237): `if (request.StatusId == 4)`

**Causa:** Mobile assume ID 5 para "Fechado", backend verifica ID 4

**Sintoma:**
- Quando mobile tenta fechar um chamado (StatusId=5), backend NÃO preenche `DataFechamento`
- Chamado fica em estado inconsistente

**Solução:**
1. Verificar ID real do status "Fechado" no banco de dados
2. Atualizar Mobile OU Backend para usar o ID correto
3. **Melhor ainda:** Criar endpoint `POST /chamados/{id}/fechar` que não depende de ID hardcoded

---

### BUG #2: Status "Resolvido" vs "Fechado"
**Local:**
- `Desktop/script-desktop.js` (linha 392)

**Causa:** Desktop aceita dois nomes ('fechado' ou 'resolvido'), mobile aceita só 'fechado'

**Sintoma:**
- Se banco tiver status "Resolvido", estatísticas divergem entre plataformas
- Desktop conta, mobile não

**Solução:**
1. Padronizar nomenclatura no banco (usar APENAS "Fechado")
2. OU atualizar ambos apps para aceitar ambos os nomes
3. **Melhor ainda:** Usar IDs ao invés de nomes nas comparações

---

### BUG #3: Funcionalidade Ausente - Assumir Chamado (Mobile)
**Local:**
- Funcionalidade existe no Desktop (`assumirChamado`), não existe no Mobile

**Impacto:**
- Técnicos usando mobile não podem assumir chamados da fila
- Quebra workflow de atendimento

**Solução:**
- Implementar `Task<ChamadoDto?> AssumeTicket(int id)` no `IChamadoService`
- Usar PUT /chamados/{id} com StatusId=2 + TecnicoId do usuário logado

---

## 🎯 RECOMENDAÇÕES

### Prioridade 🔴 CRÍTICA
1. **Corrigir BUG #1 (StatusId Fechado)** - Alinha IDs entre mobile/backend
2. **Padronizar Status** - Usar IDs ao invés de nomes em todas as plataformas

### Prioridade 🟠 ALTA
3. **Implementar assumir chamado no Mobile** (BUG #3)
4. **Criar endpoint `/fechar`** - Evita hardcoding de StatusId

### Prioridade 🟡 MÉDIA
5. **Unificar DTOs de Listagem** - Desktop deveria usar sempre objetos aninhados
6. **Limpar campos redundantes** - Mobile tem `Usuario` + `UsuarioNome` desnecessariamente
7. **Documentar IDs de Status** - Criar constantes ao invés de magic numbers

### Prioridade 🟢 BAIXA
8. **Padronizar nomenclatura** - Escolher camelCase OU PascalCase
9. **Melhorar validações** - Ambos apps confiam muito na API

---

## 📝 CHECKLIST DE COMPATIBILIDADE

- [ ] IDs de Status documentados e consistentes
- [ ] Endpoints usam mesmo método HTTP (POST/PUT/DELETE)
- [ ] DTOs têm mesma estrutura em lista e detalhes
- [ ] Lógica de negócio (fechamento, atribuição) é idêntica
- [ ] Validações client-side são equivalentes
- [ ] Tratamento de erros da API é consistente
- [ ] Funcionalidades principais existem em ambas plataformas
- [ ] Testes de integração cobrem ambos os clientes

---

**Gerado por:** GitHub Copilot  
**Próximos passos:** Priorizar correção dos bugs críticos (#1 e #2) antes de adicionar novas features
