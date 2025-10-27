# 🗄️ Guia de Configuração - SQL Server 2022/2025

## 📋 Status da Migração

✅ **CONCLUÍDO** - Sistema migrado para SQL Server Management Studio 21

---

## 🔧 Configuração Realizada

### 1. Connection String Atualizada

**Arquivo:** `Backend/appsettings.json`

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=SistemaChamados;Integrated Security=True;TrustServerCertificate=True;",
    "DefaultConnection_LocalDB": "Server=(localdb)\\mssqllocaldb;Database=SistemaChamados;Trusted_Connection=True;"
  }
}
```

**Mudança:**
- ❌ `Server=(localdb)\\mssqllocaldb` (LocalDB - Windows only)
- ✅ `Server=localhost` (SQL Server 2022 - Multiplataforma)
- ✅ `TrustServerCertificate=True` (Certificados self-signed)

---

## 🚀 Como Usar

### Opção 1: SQL Server Local (Padrão)

**Pré-requisitos:**
- SQL Server 2022/2025 instalado
- SQL Server Management Studio 21
- Serviço SQL Server rodando

**Passos:**
1. Abra **SQL Server Management Studio**
2. Conecte em: `localhost` ou `.\SQLEXPRESS`
3. Execute o sistema: `.\IniciarWeb.ps1`
4. Backend cria automaticamente o banco `SistemaChamados`

### Opção 2: Voltar para LocalDB (Opcional)

Se preferir usar LocalDB novamente:

1. Edite `Backend/appsettings.json`:
```json
"DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=SistemaChamados;Trusted_Connection=True;"
```

2. Reinicie o backend

---

## 🔐 Connection Strings Disponíveis

### SQL Server Local (Atual)
```
Server=localhost;Database=SistemaChamados;Integrated Security=True;TrustServerCertificate=True;
```

### SQL Server com Usuário/Senha
```
Server=localhost;Database=SistemaChamados;User Id=sa;Password=SuaSenha;TrustServerCertificate=True;
```

### SQL Server Remoto
```
Server=192.168.1.100;Database=SistemaChamados;User Id=usuario;Password=senha;TrustServerCertificate=True;
```

### SQL Express
```
Server=.\SQLEXPRESS;Database=SistemaChamados;Integrated Security=True;TrustServerCertificate=True;
```

### LocalDB (Backup)
```
Server=(localdb)\\mssqllocaldb;Database=SistemaChamados;Trusted_Connection=True;
```

---

## 🛠️ Solução de Problemas

### Erro: "Cannot open database"

**Solução:**
```sql
-- Conecte no SSMS e execute:
CREATE DATABASE SistemaChamados;
GO

-- Ou deixe o backend criar automaticamente (EnsureCreated)
```

### Erro: "Login failed for user"

**Solução 1 - Windows Authentication:**
```json
"Integrated Security=True"
```

**Solução 2 - SQL Authentication:**
```json
"User Id=sa;Password=SuaSenha"
```

### Erro: "A connection was successfully established but an error occurred during the login"

**Solução:**
Adicione `TrustServerCertificate=True` na connection string

### Erro: "The server was not found"

**Verificar:**
1. SQL Server está rodando?
   ```powershell
   Get-Service -Name "MSSQLSERVER" | Start-Service
   ```

2. Porta correta (1433)?
   ```powershell
   Test-NetConnection -ComputerName localhost -Port 1433
   ```

---

## 📊 Vantagens do SQL Server vs LocalDB

| Recurso | LocalDB | SQL Server |
|---------|---------|------------|
| **Multiplataforma** | ❌ Windows only | ✅ Windows/Linux |
| **Ferramentas** | ⚠️ Limitadas | ✅ SSMS completo |
| **Performance** | ⚠️ Básica | ✅ Otimizada |
| **Rede** | ❌ Local only | ✅ Acesso remoto |
| **Backup** | ⚠️ Manual | ✅ Automático |
| **Monitoramento** | ❌ Nenhum | ✅ Completo |
| **Produção** | ❌ Não recomendado | ✅ Pronto |

---

## 🗄️ Gerenciamento do Banco

### Conectar via SSMS

1. Abra **SQL Server Management Studio 21**
2. **Server name:** `localhost` ou `.\SQLEXPRESS`
3. **Authentication:** Windows Authentication
4. Clique em **Connect**

### Ver Tabelas

```sql
USE SistemaChamados;
GO

-- Listar todas as tabelas
SELECT * FROM INFORMATION_SCHEMA.TABLES;

-- Ver dados
SELECT * FROM Usuarios;
SELECT * FROM Chamados;
SELECT * FROM Categorias;
```

### Backup do Banco

```sql
BACKUP DATABASE SistemaChamados
TO DISK = 'C:\Backup\SistemaChamados.bak'
WITH FORMAT, INIT, COMPRESSION;
```

### Restaurar Backup

```sql
RESTORE DATABASE SistemaChamados
FROM DISK = 'C:\Backup\SistemaChamados.bak'
WITH REPLACE;
```

### Limpar Banco (Reset)

```sql
-- CUIDADO: Apaga todos os dados!
USE master;
GO
DROP DATABASE SistemaChamados;
GO

-- Backend recria automaticamente na próxima execução
```

---

## 🔄 Migração de Dados (LocalDB → SQL Server)

Se você já tem dados no LocalDB e quer migrar:

### Opção 1: Backup/Restore (Recomendado)

```sql
-- 1. Backup do LocalDB
BACKUP DATABASE SistemaChamados
TO DISK = 'C:\Temp\SistemaChamados_LocalDB.bak';

-- 2. Restore no SQL Server
RESTORE DATABASE SistemaChamados
FROM DISK = 'C:\Temp\SistemaChamados_LocalDB.bak'
WITH MOVE 'SistemaChamados' TO 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\SistemaChamados.mdf',
     MOVE 'SistemaChamados_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\SistemaChamados_log.ldf';
```

### Opção 2: Script de Dados

```powershell
# 1. Gerar script no SSMS:
# - Tasks → Generate Scripts
# - Selecione todas as tabelas
# - Marque "Script data"

# 2. Execute o script no SQL Server
```

### Opção 3: Deixar Backend Recriar (Dados Perdidos)

```powershell
# Simplesmente rode com nova connection string
# Backend recria banco vazio
.\IniciarWeb.ps1
```

---

## 🎯 Próximos Passos

1. ✅ **Testar Conexão**
   ```powershell
   .\IniciarWeb.ps1
   # Backend deve conectar e criar banco automaticamente
   ```

2. ✅ **Verificar no SSMS**
   - Abra SSMS
   - Conecte em `localhost`
   - Verifique se banco `SistemaChamados` existe

3. ✅ **Testar Aplicação**
   - Acesse: http://localhost:5246/
   - Faça login com: admin@sistema.com / Admin@123
   - Crie um chamado de teste

4. 📝 **Documentar**
   - Se usar servidor remoto, atualize connection string
   - Documente credenciais no .env (NÃO commitar!)

---

## 📞 Suporte

**Erro não resolvido?**
1. Verifique logs do backend no terminal
2. Verifique SQL Server Event Viewer
3. Teste connection string no SSMS primeiro

**Gerado em:** 27/10/2025  
**Versão:** Sistema de Chamados v1.0  
**Database:** SQL Server 2022/2025 (SSMS 21)
