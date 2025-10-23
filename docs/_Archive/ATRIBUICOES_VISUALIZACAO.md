# 🔍 Atribuições de Visualização de Chamados

## 📋 Regras de Visualização por Tipo de Usuário

Este documento define quais chamados cada tipo de usuário pode visualizar no sistema.

---

## 1️⃣ ALUNO (TipoUsuario = 1)

### Regra Geral
**Visualiza APENAS seus próprios chamados**

### Detalhamento
- ✅ Pode ver chamados onde `CriadorId = [ID do próprio aluno]`
- ❌ **NÃO** pode ver chamados de outros alunos
- ❌ **NÃO** pode ver chamados de professores
- ❌ **NÃO** pode ver lista global de chamados

### Todas as Categorias Disponíveis
O aluno pode criar chamados em **todas as 10 categorias**:

| ID | Categoria | Descrição | Pode Criar | Pode Visualizar |
|----|-----------|-----------|------------|-----------------|
| 1 | Hardware | Problemas com equipamentos, computadores, impressoras | ✅ | ✅ (apenas seus) |
| 2 | Software | Instalação e problemas com programas | ✅ | ✅ (apenas seus) |
| 3 | Rede | Conectividade, internet, Wi-Fi | ✅ | ✅ (apenas seus) |
| 4 | Sistema | Problemas com sistemas acadêmicos | ✅ | ✅ (apenas seus) |
| 5 | Email | Problemas com e-mail institucional | ✅ | ✅ (apenas seus) |
| 6 | Laboratório | Questões relacionadas aos laboratórios | ✅ | ✅ (apenas seus) |
| 7 | Biblioteca | Sistema de biblioteca e acervo | ✅ | ✅ (apenas seus) |
| 8 | Matrícula | Problemas com matrícula e rematrícula | ✅ | ✅ (apenas seus) |
| 9 | Nota/Frequência | Questões sobre notas e frequência | ✅ | ✅ (apenas seus) |
| 10 | Outros | Outras solicitações | ✅ | ✅ (apenas seus) |

### Query SQL Recomendada
```sql
SELECT * FROM Chamados 
WHERE CriadorId = @UsuarioId
ORDER BY DataCriacao DESC
```

---

## 2️⃣ PROFESSOR (TipoUsuario = 2)

### Regra Geral
**Visualiza seus próprios chamados + chamados onde foi atribuído como técnico**

### Detalhamento
- ✅ Pode ver chamados onde `CriadorId = [ID do próprio professor]`
- ✅ Pode ver chamados onde `TecnicoId = [ID do próprio professor]`
- ✅ Pode ver chamados da sua especialidade quando atribuído
- ❌ **NÃO** pode ver chamados de outras categorias se não for o técnico
- ❌ **NÃO** pode ver chamados de outros professores (a menos que seja técnico)
- ❌ **NÃO** pode ver lista global de chamados

### Especialidades por Categoria

#### Professor Atual: Maria Santos
- **Especialidade:** Hardware (CategoriaId = 1)
- **Pode ser técnico em:** Chamados de Hardware

### Matriz de Visualização por Categoria

| ID | Categoria | Como Criador | Como Técnico | Observação |
|----|-----------|--------------|--------------|------------|
| 1 | Hardware | ✅ Seus próprios | ✅ Se atribuído | Categoria da especialidade |
| 2 | Software | ✅ Seus próprios | ✅ Se atribuído | Fora da especialidade |
| 3 | Rede | ✅ Seus próprios | ✅ Se atribuído | Fora da especialidade |
| 4 | Sistema | ✅ Seus próprios | ✅ Se atribuído | Fora da especialidade |
| 5 | Email | ✅ Seus próprios | ✅ Se atribuído | Fora da especialidade |
| 6 | Laboratório | ✅ Seus próprios | ✅ Se atribuído | Fora da especialidade |
| 7 | Biblioteca | ✅ Seus próprios | ✅ Se atribuído | Fora da especialidade |
| 8 | Matrícula | ✅ Seus próprios | ✅ Se atribuído | Fora da especialidade |
| 9 | Nota/Frequência | ✅ Seus próprios | ✅ Se atribuído | Fora da especialidade |
| 10 | Outros | ✅ Seus próprios | ✅ Se atribuído | Fora da especialidade |

