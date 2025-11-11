# ANÁLISE COMPLETA: BANCO DE DADOS E API

**Data da Análise:** 10 de Novembro de 2025  
**Status:** Reestruturação em andamento - Fase de correção de incompatibilidades

---

## 📊 RESUMO EXECUTIVO

### Situação Atual
O sistema passou por uma **reestruturação completa do banco de dados** baseada em auditoria de todos os clientes (Mobile, Desktop, Web). As entidades foram recriadas com um esquema simplificado e otimizado, mas os **Controllers e Services ainda referenciam campos antigos** que foram removidos.

### Crítico
- ✅ **Entidades:** 7 entidades criadas corretamente (sem duplicação)
- ✅ **ApplicationDbContext:** Configurado com Fluent API completa
- ❌ **Compilação:** 32 erros - Controllers usam campos removidos
- 🔄 **Migrations:** Pasta vazia - aguardando correção dos erros
- ⏳ **Database:** Ainda com schema antigo (não dropado)

---

## 🗃️ ARQUITETURA DO BANCO DE DADOS

### Esquema Novo (7 Entidades)

#### 1. **Usuario** (Tabela Principal de Autenticação)
```csharp
public class Usuario
{
    public int Id { get; set; }
    public string NomeCompleto { get; set; }      // Max: 150
    public string Email { get; set; }             // Max: 150, Unique Index
    public string SenhaHash { get; set; }         // Max: 255
    public int TipoUsuario { get; set; }          // 1=Solicitante, 2=Técnico, 3=Admin
    
    // NOVOS CAMPOS (não existiam antes)
    public bool IsInterno { get; set; } = true;   // Aluno=true, Professor=false
    public string? Especialidade { get; set; }    // Max: 100, ex: "Redes", "Hardware"
    public int? EspecialidadeCategoriaId { get; set; } // FK para Categoria preferencial
    
    public DateTime DataCadastro { get; set; } = DateTime.UtcNow;
    
    // Navegação
    public virtual Categoria? EspecialidadeCategoria { get; set; }
    public virtual ICollection<Chamado> ChamadosSolicitados { get; set; }
    public virtual ICollection<Chamado> ChamadosAtribuidos { get; set; }
    public virtual ICollection<Comentario> Comentarios { get; set; }
}
```

**Campos REMOVIDOS:**
- ❌ `Ativo` (bool) - usado em 10 lugares nos controllers
- ❌ `PasswordResetToken` (string?) - usado em 2 lugares
- ❌ `ResetTokenExpires` (DateTime?) - usado em 1 lugar

**Relacionamentos:**
- `1:N` → Chamados (como Solicitante)
- `1:N` → Chamados (como Técnico atribuído)
- `1:N` → Comentários
- `N:1` → Categoria (especialidade - pode ser NULL)

---

#### 2. **Chamado** (Tickets de Suporte)
```csharp
public class Chamado
{
    public int Id { get; set; }
    public string Titulo { get; set; }            // Max: 200
    public string Descricao { get; set; }         // Sem limite
    
    public DateTime DataAbertura { get; set; } = DateTime.UtcNow;
    public DateTime? DataFechamento { get; set; }
    public DateTime? DataUltimaAtualizacao { get; set; }
    public DateTime? SlaDataExpiracao { get; set; }
    
    // FKs
    public int SolicitanteId { get; set; }
    public int? TecnicoId { get; set; }           // Nullable - pode estar não atribuído
    public int CategoriaId { get; set; }
    public int PrioridadeId { get; set; }
    public int StatusId { get; set; }
    
    // Navegação
    public virtual Usuario Solicitante { get; set; }
    public virtual Usuario? Tecnico { get; set; }
    public virtual Categoria Categoria { get; set; }
    public virtual Prioridade Prioridade { get; set; }
    public virtual Status Status { get; set; }
    public virtual ICollection<Comentario> Comentarios { get; set; }
    public virtual ICollection<Anexo> Anexos { get; set; }
}
```

