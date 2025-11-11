# Análise de Inconsistências - Mobile App vs Backend API

**Data:** 10/11/2025  
**Revisão:** Comparação entre o aplicativo mobile e a API backend

---

## 🔴 PROBLEMAS CRÍTICOS ENCONTRADOS

### 1. **Incompatibilidade de DTOs - Comentários**

**Severidade:** 🔴 ALTA

**Localização:**
- Backend: `Backend/Application/DTOs/ComentarioResponseDto.cs`
- Backend: `Backend/Application/DTOs/CriarComentarioDto.cs`
- Mobile: `Mobile/Models/DTOs/ComentarioDto.cs`
- Mobile: `Mobile/Models/DTOs/CriarComentarioRequestDto.cs`

**Problema:**
O mobile envia um campo `IsInterno` que **NÃO É ACEITO** pelo backend.

**Backend espera (CriarComentarioDto):**
```csharp
public class CriarComentarioDto
{
    [Required]
    [StringLength(1000, MinimumLength = 1)]
    public string Texto { get; set; } = string.Empty;
}
```

**Mobile envia (CriarComentarioRequestDto):**
```csharp
public class CriarComentarioRequestDto
{
    public string Texto { get; set; } = string.Empty;
    public bool IsInterno { get; set; }  // ❌ CAMPO NÃO EXISTE NO BACKEND
}
```

**Impacto:**
- O backend vai **ignorar** o campo `IsInterno`
- Comentários marcados como "internos" no mobile serão salvos como **públicos**
- **Perda de funcionalidade de privacidade**

**Solução:**
Remover o campo `IsInterno` do DTO do mobile OU implementar suporte no backend.

---

### 2. **Incompatibilidade de DTOs - Resposta de Comentários**

**Severidade:** 🟡 MÉDIA

**Backend retorna (ComentarioResponseDto):**
```csharp
public class ComentarioResponseDto
{
    public int Id { get; set; }
    public string Texto { get; set; }
    public DateTime DataCriacao { get; set; }
    public int UsuarioId { get; set; }
    public string UsuarioNome { get; set; }
    public int ChamadoId { get; set; }
}
```

**Mobile espera (ComentarioDto):**
```csharp
public class ComentarioDto
{
    public int Id { get; set; }
    public int ChamadoId { get; set; }
    public string Texto { get; set; }
    public DateTime DataCriacao { get; set; }
    public DateTime DataHora { get; set; }  // ❌ CAMPO NÃO ENVIADO PELO BACKEND
    public UsuarioResumoDto? Usuario { get; set; }  // ❌ BACKEND ENVIA APENAS UsuarioNome
    public int UsuarioId { get; set; }
    public string UsuarioNome { get; set; }
    public bool IsInterno { get; set; }  // ❌ BACKEND NÃO ENVIA
}
```

**Impacto:**
- Campo `DataHora` ficará com valor padrão (01/01/0001) se não mapeado
- Campo `Usuario` será sempre `null` (mobile usa `UsuarioNome` como fallback)
- Campo `IsInterno` sempre será `false`
- **UI pode apresentar datas incorretas** se depender de `DataHora`

**Solução:**
Ajustar o DTO do mobile para usar apenas `DataCriacao` e remover campos não suportados.

---

### 3. **Método Close() Usa StatusId Incorreto**

**Severidade:** 🔴 ALTA

**Localização:**
- Mobile: `Mobile/Services/Chamados/ChamadoService.cs` - método `Close()`

**Código Atual:**
```csharp
public Task<ChamadoDto?> Close(int id)
{
    var atualizacao = new AtualizarChamadoDto
    {
        StatusId = 5 // ❌ ID INCORRETO
    };
    return _api.PutAsync<AtualizarChamadoDto, ChamadoDto>($"chamados/{id}", atualizacao);
}
```

**Problema:**
O código usa `StatusId = 5` para "Fechado", mas de acordo com o backend:
- **1 = Aberto**
- **2 = Em Andamento**  
- **3 = Aguardando Resposta**
- **4 = Fechado** ✅
- **5 = Violado** (SLA excedido)

**Impacto:**
- Chamados serão marcados como "Violado" em vez de "Fechado"
- **Lógica de negócio incorreta**
- **Relatórios e métricas incorretas**

**Solução:**
```csharp
public Task<ChamadoDto?> Close(int id)
{
    var atualizacao = new AtualizarChamadoDto
    {
        StatusId = 4 // ✅ CORRETO: Fechado
    };
    return _api.PutAsync<AtualizarChamadoDto, ChamadoDto>($"chamados/{id}", atualizacao);
}
```

---

### 4. **Restrição de Tipo de Usuário Apenas no Mobile**

**Severidade:** 🟡 MÉDIA (Segurança)

