# 📊 ANÁLISE COMPLETA - MOBILE vs DESKTOP vs WEB (wwwroot) vs BACKEND

**Data:** 2025-01-31  
**Objetivo:** Identificar inconsistências nos Modelos de Dados (DTOs), Lógica de Negócio Duplicada/Conflitante e Uso Incorreto de Endpoints da API entre os aplicativos Mobile (.NET MAUI), Desktop (HTML/JS) e Web (wwwroot HTML/JS) comparados com a API do Backend (ASP.NET Core).

---

## 🎯 RESUMO EXECUTIVO

### ❗ PROBLEMAS CRÍTICOS IDENTIFICADOS

1. **StatusId Conflict - BLOQUEADOR** 🔴
   - **Mobile:** Usa `StatusId = 5` para fechar chamados (ChamadoService.cs linha 79)
   - **Backend:** Espera `StatusId = 4` para marcar como "Fechado" e definir `DataFechamento` (ChamadosController.cs linha 239)
   - **Impacto:** Mobile NUNCA consegue fechar chamados corretamente - a data de fechamento não é definida
   - **Solução:** Corrigir Mobile para usar `StatusId = 4` OU adicionar StatusConstants no Backend

2. **Funcionalidade "Assumir Chamado" ausente no Mobile** 🟡
   - **Desktop:** Implementa botão "Assumir" que define `StatusId = 2` (Em Andamento) + `TecnicoId` (script-desktop.js linha 1271)
   - **Mobile:** NÃO possui método `AssumirChamado()` ou equivalente em ChamadoService.cs
   - **Impacto:** Técnicos usando Mobile não conseguem assumir chamados da fila
   - **Solução:** Adicionar método `Assumir(int id)` no ChamadoService que use `StatusId = 2`

---

## 📁 1. INCONSISTÊNCIAS NOS MODELOS DE DADOS (DTOs)

### 1.1 ComentarioDto - Redundâncias e Incompatibilidades

#### Backend (ComentarioResponseDto.cs)
```csharp
public class ComentarioResponseDto
{
    public int Id { get; set; }
    public string Texto { get; set; }
    public DateTime DataCriacao { get; set; }
    public int UsuarioId { get; set; }
    public string UsuarioNome { get; set; }  // ✅ Propriedade plana (string)
    public int ChamadoId { get; set; }
}
```

#### Mobile (ComentarioDto.cs)
```csharp
public class ComentarioDto
{
    public int Id { get; set; }
    public string Texto { get; set; }
    public UsuarioResumoDto? Usuario { get; set; }  // ❌ Objeto complexo (Backend NÃO envia)
    public string? UsuarioNome { get; set; }          // ❌ REDUNDANTE com Usuario.Nome
    public bool IsInterno { get; set; }               // ❌ Backend não envia este campo
    public DateTime DataHora { get; set; }            // ✅ Equivalente a DataCriacao
    public DateTime DataCriacao { get; set; }         // ❌ DUPLICADO com DataHora
    // UI Helpers
    public string DataHoraFormatada { get; }
    public string TempoRelativo { get; }
}
```

**Problemas Identificados:**
- ✅ **Compatível:** Backend retorna `UsuarioNome` como string, Mobile tem esta propriedade
- ❌ **Incompatível:** Mobile espera objeto `Usuario` (UsuarioResumoDto) que o Backend NÃO envia
- ❌ **Redundância:** Mobile tem `UsuarioNome` string E objeto `Usuario` (duplica Usuario.Nome)
- ❌ **Campo não enviado:** Mobile tem `IsInterno` boolean que o Backend não fornece
- ❌ **Duplicação de datas:** Mobile tem `DataHora` E `DataCriacao` (mesma informação)

**Recomendação:**
1. Remover `Usuario` objeto do ComentarioDto no Mobile
2. Manter apenas `UsuarioNome` string
3. Remover `DataHora` ou `DataCriacao` (manter apenas um)
4. Remover `IsInterno` ou adicionar no Backend se necessário

---

### 1.2 ChamadoDto - Estrutura Complexa vs Simples

