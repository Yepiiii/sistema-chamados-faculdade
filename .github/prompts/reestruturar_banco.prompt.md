---
mode: agent
---
Define the task to achieve, including specific requirements, constraints, and success criteria.

# 📋 PLANO DE AÇÃO: REESTRUTURAÇÃO COMPLETA DO BANCO DE DADOS

**Data:** 10/11/2025  
**Objetivo:** Definir um esquema de banco de dados que atenda 100% às necessidades de Backend, Mobile, Desktop e Web

---

## 📊 FASE 1: AUDITORIA DE CONTRATO (O que os clientes consomem?)

### 1.1 DTOs Identificados nos Frontends

#### 🔵 **Mobile** (23 DTOs)

**Autenticação:**
- `LoginRequestDto` - Email, Senha
- `LoginResponseDto` - Token, TipoUsuario
- `EsqueciSenhaRequestDto` - Email
- `ResetarSenhaRequestDto` - Token, NovaSenha
- `UsuarioResponseDto` - Id, NomeCompleto, Email, TipoUsuario, DataCadastro, Ativo

**Chamados:**
- `ChamadoDto` - **COMPLETO** com SLA e objetos aninhados
- `ChamadoListDto` - Id, Titulo, CategoriaNome, StatusNome, PrioridadeNome
- `CriarChamadoRequestDto` - Titulo, Descricao, CategoriaId, PrioridadeId
- `AtualizarChamadoDto` - StatusId, TecnicoId
- `AnalisarChamadoRequestDto` - DescricaoProblema
- `AnaliseChamadoResponseDto` - CategoriaId, CategoriaNome, PrioridadeId, PrioridadeNome, TituloSugerido, Justificativa, ConfiancaCategoria, ConfiancaPrioridade, TecnicoId, TecnicoNome

**Comentários:**
- `ComentarioDto` - Id, Texto, DataCriacao, UsuarioId, UsuarioNome, ChamadoId
- `CriarComentarioRequestDto` - Texto

**Lookup Tables:**
- `CategoriaDto` - Id, Nome, Descricao
- `StatusDto` - Id, Nome, Descricao
- `PrioridadeDto` - Id, Nome, Nivel, Descricao
- `UsuarioResumoDto` - Id, NomeCompleto, Email (**usado em objetos aninhados**)

**Histórico/Anexos:**
- `HistoricoItemDto` - Tipo, Descricao, Data, Usuario
- `AnexoDto` - Id, Nome, Url, Tamanho
- `AtualizacaoDto` - VersaoAtual, VersaoDisponivel, NotasVersao
- `VerificacaoAtualizacoesDto` - TemAtualizacao, Atualizacao

#### 🟢 **Desktop/Web** (JavaScript - Script-desktop.js)

**Consumo via API:**
```javascript
// Chamados List
{
  id: number,
  titulo: string,
  categoriaNome: string,    // <-- Propriedade flat do DTO
  statusNome: string,       // <-- Propriedade flat do DTO
  prioridadeNome: string    // <-- Propriedade flat do DTO
}

// Chamado Detail
{
  id: number,
  titulo: string,
  descricao: string,
  dataAbertura: DateTime,
  dataFechamento: DateTime?,
  slaDataExpiracao: DateTime?,  // <-- SLA
  statusId: number,
  statusNome: string,
  prioridadeId: number,
  prioridadeNome: string,
  categoriaId: number,
  categoriaNome: string,
  solicitante: { id, nomeCompleto, email },  // <-- Objeto aninhado
  tecnico: { id, nomeCompleto, email }?,     // <-- Objeto aninhado
  comentarios: [...]
}
```

### 1.2 Campos Críticos Mapeados

| Campo | Mobile | Desktop | Web | Backend | Uso |
|-------|--------|---------|-----|---------|-----|
| **SlaDataExpiracao** | ✅ | ✅ | ✅ | ✅ | Exibição de prazos |
| **StatusNome** (flat) | ✅ | ✅ | ✅ | ✅ | Evita joins no cliente |
| **CategoriaNome** (flat) | ✅ | ✅ | ✅ | ✅ | Evita joins no cliente |
| **PrioridadeNome** (flat) | ✅ | ✅ | ✅ | ✅ | Evita joins no cliente |
| **UsuarioResumoDto** (aninhado) | ✅ | ✅ | ✅ | ✅ | Solicitante/Tecnico |
| **DataCriacao** (Comentario) | ✅ | ✅ | ✅ | ✅ | Timeline de comentários |
| **IsInterno** (Usuario) | ❌ | ❌ | ❌ | ⚠️ | Lógica de permissão |