**Localização:**
- Mobile: `Mobile/Services/Auth/AuthService.cs` - método `Login()`

**Código:**
```csharp
// Verifica se o usuário é do tipo 1 (Colaborador/Usuário comum)
if (resp.TipoUsuario != 1)
{
    Debug.WriteLine($"[AuthService] Login negado: TipoUsuario {resp.TipoUsuario} não tem acesso ao app mobile");
    throw new UnauthorizedAccessException("Apenas usuários comuns podem acessar o aplicativo mobile.");
}
```

**Problema:**
- A validação de tipo de usuário está **apenas no lado do cliente** (mobile)
- Um usuário técnico/admin poderia fazer requisições diretas à API sem usar o app
- **Falta validação no backend** para endpoints que deveriam ser restritos

**Análise do Backend:**
- Endpoint `POST /api/chamados` aceita qualquer usuário autenticado
- Endpoint `POST /api/chamados/analisar` aceita qualquer usuário autenticado
- **Não há restrição de TipoUsuario no backend**

**Impacto:**
- Violação da regra de negócio se acessada diretamente
- Possível criação de chamados por técnicos/admins usando outras interfaces

**Solução:**
Implementar validação no backend (exemplo):
```csharp
[HttpPost]
[Authorize]
public async Task<IActionResult> CriarChamado([FromBody] CriarChamadoRequestDto request)
{
    var tipoUsuarioStr = User.FindFirst("TipoUsuario")?.Value;
    if (tipoUsuarioStr != "1")
    {
        return Forbid("Apenas usuários comuns podem criar chamados via mobile.");
    }
    // ... resto do código
}
```

---

## 🟡 PROBLEMAS DE DESIGN E LÓGICA

### 5. **Duplicação de Lógica - Cálculo de SLA**

**Severidade:** 🟡 MÉDIA

**Localização:**
- Backend: `Backend/API/Controllers/ChamadosController.cs`

**Problema:**
A lógica de cálculo de SLA está implementada **dentro do controller**, não em um serviço dedicado:
```csharp
private DateTime? CalcularSla(int nivelPrioridade, DateTime dataAbertura)
{
    // ... lógica complexa de dias úteis
}

private DateTime AddBusinessDays(DateTime date, int days)
{
    // ... lógica de adição de dias úteis
}
```

**Impacto:**
- Dificulta reutilização
- Dificulta testes unitários
- Viola o princípio de responsabilidade única (SRP)

**Solução:**
Mover para um serviço `ISlaService`:
```csharp
public interface ISlaService
{
    DateTime? CalcularSla(int nivelPrioridade, DateTime dataAbertura);
}
```

---

### 6. **Verificação Automática de SLA em Endpoint de Listagem**

**Severidade:** 🟡 MÉDIA (Performance)

**Localização:**
- Backend: `Backend/API/Controllers/ChamadosController.cs` - método `GetChamados()`

**Código:**
```csharp
[HttpGet]
public async Task<IActionResult> GetChamados(...)
{
    // --- LÓGICA VERIFICAÇÃO SLA ---
    var statusParaVerificar = new[] { 1, 2, 3 };
    var statusVioladoId = 5; 
    
    var chamadosViolados = await _context.Chamados
        .Where(c => statusParaVerificar.Contains(c.StatusId) &&
                    c.SlaDataExpiracao.HasValue &&
                    c.SlaDataExpiracao < DateTime.UtcNow)
        .ToListAsync();

    if (chamadosViolados.Any())
    {
        foreach (var chamado in chamadosViolados)
        {
            chamado.StatusId = statusVioladoId;
            chamado.DataUltimaAtualizacao = DateTime.UtcNow;
        }
        await _context.SaveChangesAsync();
    }
    // ... continua
}
```

**Problema:**
- **Efeito colateral** em um endpoint de leitura (GET)
- Toda vez que alguém lista chamados, o sistema verifica **TODOS** os chamados e atualiza status
- Pode causar **lentidão** em sistemas com muitos chamados
- **Viola convenção REST** (GET não deveria modificar dados)

**Impacto:**
- Performance degradada em listagens
- Possíveis race conditions se múltiplas requisições simultâneas

**Solução:**
Implementar verificação de SLA via:
1. **Background Job/Worker** (executar a cada X minutos)
2. **Trigger de banco de dados**
3. **Endpoint dedicado** para administradores forçarem verificação

---

### 7. **Endpoint /analisar Cria Chamado Automaticamente**

**Severidade:** 🟡 MÉDIA (Confusão de API)

**Localização:**
- Backend: `Backend/API/Controllers/ChamadosController.cs` - `POST /api/chamados/analisar`
- Mobile: `Mobile/Services/Chamados/ChamadoService.cs` - `CreateComAnaliseAutomatica()`