#### Backend (ChamadoListDto.cs) - Usado em GET /api/chamados
```csharp
public class ChamadoListDto
{
    public int Id { get; set; }
    public string Titulo { get; set; }
    public string CategoriaNome { get; set; }     // ✅ String plana
    public string StatusNome { get; set; }        // ✅ String plana
    public string PrioridadeNome { get; set; }    // ✅ String plana
}
```

#### Mobile (ChamadoDto.cs)
```csharp
public class ChamadoDto
{
    public int Id { get; set; }
    public string Titulo { get; set; }
    public string Descricao { get; set; }
    
    // Objetos complexos
    public CategoriaDto? Categoria { get; set; }        // ❌ Backend lista retorna string
    public PrioridadeDto? Prioridade { get; set; }      // ❌ Backend lista retorna string
    public StatusDto? Status { get; set; }              // ❌ Backend lista retorna string
    public UsuarioResumoDto? Solicitante { get; set; }
    public UsuarioResumoDto? Tecnico { get; set; }
    
    // Informações redundantes do técnico
    public int? TecnicoAtribuidoId { get; set; }           // ❌ Duplica Tecnico.Id
    public string? TecnicoAtribuidoNome { get; set; }      // ❌ Duplica Tecnico.NomeCompleto
    public int? TecnicoAtribuidoNivel { get; set; }        // ❌ Backend não envia
    public string? TecnicoAtribuidoNivelDescricao { get; } // ❌ Backend não envia
    
    // Datas
    public DateTime DataAbertura { get; set; }
    public DateTime? DataUltimaAtualizacao { get; set; }
    public DateTime? DataFechamento { get; set; }
    
    // Outros
    public UsuarioResumoDto? FechadoPor { get; set; }
    public List<HistoricoItemDto>? Historico { get; set; }
    public AnaliseChamadoResponseDto? Analise { get; set; }
}
```

**Observação Importante:**
- O endpoint `GET /api/chamados` retorna **ChamadoListDto** (propriedades planas com nomes)
- O endpoint `GET /api/chamados/{id}` retorna **Chamado** completo (com objetos navegação EF Core)
- Mobile usa **ChamadoDto** complexo para ambos os casos, mas Desktop/Web usam apenas os nomes

**Problemas:**
- ❌ Mobile espera objetos complexos (Categoria, Status, Prioridade) mesmo na lista
- ❌ Desktop/Web usam apenas strings dos nomes (mais simples e eficiente)
- ❌ Mobile tem campos redundantes de TecnicoAtribuido (duplica objeto Tecnico)

**Recomendação:**
1. Criar `ChamadoListDto` no Mobile para listagens (propriedades planas)
2. Usar `ChamadoDto` completo apenas para detalhes (GET /api/chamados/{id})
3. Remover campos redundantes `TecnicoAtribuido*` (usar apenas objeto `Tecnico`)

---

## 🔄 2. LÓGICA DE NEGÓCIO DUPLICADA OU CONFLITANTE

### 2.1 Cálculo de KPIs - String-Based Filtering (FRÁGIL)

Todos os clientes usam string matching para filtrar status, o que é frágil caso o admin mude nomes no banco.

#### Desktop/Web (script-desktop.js linha 392)
```javascript
function atualizarKPIs(chamados) {
  const abertos = chamados.filter(c => c.statusNome.toLowerCase() === 'aberto').length;
  const emAndamento = chamados.filter(c => c.statusNome.toLowerCase() === 'em andamento').length;
  const resolvidos = chamados.filter(c => 
    c.statusNome.toLowerCase() === 'fechado' || 
    c.statusNome.toLowerCase() === 'resolvido'  // ✅ Aceita DOIS nomes
  ).length;
  const pendentes = chamados.filter(c => c.statusNome.toLowerCase() === 'aguardando resposta').length;
  const violados = chamados.filter(c => c.statusNome.toLowerCase() === 'violado').length;
}
```

#### Mobile (DashboardViewModel.cs linha 84-86)
```csharp
private string NormalizeStatus(ChamadoDto chamado)
{
    return chamado.Status?.Nome?.ToLowerInvariant() ?? "desconhecido";
}

// KPI calculation
TotalAbertos = listaUsuario.Count(c => NormalizeStatus(c) == "aberto");
TotalEmAndamento = listaUsuario.Count(c => NormalizeStatus(c) == "em andamento");
TotalEncerrados = listaUsuario.Count(c => NormalizeStatus(c) == "fechado"); // ❌ Só aceita "fechado"
TotalViolados = listaUsuario.Count(c => NormalizeStatus(c) == "violado");
```

