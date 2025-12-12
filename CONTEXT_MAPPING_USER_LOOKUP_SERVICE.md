# 🌉 Context Mapping: UserLookupService

**Data:** 12/12/2025  
**Padrão:** Context Mapping / Anti-Corruption Layer  
**Referência:** AUDITORIA_ARQUITETURAL_NEUROHELP.md - Phase 4.2

---

## 📋 Objetivo

Criar uma **ponte** entre os Bounded Contexts de **Auth** e **Tickets**, permitindo que o contexto de Tickets obtenha informações de usuário sem acoplamento direto ao contexto de Autenticação.

---

## 🏗️ Arquivos Criados

### 1. Interface: `Backend/Core/Tickets/Interfaces/IUserLookupService.cs`

**Localização:** Core Layer (Tickets Context)

**Métodos:**

```csharp
Task<TicketUser> GetUserForTicketAsync(UserId userId);
Task<Dictionary<UserId, TicketUser>> GetUsersForTicketsAsync(IEnumerable<UserId> userIds);
Task<bool> UserExistsAsync(UserId userId);
```

**Características:**
- ✅ Interface no Core (não depende de Infrastructure)
- ✅ Retorna `TicketUser` (entidade do contexto de Tickets)
- ✅ Aceita `UserId` (Strongly Typed ID)
- ✅ Suporta operações em lote para melhor performance

---

### 2. Implementação: `Backend/Infrastructure/Services/UserLookupService.cs`

**Localização:** Infrastructure Layer

**Responsabilidades:**
1. Acessar tabela `Usuarios` (Auth context)
2. Mapear `Usuario` → `TicketUser`
3. Converter entre IDs (int legado → Guid)
4. Fornecer dados para o contexto de Tickets

**Implementação Destacada:**

```csharp
public async Task<TicketUser> GetUserForTicketAsync(UserId userId)
{
    // 1. Converter UserId (Guid) para int (durante migração)
    var guidBytes = userId.Value.ToByteArray();
    var userIdInt = BitConverter.ToInt32(guidBytes, 0);

    // 2. Buscar no banco (Auth context)
    var usuario = await _context.Usuarios
        .AsNoTracking()
        .Where(u => u.Id == userIdInt)
        .Select(u => new
        {
            u.Id,
            u.NomeCompleto,
            u.Email,
            u.TipoUsuario,
            u.Especialidade,
            u.Ativo
        })
        .FirstOrDefaultAsync();

    // 3. Mapear para TicketUser (Tickets context)
    return TicketUser.Create(
        id: UserId.FromInt(usuario.Id),
        nomeExibicao: usuario.NomeCompleto,
        emailContato: usuario.Email,
        tipoUsuario: MapTipoUsuario(usuario.TipoUsuario),
        especialidade: usuario.Especialidade
    );
}
```

**Mapeamento de TipoUsuario:**
```csharp
private static string MapTipoUsuario(int tipoUsuario)
{
    return tipoUsuario switch
    {
        1 => "Solicitante",
        2 => "Tecnico",
        3 => "Admin",
        _ => "Desconhecido"
    };
}
```

---

## 🎨 Padrão Arquitetural

### Context Mapping (DDD)

```
┌─────────────────────────────┐
│   Auth Bounded Context      │
│                              │
│  ┌─────────────────────┐    │
│  │  Usuario (Entity)   │    │
│  │  - Id: int          │    │
│  │  - Email            │    │
│  │  - SenhaHash        │    │
│  │  - TipoUsuario: int │    │
│  └─────────────────────┘    │
└──────────────┬───────────────┘
               │
               │ Infrastructure Layer
               │ (UserLookupService)
               │ Maps: Usuario → TicketUser
               │
               ↓
┌──────────────┴───────────────┐
│  Tickets Bounded Context     │
│                              │
│  ┌─────────────────────┐    │
│  │ TicketUser (Entity) │    │
│  │ - Id: UserId        │    │
│  │ - NomeExibicao      │    │
│  │ - EmailContato      │    │
│  │ - TipoUsuario: str  │    │
│  └─────────────────────┘    │
│                              │
│  ┌─────────────────────┐    │
│  │  Ticket (Entity)    │    │
│  │  - SolicitanteId    │    │
│  │  - NomeSnapshot     │    │
│  └─────────────────────┘    │
└──────────────────────────────┘
```

### Anti-Corruption Layer

O `IUserLookupService` atua como **Anti-Corruption Layer**:

- **Proteção:** Tickets não conhece estrutura de Auth
- **Tradução:** Converte conceitos de Auth para conceitos de Tickets
- **Isolamento:** Mudanças em Auth não quebram Tickets

---

## 💡 Uso Prático

### Exemplo 1: Criar Ticket com Lookup