### 1.3 Objetos Aninhados Identificados

```csharp
// ChamadoDto retorna objetos aninhados:
public class ChamadoDto
{
    public int Id { get; set; }
    public string Titulo { get; set; }
    public UsuarioResumoDto Solicitante { get; set; }  // <-- ANINHADO
    public UsuarioResumoDto? Tecnico { get; set; }     // <-- ANINHADO
    public CategoriaDto Categoria { get; set; }        // <-- ANINHADO
    public StatusDto Status { get; set; }              // <-- ANINHADO
    public PrioridadeDto Prioridade { get; set; }      // <-- ANINHADO
    public List<ComentarioDto> Comentarios { get; set; } // <-- COLEÇÃO
}
```

---

## 🔍 FASE 2: AUDITORIA DE DOMÍNIO (O que o backend precisa?)

### 2.1 Entidades Atuais do EF Core

#### ✅ **Entidades Existentes:**

1. **Usuario**
   - Campos: Id, NomeCompleto, Email, PasswordHash, TipoUsuario, Ativo, DataCadastro
   - Relacionamentos: Chamados (Solicitante), Chamados (Tecnico), Comentarios

2. **Chamado**
   - Campos: Id, Titulo, Descricao, DataAbertura, DataFechamento, DataUltimaAtualizacao, SolicitanteId, TecnicoId, CategoriaId, PrioridadeId, StatusId, **SlaDataExpiracao**
   - Relacionamentos: Solicitante (Usuario), Tecnico (Usuario), Categoria, Prioridade, Status, Comentarios (List)

3. **Categoria**
   - Campos: Id, Nome, Descricao, Ativo, DataCadastro
   - Relacionamentos: Chamados (List)

4. **Prioridade**
   - Campos: Id, Nome, Descricao, **Nivel** (1-4), Ativo, DataCadastro
   - Relacionamentos: Chamados (List)

5. **Status**
   - Campos: Id, Nome, Descricao, Ativo, DataCadastro
   - Relacionamentos: Chamados (List)

6. **Comentario**
   - Campos: Id, Texto, **DataCriacao**, ChamadoId, UsuarioId
   - Relacionamentos: Chamado, Usuario

### 2.2 Regras de Negócio Identificadas

#### 🔴 **SLA (Service Level Agreement)**
```csharp
// Services/SlaService.cs (DEVE EXISTIR)
DateTime CalcularSla(int nivelPrioridade, DateTime dataAbertura)
{
    // Baixa: 7 dias, Média: 3 dias, Alta: 1 dia, Crítica: 4 horas
    return nivelPrioridade switch {
        1 => dataAbertura.AddDays(7),
        2 => dataAbertura.AddDays(3),
        3 => dataAbertura.AddDays(1),
        4 => dataAbertura.AddHours(4),
        _ => dataAbertura.AddDays(7)
    };
}
```

#### 🔴 **Permissões e Fluxo de Status**
```csharp
// Lógica atual nos Controllers:
// - Solicitante: Pode criar chamados (StatusId = 1 "Aberto")
// - Técnico: Pode "Assumir" chamado (StatusId = 2 "Em Andamento")
// - Técnico: Pode marcar como "Resolvido" (StatusId = 4)
// - Solicitante: Pode marcar como "Fechado" (StatusId = 5)
```

#### 🔴 **Atualização Automática de Timestamps**
```csharp
// Regras:
// - DataAbertura: GETDATE() no INSERT
// - DataUltimaAtualizacao: Atualiza ao adicionar comentário ou mudar status
// - DataFechamento: Atualiza quando StatusId = 5
```

### 2.3 Campos Ausentes ou Incorretos