**Problemas Identificados:**
- ❌ Desktop aceita "fechado" **OU** "resolvido" para contabilizar encerrados
- ❌ Mobile aceita **APENAS** "fechado"
- ❌ Comportamento inconsistente entre plataformas
- ❌ Todos dependem de strings (quebra se o admin mudar nomes no banco)
- ❌ Desktop tem KPI "pendentes" (aguardando resposta), Mobile não tem

**Recomendação:**
1. Padronizar: Aceitar "fechado" OU "resolvido" em todos os clientes
2. **MELHOR SOLUÇÃO:** Usar IDs dos status em vez de nomes (imune a mudanças de nomenclatura)
3. Adicionar KPI "pendentes" no Mobile

---

### 2.2 Funcionalidade "Assumir Chamado" - AUSENTE no Mobile 🟡

#### Desktop (script-desktop.js linha 1243-1312)
```javascript
async function assumirChamado(chamadoId) {
  const token = sessionStorage.getItem('authToken');
  const payload = decodeJWT(token);
  const nameIdentifierClaim = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier";
  const idDoTecnicoLogado = payload[nameIdentifierClaim];
  
  const novoStatusId = 2; // ✅ "Em Andamento"
  
  const body = {
    statusId: novoStatusId,
    tecnicoId: parseInt(idDoTecnicoLogado)
  };
  
  // PUT /api/chamados/{id}
  const response = await fetch(`${API_BASE}/api/chamados/${chamadoId}`, {
    method: 'PUT',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(body)
  });
  
  if (response.ok) {
    toast("Chamado assumido com sucesso!");
    initTecnicoDashboard(); // Recarrega ambas as tabelas
  }
}
```

#### Mobile (ChamadoService.cs)
```csharp
// ❌ NÃO EXISTE método Assumir() ou AssignToMe()

public Task<ChamadoDto?> Update(int id, AtualizarChamadoDto dto)
{
    return _api.PutAsync<AtualizarChamadoDto, ChamadoDto>($"chamados/{id}", dto);
}

public Task<ChamadoDto?> Close(int id)
{
    var atualizacao = new AtualizarChamadoDto
    {
        StatusId = 5 // ❌ ERRADO! Backend espera 4
    };
    return _api.PutAsync<AtualizarChamadoDto, ChamadoDto>($"chamados/{id}", atualizacao);
}

// ❌ FALTA: public Task<ChamadoDto?> Assumir(int id)
```

**Impacto:**
- ❌ Desktop tem funcionalidade completa para técnicos assumirem chamados da fila
- ❌ Mobile NÃO tem método dedicado `Assumir()`
- ❌ Técnicos usando Mobile precisam usar método genérico `Update()` manualmente
- ❌ Inconsistência de UX entre plataformas

**Recomendação:**
Adicionar método no Mobile ChamadoService.cs:
```csharp
public Task<ChamadoDto?> Assumir(int id)
{
    // Obtém TecnicoId do AuthService (usuário logado)
    var tecnicoId = _authService.GetCurrentUserId();
    
    var atualizacao = new AtualizarChamadoDto
    {
        StatusId = 2, // "Em Andamento"
        TecnicoId = tecnicoId
    };
    
    return _api.PutAsync<AtualizarChamadoDto, ChamadoDto>($"chamados/{id}", atualizacao);
}
```

---

### 2.3 Filtragem de Chamados - Abordagens Diferentes

#### Desktop (script-desktop.js linha 428-456)
```javascript
async function initDashboard() {
  let url = `${API_BASE}/api/chamados`; // URL padrão (Admin)
  const path = window.location.pathname;

  // Usuário comum: filtra por solicitanteId
  if (path.endsWith("user-dashboard-desktop.html")) {
    const payload = decodeJWT(token);
    const userId = parseInt(payload[nameIdentifierClaim]);
    url = `${API_BASE}/api/chamados?solicitanteId=${userId}`; // ✅ Query string manual
  }
}
```

