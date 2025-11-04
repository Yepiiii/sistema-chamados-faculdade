# Rastreabilidade de Fechamento de Chamados

## Visão Geral

Esta funcionalidade implementa o rastreamento completo de **quem** fechou um chamado e **quando** o fechamento ocorreu, proporcionando total transparência e auditoria no ciclo de vida dos chamados.

## Objetivo

Registrar e exibir claramente o nome do usuário que marcou o chamado como "Fechado", junto com a data e hora da ação, atendendo à necessidade de accountability e rastreabilidade no sistema.

## Implementação Técnica

### 1. Schema do Banco de Dados

**Tabela:** `Chamados`

**Novo Campo Adicionado:**
- `FechadoPorId` (int, nullable) - FK para tabela `Usuarios`
- Índice criado: `IX_Chamados_FechadoPorId`
- Constraint: `FK_Chamados_Usuarios_FechadoPorId` com `DeleteBehavior.Restrict`

**Migration:** `20251104184208_AdicionarFechadoPorChamado`

```sql
ALTER TABLE [Chamados] ADD [FechadoPorId] int NULL;
CREATE INDEX [IX_Chamados_FechadoPorId] ON [Chamados] ([FechadoPorId]);
ALTER TABLE [Chamados] ADD CONSTRAINT [FK_Chamados_Usuarios_FechadoPorId] 
    FOREIGN KEY ([FechadoPorId]) REFERENCES [Usuarios] ([Id]) ON DELETE NO ACTION;
```

### 2. Modelo de Entidade

**Arquivo:** `Core/Entities/Chamado.cs`

```csharp
public class Chamado
{
    // ... outras propriedades ...
    
    public int? FechadoPorId { get; set; }
    public virtual Usuario? FechadoPor { get; set; }
    
    public DateTime? DataFechamento { get; set; }
    
    // ... outras propriedades ...
}
```

### 3. Data Transfer Object (DTO)

**Arquivo:** `Application/DTOs/ChamadoDTO.cs`

```csharp
public class ChamadoDto
{
    // ... outras propriedades ...
    
    public UsuarioResumoDto? FechadoPor { get; set; }
    public DateTime? DataFechamento { get; set; }
    
    // ... outras propriedades ...
}
```

### 4. Lógica do Controller

**Arquivo:** `API/Controllers/ChamadosController.cs`

#### 4.1 UpdateChamado - Detecção Automática de Fechamento

```csharp
// Verifica se o novo status é 'Fechado' (StatusId = 5)
if (request.StatusId == 5 && chamado.StatusId != 5) 
{
    // Registra data e usuário que fechou o chamado
    chamado.DataFechamento = DateTime.UtcNow;
    
    // Captura o usuário autenticado que está fechando o chamado
    var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int userId))
    {
        chamado.FechadoPorId = userId;
    }
}
else if (request.StatusId != 5)
{
    // Garante que a data de fechamento e usuário sejam nulos se o chamado for reaberto
    chamado.DataFechamento = null;
    chamado.FechadoPorId = null;
}
```

#### 4.2 FecharChamado - Endpoint Dedicado

```csharp
[HttpPost("{id}/fechar")]
public async Task<IActionResult> FecharChamado(int id)
{
    // ... validações ...
    
    chamado.StatusId = 5; // Status "Fechado"
    chamado.DataUltimaAtualizacao = DateTime.UtcNow;
    chamado.DataFechamento = DateTime.UtcNow;
    chamado.FechadoPorId = usuarioAutenticadoId; // Captura o usuário autenticado
    
    // ... salva e retorna ...
}
```

#### 4.3 Queries com Include do FechadoPor

Todos os endpoints que retornam chamados foram atualizados para incluir a relação `FechadoPor`:

