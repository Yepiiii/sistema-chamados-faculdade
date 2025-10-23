# Script para limpar todos os chamados do banco de dados
Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Limpar Chamados do Sistema" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$confirmar = Read-Host "ATENÇÃO: Isso irá excluir TODOS os chamados do banco de dados. Deseja continuar? (S/N)"

if ($confirmar -ne "S" -and $confirmar -ne "s") {
    Write-Host "Operação cancelada." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Limpando chamados..." -ForegroundColor Yellow

# SQL para deletar todos os chamados
$sqlScript = @"
-- Deletar todos os chamados
DELETE FROM [Chamados];

-- Resetar o IDENTITY (auto-increment) para começar do 1 novamente
DBCC CHECKIDENT ('[Chamados]', RESEED, 0);

-- Verificar se foi limpo
SELECT COUNT(*) as TotalChamados FROM [Chamados];
"@

# Salvar SQL em arquivo temporário
$tempSqlFile = Join-Path $env:TEMP "limpar_chamados.sql"
$sqlScript | Out-File -FilePath $tempSqlFile -Encoding UTF8

# Detectar caminhos relativos
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$backendPath = Join-Path $repoRoot "Backend"
$appsettingsPath = Join-Path $backendPath "appsettings.json"

# Executar SQL usando sqlcmd
try {
    Write-Host "Executando limpeza no SQL Server..." -ForegroundColor Cyan
    
    # Pegar connection string do appsettings.json
    if (-not (Test-Path $appsettingsPath)) {
        Write-Host "[ERRO] appsettings.json não encontrado em: $appsettingsPath" -ForegroundColor Red
        exit 1
    }
    
    $appsettings = Get-Content $appsettingsPath | ConvertFrom-Json
    $connectionString = $appsettings.ConnectionStrings.DefaultConnection
    
    # Extrair server e database da connection string
    if ($connectionString -match "Server=([^;]+)") {
        $server = $matches[1]
    }
    if ($connectionString -match "Database=([^;]+)") {
        $database = $matches[1]
    }
    
    Write-Host "Server: $server" -ForegroundColor Gray
    Write-Host "Database: $database" -ForegroundColor Gray
    Write-Host ""
    
    # Executar com sqlcmd
    $result = sqlcmd -S $server -d $database -E -i $tempSqlFile -h -1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Chamados excluídos com sucesso!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Resultado:" -ForegroundColor Cyan
        $result | ForEach-Object { Write-Host $_ -ForegroundColor White }
    }
    else {
        Write-Host "[ERRO] Falha ao executar SQL" -ForegroundColor Red
    }
}
catch {
    Write-Host "[ERRO] $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    # Limpar arquivo temporário
    if (Test-Path $tempSqlFile) {
        Remove-Item $tempSqlFile -Force
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
