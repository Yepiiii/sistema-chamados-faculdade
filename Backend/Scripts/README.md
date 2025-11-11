# Scripts de Banco de Dados

Este diret√≥rio cont√©m scripts para gerenciar o banco de dados SistemaChamados.

---

## üÜï Execute-CreateDatabase.ps1 (NOVO!)

**Script PowerShell automatizado para criar o banco de dados em qualquer PC.**

### Como usar:

```powershell
# Uso b√°sico (localhost)
.\Execute-CreateDatabase.ps1

# Com SQL Server Express
.\Execute-CreateDatabase.ps1 -ServerName ".\SQLEXPRESS"

# Com servidor/inst√¢ncia espec√≠fica
.\Execute-CreateDatabase.ps1 -ServerName "SERVIDOR\INSTANCIA"
```

### O que faz:
- ‚úÖ Cria o banco SistemaChamados automaticamente
- ‚úÖ Executa o CreateDatabaseSchema.sql
- ‚úÖ Contorna problemas de caminhos espec√≠ficos
- ‚úÖ Verifica conex√£o e permiss√µes
- ‚úÖ Lista tabelas criadas
- ‚úÖ Funciona em qualquer PC com SQL Server

**[Ver documenta√ß√£o completa abaixo](#execute-createdatabaseps1-documenta√ß√£o)**

---

## Scripts de Migrations ‚Äî how to apply

Este arquivo tamb√©m explica como aplicar o script T-SQL gerado por EF Migrations (`align-db-schema-sqlserver.sql`) e como exportar/importar uma c√≥pia completa do banco (bacpac / bak) via SSMS / SqlPackage.

IMPORTANTE: sempre fa√ßa backup do banco antes de aplicar scripts em ambientes de produ√ß√£o.

---

## üöÄ M√âTODO R√ÅPIDO (Recomendado)

### Aplicar Schema Alignment com PowerShell

Execute o script automatizado:

```powershell
.\Backend\Scripts\apply-schema-alignment.ps1
```

O script ir√°:
1. Solicitar credenciais do SQL Server
2. Aplicar todas as altera√ß√µes de schema necess√°rias
3. Confirmar sucesso ou erro

---

## 1) Aplicar o script T-SQL manualmente (SSMS)
Arquivo: `Backend/Scripts/align-db-schema.sql`

1. Abra o SQL Server Management Studio (SSMS) e conecte-se ao servidor de destino (por exemplo, `localhost`).
2. Crie ou selecione o banco de dados alvo. Se preferir criar via script, o script √© idempotente e cria tabelas quando necess√°rio.
3. Abra o arquivo `align-db-schema-sqlserver.sql` no editor do SSMS.
4. Revise o conte√∫do (procure por altera√ß√µes que afetam dados) e, se estiver tudo ok, execute (F5).

Observa√ß√µes:
- O script foi gerado a partir das migrations do projeto e cont√©m verifica√ß√µes `IF NOT EXISTS` para reduzir o risco de aplicar duas vezes.
- Ap√≥s aplicar o script, execute a aplica√ß√£o (Backend) para que o `DatabaseSeed.Seed(context)` insira os dados de seed.

## 2) Exportar um .bacpac (schema + dados) do servidor de produ√ß√£o
Use este fluxo quando voc√™ quiser a c√≥pia exata com dados reais.

### A) Usando SSMS (GUI)
1. No SSMS, clique com o bot√£o direito no banco `SistemaChamados` ‚Üí `Tasks` ‚Üí `Export Data-tier Application...`.
2. Siga o wizard e salve o arquivo `.bacpac` em um local seguro.

### B) Usando SqlPackage.exe (CLI)
No servidor/PC onde tem acesso ao banco, execute (PowerShell):

```powershell
# Ajuste SourceServerName e SourceDatabaseName
& "C:\Program Files\Microsoft SQL Server\150\DAC\bin\SqlPackage.exe" /Action:Export /SourceServerName:"<SERVER>" /SourceDatabaseName:"SistemaChamados" /TargetFile:"C:\temp\SistemaChamados.bacpac"
```

Substitua `<SERVER>` por `localhost` ou por `server\instance` conforme necess√°rio.

## 3) Importar / restaurar .bacpac no PC local
### A) Via SSMS (GUI)
- No SSMS do PC local: Databases ‚Üí Right-click ‚Üí `Deploy Data-tier Application...` ‚Üí escolha o .bacpac e siga o wizard.

### B) Via SqlPackage.exe (CLI)
```powershell
& "C:\Program Files\Microsoft SQL Server\150\DAC\bin\SqlPackage.exe" /Action:Import /TargetServerName:"localhost" /TargetDatabaseName:"SistemaChamados_Local" /SourceFile:"C:\temp\SistemaChamados.bacpac" /TargetUser:sa /TargetPassword:"Your_password123"
```

## 4) Exportar e restaurar .bak (backup)
Se preferir usar .bak (backup/restore), fa√ßa no servidor de origem:
- No SSMS: Right-click database ‚Üí Tasks ‚Üí Back Up... ‚Üí salve .bak
- No destino: Restore Database ‚Üí escolha .bak e restaure (ajuste caminhos de MDF/LDF conforme necess√°rio).

Exemplo T-SQL (restore):
```sql
RESTORE DATABASE [SistemaChamados]
FROM DISK = N'C:\backups\SistemaChamados.bak'
WITH REPLACE,
MOVE N'SistemaChamados' TO N'C:\MSSQL\Data\SistemaChamados.mdf',
MOVE N'SistemaChamados_log' TO N'C:\MSSQL\Data\SistemaChamados_log.ldf';
```

## 5) Alternativa: usar Docker com SQL Server
Se voc√™ n√£o quiser instalar SQL Server no PC local, use o container oficial:

```powershell
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Your_password123" -p 1433:1433 --name sql1 -d mcr.microsoft.com/mssql/server:2019-latest
```

Depois importe o `.bacpac` para esse container (conecte com SSMS em `localhost,1433`).

## 6) Passo a passo simples (recomendado para desenvolvedores locais)
1. Baixe `Backend/Scripts/align-db-schema-sqlserver.sql` do reposit√≥rio.
2. No SSMS conectado ao `localhost`, crie um novo database `SistemaChamados_Local` (opcional) e execute o script.
3. Inicie a API localmente: abra PowerShell na pasta `Backend` e rode `dotnet run` ‚Äî isso aplicar√° migrations restantes (se houver) e executar√° o seed.

---

Se quiser, posso:
- Gerar um `.bacpac` (mas preciso que voc√™ rode os comandos no servidor e me entregue o arquivo ‚Äî por seguran√ßa eu n√£o conecto ao seu servidor).
- Ajudar a adaptar o script se sua vers√£o do SQL Server for diferente.
- Fornecer um PowerShell script pronto que execute `SqlPackage.exe` com par√¢metros que voc√™ s√≥ precise ajustar.

Selecione o que prefere que eu fa√ßa a seguir: gerar o script PowerShell para export .bacpac, gerar instru√ß√µes T-SQL adicionais, ou limpar o `appsettings.json` tempor√°rio criado no reposit√≥rio.

---

# Execute-CreateDatabase.ps1 (DocumentaÁ„o)

## Vis„o Geral

Script PowerShell para criar o banco de dados SistemaChamados a partir do arquivo `CreateDatabaseSchema.sql` em qualquer PC.

## PrÈ-requisitos

- SQL Server instalado (qualquer vers„o)
- SQL Server Command Line Tools (sqlcmd)
- PowerShell 5.1 ou superior
- Permissıes de administrador no SQL Server

## Uso

### B·sico (SQL Server padr„o - localhost)

``powershell
cd Backend\Scripts
.\Execute-CreateDatabase.ps1
``

### Com SQL Server Express

``powershell
.\Execute-CreateDatabase.ps1 -ServerName ".\SQLEXPRESS"
``

### Com servidor remoto

``powershell
.\Execute-CreateDatabase.ps1 -ServerName "SERVIDOR\INSTANCIA" -DatabaseName "SistemaChamados"
``

## Par‚metros

- **ServerName** (opcional): Nome do servidor SQL Server
  - Padr„o: `localhost`
  - Exemplos: `localhost`, `.\SQLEXPRESS`, `192.168.1.100`, `SERVIDOR\SQLEXPRESS`

- **DatabaseName** (opcional): Nome do banco de dados a ser criado
  - Padr„o: `SistemaChamados`

## Processo de ExecuÁ„o

1. ? Verifica se o arquivo `CreateDatabaseSchema.sql` existe
2. ? Testa a conex„o com o SQL Server
3. ? Verifica se o banco j· existe (pergunta se quer deletar)
4. ? Cria o banco de dados
5. ? Extrai apenas a parte de criaÁ„o de tabelas do SQL
6. ? Executa o script modificado
7. ? Lista as tabelas criadas
8. ? Limpa arquivos tempor·rios

## Resultado Esperado

``
=========================================
  Script de CriaÁ„o do Banco de Dados
=========================================

?? Arquivo SQL encontrado
? sqlcmd encontrado
?? Testando conex„o com SQL Server: localhost
? Conex„o bem-sucedida
???  Criando banco de dados 'SistemaChamados'...
? Banco 'SistemaChamados' criado com sucesso
??  Executando criaÁ„o de tabelas...
? Tabelas criadas com sucesso

? Tabelas criadas no banco 'SistemaChamados':
   ?? __EFMigrationsHistory
   ?? Anexos
   ?? Categorias
   ?? Chamados
   ?? Comentarios
   ?? Prioridades
   ?? Status
   ?? Usuarios

=========================================
  ? Banco de dados criado com sucesso!
=========================================
``

## SoluÁ„o de Problemas

### Erro: sqlcmd n„o encontrado

Instale o SQL Server Command Line Tools:
https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility

### Erro: N„o foi possÌvel conectar ao servidor SQL

- Verifique se o SQL Server est· rodando
- Verifique o nome do servidor/inst‚ncia
- Verifique suas permissıes

### Erro: Banco j· existe

O script perguntar· se vocÍ quer deletar e recriar, ou delete manualmente:

``sql
USE master;
ALTER DATABASE [SistemaChamados] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE [SistemaChamados];
``

## PrÛximos Passos

### 1. Popular com dados iniciais

``powershell
cd ..\
dotnet run
``

O backend detectar· o banco vazio e executar· o seeding autom·tico.

### 2. Ou restaurar um backup

``sql
RESTORE DATABASE [SistemaChamados] 
FROM DISK = 'C:\Backups\SistemaChamados_20251111_180552.bak'
WITH REPLACE;
``

## Vantagens deste Script

- ?? **Automatizado**: Executa todo o processo com um comando
- ?? **FlexÌvel**: Funciona com qualquer inst‚ncia SQL Server
- ??? **Seguro**: Pergunta antes de deletar banco existente
- ?? **Informativo**: Mostra progresso e resultado detalhado
- ?? **Limpo**: Remove arquivos tempor·rios automaticamente
- ? **Confi·vel**: Verifica cada etapa antes de prosseguir