| Campo | Entidade | Status | Problema |
|-------|----------|--------|----------|
| **IsInterno** | Usuario | ❌ AUSENTE | Necessário para diferenciar Aluno vs Professor |
| **Especialidade** | Usuario | ❌ AUSENTE | Necessário para routing de chamados |
| **EspecialidadeCategoriaId** | Usuario | ⚠️ PODE EXISTIR | Relacionamento Tecnico → Categoria |
| **Anexos** | Chamado | ❌ AUSENTE | Frontends mencionam AnexoDto |

---

## 🎯 FASE 3: DEFINIÇÃO DO ESQUEMA (O "Ponto da Verdade")

### 3.1 Modelos de Entidade Ideais (POCOs C#)

#### **1. Usuario.cs**
```csharp
namespace SistemaChamados.Core.Entities;

public class Usuario
{
    public int Id { get; set; }
    public string NomeCompleto { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    
    // TipoUsuario: 1 = Solicitante, 2 = Técnico, 3 = Administrador
    public int TipoUsuario { get; set; }
    
    // NOVO: Diferencia Aluno (IsInterno=true) de Professor (IsInterno=false)
    public bool IsInterno { get; set; } = true;
    
    // NOVO: Especialidade do Técnico (ex: "Redes", "Hardware")
    public string? Especialidade { get; set; }
    
    // NOVO: Relacionamento Técnico → Categoria preferencial
    public int? EspecialidadeCategoriaId { get; set; }
    
    public bool Ativo { get; set; } = true;
    public DateTime DataCadastro { get; set; } = DateTime.UtcNow;
    
    // Navegação
    public virtual Categoria? EspecialidadeCategoria { get; set; }
    public virtual ICollection<Chamado> ChamadosSolicitados { get; set; } = new List<Chamado>();
    public virtual ICollection<Chamado> ChamadosAtribuidos { get; set; } = new List<Chamado>();
    public virtual ICollection<Comentario> Comentarios { get; set; } = new List<Comentario>();
}
```

#### **2. Chamado.cs**
```csharp
namespace SistemaChamados.Core.Entities;

public class Chamado
{
    public int Id { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string Descricao { get; set; } = string.Empty;
    
    public DateTime DataAbertura { get; set; } = DateTime.UtcNow;
    public DateTime? DataFechamento { get; set; }
    public DateTime? DataUltimaAtualizacao { get; set; }
    
    // SLA: Data de expiração calculada baseada na Prioridade
    public DateTime? SlaDataExpiracao { get; set; }
    
    // Chaves estrangeiras
    public int SolicitanteId { get; set; }
    public int? TecnicoId { get; set; }
    public int CategoriaId { get; set; }
    public int PrioridadeId { get; set; }
    public int StatusId { get; set; }
    
    // Navegação
    public virtual Usuario Solicitante { get; set; } = null!;
    public virtual Usuario? Tecnico { get; set; }
    public virtual Categoria Categoria { get; set; } = null!;
    public virtual Prioridade Prioridade { get; set; } = null!;
    public virtual Status Status { get; set; } = null!;
    public virtual ICollection<Comentario> Comentarios { get; set; } = new List<Comentario>();
    public virtual ICollection<Anexo> Anexos { get; set; } = new List<Anexo>();
}
```

#### **3. Comentario.cs**
```csharp
namespace SistemaChamados.Core.Entities;

public class Comentario
{
    public int Id { get; set; }
    public string Texto { get; set; } = string.Empty;
    public DateTime DataCriacao { get; set; } = DateTime.UtcNow;
    
    // Chaves estrangeiras
    public int ChamadoId { get; set; }
    public int UsuarioId { get; set; }
    
    // Navegação
    public virtual Chamado Chamado { get; set; } = null!;
    public virtual Usuario Usuario { get; set; } = null!;
}
```

#### **4. Anexo.cs** (NOVA ENTIDADE)
```csharp
namespace SistemaChamados.Core.Entities;

public class Anexo
{
    public int Id { get; set; }
    public string NomeArquivo { get; set; } = string.Empty;
    public string CaminhoArquivo { get; set; } = string.Empty; // ou URL
    public long TamanhoBytes { get; set; }
    public string TipoMime { get; set; } = string.Empty;
    public DateTime DataUpload { get; set; } = DateTime.UtcNow;
    
    // Chaves estrangeiras
    public int ChamadoId { get; set; }
    public int UsuarioId { get; set; } // Quem fez upload
    
    // Navegação
    public virtual Chamado Chamado { get; set; } = null!;
    public virtual Usuario Usuario { get; set; } = null!;
}
```