### Query SQL Recomendada
```sql
SELECT * FROM Chamados 
WHERE CriadorId = @UsuarioId 
   OR TecnicoId = @UsuarioId
ORDER BY DataCriacao DESC
```

### Recomendação de Atribuição Inteligente
Quando um admin atribuir um técnico, o sistema deveria:
1. Priorizar professores com `EspecialidadeCategoriaId` correspondente
2. Mostrar apenas professores qualificados para aquela categoria

---

## 3️⃣ ADMINISTRADOR (TipoUsuario = 3)

### Regra Geral
**Visualiza TODOS os chamados do sistema sem restrições**

### Detalhamento
- ✅ Pode ver **todos** os chamados de todas as categorias
- ✅ Pode ver chamados de alunos
- ✅ Pode ver chamados de professores
- ✅ Pode ver chamados de outros administradores
- ✅ Pode filtrar por categoria, status, prioridade
- ✅ Pode ver chamados encerrados e abertos
- ✅ Acesso total ao histórico

### Todas as Categorias
| ID | Categoria | Visualização |
|----|-----------|--------------|
| 1 | Hardware | ✅ Todos |
| 2 | Software | ✅ Todos |
| 3 | Rede | ✅ Todos |
| 4 | Sistema | ✅ Todos |
| 5 | Email | ✅ Todos |
| 6 | Laboratório | ✅ Todos |
| 7 | Biblioteca | ✅ Todos |
| 8 | Matrícula | ✅ Todos |
| 9 | Nota/Frequência | ✅ Todos |
| 10 | Outros | ✅ Todos |

### Query SQL Recomendada
```sql
-- Sem filtros - vê tudo
SELECT * FROM Chamados 
ORDER BY DataCriacao DESC

-- Com filtros opcionais
SELECT * FROM Chamados 
WHERE (@CategoriaId IS NULL OR CategoriaId = @CategoriaId)
  AND (@StatusId IS NULL OR StatusId = @StatusId)
  AND (@PrioriadadeId IS NULL OR PrioridadeId = @PrioridadeId)
ORDER BY DataCriacao DESC
```

---

## 📊 Resumo Comparativo

| Aspecto | Aluno | Professor | Admin |
|---------|-------|-----------|-------|
| **Próprios chamados** | ✅ Sim | ✅ Sim | ✅ Sim |
| **Chamados como técnico** | ❌ Não | ✅ Sim | ✅ Sim |
| **Todos os chamados** | ❌ Não | ❌ Não | ✅ Sim |
| **Filtro por categoria** | ❌ N/A | ⚠️ Limitado | ✅ Total |
| **Filtro por técnico** | ❌ N/A | ⚠️ Próprio | ✅ Qualquer |
| **Chamados de outros** | ❌ Não | ⚠️ Se técnico | ✅ Sim |

---

## 🔧 Implementação Recomendada

### No Controller da API

```csharp
[HttpGet]
[Authorize]
public async Task<ActionResult<IEnumerable<ChamadoDto>>> GetChamados()
{
    var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value);
    var tipoUsuario = int.Parse(User.FindFirst("TipoUsuario")?.Value);
    
    IQueryable<Chamado> query = _context.Chamados
        .Include(c => c.Categoria)
        .Include(c => c.Prioridade)
        .Include(c => c.Status)
        .Include(c => c.Criador)
        .Include(c => c.Tecnico);
    
    // Aplicar filtro baseado no tipo de usuário
    switch (tipoUsuario)
    {
        case 1: // Aluno
            query = query.Where(c => c.CriadorId == userId);
            break;
            
        case 2: // Professor
            query = query.Where(c => c.CriadorId == userId || c.TecnicoId == userId);
            break;
            
        case 3: // Admin
            // Sem filtro - vê tudo
            break;
            
        default:
            return Forbid();
    }
    
    var chamados = await query
        .OrderByDescending(c => c.DataCriacao)
        .ToListAsync();
    
    return Ok(MapToDtoList(chamados));
}
```

### No Mobile (ViewModel)

