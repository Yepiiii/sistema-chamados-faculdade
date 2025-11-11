# 🗄️ Guia de Configuração do Banco de Dados

Este guia ensina como configurar o banco de dados **SistemaChamados** no SQL Server.

---

## 📋 Pré-requisitos

✅ **SQL Server 2019 ou superior** instalado  
✅ **SQL Server Management Studio (SSMS)** ou **Azure Data Studio**  
✅ Permissões de administrador no SQL Server

---

## 🚀 Método 1: Criação Automática via Entity Framework (Recomendado)

### Passo 1: Configure a Connection String

Edite o arquivo `Backend/appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=SistemaChamados;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true"
  }
}
```

> **💡 Dica:** Se usar autenticação SQL Server, altere para:
> ```
> Server=localhost;Database=SistemaChamados;User Id=seu_usuario;Password=sua_senha;TrustServerCertificate=True
> ```

### Passo 2: Execute a Aplicação

```powershell
cd Backend
dotnet run
```

✅ O Entity Framework criará o banco **automaticamente** na primeira execução!

### Passo 3: Popular com Dados Iniciais

O sistema já vem com **seed data** automático que cria:
- ✅ 4 Categorias (Hardware, Software, Redes, Infraestrutura)
- ✅ 4 Prioridades (Baixa, Média, Alta, Crítica)
- ✅ 5 Status (Aberto, Em Andamento, Aguardando Cliente, Resolvido, Fechado)
- ✅ 6 Usuários (1 Admin, 3 Técnicos, 2 Clientes)

---

## 🛠️ Método 2: Criação Manual via Script SQL

Se preferir criar o banco manualmente:

### Passo 1: Abra o SSMS

1. Conecte-se ao seu SQL Server
2. Clique em **File → Open → File**
3. Navegue até: `Backend/Scripts/CreateDatabaseSchema.sql`

### Passo 2: Execute o Script

```sql
-- Ou copie e cole o conteúdo do arquivo CreateDatabaseSchema.sql
-- e execute (F5)
```

### Passo 3: Popular Dados Iniciais

Execute a aplicação uma vez para popular os dados:

```powershell
cd Backend
dotnet run
```

---

## 📊 Estrutura do Banco

### Tabelas Criadas:

| Tabela | Descrição |
|--------|-----------|
| **Usuarios** | Clientes, Técnicos e Admins |
| **Categorias** | Tipos de problemas (Hardware, Software, etc.) |
| **Prioridades** | Níveis de urgência (Baixa, Média, Alta, Crítica) |
| **Status** | Estados do chamado (Aberto, Em Andamento, etc.) |
| **Chamados** | Tickets/chamados abertos |
| **Comentarios** | Histórico de comunicação |
| **Anexos** | Arquivos enviados |

### Relacionamentos:

```
Usuarios (1) ----< (N) Chamados (Solicitante)
Usuarios (1) ----< (N) Chamados (Técnico)
Categorias (1) --< (N) Chamados
Prioridades (1) -< (N) Chamados
Status (1) ------< (N) Chamados
Chamados (1) ----< (N) Comentarios
Chamados (1) ----< (N) Anexos
```

---

## 👥 Usuários Padrão Criados

Após o seed, você terá acesso com:

### 🔑 Admin
- **Email:** `admin@neurohelp.com.br`
- **Senha:** `Admin@123`
- **Tipo:** Administrador

### 👨‍💻 Técnicos
| Nome | Email | Senha | Especialidade |
|------|-------|-------|---------------|
| Rafael Costa | rafael.costa@neurohelp.com.br | Tecnico@123 | Hardware |
| Ana Paula Silva | ana.silva@neurohelp.com.br | Tecnico@123 | Software |
| Bruno Ferreira | bruno.ferreira@neurohelp.com.br | Tecnico@123 | Redes |

### 👤 Clientes
| Nome | Email | Senha |
|------|-------|-------|
| Juliana Martins | juliana.martins@neurohelp.com.br | User@123 |
| Marcelo Santos | marcelo.santos@neurohelp.com.br | User@123 |

---

## 🔄 Resetar o Banco de Dados

Se precisar recomeçar do zero:

### Opção 1: Deletar e Recriar

```sql
USE master;
DROP DATABASE SistemaChamados;
```

Depois execute a aplicação novamente ou rode o script `CreateDatabaseSchema.sql`.

### Opção 2: Usar Script de Reset

```powershell
cd Backend/Scripts
.\reset-database.ps1
```

---

## ⚠️ Troubleshooting

### Erro: "Cannot open database"
**Solução:** Verifique se o SQL Server está rodando:
```powershell
Get-Service MSSQLSERVER
```

### Erro: "Login failed for user"
**Solução:** Ajuste a connection string para usar autenticação SQL:
```json
"DefaultConnection": "Server=localhost;Database=SistemaChamados;User Id=sa;Password=SUA_SENHA;TrustServerCertificate=True"
```

### Erro: "A network-related error"
**Solução:** Habilite TCP/IP no SQL Server Configuration Manager

---

## 📚 Recursos Adicionais

- **Migrations:** `Backend/Migrations/` - Histórico de alterações do schema
- **Seed Data:** `Backend/Data/Seed/DatabaseSeed.cs` - Dados iniciais
- **Scripts Úteis:** `Backend/Scripts/` - Scripts SQL auxiliares

---

## ✅ Verificação Final

Teste se tudo está funcionando:

```sql
-- No SSMS, execute:
USE SistemaChamados;

SELECT COUNT(*) AS TotalUsuarios FROM Usuarios;
SELECT COUNT(*) AS TotalCategorias FROM Categorias;
SELECT COUNT(*) AS TotalPrioridades FROM Prioridades;
SELECT COUNT(*) AS TotalStatus FROM Status;
```

**Resultado esperado:**
- TotalUsuarios: **6**
- TotalCategorias: **4**
- TotalPrioridades: **4**
- TotalStatus: **5**

---

🎉 **Pronto!** Seu banco de dados está configurado e pronto para uso!
