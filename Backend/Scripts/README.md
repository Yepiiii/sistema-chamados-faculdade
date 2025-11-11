# Scripts de banco — how to apply

Este arquivo explica como aplicar o script T-SQL gerado por EF Migrations (`align-db-schema-sqlserver.sql`) e também como exportar/importar uma cópia completa do banco (bacpac / bak) via SSMS / SqlPackage.

IMPORTANTE: sempre faça backup do banco antes de aplicar scripts em ambientes de produção.

## 1) Aplicar o script T-SQL (recomendado para alinhar schema)
Arquivo: `Backend/Scripts/align-db-schema-sqlserver.sql`

1. Abra o SQL Server Management Studio (SSMS) e conecte-se ao servidor de destino (por exemplo, `localhost`).
2. Crie ou selecione o banco de dados alvo. Se preferir criar via script, o script é idempotente e cria tabelas quando necessário.
3. Abra o arquivo `align-db-schema-sqlserver.sql` no editor do SSMS.
4. Revise o conteúdo (procure por alterações que afetam dados) e, se estiver tudo ok, execute (F5).

Observações:
- O script foi gerado a partir das migrations do projeto e contém verificações `IF NOT EXISTS` para reduzir o risco de aplicar duas vezes.
- Após aplicar o script, execute a aplicação (Backend) para que o `DatabaseSeed.Seed(context)` insira os dados de seed.

## 2) Exportar um .bacpac (schema + dados) do servidor de produção
Use este fluxo quando você quiser a cópia exata com dados reais.

### A) Usando SSMS (GUI)
1. No SSMS, clique com o botão direito no banco `SistemaChamados` → `Tasks` → `Export Data-tier Application...`.
2. Siga o wizard e salve o arquivo `.bacpac` em um local seguro.

### B) Usando SqlPackage.exe (CLI)
No servidor/PC onde tem acesso ao banco, execute (PowerShell):

```powershell
# Ajuste SourceServerName e SourceDatabaseName
& "C:\Program Files\Microsoft SQL Server\150\DAC\bin\SqlPackage.exe" /Action:Export /SourceServerName:"<SERVER>" /SourceDatabaseName:"SistemaChamados" /TargetFile:"C:\temp\SistemaChamados.bacpac"
```

Substitua `<SERVER>` por `localhost` ou por `server\instance` conforme necessário.

## 3) Importar / restaurar .bacpac no PC local
### A) Via SSMS (GUI)
- No SSMS do PC local: Databases → Right-click → `Deploy Data-tier Application...` → escolha o .bacpac e siga o wizard.

### B) Via SqlPackage.exe (CLI)
```powershell
& "C:\Program Files\Microsoft SQL Server\150\DAC\bin\SqlPackage.exe" /Action:Import /TargetServerName:"localhost" /TargetDatabaseName:"SistemaChamados_Local" /SourceFile:"C:\temp\SistemaChamados.bacpac" /TargetUser:sa /TargetPassword:"Your_password123"
```

## 4) Exportar e restaurar .bak (backup)
Se preferir usar .bak (backup/restore), faça no servidor de origem:
- No SSMS: Right-click database → Tasks → Back Up... → salve .bak
- No destino: Restore Database → escolha .bak e restaure (ajuste caminhos de MDF/LDF conforme necessário).

Exemplo T-SQL (restore):
```sql
RESTORE DATABASE [SistemaChamados]
FROM DISK = N'C:\backups\SistemaChamados.bak'
WITH REPLACE,
MOVE N'SistemaChamados' TO N'C:\MSSQL\Data\SistemaChamados.mdf',
MOVE N'SistemaChamados_log' TO N'C:\MSSQL\Data\SistemaChamados_log.ldf';
```

## 5) Alternativa: usar Docker com SQL Server
Se você não quiser instalar SQL Server no PC local, use o container oficial:

```powershell
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Your_password123" -p 1433:1433 --name sql1 -d mcr.microsoft.com/mssql/server:2019-latest
```

Depois importe o `.bacpac` para esse container (conecte com SSMS em `localhost,1433`).

## 6) Passo a passo simples (recomendado para desenvolvedores locais)
1. Baixe `Backend/Scripts/align-db-schema-sqlserver.sql` do repositório.
2. No SSMS conectado ao `localhost`, crie um novo database `SistemaChamados_Local` (opcional) e execute o script.
3. Inicie a API localmente: abra PowerShell na pasta `Backend` e rode `dotnet run` — isso aplicará migrations restantes (se houver) e executará o seed.

---

Se quiser, posso:
- Gerar um `.bacpac` (mas preciso que você rode os comandos no servidor e me entregue o arquivo — por segurança eu não conecto ao seu servidor).
- Ajudar a adaptar o script se sua versão do SQL Server for diferente.
- Fornecer um PowerShell script pronto que execute `SqlPackage.exe` com parâmetros que você só precise ajustar.

Selecione o que prefere que eu faça a seguir: gerar o script PowerShell para export .bacpac, gerar instruções T-SQL adicionais, ou limpar o `appsettings.json` temporário criado no repositório.