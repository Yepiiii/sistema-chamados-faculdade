---
mode: agent
---
Define the task to achieve, including specific requirements, constraints, and success criteria.

# 🏢 Plano de Migração: Contexto Educacional → Contexto Empresarial

**Data**: 23/10/2025  
**Branch**: mobile-simplified  
**Duração Estimada**: 2-3 horas  
**Tipo**: Refatoração Completa (Opção 1)

---

## 🎯 Objetivo

Migrar todo o sistema de **"Sistema de Chamados - Faculdade"** para **"Sistema de Suporte Técnico - Empresa"**, adequando domínio, nomenclatura e interface ao novo contexto empresarial.

---

## 📊 Mapeamento de Mudanças

### Conceitos Antigos → Novos

| Antigo | Novo | Justificativa |
|--------|------|---------------|
| **Faculdade/Academia** | **Empresa/Companhia** | Contexto empresarial |
| **Aluno** | **Colaborador** | Funcionário que solicita suporte |
| **Professor** | **Técnico de TI** | Profissional de suporte técnico |
| **Administrador** | **Administrador** | Mantém função |
| **Especialidade** | **Área de Atuação** | Hardware/Software/Rede |
| **TipoUsuario=1** | **TipoUsuario=1** | Colaborador (antes Aluno) |
| **TipoUsuario=2** | **TipoUsuario=2** | Técnico TI (antes Professor) |
| **TipoUsuario=3** | **TipoUsuario=3** | Administrador |

### Entidades do Banco

| Tabela Antiga | Tabela Nova | Migration |
|---------------|-------------|-----------|
| `AlunoPerfis` | `ColaboradorPerfis` | Rename Table |
| `ProfessorPerfis` | `TecnicoTIPerfis` | Rename Table |
| `Usuarios` | `Usuarios` | Sem mudança |
| `Chamados` | `Chamados` | Sem mudança |
| `Categorias` | `Categorias` | Update Seed Data |

---

## 🗂️ Fases de Execução

## ===================================================================
## FASE 1: BACKEND - ENTIDADES (30 minutos)
## ===================================================================

### 1.1. Renomear Classes de Entidade

**Arquivos a modificar:**

#### `Backend/Core/Entities/AlunoPerfil.cs` → `ColaboradorPerfil.cs`
```csharp
// ANTES
public class AlunoPerfil
{
    public int Id { get; set; }
    public int UsuarioId { get; set; }
    public string Matricula { get; set; }
    public string Curso { get; set; }
    public DateTime DataMatricula { get; set; }
    
    public Usuario Usuario { get; set; }
}

// DEPOIS
public class ColaboradorPerfil
{
    public int Id { get; set; }
    public int UsuarioId { get; set; }
    public string Matricula { get; set; }        // Mantém (número funcional)
    public string Departamento { get; set; }      // Era "Curso"
    public DateTime DataAdmissao { get; set; }    // Era "DataMatricula"
    
    public Usuario Usuario { get; set; }
}
```

#### `Backend/Core/Entities/ProfessorPerfil.cs` → `TecnicoTIPerfil.cs`
```csharp
// ANTES
public class ProfessorPerfil
{
    public int Id { get; set; }
    public int UsuarioId { get; set; }
    public string Especialidade { get; set; }
    public DateTime DataContratacao { get; set; }
    
    public Usuario Usuario { get; set; }
    public ICollection<Chamado> ChamadosAtribuidos { get; set; }
}

// DEPOIS
public class TecnicoTIPerfil
{
    public int Id { get; set; }
    public int UsuarioId { get; set; }
    public string AreaAtuacao { get; set; }       // Era "Especialidade"
                                                   // Valores: "Hardware", "Software", "Rede"
    public DateTime DataContratacao { get; set; }
    
    public Usuario Usuario { get; set; }
    public ICollection<Chamado> ChamadosAtribuidos { get; set; }
}
```