```csharp
// Use Case: CreateTicketUseCase.cs
public class CreateTicketUseCase
{
    private readonly IUserLookupService _userLookupService;
    private readonly ITicketRepository _ticketRepository;

    public async Task<Ticket> ExecuteAsync(
        string titulo,
        string descricao,
        UserId solicitanteId,
        int categoriaId,
        int prioridadeId)
    {
        // 1. Buscar dados do usuário (Auth context)
        var ticketUser = await _userLookupService
            .GetUserForTicketAsync(solicitanteId);

        // 2. Criar ticket (Tickets context)
        var ticket = Ticket.Create(
            titulo: titulo,
            descricao: descricao,
            solicitanteId: ticketUser.Id,
            nomeSolicitante: ticketUser.NomeExibicao,
            categoriaId: categoriaId,
            prioridadeId: prioridadeId,
            statusAberto: 1
        );

        // 3. Salvar
        await _ticketRepository.AddAsync(ticket);
        return ticket;
    }
}
```

### Exemplo 2: Validar Usuário antes de Atribuir Técnico

```csharp
// Use Case: AssignTechnicianUseCase.cs
public class AssignTechnicianUseCase
{
    private readonly IUserLookupService _userLookupService;
    private readonly ITicketRepository _ticketRepository;

    public async Task<bool> ExecuteAsync(
        TicketId ticketId,
        UserId tecnicoId)
    {
        // 1. Verificar se técnico existe e está ativo
        var tecnicoExists = await _userLookupService
            .UserExistsAsync(tecnicoId);

        if (!tecnicoExists)
        {
            throw new InvalidOperationException(
                "Técnico não encontrado ou inativo.");
        }

        // 2. Buscar dados do técnico
        var tecnico = await _userLookupService
            .GetUserForTicketAsync(tecnicoId);

        // 3. Carregar ticket
        var ticket = await _ticketRepository
            .GetByIdAsync(ticketId);

        // 4. Atribuir técnico
        ticket.AtribuirTecnico(
            tecnicoId: tecnico.Id,
            nomeTecnico: tecnico.NomeExibicao
        );

        // 5. Salvar
        await _ticketRepository.UpdateAsync(ticket);
        return true;
    }
}
```

### Exemplo 3: Carregar Múltiplos Usuários (Batch)

```csharp
// Query: GetTicketListQuery.cs
public class GetTicketListQueryHandler
{
    private readonly ITicketRepository _ticketRepository;
    private readonly IUserLookupService _userLookupService;

    public async Task<List<TicketListDto>> Handle(
        GetTicketListQuery request,
        CancellationToken ct)
    {
        // 1. Carregar tickets
        var tickets = await _ticketRepository
            .GetAllAsync();

        // 2. Extrair UserIds únicos
        var userIds = tickets
            .SelectMany(t => new[] 
            { 
                t.SolicitanteId, 
                t.TecnicoId 
            })
            .Where(id => id != null)
            .Distinct()
            .ToList();

        // 3. Carregar TODOS os usuários de uma vez (performance!)
        var usersDict = await _userLookupService
            .GetUsersForTicketsAsync(userIds);

        // 4. Mapear para DTOs
        var dtos = tickets.Select(t => new TicketListDto
        {
            Id = t.Id,
            Titulo = t.Titulo,
            SolicitanteNome = usersDict.TryGetValue(
                t.SolicitanteId, out var solicitante)
                ? solicitante.NomeExibicao
                : t.NomeSolicitanteSnapshot, // Fallback
            TecnicoNome = t.TecnicoId.HasValue && 
                usersDict.TryGetValue(t.TecnicoId.Value, out var tec)
                ? tec.NomeExibicao
                : t.NomeTecnicoSnapshot // Fallback
        }).ToList();

        return dtos;
    }
}
```

---

## 🚀 Benefícios

### 1. **Desacoplamento Total**
- ✅ Tickets não conhece `Usuario` (Auth entity)
- ✅ Tickets não conhece estrutura de banco de Auth
- ✅ Tickets usa apenas `TicketUser` (própria entidade)

### 2. **Testabilidade**
```csharp
// Mock fácil em testes
var mockUserLookup = new Mock<IUserLookupService>();
mockUserLookup
    .Setup(x => x.GetUserForTicketAsync(It.IsAny<UserId>()))
    .ReturnsAsync(new TicketUser(...));

var useCase = new CreateTicketUseCase(
    mockUserLookup.Object, 
    mockTicketRepo.Object
);
```

### 3. **Performance**
- ✅ Método `GetUsersForTicketsAsync()` evita N+1 queries
- ✅ Single query para múltiplos usuários
- ✅ `AsNoTracking()` para leitura otimizada

### 4. **Evolução Independente**
- ✅ Auth pode mudar estrutura de `Usuario` sem quebrar Tickets
- ✅ Tickets pode evoluir `TicketUser` independentemente
- ✅ Mapping centralizado em um único lugar

### 5. **Migração Gradual**
- ✅ Suporta conversão int → Guid durante migração
- ✅ `FromInt()` permite coexistência de IDs legados
- ✅ Facilita refatoração incremental