#### **5. Categoria.cs** (SEM ALTERAÇÕES)
```csharp
namespace SistemaChamados.Core.Entities;

public class Categoria
{
    public int Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string? Descricao { get; set; }
    public bool Ativo { get; set; } = true;
    public DateTime DataCadastro { get; set; } = DateTime.UtcNow;
    
    public virtual ICollection<Chamado> Chamados { get; set; } = new List<Chamado>();
    public virtual ICollection<Usuario> TecnicosEspecializados { get; set; } = new List<Usuario>();
}
```

#### **6. Prioridade.cs** (SEM ALTERAÇÕES)
```csharp
namespace SistemaChamados.Core.Entities;

public class Prioridade
{
    public int Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string? Descricao { get; set; }
    public int Nivel { get; set; } // 1=Baixa, 2=Média, 3=Alta, 4=Crítica
    public bool Ativo { get; set; } = true;
    public DateTime DataCadastro { get; set; } = DateTime.UtcNow;
    
    public virtual ICollection<Chamado> Chamados { get; set; } = new List<Chamado>();
}
```

#### **7. Status.cs** (SEM ALTERAÇÕES)
```csharp
namespace SistemaChamados.Core.Entities;

public class Status
{
    public int Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string? Descricao { get; set; }
    public bool Ativo { get; set; } = true;
    public DateTime DataCadastro { get; set; } = DateTime.UtcNow;
    
    public virtual ICollection<Chamado> Chamados { get; set; } = new List<Chamado>();
}
```

### 3.2 Configuração do DbContext

```csharp
// Data/ApplicationDbContext.cs
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
        base.OnModelCreating(modelBuilder);
        
        // Usuario
        modelBuilder.Entity<Usuario>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.NomeCompleto).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Email).IsRequired().HasMaxLength(100);
            entity.HasIndex(e => e.Email).IsUnique();
            entity.Property(e => e.TipoUsuario).IsRequired();
            entity.Property(e => e.IsInterno).HasDefaultValue(true);
            entity.Property(e => e.Especialidade).HasMaxLength(100);
            
            // Relacionamento: Especialidade → Categoria
            entity.HasOne(e => e.EspecialidadeCategoria)
                  .WithMany(c => c.TecnicosEspecializados)
                  .HasForeignKey(e => e.EspecialidadeCategoriaId)
                  .OnDelete(DeleteBehavior.SetNull);
        });
        
        // Chamado
        modelBuilder.Entity<Chamado>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Titulo).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Descricao).IsRequired().HasMaxLength(2000);
            entity.Property(e => e.DataAbertura).HasDefaultValueSql("GETDATE()");
            
            // Relacionamentos
            entity.HasOne(e => e.Solicitante)
                  .WithMany(u => u.ChamadosSolicitados)
                  .HasForeignKey(e => e.SolicitanteId)
                  .OnDelete(DeleteBehavior.Restrict);
                  
            entity.HasOne(e => e.Tecnico)
                  .WithMany(u => u.ChamadosAtribuidos)
                  .HasForeignKey(e => e.TecnicoId)
                  .OnDelete(DeleteBehavior.Restrict);
                  
            entity.HasOne(e => e.Categoria)
                  .WithMany(c => c.Chamados)
                  .HasForeignKey(e => e.CategoriaId)
                  .OnDelete(DeleteBehavior.Restrict);
                  
            entity.HasOne(e => e.Prioridade)
                  .WithMany(p => p.Chamados)
                  .HasForeignKey(e => e.PrioridadeId)
                  .OnDelete(DeleteBehavior.Restrict);
                  
            entity.HasOne(e => e.Status)
                  .WithMany(s => s.Chamados)
                  .HasForeignKey(e => e.StatusId)
                  .OnDelete(DeleteBehavior.Restrict);
        });
        
        // Comentario
        modelBuilder.Entity<Comentario>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Texto).IsRequired().HasMaxLength(1000);
            entity.Property(e => e.DataCriacao).HasDefaultValueSql("GETDATE()");
            
            entity.HasOne(e => e.Chamado)
                  .WithMany(c => c.Comentarios)
                  .HasForeignKey(e => e.ChamadoId)
                  .OnDelete(DeleteBehavior.Cascade);
                  
            entity.HasOne(e => e.Usuario)
                  .WithMany(u => u.Comentarios)
                  .HasForeignKey(e => e.UsuarioId)
                  .OnDelete(DeleteBehavior.Restrict);
        });
        
        // Anexo (NOVO)
        modelBuilder.Entity<Anexo>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.NomeArquivo).IsRequired().HasMaxLength(255);
            entity.Property(e => e.CaminhoArquivo).IsRequired().HasMaxLength(500);
            entity.Property(e => e.TipoMime).HasMaxLength(100);
            entity.Property(e => e.DataUpload).HasDefaultValueSql("GETDATE()");
            
            entity.HasOne(e => e.Chamado)
                  .WithMany(c => c.Anexos)
                  .HasForeignKey(e => e.ChamadoId)
                  .OnDelete(DeleteBehavior.Cascade);
                  
            entity.HasOne(e => e.Usuario)
                  .WithMany()
                  .HasForeignKey(e => e.UsuarioId)
                  .OnDelete(DeleteBehavior.Restrict);
        });
        
        // Categoria
        modelBuilder.Entity<Categoria>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Nome).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Descricao).HasMaxLength(200);
            entity.Property(e => e.DataCadastro).HasDefaultValueSql("GETDATE()");
        });
        
        // Prioridade
        modelBuilder.Entity<Prioridade>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Nome).IsRequired().HasMaxLength(50);
            entity.Property(e => e.Descricao).HasMaxLength(200);
            entity.Property(e => e.DataCadastro).HasDefaultValueSql("GETDATE()");
        });
        
        // Status
        modelBuilder.Entity<Status>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Nome).IsRequired().HasMaxLength(50);
            entity.Property(e => e.Descricao).HasMaxLength(200);
            entity.Property(e => e.DataCadastro).HasDefaultValueSql("GETDATE()");
        });
    }
}
```