#### `Backend/Core/Entities/Usuario.cs`
```csharp
// Atualizar relacionamentos e comentários

public class Usuario
{
    // ... propriedades existentes ...
    
    // ANTES
    public AlunoPerfil? AlunoPerfil { get; set; }
    public ProfessorPerfil? ProfessorPerfil { get; set; }
    
    // DEPOIS
    public ColaboradorPerfil? ColaboradorPerfil { get; set; }
    public TecnicoTIPerfil? TecnicoTIPerfil { get; set; }
}
```

### 1.2. Atualizar DbContext

**Arquivo:** `Backend/Data/ApplicationDbContext.cs`

```csharp
public class ApplicationDbContext : DbContext
{
    // ANTES
    public DbSet<AlunoPerfil> AlunoPerfis { get; set; }
    public DbSet<ProfessorPerfil> ProfessorPerfis { get; set; }
    
    // DEPOIS
    public DbSet<ColaboradorPerfil> ColaboradorPerfis { get; set; }
    public DbSet<TecnicoTIPerfil> TecnicoTIPerfis { get; set; }
    
    // ... resto do código ...
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Atualizar configurações de entidade
        modelBuilder.Entity<ColaboradorPerfil>(/* ... */);
        modelBuilder.Entity<TecnicoTIPerfil>(/* ... */);
    }
}
```

---

## ===================================================================
## FASE 2: BACKEND - LÓGICA DE NEGÓCIO (30 minutos)
## ===================================================================

### 2.1. DTOs (Data Transfer Objects)

**Criar novos arquivos:**

#### `Backend/Application/DTOs/ColaboradorPerfilDTO.cs`
```csharp
public class ColaboradorPerfilDTO
{
    public int Id { get; set; }
    public string Matricula { get; set; }
    public string Departamento { get; set; }
    public DateTime DataAdmissao { get; set; }
}
```

#### `Backend/Application/DTOs/TecnicoTIPerfilDTO.cs`
```csharp
public class TecnicoTIPerfilDTO
{
    public int Id { get; set; }
    public string AreaAtuacao { get; set; }
    public DateTime DataContratacao { get; set; }
    public int TotalChamadosAtribuidos { get; set; }
}
```

### 2.2. Controllers

**Arquivos a modificar:**

#### `Backend/API/Controllers/UsuariosController.cs`
- Atualizar métodos de registro
- Trocar referências de `AlunoPerfil` → `ColaboradorPerfil`
- Trocar referências de `ProfessorPerfil` → `TecnicoTIPerfil`

#### `Backend/API/Controllers/ChamadosController.cs`
- Atualizar lógica de atribuição de técnicos
- Ajustar queries de `ProfessorPerfil` → `TecnicoTIPerfil`

### 2.3. Services

#### `Backend/Application/Services/UsuarioService.cs`
- Atualizar métodos de criação de perfis
- Ajustar validações

#### `Backend/Application/Services/ChamadoService.cs`
- Atualizar lógica de atribuição automática
- Ajustar queries para buscar técnicos por área de atuação

---

## ===================================================================
## FASE 3: MIGRATIONS E SEED DATA (15 minutos)
## ===================================================================

### 3.1. Criar Migration de Renomeação

```powershell
cd Backend
dotnet ef migrations add RenomearParaContextoEmpresarial
```

**Arquivo gerado:** `Migrations/[timestamp]_RenomearParaContextoEmpresarial.cs`

```csharp
public partial class RenomearParaContextoEmpresarial : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        // Renomear tabelas
        migrationBuilder.RenameTable(
            name: "AlunoPerfis",
            newName: "ColaboradorPerfis");
            
        migrationBuilder.RenameTable(
            name: "ProfessorPerfis",
            newName: "TecnicoTIPerfis");
        
        // Renomear colunas
        migrationBuilder.RenameColumn(
            name: "Curso",
            table: "ColaboradorPerfis",
            newName: "Departamento");
            
        migrationBuilder.RenameColumn(
            name: "DataMatricula",
            table: "ColaboradorPerfis",
            newName: "DataAdmissao");
            
        migrationBuilder.RenameColumn(
            name: "Especialidade",
            table: "TecnicoTIPerfis",
            newName: "AreaAtuacao");
    }
    
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        // Reverter mudanças
        migrationBuilder.RenameTable(
            name: "ColaboradorPerfis",
            newName: "AlunoPerfis");
            
        // ... resto do rollback ...
    }
}
```