---

## 🔄 Fluxo de Dados

### Criar Ticket

```
┌──────────────┐
│   Client     │
│  (API Call)  │
└──────┬───────┘
       │ POST /api/tickets
       │ { titulo, descricao, categoriaId, ... }
       ↓
┌──────────────────────┐
│  ChamadosController  │
│  (Presentation)      │
└──────┬───────────────┘
       │ ICurrentUserService.GetUserId()
       │ → userId (string → convert to UserId)
       ↓
┌──────────────────────┐
│  CreateTicketUseCase │
│  (Application)       │
└──────┬───────────────┘
       │
       ├──→ IUserLookupService.GetUserForTicketAsync(userId)
       │    └─→ Infrastructure queries Auth DB
       │        └─→ Returns TicketUser
       │
       └──→ Ticket.Create(
                titulo, 
                descricao, 
                solicitanteId: ticketUser.Id,
                nomeSolicitante: ticketUser.NomeExibicao,
                ...
            )
            └─→ ITicketRepository.AddAsync(ticket)
                └─→ Persists to DB
```

---

## ⚠️ Considerações Importantes

### 1. **Conversão de IDs (Temporária)**

Durante a migração de `int` para `Guid`:

```csharp
// UserLookupService usa conversão temporária
var guidBytes = userId.Value.ToByteArray();
var userIdInt = BitConverter.ToInt32(guidBytes, 0);
```

**Após migração completa:**
- Remover conversão BitConverter
- Usar Guid diretamente no banco
- Simplificar queries

### 2. **Cache (Futuro)**

Adicionar caching para melhorar performance:

```csharp
public class CachedUserLookupService : IUserLookupService
{
    private readonly IUserLookupService _inner;
    private readonly IMemoryCache _cache;

    public async Task<TicketUser> GetUserForTicketAsync(UserId userId)
    {
        return await _cache.GetOrCreateAsync(
            $"ticketuser_{userId}",
            async entry =>
            {
                entry.AbsoluteExpirationRelativeToNow = 
                    TimeSpan.FromMinutes(15);
                return await _inner.GetUserForTicketAsync(userId);
            }
        );
    }
}
```

### 3. **Event-Driven Sync (Futuro)**

Quando usuário muda nome em Auth:

```csharp
// AuthContext publica evento
public class UserNameChangedEvent
{
    public UserId UserId { get; set; }
    public string NewName { get; set; }
}

// Tickets escuta e atualiza snapshots
public class UserNameChangedHandler : 
    INotificationHandler<UserNameChangedEvent>
{
    public async Task Handle(UserNameChangedEvent evt, CT ct)
    {
        var tickets = await _repo.GetByUserIdAsync(evt.UserId);
        foreach (var ticket in tickets)
        {
            ticket.AtualizarNomeSolicitante(evt.NewName);
        }
        await _repo.SaveChangesAsync();
    }
}
```

---

## 📊 Registro DI

**Arquivo:** `Backend/program.cs`

```csharp
// Context Mapping Services (Bridge between Bounded Contexts)
// AUDITORIA_ARQUITETURAL_NEUROHELP.md - Phase 4.2 (Context Mapping)
builder.Services.AddScoped<
    SistemaChamados.Core.Tickets.Interfaces.IUserLookupService,
    SistemaChamados.Infrastructure.Services.UserLookupService>();
```

---

## ✅ Checklist de Implementação

- [x] Interface `IUserLookupService` criada no Core/Tickets
- [x] Implementação `UserLookupService` criada na Infrastructure
- [x] Método `GetUserForTicketAsync()` implementado
- [x] Método `GetUsersForTicketsAsync()` implementado (batch)
- [x] Método `UserExistsAsync()` implementado
- [x] Mapeamento `TipoUsuario` (int → string) implementado
- [x] Suporte a `Especialidade` adicionado
- [x] Conversão temporária int → Guid implementada
- [x] Serviço registrado no DI container
- [x] Compilação bem-sucedida (0 erros)

---

## 🎓 Próximos Passos

1. **Usar em Use Cases:**
   - Refatorar `CreateTicketWithAIAnalysisUseCase` para usar `IUserLookupService`
   - Refatorar `AssignTechnicianUseCase` para validar técnico via serviço

2. **Adicionar Cache:**
   - Implementar `CachedUserLookupService` wrapper
   - Usar `IMemoryCache` ou `IDistributedCache` (Redis)

3. **Event-Driven Sync:**
   - Publicar eventos quando usuário muda nome/email
   - Atualizar snapshots em tickets automaticamente

4. **Testes:**
   - Unit tests para `UserLookupService`
   - Integration tests com banco in-memory
   - Mock tests em Use Cases

---

**Última Atualização:** 12/12/2025  
**Status:** ✅ Implementado e Funcional  
**Próxima Etapa:** Refatorar Use Cases para usar o novo serviço