### 3.3 Diagrama ER

```
┌─────────────┐       ┌──────────────┐       ┌─────────────┐
│   Usuario   │1     *│   Chamado    │*     1│  Categoria  │
├─────────────┤◄──────┤──────────────┤──────►├─────────────┤
│ Id (PK)     │       │ Id (PK)      │       │ Id (PK)     │
│ NomeCompleto│       │ Titulo       │       │ Nome        │
│ Email       │       │ Descricao    │       │ Descricao   │
│ TipoUsuario │       │ DataAbertura │       └─────────────┘
│ IsInterno   │       │ SlaDataExp   │
│ Especialidad│       │ SolicitanteId│       ┌─────────────┐
│ EspecCategId│       │ TecnicoId    │*     1│ Prioridade  │
└─────────────┘       │ CategoriaId  │──────►├─────────────┤
       │              │ PrioridadeId │       │ Id (PK)     │
       │              │ StatusId     │       │ Nome        │
       │              └──────────────┘       │ Nivel       │
       │                     │               └─────────────┘
       │                     │
       │              ┌──────┴───────┐       ┌─────────────┐
       │              │              │*     1│   Status    │
       │         ┌────┴────┐    ┌───┴──┐    ├─────────────┤
       │        1│Comentar │   1│Anexo │    │ Id (PK)     │
       └────────►├─────────┤    ├──────┤    │ Nome        │
                │Id (PK)   │    │Id(PK)│    └─────────────┘
                │Texto     │    │Nome  │
                │DataCriaca│    │Camnh │
                │ChamadoId │    │Tamnh │
                │UsuarioId │    │ChamdI│
                └──────────┘    │UsrioI│
                                └──────┘
```

---

## 🔧 FASE 4: IMPLEMENTAÇÃO E MIGRAÇÃO

### 4.1 Passo a Passo de Limpeza e Recriação

#### **PASSO 1: Backup (Segurança)**
```powershell
# No SQL Server Management Studio ou via comandos:
BACKUP DATABASE [SistemaChamados] 
TO DISK = 'C:\Backups\SistemaChamados_Backup_20251110.bak'
WITH FORMAT, INIT, NAME = 'Backup antes da reestruturação';
```