**Delete Behavior:**
- Solicitante: **Restrict** (não pode deletar usuário com chamados)
- Tecnico: **Restrict**
- Categoria: **Restrict**
- Prioridade: **Restrict**
- Status: **Restrict**

---

#### 3. **Categoria** (Tabela Lookup)
```csharp
public class Categoria
{
    public int Id { get; set; }
    public string Nome { get; set; }              // Max: 100
    public DateTime DataCadastro { get; set; } = DateTime.UtcNow;
    
    // Navegação
    public virtual ICollection<Chamado> Chamados { get; set; }
    public virtual ICollection<Usuario> TecnicosEspecializados { get; set; }
}
```

**Campos REMOVIDOS:**
- ❌ `Descricao` (string?) - usado em 3 lugares
- ❌ `Ativo` (bool) - usado em 3 lugares

**Dados Seed Esperados:**
1. Hardware
2. Software
3. Redes
4. Infraestrutura

---

#### 4. **Prioridade** (Tabela Lookup)
```csharp
public class Prioridade
{
    public int Id { get; set; }                   // 1=Baixa, 2=Média, 3=Alta, 4=Crítica
    public string Nome { get; set; }              // Max: 50
    public int TempoRespostaHoras { get; set; }   // SLA em horas
    public DateTime DataCadastro { get; set; } = DateTime.UtcNow;
    
    // Navegação
    public virtual ICollection<Chamado> Chamados { get; set; }
}
```

**Campos REMOVIDOS:**
- ❌ `Nivel` (int) - usado em 2 lugares (conflito com Id)
- ❌ `Descricao` (string?) - usado em 1 lugar
- ❌ `Ativo` (bool) - usado em 4 lugares

**Dados Seed Esperados:**
1. Baixa (TempoRespostaHoras: 72)
2. Média (TempoRespostaHoras: 48)
3. Alta (TempoRespostaHoras: 24)
4. Crítica (TempoRespostaHoras: 4)

---

#### 5. **Status** (Tabela Lookup)
```csharp
public class Status
{
    public int Id { get; set; }                   // 1=Aberto, 2=Em Andamento, 3=Aguardando, 4=Resolvido, 5=Fechado
    public string Nome { get; set; }              // Max: 50
    public DateTime DataCadastro { get; set; } = DateTime.UtcNow;
    
    // Navegação
    public virtual ICollection<Chamado> Chamados { get; set; }
}
```

**Campos REMOVIDOS:**
- ❌ `Descricao` (string?) - usado em 1 lugar
- ❌ `Ativo` (bool) - usado em 2 lugares

**Dados Seed Esperados:**
1. Aberto
2. Em Andamento
3. Aguardando Cliente
4. Resolvido
5. Fechado

---

#### 6. **Comentario** (Histórico de Chamados)
```csharp
public class Comentario
{
    public int Id { get; set; }
    public string Texto { get; set; }             // Sem limite
    public DateTime DataCriacao { get; set; } = DateTime.UtcNow;
    public bool IsInterno { get; set; }           // Default: false
    
    // FKs
    public int ChamadoId { get; set; }
    public int UsuarioId { get; set; }
    
    // Navegação
    public virtual Chamado Chamado { get; set; }
    public virtual Usuario Usuario { get; set; }
}
```

**Delete Behavior:**
- Chamado: **Cascade** (deletar chamado deleta comentários)
- Usuario: **Restrict** (não pode deletar usuário com comentários)

---

#### 7. **Anexo** (NOVA - Não existia antes)
```csharp
public class Anexo
{
    public int Id { get; set; }
    public string NomeArquivo { get; set; }       // Max: 255
    public string CaminhoArquivo { get; set; }    // Max: 500
    public long TamanhoBytes { get; set; }
    public string TipoMime { get; set; }          // Max: 100
    public DateTime DataUpload { get; set; } = DateTime.UtcNow;
    
    // FKs
    public int ChamadoId { get; set; }
    public int UsuarioId { get; set; }
    
    // Navegação
    public virtual Chamado Chamado { get; set; }
    public virtual Usuario Usuario { get; set; }
}
```

**Delete Behavior:**
- Chamado: **Cascade** (deletar chamado deleta anexos)
- Usuario: **Restrict**