```csharp
public async Task LoadChamadosAsync()
{
    // A API já retorna apenas os chamados que o usuário pode ver
    // baseado no token JWT (que contém TipoUsuario)
    var chamados = await _chamadoService.GetAllAsync();
    
    // Não precisa filtrar novamente - confie na API
    Chamados = new ObservableCollection<ChamadoDto>(chamados);
}
```

---

## 🎯 Cenários de Teste

### Cenário 1: Aluno cria chamado
1. Aluno cria chamado de Hardware
2. Aluno vê apenas esse chamado na lista
3. Outros alunos **NÃO** veem este chamado

### Cenário 2: Professor como técnico
1. Admin atribui professor como técnico em chamado de Hardware
2. Professor vê o chamado (mesmo não sendo o criador)
3. Professor vê seus próprios chamados + chamados onde é técnico

### Cenário 3: Admin visualização global
1. Admin acessa lista de chamados
2. Vê todos os chamados de todos os usuários
3. Pode filtrar por qualquer critério

### Cenário 4: Professor sem atribuição
1. Professor cria chamado de Software
2. Professor vê apenas seu chamado
3. Enquanto não for atribuído como técnico em outros, vê só os seus

---

## 🚨 Regras de Segurança

### ⚠️ CRÍTICO
1. **NUNCA** retornar chamados que o usuário não deve ver
2. **SEMPRE** filtrar no backend (API), não confiar no frontend
3. **VALIDAR** TipoUsuario em cada request
4. **INCLUIR** validações em todos os endpoints:
   - GET /api/chamados
   - GET /api/chamados/{id}
   - PUT /api/chamados/{id}
   - POST /api/chamados/{id}/fechar

### Exemplo de Validação no GET por ID
```csharp
[HttpGet("{id}")]
[Authorize]
public async Task<ActionResult<ChamadoDto>> GetChamado(int id)
{
    var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value);
    var tipoUsuario = int.Parse(User.FindFirst("TipoUsuario")?.Value);
    
    var chamado = await _context.Chamados
        .Include(c => c.Categoria)
        .Include(c => c.Prioridade)
        .Include(c => c.Status)
        .Include(c => c.Criador)
        .Include(c => c.Tecnico)
        .FirstOrDefaultAsync(c => c.Id == id);
    
    if (chamado == null)
        return NotFound();
    
    // Validar permissão
    bool temPermissao = tipoUsuario switch
    {
        1 => chamado.CriadorId == userId, // Aluno: só seus próprios
        2 => chamado.CriadorId == userId || chamado.TecnicoId == userId, // Professor
        3 => true, // Admin: todos
        _ => false
    };
    
    if (!temPermissao)
        return Forbid(); // HTTP 403
    
    return Ok(MapToDto(chamado));
}
```

---

## 📚 Categorias - Referência Completa

| ID | Nome | Descrição Completa | Exemplos de Chamados |
|----|------|-------------------|---------------------|
| 1 | Hardware | Problemas com equipamentos, computadores, impressoras | Mouse quebrado, teclado não funciona, impressora sem papel |
| 2 | Software | Instalação e problemas com programas | Instalar Office, erro no Visual Studio, licença expirada |
| 3 | Rede | Conectividade, internet, Wi-Fi | Sem internet, Wi-Fi lento, não conecta na rede |
| 4 | Sistema | Problemas com sistemas acadêmicos | Portal do aluno fora do ar, erro ao acessar notas |
| 5 | Email | Problemas com e-mail institucional | Não recebe emails, esqueci senha, caixa cheia |
| 6 | Laboratório | Questões relacionadas aos laboratórios | Computador do lab 3 travado, software desatualizado |
| 7 | Biblioteca | Sistema de biblioteca e acervo | Livro não aparece no sistema, renovação de empréstimo |
| 8 | Matrícula | Problemas com matrícula e rematrícula | Não consigo me matricular, erro na grade |
| 9 | Nota/Frequência | Questões sobre notas e frequência | Nota incorreta, falta não lançada |
| 10 | Outros | Outras solicitações | Solicitações gerais que não se encaixam nas anteriores |

---

**Última atualização:** 17/10/2025  
**Status:** 📋 Documento de especificação - Aguardando implementação