### 3.2. Atualizar Seed Data

**Arquivo:** `Backend/Data/ApplicationDbContext.cs` (método OnModelCreating)

```csharp
// Atualizar categorias
modelBuilder.Entity<Categoria>().HasData(
    new Categoria 
    { 
        Id = 1, 
        Nome = "Hardware", 
        Descricao = "Problemas com equipamentos e periféricos",
        // ...
    },
    new Categoria 
    { 
        Id = 2, 
        Nome = "Software", 
        Descricao = "Problemas com aplicativos e sistemas",
        // ...
    },
    new Categoria 
    { 
        Id = 3, 
        Nome = "Rede", 
        Descricao = "Problemas de conectividade e acesso",
        // ...
    }
);

// Atualizar usuários de exemplo
modelBuilder.Entity<Usuario>().HasData(
    new Usuario 
    { 
        Id = 1,
        NomeCompleto = "João Silva",
        Email = "colaborador@empresa.com",
        TipoUsuario = 1, // Colaborador
        // ...
    },
    new Usuario 
    { 
        Id = 2,
        NomeCompleto = "Maria Santos",
        Email = "tecnico@empresa.com",
        TipoUsuario = 2, // Técnico TI
        // ...
    }
);
```

### 3.3. Executar Migration

```powershell
dotnet ef database update
```

---

## ===================================================================
## FASE 4: MOBILE - APLICATIVO (45 minutos)
## ===================================================================

### 4.1. Models

**Renomear arquivos:**

- `Mobile/Models/Entities/AlunoPerfil.cs` → `ColaboradorPerfil.cs`
- `Mobile/Models/Entities/ProfessorPerfil.cs` → `TecnicoTIPerfil.cs`

**Atualizar conteúdo similar ao backend.**

### 4.2. Services

#### `Mobile/Services/Auth/AuthService.cs`
- Atualizar métodos de registro
- Ajustar DTOs

#### `Mobile/Services/Chamados/ChamadoService.cs`
- Atualizar queries
- Ajustar serialização JSON

### 4.3. ViewModels

#### `Mobile/ViewModels/LoginViewModel.cs`
- Atualizar mensagens de erro/sucesso
- Ajustar textos

#### `Mobile/ViewModels/NovoChamadoViewModel.cs`
- Atualizar labels das categorias
- Ajustar placeholder texts

### 4.4. Views (XAML)

**Arquivos principais:**

#### `Mobile/Views/Auth/LoginPage.xaml`
```xml
<!-- ANTES -->
<Label Text="Sistema de Chamados - Faculdade" />
<Label Text="Aluno, Professor ou Administrador" />

<!-- DEPOIS -->
<Label Text="Sistema de Suporte Técnico" />
<Label Text="Colaborador, Técnico TI ou Administrador" />
```

#### `Mobile/Views/Chamados/NovoChamadoPage.xaml`
```xml
<!-- Atualizar placeholders -->
<Entry Placeholder="Descreva o problema técnico..." />

<!-- Atualizar labels de categoria -->
<Label Text="Hardware" />
<Label Text="Software" />
<Label Text="Rede" />
```

#### `Mobile/Views/MainPage.xaml`
```xml
<!-- Atualizar título -->
<Label Text="Suporte Técnico - Empresa" />
```

### 4.5. Resources (Strings)

**Criar arquivo:** `Mobile/Resources/Strings/AppStrings.cs`

```csharp
public static class AppStrings
{
    // Títulos
    public const string AppName = "Suporte Técnico TI";
    public const string LoginTitle = "Acesso ao Sistema";
    
    // Tipos de Usuário
    public const string TipoColaborador = "Colaborador";
    public const string TipoTecnicoTI = "Técnico de TI";
    public const string TipoAdministrador = "Administrador";
    
    // Categorias
    public const string CategoriaHardware = "Hardware";
    public const string CategoriaSoftware = "Software";
    public const string CategoriaRede = "Rede";
    
    // Mensagens
    public const string MsgChamadoCriado = "Chamado registrado! Nossa equipe entrará em contato.";
    public const string MsgSemChamados = "Nenhum chamado técnico registrado.";
}
```