---

## 🔧 CONFIGURAÇÃO DO DbContext

### ApplicationDbContext.cs (134 linhas)
```csharp
public class ApplicationDbContext : DbContext
{
    public DbSet<Usuario> Usuarios { get; set; }
    public DbSet<Chamado> Chamados { get; set; }
    public DbSet<Comentario> Comentarios { get; set; }
    public DbSet<Anexo> Anexos { get; set; }
    public DbSet<Categoria> Categorias { get; set; }
    public DbSet<Prioridade> Prioridades { get; set; }
    public DbSet<Status> Status { get; set; }
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Configurações Fluent API para todas as 7 entidades
        // - Constraints de MaxLength
        // - Índices únicos (Email em Usuario)
        // - Default values (GETDATE() para datas, true para IsInterno)
        // - Relacionamentos com Delete Behaviors configurados
    }
}
```

**✅ Destaques:**
- Email único em Usuario
- DateTime padrão via `GETDATE()` (SQL Server) - será gerado pela migration
- Cascade delete apenas em Comentario/Anexo → Chamado
- Restrict em todos os relacionamentos com Usuario

---

## ❌ PROBLEMAS DE COMPILAÇÃO (32 Erros)

### Categorização dos Erros

#### **Categoria A: Campo `Ativo` removido** (22 erros)
Afeta:
- `UsuariosController.cs` - 10 ocorrências
- `CategoriasController.cs` - 2 ocorrências
- `PrioridadesController.cs` - 2 ocorrências
- `StatusController.cs` - 2 ocorrências
- `OpenAIService.cs` - 4 ocorrências
- `ChamadosController.cs` - 2 ocorrências

**Locais:**
```csharp
// UsuariosController.cs
Ativo = true                          // Linhas 55, 95, 141 (atribuição)
.Where(u => u.Ativo)                  // Linhas 68, 108, 156, 209 (filtro)
usuario.Ativo                         // Linhas 329 (leitura)

// CategoriasController.cs
.Where(c => c.Ativo)                  // Linha 25 (filtro)
Ativo = true                          // Linha 57 (atribuição)

// PrioridadesController.cs
.Where(p => p.Ativo)                  // Linha 25 (filtro)
Ativo = true                          // Linha 59 (atribuição)

// StatusController.cs
.Where(s => s.Ativo)                  // Linha 25 (filtro)
Ativo = true                          // Linha 57 (atribuição)

// OpenAIService.cs
.Where(u => u.Ativo)                  // Linhas 81, 88 (filtros)
.Where(c => c.Ativo)                  // Linha 115 (filtro)
.Where(p => p.Ativo)                  // Linha 116 (filtro)
```

**Solução:**
- **Remover** todas as atribuições `Ativo = true`
- **Remover** todos os filtros `.Where(x => x.Ativo)`
- **Alternativa:** Adicionar campo `Ativo` de volta (soft delete pattern)

---

#### **Categoria B: Campos `PasswordResetToken` e `ResetTokenExpires`** (3 erros)
Afeta:
- `UsuariosController.cs` - 3 ocorrências

**Locais:**
```csharp
// Linha 256
usuario.PasswordResetToken = resetToken;

// Linha 257
usuario.ResetTokenExpires = DateTime.UtcNow.AddHours(1);

// Linha 300
.FirstOrDefaultAsync(u => u.PasswordResetToken == request.Token)
```

**Solução:**
- **Adicionar** campos de volta em `Usuario.cs`:
```csharp
public string? PasswordResetToken { get; set; }
public DateTime? ResetTokenExpires { get; set; }
```

---

#### **Categoria C: Campo `Descricao` removido** (4 erros)
Afeta:
- `CategoriasController.cs` - 1 ocorrência
- `PrioridadesController.cs` - 1 ocorrência
- `StatusController.cs` - 1 ocorrência
- `program.cs` - 1 ocorrência (seed inicial)

**Locais:**
```csharp
// Controllers
Descricao = request.Descricao         // Criação de entidades

// program.cs (seed)
Descricao = "Descrição da categoria"
```