#### Mobile (ChamadoQueryParameters.cs)
```csharp
public class ChamadoQueryParameters
{
    public int? StatusId { get; set; }
    public int? TecnicoId { get; set; }
    public int? SolicitanteId { get; set; }
    public int? PrioridadeId { get; set; }
    public string? TermoBusca { get; set; }

    public string ToQueryString()
    {
        var parameters = new List<string>();
        if (StatusId.HasValue) parameters.Add($"statusId={StatusId}");
        if (TecnicoId.HasValue) parameters.Add($"tecnicoId={TecnicoId}");
        if (SolicitanteId.HasValue) parameters.Add($"solicitanteId={SolicitanteId}");
        if (PrioridadeId.HasValue) parameters.Add($"prioridadeId={PrioridadeId}");
        if (!string.IsNullOrWhiteSpace(TermoBusca)) 
            parameters.Add($"termoBusca={Uri.EscapeDataString(TermoBusca)}");
        
        return string.Join("&", parameters);
    }
}
```

**Análise:**
- ✅ **Desktop:** Constrói query strings manualmente (simples mas propenso a erros)
- ✅ **Mobile:** Usa classe `ChamadoQueryParameters` (type-safe, robusto)
- ✅ **Backend:** Aceita query parameters padrão (funciona com ambos)
- ✅ **Funcionalidade:** Ambos funcionam corretamente

**Conclusão:** Abordagens diferentes mas funcionais. Mobile tem abordagem mais robusta.

---

## 🌐 3. USO INCORRETO DE ENDPOINTS DA API

### 3.1 StatusId Hardcoded Conflict - CRÍTICO 🔴

#### Mobile Close() - ChamadoService.cs linha 73-82
```csharp
public Task<ChamadoDto?> Close(int id)
{
    // ⚠️ FIX: Backend não tem endpoint /fechar
    // Usa PUT /chamados/{id} com StatusId = 5 (Fechado)
    var atualizacao = new AtualizarChamadoDto
    {
        StatusId = 5 // ❌ ERRADO! Backend espera 4
    };
    return _api.PutAsync<AtualizarChamadoDto, ChamadoDto>($"chamados/{id}", atualizacao);
}
```

#### Backend AtualizarChamado() - ChamadosController.cs linha 219-262
```csharp
[HttpPut("{id}")]
public async Task<IActionResult> AtualizarChamado(int id, [FromBody] AtualizarChamadoDto request)
{
    var chamado = await _context.Chamados.FindAsync(id);
    if (chamado == null) return NotFound("Chamado não encontrado.");

    var statusExiste = await _context.Status.AnyAsync(s => s.Id == request.StatusId);
    if (!statusExiste) return BadRequest("O StatusId fornecido é inválido.");

    chamado.DataUltimaAtualizacao = DateTime.UtcNow;

    // ✅ Backend verifica StatusId = 4 para definir DataFechamento
    if (request.StatusId == 4) 
    {
        chamado.DataFechamento = DateTime.UtcNow;
    }
    else
    {
        chamado.DataFechamento = null; // Reabertura limpa data
    }

    chamado.StatusId = request.StatusId;

    if (request.TecnicoId.HasValue)
    {
        var tecnicoExiste = await _context.Usuarios.AnyAsync(u => u.Id == request.TecnicoId.Value && u.Ativo);
        if (!tecnicoExiste) return BadRequest("O TecnicoId fornecido é inválido ou o usuário está inativo.");
        chamado.TecnicoId = request.TecnicoId;
    }

    _context.Chamados.Update(chamado);
    await _context.SaveChangesAsync();

    return Ok(chamado);
}
```

#### Desktop "Assumir" - script-desktop.js linha 1271
```javascript
const novoStatusId = 2; // ✅ "Em Andamento" para assumir chamado
```

**Evidência Definitiva do Bug:**
- **Mobile:** `StatusId = 5` (linha 79 de ChamadoService.cs)
- **Backend:** `if (request.StatusId == 4)` (linha 239 de ChamadosController.cs)
- **Desktop Assumir:** `StatusId = 2` (linha 1271 de script-desktop.js)