#### **PASSO 2: Limpar Migrations Antigas**
```powershell
# No diretório do Backend
cd Backend

# Remover todas as migrations antigas
Remove-Item -Path "Migrations\*.cs" -Force

# Limpar histórico de migrations no banco
# OPÇÃO A: Dropar banco completamente (localhost)
dotnet ef database drop --force

# OPÇÃO B: Dropar apenas tabela __EFMigrationsHistory
# Execute no SQL Server:
# DROP TABLE [__EFMigrationsHistory];
```

#### **PASSO 3: Atualizar Entidades**

1. **Criar `Core/Entities/Anexo.cs`** (código da Fase 3.1)
2. **Atualizar `Core/Entities/Usuario.cs`** (adicionar IsInterno, Especialidade, EspecialidadeCategoriaId)
3. **Verificar** outras entidades (Chamado, Comentario, etc.)

#### **PASSO 4: Atualizar DbContext**

Substituir `Data/ApplicationDbContext.cs` pelo código da Fase 3.2

#### **PASSO 5: Gerar Migration Inicial**
```powershell
# Certifique-se de estar no diretório Backend
cd C:\Users\T-GAMER\sistema-chamados-faculdade\Backend

# Gerar migration inicial com TUDO
dotnet ef migrations add InitialCreate --context ApplicationDbContext

# Verificar arquivos gerados em Migrations/
# Deve criar:
# - YYYYMMDDHHMMSS_InitialCreate.cs
# - YYYYMMDDHHMMSS_InitialCreate.Designer.cs
# - ApplicationDbContextModelSnapshot.cs
```

#### **PASSO 6: Aplicar Migration**
```powershell
# Aplicar no banco localhost
dotnet ef database update

# Verificar se criou todas as tabelas:
# - Usuarios
# - Categorias
# - Prioridades
# - Status
# - Chamados
# - Comentarios
# - Anexos (NOVA!)
# - __EFMigrationsHistory
```

#### **PASSO 7: Seed de Dados Iniciais**

Criar arquivo `Data/Seed/DatabaseSeed.cs`:

```csharp
public static class DatabaseSeed
{
    public static void Seed(ApplicationDbContext context)
    {
        // 1. Status
        if (!context.Status.Any())
        {
            context.Status.AddRange(
                new Status { Id = 1, Nome = "Aberto", Descricao = "Chamado recém-criado" },
                new Status { Id = 2, Nome = "Em Andamento", Descricao = "Técnico assumiu" },
                new Status { Id = 3, Nome = "Aguardando", Descricao = "Aguardando retorno" },
                new Status { Id = 4, Nome = "Resolvido", Descricao = "Técnico marcou como resolvido" },
                new Status { Id = 5, Nome = "Fechado", Descricao = "Solicitante confirmou solução" }
            );
        }
        
        // 2. Prioridades
        if (!context.Prioridades.Any())
        {
            context.Prioridades.AddRange(
                new Prioridade { Id = 1, Nome = "Baixa", Nivel = 1, Descricao = "SLA: 7 dias" },
                new Prioridade { Id = 2, Nome = "Média", Nivel = 2, Descricao = "SLA: 3 dias" },
                new Prioridade { Id = 3, Nome = "Alta", Nivel = 3, Descricao = "SLA: 1 dia" },
                new Prioridade { Id = 4, Nome = "Crítica", Nivel = 4, Descricao = "SLA: 4 horas" }
            );
        }
        
        // 3. Categorias
        if (!context.Categorias.Any())
        {
            context.Categorias.AddRange(
                new Categoria { Id = 1, Nome = "Hardware", Descricao = "Problemas físicos" },
                new Categoria { Id = 2, Nome = "Software", Descricao = "Aplicativos e sistemas" },
                new Categoria { Id = 3, Nome = "Rede", Descricao = "Conectividade e internet" },
                new Categoria { Id = 4, Nome = "Acesso", Descricao = "Senhas e permissões" }
            );
        }
        
        // 4. Usuário Admin
        if (!context.Usuarios.Any(u => u.Email == "admin@sistema.com"))
        {
            var adminHash = BCrypt.Net.BCrypt.HashPassword("Admin@123");
            context.Usuarios.Add(new Usuario
            {
                NomeCompleto = "Administrador",
                Email = "admin@sistema.com",
                PasswordHash = adminHash,
                TipoUsuario = 3, // Admin
                IsInterno = true,
                Ativo = true
            });
        }
        
        // 5. Usuário Técnico de Teste
        if (!context.Usuarios.Any(u => u.Email == "tecnico@teste.com"))
        {
            var tecnicoHash = BCrypt.Net.BCrypt.HashPassword("Senha@123");
            context.Usuarios.Add(new Usuario
            {
                NomeCompleto = "João Técnico",
                Email = "tecnico@teste.com",
                PasswordHash = tecnicoHash,
                TipoUsuario = 2, // Técnico
                IsInterno = true,
                Especialidade = "Hardware",
                EspecialidadeCategoriaId = 1, // Hardware
                Ativo = true
            });
        }
        
        // 6. Usuário Solicitante de Teste
        if (!context.Usuarios.Any(u => u.Email == "aluno@teste.com"))
        {
            var alunoHash = BCrypt.Net.BCrypt.HashPassword("Senha@123");
            context.Usuarios.Add(new Usuario
            {
                NomeCompleto = "Maria Aluna",
                Email = "aluno@teste.com",
                PasswordHash = alunoHash,
                TipoUsuario = 1, // Solicitante
                IsInterno = true,
                Ativo = true
            });
        }
        
        context.SaveChanges();
    }
}
```