**Solução:**
- **Remover** do DTO `CriarCategoriaDto`/`CriarPrioridadeDto`/`CriarStatusDto`
- **Atualizar** seed em `program.cs`

---

#### **Categoria D: Campo `Nivel` removido** (2 erros)
Afeta:
- `PrioridadesController.cs` - 1 ocorrência
- `ChamadosController.cs` - 2 ocorrências

**Locais:**
```csharp
// PrioridadesController.cs
Nivel = request.Nivel                 // Linha 57

// ChamadosController.cs
prioridade.Nivel                      // Linhas 84, 316 (cálculo SLA)
```

**Solução:**
- **Usar `Id`** ao invés de `Nivel` (são equivalentes: Id=1 é Baixa, Id=2 é Média, etc.)
- Atualizar lógica de SLA:
```csharp
// ANTES
if (prioridade.Nivel == 1) slaHoras = 72;

// DEPOIS
if (prioridade.Id == 1) slaHoras = 72;
// OU usar diretamente
slaHoras = prioridade.TempoRespostaHoras;
```

---

## 📋 MAPEAMENTO DE DEPENDÊNCIAS

### Diagrama de Relacionamentos
```
Usuario
  ├─[1:N]→ Chamado (Solicitante) [Restrict]
  ├─[1:N]→ Chamado (Técnico) [Restrict]
  ├─[1:N]→ Comentario [Restrict]
  ├─[1:N]→ Anexo [Restrict]
  └─[N:1]→ Categoria (Especialidade) [SetNull]

Chamado
  ├─[N:1]→ Usuario (Solicitante) [Restrict]
  ├─[N:1]→ Usuario (Técnico) [Restrict]
  ├─[N:1]→ Categoria [Restrict]
  ├─[N:1]→ Prioridade [Restrict]
  ├─[N:1]→ Status [Restrict]
  ├─[1:N]→ Comentario [Cascade]
  └─[1:N]→ Anexo [Cascade]

Categoria
  ├─[1:N]→ Chamado [Restrict]
  └─[1:N]→ Usuario (TecnicosEspecializados) [SetNull]

Prioridade
  └─[1:N]→ Chamado [Restrict]

Status
  └─[1:N]→ Chamado [Restrict]

Comentario
  ├─[N:1]→ Chamado [Cascade]
  └─[N:1]→ Usuario [Restrict]

Anexo
  ├─[N:1]→ Chamado [Cascade]
  └─[N:1]→ Usuario [Restrict]
```

---

## 🔍 AUDITORIA DE DTOs

### DTOs Consumidos pelos Frontends

#### **Mobile App (23 DTOs identificados)**
- ChamadoListDto
- CriarComentarioDto
- ComentarioResponseDto
- LoginRequestDto
- LoginResponseDto
- RegistrarUsuarioDto
- UsuarioResponseDto
- CriarChamadoRequestDto
- AtualizarChamadoDto

#### **Desktop (HTML + JS)**
- Não usa DTOs formalizados
- Consome JSON direto das entidades

#### **Web App (ASP.NET MVC)**
- Compartilha DTOs com Mobile
- ViewModels próprios (não auditados ainda)

---

## 🚀 PLANO DE AÇÃO PARA CORREÇÃO

### Fase 1: Correção Rápida (Prioridade ALTA)
**Objetivo:** Fazer o código compilar

1. **Adicionar campos de volta em Usuario:**
```csharp
public bool Ativo { get; set; } = true;
public string? PasswordResetToken { get; set; }
public DateTime? ResetTokenExpires { get; set; }
```

2. **Adicionar campos de volta em Categoria/Prioridade/Status:**
```csharp
// Categoria
public string? Descricao { get; set; }
public bool Ativo { get; set; } = true;

// Prioridade
public int Nivel { get; set; }  // Pode ser calculado: Nivel = Id
public string? Descricao { get; set; }
public bool Ativo { get; set; } = true;

// Status
public string? Descricao { get; set; }
public bool Ativo { get; set; } = true;
```

3. **Atualizar ApplicationDbContext** com novos campos