**Impacto CRÍTICO:**
1. ❌ Mobile envia `StatusId = 5` ao fechar chamado
2. ❌ Backend NÃO reconhece 5 como "Fechado" (espera 4)
3. ❌ `DataFechamento` **NUNCA** é definida quando Mobile fecha chamados
4. ❌ Chamados aparecem como "fechados" no nome do status, mas sem data de fechamento
5. ❌ Relatórios de tempo de resolução ficam incorretos
6. ❌ SLA calculations podem estar errados

**Solução URGENTE:**
```csharp
// Mobile/Services/Chamados/ChamadoService.cs linha 79
StatusId = 4 // ✅ CORRIGIR de 5 para 4
```

**Solução IDEAL (longo prazo):**
Criar classe de constantes compartilhada:
```csharp
public static class StatusConstants
{
    public const int Aberto = 1;
    public const int EmAndamento = 2;
    public const int AguardandoResposta = 3;
    public const int Fechado = 4;
    public const int Violado = 5;
}
```

---

### 3.2 AtualizarChamadoDto - Estrutura Consistente ✅

#### Backend (AtualizarChamadoDto.cs)
```csharp
public class AtualizarChamadoDto
{
    public int StatusId { get; set; }
    public int? TecnicoId { get; set; } // Opcional
}
```

#### Mobile (AtualizarChamadoDto.cs)
```csharp
public class AtualizarChamadoDto
{
    public int StatusId { get; set; }
    public int? TecnicoId { get; set; } // Opcional
}
```

**Análise:**
- ✅ **Estrutura idêntica** entre Mobile e Backend
- ✅ **TecnicoId opcional** permite atualizar apenas status OU status + técnico
- ✅ **Usado corretamente** por Desktop e Mobile (exceto bug do StatusId = 5)

---

## 📋 TABELA RESUMO DE INCONSISTÊNCIAS

| Componente | Mobile | Desktop/Web | Backend | Severidade | Status |
|------------|--------|-------------|---------|------------|--------|
| **ComentarioDto** | Objeto Usuario + UsuarioNome (redundante) + IsInterno + 2 datas | Usa UsuarioNome (string) | Retorna UsuarioNome (string) + DataCriacao | 🟡 MÉDIA | ❌ Incompatível |
| **ChamadoDto (lista)** | Objetos complexos (Categoria, Status, Prioridade) | Strings planas (categoriaNome, statusNome) | Retorna ChamadoListDto (strings) | 🟡 MÉDIA | ⚠️ Funciona mas ineficiente |
| **StatusId "Fechado"** | 5 (hardcoded) | Não hardcoded (usa dropdown) | 4 (hardcoded) | 🔴 CRÍTICA | ❌ BLOQUEADOR |
| **StatusId "Em Andamento"** | - | 2 (assumir chamado) | 2 (hardcoded) | 🟢 BAIXA | ✅ Correto |
| **KPI "Encerrados"** | Só "fechado" | "fechado" OU "resolvido" | N/A | 🟡 MÉDIA | ⚠️ Inconsistente |
| **Função Assumir Chamado** | ❌ Não existe | ✅ Implementada | ✅ Suportada | 🟡 MÉDIA | ❌ Falta no Mobile |
| **Filtragem Query Params** | Type-safe (ChamadoQueryParameters) | Query strings manuais | Aceita query params | 🟢 BAIXA | ✅ Funcional (diferentes mas ok) |
| **AtualizarChamadoDto** | StatusId + TecnicoId opcional | Usa corretamente | StatusId + TecnicoId opcional | 🟢 BAIXA | ✅ Compatível |

---

## ✅ PLANO DE CORREÇÃO PRIORIZADO

### 🔴 PRIORIDADE CRÍTICA - CORREÇÃO IMEDIATA NECESSÁRIA

#### 1. Corrigir StatusId no Mobile (BLOQUEADOR)
**Arquivo:** `Mobile/Services/Chamados/ChamadoService.cs` linha 79

**Mudança:**
```csharp
// ANTES (ERRADO):
StatusId = 5

// DEPOIS (CORRETO):
StatusId = 4
```

**Justificativa:** 
- Bug crítico que impede Mobile de fechar chamados corretamente
- `DataFechamento` nunca é definida
- Afeta relatórios e métricas de resolução

**Tempo estimado:** 2 minutos  
**Teste:** Fechar chamado no Mobile e verificar se `DataFechamento` é preenchida no banco