---

## ===================================================================
## FASE 5: DOCUMENTAÇÃO (30 minutos)
## ===================================================================

### 5.1. README.md Principal

**Mudanças:**

```markdown
# ANTES
# 🎓 Sistema de Chamados - Faculdade
> Sistema de gerenciamento de chamados técnicos para ambiente acadêmico

## Para Alunos
- Criar chamados com descrição do problema

## Para Professores
- Atribuição automática como técnico

# DEPOIS
# 🏢 Sistema de Suporte Técnico - Empresa
> Sistema de centralização e otimização do suporte técnico de TI empresarial

## Para Colaboradores
- Registrar chamados técnicos via web ou mobile

## Para Técnicos de TI
- Gestão da fila de chamados e atualização de status
```

### 5.2. WORKFLOWS.md

**Atualizar workflows:**

```markdown
# Workflow 1: Colaborador Registra Chamado
1. Colaborador acessa sistema
2. Descreve problema técnico
3. IA classifica automaticamente (Hardware/Software/Rede)
4. Sistema atribui técnico de TI
5. Colaborador recebe notificação

# Workflow 2: Técnico de TI Atende Chamado
1. Técnico visualiza fila de chamados
2. Atualiza status (Pendente → Em Andamento)
3. Resolve problema
4. Atualiza status (Resolvido)
5. Colaborador é notificado
```

### 5.3. docs/INDEX.md

Atualizar toda referência a:
- Faculdade → Empresa
- Aluno → Colaborador
- Professor → Técnico de TI

### 5.4. Credenciais de Teste

**Arquivo:** Criar novo documento com credenciais empresariais

```markdown
# Usuários de Teste

| Tipo | Email | Senha | Descrição |
|------|-------|-------|-----------|
| Colaborador | colaborador@empresa.com | Colab@123 | Funcionário solicitante |
| Técnico TI | tecnico@empresa.com | TecnicoTI@123 | Analista de suporte |
| Admin | admin@empresa.com | Admin@123 | Administrador do sistema |
```

### 5.5. Atualizar Diagramas (se existirem)

- Diagrama de casos de uso
- Diagrama de classes
- Fluxogramas

---

## ===================================================================
## FASE 6: SCRIPTS POWERSHELL (15 minutos)
## ===================================================================

### 6.1. Scripts de Setup

**Atualizar mensagens de output:**

#### `Scripts/Database/InicializarBanco.ps1`
```powershell
# ANTES
Write-Host "Criando usuarios de teste (Aluno, Professor, Admin)..."

# DEPOIS
Write-Host "Criando usuarios de teste (Colaborador, Tecnico TI, Admin)..."
```

#### `Scripts/Teste/TestarAPI.ps1`
```powershell
# Atualizar endpoints de teste
# Ajustar exemplos de requisições
```

---

## ===================================================================
## CHECKLIST DE VALIDAÇÃO
## ===================================================================

### Backend ✅
- [ ] Entidades renomeadas (ColaboradorPerfil, TecnicoTIPerfil)
- [ ] DbContext atualizado
- [ ] DTOs criados/atualizados
- [ ] Controllers atualizados
- [ ] Services atualizados
- [ ] Migration criada e executada
- [ ] Seed data atualizado
- [ ] API compilando sem erros
- [ ] Swagger acessível

### Mobile ✅
- [ ] Models renomeados
- [ ] Services atualizados
- [ ] ViewModels atualizados
- [ ] Views (XAML) atualizadas
- [ ] Strings centralizadas
- [ ] App compilando sem erros
- [ ] Navegação funcional
- [ ] Chamados sendo criados corretamente