4. **Gerar Migration:**
```bash
dotnet ef migrations add InitialCreate
```

---

### Fase 2: Refatoração (Prioridade MÉDIA)
**Objetivo:** Limpar código técnico

1. **Substituir `Nivel` por `Id` ou `TempoRespostaHoras`**
2. **Criar computed property** (se quiser manter Nivel):
```csharp
public int Nivel => Id;
```

3. **Avaliar soft delete:**
   - Manter `Ativo` como padrão de soft delete?
   - Ou remover e usar hard delete?

---

### Fase 3: Database Seeding (Prioridade ALTA)
**Objetivo:** Popular dados iniciais

**Criar:** `Backend/Data/Seed/DatabaseSeed.cs`
```csharp
public static class DatabaseSeed
{
    public static void Seed(ApplicationDbContext context)
    {
        // 1. Categorias
        if (!context.Categorias.Any())
        {
            context.Categorias.AddRange(
                new Categoria { Id = 1, Nome = "Hardware", Ativo = true },
                new Categoria { Id = 2, Nome = "Software", Ativo = true },
                new Categoria { Id = 3, Nome = "Redes", Ativo = true },
                new Categoria { Id = 4, Nome = "Infraestrutura", Ativo = true }
            );
        }

        // 2. Prioridades
        if (!context.Prioridades.Any())
        {
            context.Prioridades.AddRange(
                new Prioridade { Id = 1, Nome = "Baixa", TempoRespostaHoras = 72, Nivel = 1, Ativo = true },
                new Prioridade { Id = 2, Nome = "Média", TempoRespostaHoras = 48, Nivel = 2, Ativo = true },
                new Prioridade { Id = 3, Nome = "Alta", TempoRespostaHoras = 24, Nivel = 3, Ativo = true },
                new Prioridade { Id = 4, Nome = "Crítica", TempoRespostaHoras = 4, Nivel = 4, Ativo = true }
            );
        }

        // 3. Status
        if (!context.Status.Any())
        {
            context.Status.AddRange(
                new Status { Id = 1, Nome = "Aberto", Ativo = true },
                new Status { Id = 2, Nome = "Em Andamento", Ativo = true },
                new Status { Id = 3, Nome = "Aguardando Cliente", Ativo = true },
                new Status { Id = 4, Nome = "Resolvido", Ativo = true },
                new Status { Id = 5, Nome = "Fechado", Ativo = true }
            );
        }

        // 4. Usuários de teste
        if (!context.Usuarios.Any())
        {
            context.Usuarios.AddRange(
                new Usuario 
                { 
                    NomeCompleto = "Administrador", 
                    Email = "admin@faculdade.edu.br",
                    SenhaHash = BCrypt.Net.BCrypt.HashPassword("Admin@123"),
                    TipoUsuario = 3,
                    IsInterno = true,
                    Ativo = true
                },
                new Usuario 
                { 
                    NomeCompleto = "Técnico Redes", 
                    Email = "tecnico@faculdade.edu.br",
                    SenhaHash = BCrypt.Net.BCrypt.HashPassword("Tecnico@123"),
                    TipoUsuario = 2,
                    IsInterno = true,
                    Especialidade = "Redes",
                    EspecialidadeCategoriaId = 3,
                    Ativo = true
                },
                new Usuario 
                { 
                    NomeCompleto = "João Aluno", 
                    Email = "aluno@faculdade.edu.br",
                    SenhaHash = BCrypt.Net.BCrypt.HashPassword("Aluno@123"),
                    TipoUsuario = 1,
                    IsInterno = true,
                    Ativo = true
                }
            );
        }

        context.SaveChanges();
    }
}
```

**Atualizar:** `Backend/program.cs`
```csharp
// Após app.Build(), antes de app.Run()
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    DatabaseSeed.Seed(context);
}
```

---

## 📊 COMPARATIVO: SCHEMA ANTIGO vs NOVO

