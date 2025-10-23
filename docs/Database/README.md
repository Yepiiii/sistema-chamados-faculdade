# 🗄️ Guia de Inicialização do Banco de Dados - GuiNRB

## 📋 Pré-requisitos

- ✅ SQL Server LocalDB instalado
- ✅ .NET SDK 8.0
- ✅ Entity Framework Core Tools

---

## 🚀 Método 1: Script Automático (Recomendado)

### Inicialização Completa

```powershell
# Navegar para o diretório do projeto
cd "c:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade"

# Executar script de inicialização
.\InicializarBanco.ps1
```

### Reinicialização (Dropar e Recriar)

```powershell
.\InicializarBanco.ps1 -DropDatabase
```

### Com Usuário Administrador

```powershell
.\InicializarBanco.ps1 -SeedUsers
```

---

## 🔧 Método 2: Passo a Passo Manual

### 1️⃣ Instalar EF Core Tools

```powershell
dotnet tool install --global dotnet-ef
```

### 2️⃣ Navegar para o Backend

```powershell
cd "c:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade\Backend"
```

### 3️⃣ Aplicar Migrations

```powershell
# Ver migrations disponíveis
dotnet ef migrations list

# Aplicar todas as migrations
dotnet ef database update
```

Migrations existentes:
- ✅ `20250916055117_FinalCorrectMigration` - Estrutura inicial
- ✅ `20250919050750_AdicionaTabelasDeChamados` - Tabelas de chamados
- ✅ `20250929155628_AdicionaEspecialidadeCategoriaId` - Especialidades
- ✅ `20251017172146_AdicionaTecnicoAtribuido` - Técnico atribuído

### 4️⃣ Executar Seed Data (SQL)

**Opção A: Via SSMS (SQL Server Management Studio)**
1. Conectar em: `   `
2. Abrir arquivo: `Backend\Scripts\01_SeedData.sql`
3. Executar (F5)

**Opção B: Via sqlcmd (Linha de comando)**
```powershell
sqlcmd -S "(localdb)\mssqllocaldb" -i "Backend\Scripts\01_SeedData.sql"
```

### 5️⃣ Iniciar API (Seed Automático)

```powershell
# A API cria os dados básicos automaticamente ao iniciar
cd Backend
dotnet run
```

---

## 📊 Estrutura do Banco Criada

### Tabelas

```
SistemaChamadosDB
├── Usuarios
│   ├── Id (PK)
│   ├── Nome
│   ├── Email (unique)
│   ├── Senha (hash BCrypt)
│   ├── TipoUsuario (1=Solicitante, 2=Técnico, 3=Admin)
│   └── Ativo
│
├── Categorias
│   ├── Id (PK)
│   ├── Nome
│   └── Descricao
│
├── Prioridades
│   ├── Id (PK)
│   ├── Nome
│   ├── Descricao
│   └── Nivel (1-3)
│
├── Status
│   ├── Id (PK)
│   ├── Nome
│   └── Descricao
│
├── Especialidades
│   ├── Id (PK)
│   ├── Nome
│   └── CategoriaId (FK)
│
└── Chamados
    ├── Id (PK)
    ├── Titulo
    ├── Descricao
    ├── DataAbertura
    ├── DataFechamento (nullable)
    ├── SolicitanteId (FK → Usuarios)
    ├── TecnicoId (FK → Usuarios, nullable)
    ├── CategoriaId (FK → Categorias)
    ├── PrioridadeId (FK → Prioridades)
    └── StatusId (FK → Status)
```

### Dados Iniciais (Seed)

**Categorias (3 registros):**
- Infraestrutura
- Sistemas Acadêmicos
- Conta e Acesso

**Prioridades (3 registros):**
- Baixa (Nível 1)
- Média (Nível 2)
- Alta (Nível 3)

**Status (4 registros):**
- Aberto
- Em andamento
- Resolvido
- **Fechado** ⭐ *Necessário para endpoint `/fechar`*

---

## 👤 Criar Usuário Administrador

### Método 1: Via API (Recomendado)

1. **Iniciar API:**
   ```powershell
   .\IniciarSistema.ps1
   ```

2. **Registrar via Swagger:**
   - Abrir: http://localhost:5246/swagger
   - Endpoint: `POST /auth/register`
   - Body:
     ```json
     {
       "nome": "Administrador",
       "email": "admin@teste.com",
       "senha": "Admin123!",
       "tipoUsuario": 1
     }
     ```

3. **Promover para Administrador via SQL:**
   ```sql
   USE SistemaChamadosDB;
   
   UPDATE Usuarios 
   SET TipoUsuario = 3 
   WHERE Email = 'admin@teste.com';
   
   -- Verificar
   SELECT Id, Nome, Email, TipoUsuario, Ativo
   FROM Usuarios
   WHERE Email = 'admin@teste.com';
   ```