Chamar seed em `Program.cs`:

```csharp
// Program.cs
var app = builder.Build();

// Seed do banco
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    DatabaseSeed.Seed(context);
}

app.Run();
```

#### **PASSO 8: Validação**

```sql
-- Verificar estrutura criada
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE';

-- Verificar dados seed
SELECT * FROM Status;
SELECT * FROM Prioridades;
SELECT * FROM Categorias;
SELECT * FROM Usuarios;

-- Verificar constraints
SELECT 
    fk.name AS ForeignKeyName,
    tp.name AS ParentTable,
    cp.name AS ParentColumn,
    tr.name AS ReferencedTable,
    cr.name AS ReferencedColumn
FROM sys.foreign_keys AS fk
INNER JOIN sys.tables AS tp ON fk.parent_object_id = tp.object_id
INNER JOIN sys.foreign_key_columns AS fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.columns AS cp ON fkc.parent_object_id = cp.object_id AND fkc.parent_column_id = cp.column_id
INNER JOIN sys.tables AS tr ON fk.referenced_object_id = tr.object_id
INNER JOIN sys.columns AS cr ON fkc.referenced_object_id = cr.object_id AND fkc.referenced_column_id = cr.column_id;
```

---

## ✅ CHECKLIST FINAL

### Antes de Executar:
- [ ] Backup do banco atual criado
- [ ] Todas as entidades atualizadas com novos campos
- [ ] DbContext configurado com relacionamentos corretos
- [ ] Migrations antigas removidas

### Durante Execução:
- [ ] `dotnet ef database drop --force` executado
- [ ] `dotnet ef migrations add InitialCreate` gerou arquivos
- [ ] `dotnet ef database update` aplicou sem erros
- [ ] Seed de dados executado

### Validação:
- [ ] 7 tabelas criadas (Usuarios, Chamados, Comentarios, Anexos, Categorias, Prioridades, Status)
- [ ] Dados seed inseridos (3 usuários, 5 status, 4 prioridades, 4 categorias)
- [ ] Foreign keys configuradas corretamente
- [ ] Backend compila sem erros
- [ ] Mobile compila sem erros
- [ ] Desktop/Web continuam funcionando

---

## 🚀 PRÓXIMOS PASSOS

1. **Atualizar DTOs** para incluir novos campos (IsInterno, Especialidade, Anexos)
2. **Atualizar Controllers** para usar nova estrutura
3. **Testar endpoints** com Swagger
4. **Atualizar frontends** para consumir novos campos
5. **Implementar upload de Anexos** (se necessário)

---

**✅ Esquema 100% Alinhado com Necessidades de Backend, Mobile, Desktop e Web!**