| Entidade | Campos Antigos | Campos Novos | Mudanças Principais |
|----------|---------------|--------------|---------------------|
| **Usuario** | 9 campos | 12 campos | + IsInterno, Especialidade, EspecialidadeCategoriaId |
| **Chamado** | 10 campos | 10 campos | Sem mudanças estruturais |
| **Categoria** | 5 campos | 3 campos | - Descricao, - Ativo |
| **Prioridade** | 6 campos | 4 campos | - Nivel, - Descricao, - Ativo |
| **Status** | 4 campos | 3 campos | - Descricao, - Ativo |
| **Comentario** | 5 campos | 5 campos | Sem mudanças |
| **Anexo** | N/A | 7 campos | **NOVA TABELA** |

---

## ⚠️ RISCOS E IMPACTOS

### Alto Risco
1. **Mobile App** pode quebrar se espera campos removidos nos DTOs
2. **Desktop App** pode ter queries SQL diretas com campos antigos
3. **Perda de dados** ao dropar database (backup obrigatório)

### Médio Risco
1. **Controllers** precisam ser atualizados (32 erros)
2. **Services** (OpenAI) precisam ajustes
3. **Seed data** deve ser recriado

### Baixo Risco
1. **Entidades** estão corretas
2. **DbContext** está completo
3. **Migrations** serão geradas corretamente após correção

---

## ✅ CHECKLIST DE VALIDAÇÃO

### Pré-Migration
- [x] Entidades criadas sem duplicação
- [x] ApplicationDbContext configurado
- [ ] **Código compila sem erros**
- [ ] Backup do database atual
- [ ] Migrations antigas removidas

### Pós-Migration
- [ ] Migration gerada com 7 tabelas
- [ ] `dotnet ef database update` executado
- [ ] Seed data aplicado
- [ ] Queries de validação:
```sql
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'
SELECT * FROM Categorias
SELECT * FROM Prioridades
SELECT * FROM Status
SELECT * FROM Usuarios
SELECT * FROM sys.foreign_keys
```

### Testes de Integração
- [ ] Login funciona (Mobile/Desktop/Web)
- [ ] Criar chamado funciona
- [ ] Listar chamados funciona
- [ ] Comentários funcionam
- [ ] **Upload de anexos funciona (novo recurso)**

---

## 🎯 PRÓXIMOS PASSOS RECOMENDADOS

### Opção 1: Correção Conservadora (Recomendado)
1. **Adicionar campos de volta** (Ativo, Descricao, Nivel, etc.)
2. Compilar
3. Gerar migration
4. Aplicar migration
5. Testar
6. **Depois** refatorar para remover campos não usados

### Opção 2: Correção Agressiva
1. **Remover todas as referências** aos campos antigos
2. Atualizar DTOs
3. Atualizar Controllers
4. Atualizar Mobile/Desktop (se necessário)
5. Compilar
6. Gerar migration

---

## 📝 NOTAS TÉCNICAS

### DateTime: UtcNow vs Now
- **Entidades:** Usam `DateTime.UtcNow` (código C#)
- **Database:** Usa `GETDATE()` (SQL Server - hora local)
- **Recomendação:** Migrar tudo para UTC

### Cascade Delete
- ✅ **Comentario** → Chamado (Cascade OK - comentários não fazem sentido sem chamado)
- ✅ **Anexo** → Chamado (Cascade OK - arquivos não fazem sentido sem chamado)
- ⚠️ **Chamado** → Usuario (Restrict - não deletar usuários com histórico)

### Performance
- Índice único em `Usuario.Email` ✅
- Considerar índices em FKs (auto-criado pelo EF em alguns casos)
- Considerar índice composto em `Chamado(StatusId, PrioridadeId)` para dashboards

---

## 📞 CREDENCIAIS DE TESTE (Após Seed)

| Tipo | Email | Senha | TipoUsuario |
|------|-------|-------|-------------|
| Admin | admin@faculdade.edu.br | Admin@123 | 3 |
| Técnico | tecnico@faculdade.edu.br | Tecnico@123 | 2 |
| Aluno | aluno@faculdade.edu.br | Aluno@123 | 1 |

---

**Gerado automaticamente pela análise de contexto do banco de dados e API**