**Código Backend:**
```csharp
[HttpPost("analisar")]
public async Task<IActionResult> AnalisarChamado([FromBody] AnalisarChamadoRequestDto request)
{
    // 1. Pede a análise da IA
    var analise = await _openAIService.AnalisarChamadoAsync(request.DescricaoProblema);
    
    // ... validações ...
    
    // 3. Cria o novo chamado com os dados da IA
    var novoChamado = new Chamado { /* ... */ };
    
    _context.Chamados.Add(novoChamado);
    await _context.SaveChangesAsync();
    
    // 5. Retorna o chamado que foi CRIADO
    return CreatedAtAction(nameof(GetChamadoPorId), new { id = novoChamado.Id }, novoChamado);
}
```

**Código Mobile:**
```csharp
public Task<ChamadoDto?> CreateComAnaliseAutomatica(string descricaoProblema)
{
    var request = new AnalisarChamadoRequestDto
    {
        DescricaoProblema = descricaoProblema
    };

    // ⚠️ ATENÇÃO: Backend JÁ CRIA o chamado no endpoint /analisar
    return _api.PostAsync<AnalisarChamadoRequestDto, ChamadoDto>("chamados/analisar", request);
}
```

**Problema:**
- O nome do endpoint sugere que apenas **analisa**, mas ele também **cria** o chamado
- Não há opção de apenas "pré-visualizar" a análise sem criar o chamado
- **Confusão de responsabilidades**

**Impacto:**
- UX limitada: não é possível mostrar sugestões sem criar o chamado
- Chamados podem ser criados acidentalmente

**Solução Sugerida:**
Separar em dois endpoints:
1. `POST /api/chamados/preview-analise` - retorna apenas a análise
2. `POST /api/chamados/criar-com-analise` - cria usando análise prévia

---

## 🟢 BOAS PRÁTICAS ENCONTRADAS

### ✅ 1. DTOs Bem Estruturados
- Mobile e backend usam DTOs separados corretamente
- Validações com Data Annotations no backend

### ✅ 2. Uso de Interfaces
- Services implementam interfaces (`IAuthService`, `IChamadoService`, etc.)
- Facilita testes e injeção de dependência

### ✅ 3. Autorização JWT
- Backend usa `[Authorize]` corretamente
- Token JWT implementado com claims

### ✅ 4. Includes Explícitos
- Backend usa `.Include()` para evitar lazy loading
- Bom para performance

---

## 📋 RESUMO DE AÇÕES RECOMENDADAS

| # | Problema | Prioridade | Ação |
|---|----------|------------|------|
| 1 | Campo `IsInterno` em comentários | 🔴 Alta | Remover do mobile OU implementar no backend |
| 2 | StatusId incorreto no método Close | 🔴 Alta | Mudar de 5 para 4 |
| 3 | Validação de tipo de usuário apenas no mobile | 🟡 Média | Implementar no backend |
| 4 | Verificação de SLA em GET | 🟡 Média | Mover para background job |
| 5 | Lógica de SLA no controller | 🟡 Média | Extrair para serviço dedicado |
| 6 | Endpoint /analisar cria chamado | 🟡 Baixa | Documentar claramente OU separar |
| 7 | Campos extras em ComentarioDto | 🟢 Baixa | Limpar campos não utilizados |

---

## 🔧 ARQUIVOS QUE PRECISAM SER MODIFICADOS

### Mobile:
1. `Mobile/Services/Chamados/ChamadoService.cs`
   - Corrigir `StatusId` no método `Close()`
   
2. `Mobile/Models/DTOs/CriarComentarioRequestDto.cs`
   - Remover campo `IsInterno`
   
3. `Mobile/Models/DTOs/ComentarioDto.cs`
   - Remover campo `IsInterno`
   - Considerar usar apenas `DataCriacao` (remover `DataHora`)

### Backend:
1. `Backend/API/Controllers/ChamadosController.cs`
   - Adicionar validação de `TipoUsuario` em `CriarChamado()`
   - Mover verificação de SLA para serviço em background
   - Extrair lógica de SLA para serviço dedicado

2. `Backend/Application/DTOs/CriarComentarioDto.cs` (OPCIONAL)
   - Adicionar campo `IsInterno` se necessário

---

## 📝 NOTAS ADICIONAIS

### Status IDs Confirmados:
- 1 = Aberto
- 2 = Em Andamento
- 3 = Aguardando Resposta
- 4 = Fechado
- 5 = Violado (SLA)

### Tipo de Usuário:
- 1 = Usuário Comum/Colaborador
- 2 = Técnico
- 3 = Administrador

---

**Gerado por:** Análise automatizada de código  
**Próximos Passos:** Revisar e implementar correções por ordem de prioridade