---

### 🟡 PRIORIDADE ALTA - CORREÇÃO EM 1-2 DIAS

#### 2. Adicionar Método "Assumir Chamado" no Mobile
**Arquivo:** `Mobile/Services/Chamados/ChamadoService.cs`

**Código a adicionar:**
```csharp
public Task<ChamadoDto?> Assumir(int id)
{
    // Obtém ID do técnico logado do AuthService
    var tecnicoId = _authService.GetCurrentUserId();
    
    var atualizacao = new AtualizarChamadoDto
    {
        StatusId = 2, // "Em Andamento"
        TecnicoId = tecnicoId
    };
    
    return _api.PutAsync<AtualizarChamadoDto, ChamadoDto>($"chamados/{id}", atualizacao);
}
```

**Justificativa:**
- Técnicos usando Mobile não conseguem assumir chamados
- Funcionalidade existe no Desktop mas ausente no Mobile
- Inconsistência de experiência do usuário

**Tempo estimado:** 30 minutos  
**Teste:** Técnico deve conseguir assumir chamado da fila e ver StatusId = 2 no banco

---

#### 3. Padronizar Lógica de KPIs
**Arquivos:** `Mobile/ViewModels/DashboardViewModel.cs` linha 84-86

**Mudança:**
```csharp
// ANTES (aceita só "fechado"):
TotalEncerrados = listaUsuario.Count(c => NormalizeStatus(c) == "fechado");

// DEPOIS (aceita "fechado" OU "resolvido"):
TotalEncerrados = listaUsuario.Count(c => 
    NormalizeStatus(c) == "fechado" || 
    NormalizeStatus(c) == "resolvido"
);
```

**Justificativa:**
- Desktop aceita ambos os nomes
- Mobile deve ter comportamento idêntico
- Evita contagens diferentes entre plataformas

**Tempo estimado:** 10 minutos  
**Teste:** KPIs Mobile devem ter os mesmos valores que Desktop

---

### 🔵 PRIORIDADE MÉDIA - CORREÇÃO EM 1 SEMANA

#### 4. Simplificar ComentarioDto no Mobile
**Arquivo:** `Mobile/Models/DTOs/ComentarioDto.cs`

**Mudanças:**
1. Remover propriedade `Usuario` (objeto)
2. Manter apenas `UsuarioNome` (string)
3. Remover `IsInterno` (Backend não envia)
4. Remover `DataHora` (manter apenas `DataCriacao`)

**Antes:**
```csharp
public UsuarioResumoDto? Usuario { get; set; }
public string? UsuarioNome { get; set; }
public bool IsInterno { get; set; }
public DateTime DataHora { get; set; }
public DateTime DataCriacao { get; set; }
```

**Depois:**
```csharp
public string UsuarioNome { get; set; } = string.Empty;
public DateTime DataCriacao { get; set; }
```

**Justificativa:**
- Backend retorna apenas `UsuarioNome` (string)
- Campos redundantes ocupam memória desnecessariamente
- Simplifica manutenção do código

**Tempo estimado:** 1 hora (incluindo testes)  
**Teste:** Comentários devem ser exibidos corretamente no Mobile

---

#### 5. Criar ChamadoListDto no Mobile
**Novo arquivo:** `Mobile/Models/DTOs/ChamadoListDto.cs`

**Código:**
```csharp
namespace SistemaChamados.Mobile.Models.DTOs;

/// <summary>
/// DTO simplificado para listagem de chamados (GET /api/chamados)
/// Corresponde ao ChamadoListDto do Backend
/// </summary>
public class ChamadoListDto
{
    public int Id { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string CategoriaNome { get; set; } = string.Empty;
    public string StatusNome { get; set; } = string.Empty;
    public string PrioridadeNome { get; set; } = string.Empty;
}
```

**Justificativa:**
- Backend retorna ChamadoListDto (strings) em GET /api/chamados
- Mobile usa ChamadoDto complexo para tudo (ineficiente)
- Separar DTOs de listagem vs detalhes melhora performance

**Tempo estimado:** 2 horas (incluindo refatoração de ViewModels)  
**Teste:** Listagens devem funcionar sem erros de deserialização

---

### 🟢 PRIORIDADE BAIXA - MELHORIA FUTURA