```csharp
// GetChamados - Lista de chamados
var chamados = await query
    .Include(c => c.Categoria)
    .Include(c => c.Status)
    .Include(c => c.Prioridade)
    .Include(c => c.Solicitante)
    .Include(c => c.Tecnico)
    .Include(c => c.FechadoPor) // ← NOVO
    .Include(c => c.Comentarios)
        .ThenInclude(com => com.Usuario)
    .AsNoTracking()
    .OrderByDescending(c => c.DataAbertura)
    .ToListAsync();

// GetChamadoPorId - Detalhe do chamado
var chamado = await _context.Chamados
    .Include(c => c.Solicitante)
    .Include(c => c.Tecnico)
    .Include(c => c.FechadoPor) // ← NOVO
    .Include(c => c.Status)
    .Include(c => c.Prioridade)
    .Include(c => c.Categoria)
    .Include(c => c.Comentarios)
        .ThenInclude(com => com.Usuario)
    .FirstOrDefaultAsync(c => c.Id == id);

// LoadChamadoDtoAsync - Projeção de DTO
var chamado = await _context.Chamados
    .Include(c => c.Categoria)
    .Include(c => c.Status)
    .Include(c => c.Prioridade)
    .Include(c => c.Solicitante)
    .Include(c => c.Tecnico)
    .Include(c => c.FechadoPor) // ← NOVO
    .Include(c => c.Comentarios)
        .ThenInclude(com => com.Usuario)
    .AsNoTracking()
    .FirstOrDefaultAsync(c => c.Id == chamadoId);
```

#### 4.4 Mapeamento para DTO

```csharp
private static ChamadoDto MapChamadoToDto(Chamado chamado, ...)
{
    return new ChamadoDto
    {
        // ... outros campos ...
        
        FechadoPor = chamado.FechadoPor == null ? null : new UsuarioResumoDto
        {
            Id = chamado.FechadoPor.Id,
            NomeCompleto = chamado.FechadoPor.NomeCompleto,
            Email = chamado.FechadoPor.Email,
            TipoUsuario = chamado.FechadoPor.TipoUsuario
        },
        
        DataFechamento = chamado.DataFechamento,
        
        // ... outros campos ...
    };
}
```

## Como Funciona

### Cenário 1: Fechamento via UpdateChamado

1. Cliente chama `PUT /api/Chamados/{id}` com `StatusId = 5`
2. Controller detecta mudança de status para "Fechado"
3. Sistema registra automaticamente:
   - `DataFechamento = DateTime.UtcNow`
   - `FechadoPorId = userId` (extraído do JWT)
4. Salva no banco de dados
5. Retorna o DTO completo com informações de `FechadoPor`

### Cenário 2: Fechamento via FecharChamado

1. Cliente chama `POST /api/Chamados/{id}/fechar`
2. Controller valida permissões
3. Sistema registra:
   - `StatusId = 5`
   - `DataFechamento = DateTime.UtcNow`
   - `FechadoPorId = usuarioAutenticadoId`
4. Salva no banco de dados
5. Retorna o DTO completo com informações de `FechadoPor`

### Cenário 3: Reabertura de Chamado

1. Cliente chama `PUT /api/Chamados/{id}` com `StatusId != 5`
2. Controller detecta que não é mais status "Fechado"
3. Sistema limpa:
   - `DataFechamento = null`
   - `FechadoPorId = null`
4. Salva no banco de dados
5. Permite novo fechamento com rastreamento correto

## Exemplo de Resposta da API

```json
{
  "id": 123,
  "titulo": "Problema com impressora",
  "descricao": "Impressora não está funcionando",
  "dataAbertura": "2025-01-10T14:30:00Z",
  "dataFechamento": "2025-01-10T16:45:00Z",
  "status": {
    "id": 5,
    "nome": "Fechado",
    "descricao": "Chamado resolvido e encerrado"
  },
  "solicitante": {
    "id": 10,
    "nomeCompleto": "João Silva",
    "email": "joao@empresa.com",
    "tipoUsuario": 1
  },
  "tecnico": {
    "id": 25,
    "nomeCompleto": "Maria Santos",
    "email": "maria@empresa.com",
    "tipoUsuario": 2
  },
  "fechadoPor": {
    "id": 25,
    "nomeCompleto": "Maria Santos",
    "email": "maria@empresa.com",
    "tipoUsuario": 2
  },
  "categoria": { ... },
  "prioridade": { ... }
}
```

## Status do Chamado

O sistema utiliza os seguintes IDs de status:

- **1** = Aberto
- **2** = Em Andamento
- **3** = Aguardando Resposta
- **5** = Fechado ⭐ (trigger para rastreamento)
- **8** = Violado (SLA expirado)

## Consulta SQL para Auditoria