### Documentação ✅
- [ ] README.md atualizado
- [ ] WORKFLOWS.md atualizado
- [ ] docs/INDEX.md atualizado
- [ ] Credenciais de teste atualizadas
- [ ] Guias técnicos revisados

### Scripts ✅
- [ ] InicializarBanco.ps1 atualizado
- [ ] TestarAPI.ps1 atualizado
- [ ] Mensagens de output atualizadas

### Testes ✅
- [ ] Login funcional (3 tipos)
- [ ] Criar chamado (Colaborador)
- [ ] Visualizar chamados (Técnico TI)
- [ ] IA classificando corretamente
- [ ] Categorias corretas (Hardware, Software, Rede)
- [ ] Mobile conectando com API
- [ ] Notificações funcionando

---

## 🚀 Ordem de Execução Recomendada

```
1. FASE 1: Backend - Entidades (30 min)
   ├── Renomear classes
   ├── Atualizar relacionamentos
   └── Atualizar DbContext

2. FASE 2: Backend - Lógica (30 min)
   ├── Criar/atualizar DTOs
   ├── Atualizar Controllers
   └── Atualizar Services

3. FASE 3: Migrations (15 min)
   ├── Criar migration
   ├── Atualizar seed data
   └── Executar migration
   └── TESTAR: dotnet run (API deve iniciar)

4. FASE 4: Mobile (45 min)
   ├── Renomear Models
   ├── Atualizar Services
   ├── Atualizar ViewModels
   └── Atualizar Views
   └── TESTAR: Compilar e executar

5. FASE 5: Documentação (30 min)
   ├── Atualizar README.md
   ├── Atualizar WORKFLOWS.md
   └── Atualizar docs/

6. FASE 6: Scripts (15 min)
   └── Atualizar mensagens

7. VALIDAÇÃO FINAL (30 min)
   └── Executar checklist completo
```

---

## ⚠️ Pontos de Atenção

### Possíveis Problemas

1. **Migration pode falhar se houver dados existentes**
   - **Solução**: Fazer backup do banco antes
   - **Comando**: `.\Scripts\Database\AnalisarBanco.ps1` para verificar dados

2. **Referências em código comentado**
   - **Ação**: Buscar por "Aluno", "Professor" em TODO o código
   - **Comando**: Fazer grep no projeto inteiro

3. **JSON Serialization no Mobile**
   - **Ação**: Testar chamadas à API após mudanças
   - **Verificar**: Deserialização de ColaboradorPerfil e TecnicoTIPerfil

4. **Navegação pode quebrar**
   - **Ação**: Testar todos os fluxos no mobile

### Backup Antes de Começar

```powershell
# Backup do banco
.\Scripts\Database\AnalisarBanco.ps1

# Commit atual
git add -A
git commit -m "backup: antes da migracao para contexto empresarial"
git push origin mobile-simplified
```

---

## 📊 Estimativa de Tempo Detalhada

| Fase | Duração | Complexidade |
|------|---------|--------------|
| Fase 1: Backend - Entidades | 30 min | ⭐⭐⭐ |
| Fase 2: Backend - Lógica | 30 min | ⭐⭐⭐⭐ |
| Fase 3: Migrations | 15 min | ⭐⭐ |
| Fase 4: Mobile | 45 min | ⭐⭐⭐⭐ |
| Fase 5: Documentação | 30 min | ⭐⭐ |
| Fase 6: Scripts | 15 min | ⭐ |
| Validação e Testes | 30 min | ⭐⭐⭐ |
| **TOTAL** | **2h 45min** | - |

---

## ✅ Resultado Esperado

Ao final da migração, teremos:

✅ Sistema renomeado para contexto empresarial  
✅ Entidades refletindo o novo domínio  
✅ Banco de dados atualizado  
✅ Interface mobile adaptada  
✅ Documentação completa e atualizada  
✅ Zero breaking changes (compatibilidade mantida)  
✅ Código semanticamente correto  
✅ Sistema profissional e escalável  

---

**Pronto para começar?** 🚀

Digite "INICIAR" para começarmos pela Fase 1!