#### 6. Criar StatusConstants Compartilhada
**Novo arquivo:** `Backend/Core/Constants/StatusConstants.cs`

**Código:**
```csharp
namespace SistemaChamados.Core.Constants;

public static class StatusConstants
{
    public const int Aberto = 1;
    public const int EmAndamento = 2;
    public const int AguardandoResposta = 3;
    public const int Fechado = 4;
    public const int Violado = 5;
}
```

**Replicar em:** `Mobile/Constants/StatusConstants.cs`

**Refatorar:**
- ChamadosController.cs linha 239: `if (request.StatusId == StatusConstants.Fechado)`
- ChamadoService.cs Mobile linha 79: `StatusId = StatusConstants.Fechado`
- script-desktop.js linha 1271: Adicionar comentário `// StatusId 2 = Em Andamento`

**Justificativa:**
- Elimina "magic numbers" hardcoded
- Facilita manutenção
- Previne bugs como o StatusId 5 vs 4

**Tempo estimado:** 3 horas (incluindo refatoração em todos os clientes)

---

#### 7. Eliminar Duplicação Desktop vs wwwroot
**Decisão necessária:**

**Opção A:** Manter apenas Frontend/wwwroot/ (servidor unificado)
- Deletar Frontend/Desktop/ completamente
- Atualizar README.md

**Opção B:** Documentar propósito de cada pasta
- Explicar por que existem 2 cópias idênticas
- Criar script de sincronização automática

**Justificativa:**
- Desktop/ e wwwroot/ são 100% idênticos
- Manutenção duplicada (toda mudança precisa ser feita em 2 lugares)
- Risco de divergência no futuro

**Tempo estimado:** 1 hora (decisão + documentação)

---

## 📊 MATRIZ DE IMPACTO vs ESFORÇO

| Tarefa | Impacto | Esforço | Prioridade | Tempo |
|--------|---------|---------|------------|-------|
| 1. Corrigir StatusId Mobile | 🔴 CRÍTICO | Mínimo | 🔴 CRÍTICA | 2 min |
| 2. Adicionar Assumir() Mobile | 🟡 ALTO | Baixo | 🟡 ALTA | 30 min |
| 3. Padronizar KPIs | 🟡 MÉDIO | Mínimo | 🟡 ALTA | 10 min |
| 4. Simplificar ComentarioDto | 🟡 MÉDIO | Médio | 🔵 MÉDIA | 1 hora |
| 5. Criar ChamadoListDto | 🟡 MÉDIO | Médio | 🔵 MÉDIA | 2 horas |
| 6. StatusConstants | 🟢 BAIXO | Alto | 🟢 BAIXA | 3 horas |
| 7. Eliminar Duplicação | 🟢 BAIXO | Baixo | 🟢 BAIXA | 1 hora |

**Total Tempo Estimado:** ~8 horas (incluindo testes)  
**Ordem de Execução:** 1 → 2 → 3 → 4 → 5 → 6 → 7

---

## 🧪 CHECKLIST DE TESTES

### Após Correção do StatusId (Tarefa #1)
- [ ] Mobile: Fechar chamado e verificar `DataFechamento` no banco
- [ ] Desktop: Fechar chamado e verificar `DataFechamento` no banco
- [ ] Ambos: Reabrir chamado e verificar `DataFechamento = NULL`

### Após Adicionar Assumir() (Tarefa #2)
- [ ] Mobile: Técnico assume chamado da fila
- [ ] Verificar `StatusId = 2` no banco
- [ ] Verificar `TecnicoId` preenchido corretamente

### Após Padronizar KPIs (Tarefa #3)
- [ ] Desktop: KPI "Encerrados" conta "fechado" e "resolvido"
- [ ] Mobile: KPI "Encerrados" conta "fechado" e "resolvido"
- [ ] Comparar valores: Desktop KPI = Mobile KPI

### Após Simplificar DTOs (Tarefas #4 e #5)
- [ ] Mobile: Listagem de chamados sem erros
- [ ] Mobile: Detalhes de chamado sem erros
- [ ] Mobile: Comentários exibem UsuarioNome corretamente

---

**Última atualização:** 2025-01-31  
**Próxima revisão:** Após implementação das correções críticas
