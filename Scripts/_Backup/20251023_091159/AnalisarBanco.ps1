# Script para Executar Analise Completa do Banco de Dados

Write-Host "`n=== ANALISE COMPLETA DO BANCO GuiNRB ===" -ForegroundColor Cyan

$scriptPath = "Backend\Scripts\00_AnaliseCompleta.sql"

# Verifica se o arquivo SQL existe
if (-not (Test-Path $scriptPath)) {
    Write-Host "ERRO: Script SQL nao encontrado: $scriptPath" -ForegroundColor Red
    exit 1
}

Write-Host "Executando analise do banco de dados..." -ForegroundColor Yellow
Write-Host ""

# Verifica se sqlcmd esta disponivel
$sqlcmd = Get-Command sqlcmd -ErrorAction SilentlyContinue

if ($sqlcmd) {
    Write-Host "Usando sqlcmd: $($sqlcmd.Source)" -ForegroundColor Gray
    Write-Host ""
    
    # Executa o script SQL
    $result = & sqlcmd -S "(localdb)\mssqllocaldb" -i $scriptPath -W -s"|" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host $result
        Write-Host ""
        Write-Host "Analise concluida!" -ForegroundColor Green
    } else {
        Write-Host "ERRO ao executar analise:" -ForegroundColor Red
        Write-Host $result
        Write-Host ""
        Write-Host "Possivel causa: Banco de dados nao existe ainda" -ForegroundColor Yellow
        Write-Host "Solucao: Execute .\IniciarSistema.ps1 para criar o banco" -ForegroundColor White
    }
} else {
    Write-Host "sqlcmd nao encontrado!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Opcoes:" -ForegroundColor Cyan
    Write-Host "1. Instalar SQL Server Command Line Tools" -ForegroundColor White
    Write-Host "2. Abrir SSMS e executar manualmente:" -ForegroundColor White
    Write-Host "   - Conectar em: (localdb)\mssqllocaldb" -ForegroundColor Gray
    Write-Host "   - Abrir: $scriptPath" -ForegroundColor Gray
    Write-Host "   - Executar (F5)" -ForegroundColor Gray
}

Write-Host ""
