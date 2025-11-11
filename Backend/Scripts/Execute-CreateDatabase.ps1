param(
    [string]$ServerName = "localhost",
    [string]$DatabaseName = "SistemaChamados"
)

$ErrorActionPreference = "Stop"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$sqlScriptPath = Join-Path $scriptPath "CreateDatabaseSchema.sql"
$tempScriptPath = Join-Path $env:TEMP "CreateTablesOnly_$(Get-Date -Format 'yyyyMMddHHmmss').sql"

function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Err { Write-Host $args -ForegroundColor Red }

Write-Info "========================================="
Write-Info "  Script de Criacao do Banco de Dados"
Write-Info "========================================="
Write-Info ""

if (-not (Test-Path $sqlScriptPath)) {
    Write-Err "Arquivo CreateDatabaseSchema.sql nao encontrado"
    exit 1
}

Write-Success "Arquivo SQL encontrado"

try {
    $null = Get-Command sqlcmd -ErrorAction Stop
    Write-Success "sqlcmd encontrado"
} catch {
    Write-Err "sqlcmd nao encontrado"
    exit 1
}

Write-Info "Testando conexao com SQL Server: $ServerName"
try {
    $testQuery = "SELECT 1"
    sqlcmd -S $ServerName -E -Q $testQuery -h -1 | Out-Null
    Write-Success "Conexao bem-sucedida"
} catch {
    Write-Err "Nao foi possivel conectar ao servidor SQL"
    exit 1
}

Write-Info "Verificando se o banco '$DatabaseName' ja existe..."
$checkDb = "SELECT name FROM sys.databases WHERE name = '$DatabaseName'"
$dbExists = sqlcmd -S $ServerName -E -Q $checkDb -h -1 2>&1

if ($dbExists -match $DatabaseName) {
    Write-Warning "O banco '$DatabaseName' ja existe!"
    $response = Read-Host "Deseja DELETAR e RECRIAR o banco? (S/N)"
    
    if ($response -eq 'S' -or $response -eq 's') {
        Write-Info "Deletando banco existente..."
        try {
            $dropDb = "USE master; ALTER DATABASE [$DatabaseName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$DatabaseName];"
            sqlcmd -S $ServerName -E -Q $dropDb | Out-Null
            Write-Success "Banco deletado com sucesso"
        } catch {
            Write-Err "Erro ao deletar banco"
            exit 1
        }
    } else {
        Write-Warning "Operacao cancelada"
        exit 0
    }
}

Write-Info "Criando banco de dados '$DatabaseName'..."
try {
    $createDb = "CREATE DATABASE [$DatabaseName]"
    sqlcmd -S $ServerName -E -Q $createDb | Out-Null
    Write-Success "Banco '$DatabaseName' criado com sucesso"
} catch {
    Write-Err "Erro ao criar banco"
    exit 1
}

Write-Info "Extraindo comandos de criacao de tabelas..."
$scriptContent = Get-Content $sqlScriptPath -Raw
$useDbPattern = "USE \[$DatabaseName\]"
$scriptParts = $scriptContent -split $useDbPattern

if ($scriptParts.Count -lt 2) {
    Write-Err "Nao foi possivel encontrar 'USE [$DatabaseName]' no script SQL"
    exit 1
}

$tablesOnlyScript = "USE [$DatabaseName]`r`n" + $scriptParts[1]
$tablesOnlyScript | Out-File -FilePath $tempScriptPath -Encoding UTF8
Write-Success "Script modificado salvo"

Write-Info "Executando criacao de tabelas..."
try {
    $output = sqlcmd -S $ServerName -E -i $tempScriptPath 2>&1
    
    # Mostrar output do sqlcmd
    if ($output) {
        Write-Info "Output do SQL:"
        $output | ForEach-Object { Write-Host $_ -ForegroundColor Gray }
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Err "Erro ao executar script (Exit Code: $LASTEXITCODE)"
        exit 1
    }
    Write-Success "Tabelas criadas com sucesso"
} catch {
    Write-Err "Erro ao executar script"
    exit 1
} finally {
    if (Test-Path $tempScriptPath) {
        Remove-Item $tempScriptPath -Force
    }
}

Write-Info "Verificando tabelas criadas..."
$listTables = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME"
$tables = sqlcmd -S $ServerName -d $DatabaseName -E -Q $listTables -h -1 2>&1

if ($tables) {
    Write-Success "`nTabelas criadas no banco '$DatabaseName':"
    $tables -split "`n" | Where-Object { $_.Trim() -ne "" } | ForEach-Object {
        Write-Info "   - $_"
    }
}

Write-Info ""
Write-Success "========================================="
Write-Success "  Banco de dados criado com sucesso!"
Write-Success "========================================="