### Método 2: Via SQL Direto

**⚠️ Atenção:** A senha deve ser hash BCrypt. Use a API para criar o usuário.

Se quiser criar diretamente via SQL (não recomendado):
```sql
-- Primeiro registre via API, depois promova:
UPDATE Usuarios SET TipoUsuario = 3 WHERE Email = 'seu@email.com';
```

---

## 🔍 Verificar Banco de Dados

### Via SQL

```sql
USE SistemaChamadosDB;

-- Verificar todas as tabelas
SELECT 
    'Categorias' AS Tabela, COUNT(*) AS Total FROM Categorias
UNION ALL
SELECT 'Prioridades', COUNT(*) FROM Prioridades
UNION ALL
SELECT 'Status', COUNT(*) FROM Status
UNION ALL
SELECT 'Usuarios', COUNT(*) FROM Usuarios
UNION ALL
SELECT 'Chamados', COUNT(*) FROM Chamados;

-- Verificar status (deve ter "Fechado")
SELECT * FROM Status;

-- Verificar usuários administradores
SELECT Id, Nome, Email, TipoUsuario, Ativo
FROM Usuarios
WHERE TipoUsuario = 3;
```

### Via PowerShell

```powershell
# Listar migrations aplicadas
cd Backend
dotnet ef migrations list

# Ver última migration
dotnet ef migrations list --json | ConvertFrom-Json | Select-Object -Last 1
```

---

## 🐛 Solução de Problemas

### Erro: "The term 'dotnet-ef' is not recognized"

**Solução:**
```powershell
dotnet tool install --global dotnet-ef
dotnet tool update --global dotnet-ef
```

### Erro: "A network-related or instance-specific error"

**Solução:**
```powershell
# Verificar se LocalDB está rodando
sqllocaldb info

# Iniciar LocalDB se necessário
sqllocaldb start mssqllocaldb

# Criar instância se não existir
sqllocaldb create mssqllocaldb
```

### Erro: "Database does not exist"

**Solução:**
```powershell
cd Backend
dotnet ef database update
```

### Status "Fechado" não existe

**Solução:**
```sql
USE SistemaChamadosDB;

INSERT INTO Status (Nome, Descricao)
VALUES ('Fechado', 'Chamado encerrado pelo administrador');
```

Ou reinicie a API (ela adiciona automaticamente se não existir).

### Usuário não consegue encerrar chamado (HTTP 403)

**Causa:** Apenas usuários com `TipoUsuario = 3` (Administrador) podem encerrar.

**Solução:**
```sql
UPDATE Usuarios 
SET TipoUsuario = 3 
WHERE Email = 'seu@email.com';
```

---

## 📦 Backup e Restore

### Criar Backup

```sql
USE master;
GO

BACKUP DATABASE SistemaChamadosDB
TO DISK = 'C:\Backup\SistemaChamadosDB.bak'
WITH FORMAT, INIT;
GO
```

### Restaurar Backup

```sql
USE master;
GO

RESTORE DATABASE SistemaChamadosDB
FROM DISK = 'C:\Backup\SistemaChamadosDB.bak'
WITH REPLACE;
GO
```

---

## 🎯 Checklist de Inicialização

- [ ] SQL Server LocalDB instalado
- [ ] .NET SDK 8.0 instalado
- [ ] EF Core Tools instalado (`dotnet tool install --global dotnet-ef`)
- [ ] Migrations aplicadas (`dotnet ef database update`)
- [ ] Seed data executado (via API ou SQL)
- [ ] Status "Fechado" criado
- [ ] Usuário admin registrado via API
- [ ] Usuário promovido para TipoUsuario = 3
- [ ] API iniciada com sucesso
- [ ] Swagger acessível em http://localhost:5246/swagger

---

## ✅ Próximos Passos

1. **Inicializar banco:**
   ```powershell
   .\InicializarBanco.ps1
   ```

2. **Iniciar sistema:**
   ```powershell
   .\IniciarSistema.ps1
   ```

3. **Registrar usuário admin via Swagger:**
   - POST `/auth/register`

4. **Promover para admin via SQL:**
   ```sql
   UPDATE Usuarios SET TipoUsuario = 3 WHERE Email = 'admin@teste.com';
   ```

5. **Testar no Mobile:**
   - Login com admin@teste.com
   - Criar chamado
   - Encerrar chamado ✅

---

**Connection String:** `Server=(localdb)\\mssqllocaldb;Database=SistemaChamadosDB;Trusted_Connection=true;MultipleActiveResultSets=true`