```sql
-- Visualizar todos os chamados fechados com informações de fechamento
SELECT 
    c.Id AS ChamadoId,
    c.Titulo,
    c.DataAbertura,
    c.DataFechamento,
    s.Nome AS Status,
    solicitante.NomeCompleto AS Solicitante,
    tecnico.NomeCompleto AS Tecnico,
    fechadoPor.NomeCompleto AS FechadoPor
FROM Chamados c
INNER JOIN Status s ON c.StatusId = s.Id
INNER JOIN Usuarios solicitante ON c.SolicitanteId = solicitante.Id
LEFT JOIN Usuarios tecnico ON c.TecnicoId = tecnico.Id
LEFT JOIN Usuarios fechadoPor ON c.FechadoPorId = fechadoPor.Id
WHERE c.StatusId = 5
ORDER BY c.DataFechamento DESC;
```

## Integração com Mobile App

### Exibição no App Mobile

**Arquivo a ser atualizado:** `Views/ChamadoDetailPage.xaml`

```xml
<!-- Seção de Fechamento (exibir apenas se chamado estiver fechado) -->
<StackLayout IsVisible="{Binding FechadoPor, Converter={StaticResource IsNotNullConverter}}">
    <Label Text="Informações de Fechamento" 
           FontSize="16" 
           FontAttributes="Bold" 
           Margin="0,10,0,5" />
    
    <Grid ColumnDefinitions="Auto,*" RowDefinitions="Auto,Auto" ColumnSpacing="10" RowSpacing="5">
        <!-- Fechado Por -->
        <Label Grid.Row="0" Grid.Column="0" Text="Fechado por:" />
        <Label Grid.Row="0" Grid.Column="1" 
               Text="{Binding FechadoPor.NomeCompleto}" 
               FontAttributes="Bold" />
        
        <!-- Data de Fechamento -->
        <Label Grid.Row="1" Grid.Column="0" Text="Data:" />
        <Label Grid.Row="1" Grid.Column="1" 
               Text="{Binding DataFechamento, Converter={StaticResource UtcToLocalDateTimeConverter}}" 
               FontAttributes="Bold" />
    </Grid>
</StackLayout>
```

### ViewModel

O `ChamadoDetailViewModel` ou similar já deve receber o objeto `ChamadoDto` com a propriedade `FechadoPor` preenchida automaticamente pela API.

## Benefícios

✅ **Transparência**: Usuários sabem exatamente quem fechou seus chamados  
✅ **Accountability**: Técnicos e administradores são responsáveis por suas ações  
✅ **Auditoria**: Histórico completo de fechamento para compliance e análise  
✅ **Rastreabilidade**: Possibilidade de análises de desempenho por técnico  
✅ **Reversível**: Se um chamado for reaberto, os campos são limpos para novo rastreamento  

## Notas Técnicas

- O campo `FechadoPorId` é **nullable** porque chamados antigos não terão essa informação
- O `DeleteBehavior.Restrict` impede que um usuário seja deletado se ele fechou algum chamado
- A detecção é baseada na mudança de status: `chamado.StatusId != 5 && request.StatusId == 5`
- O sistema captura o `NameIdentifier` do JWT token automaticamente
- Funciona tanto via `UpdateChamado` quanto via `FecharChamado` endpoint

## Testes Sugeridos

### Teste 1: Fechamento Manual
1. Login como técnico
2. Atualizar chamado para StatusId = 5
3. Verificar que FechadoPorId = ID do técnico logado
4. Confirmar DataFechamento preenchida

### Teste 2: Reabertura
1. Reabrir chamado (StatusId != 5)
2. Verificar que FechadoPorId = NULL
3. Verificar que DataFechamento = NULL

### Teste 3: Endpoint Dedicado
1. Chamar POST /api/Chamados/{id}/fechar
2. Verificar que FechadoPorId é preenchido corretamente
3. Confirmar StatusId = 5

### Teste 4: API Response
1. GET /api/Chamados (listar chamados)
2. Verificar que chamados fechados incluem objeto `FechadoPor`
3. GET /api/Chamados/{id} (detalhe)
4. Confirmar presença de `FechadoPor.NomeCompleto`

## Data de Implementação

**Data:** 04/11/2025  
**Migration:** 20251104184208_AdicionarFechadoPorChamado  
**Status:** ✅ Implementado e testado

---

**Desenvolvido para:** Sistema de Chamados NeuroHelp  
**Versão:** 1.0  
