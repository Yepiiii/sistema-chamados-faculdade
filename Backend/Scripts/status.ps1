# Script para mostrar status do sistema
# Autor: Sistema de Chamados
# Data: 2025-11-10

Write-Host ""
Write-Host "📊 Status do Sistema NeuroHelp" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

# Navega para a pasta do Backend
$backendPath = Split-Path -Parent $PSScriptRoot
Set-Location $backendPath

# Verifica processos
Write-Host "🔍 Backend:" -ForegroundColor Yellow
$process = Get-Process -Name "SistemaChamados" -ErrorAction SilentlyContinue

if ($process) {
    Write-Host "   ✅ Rodando (PID: $($process.Id))" -ForegroundColor Green
    Write-Host "   🌐 URL: http://0.0.0.0:5246" -ForegroundColor Cyan
    Write-Host "   📖 Swagger: http://localhost:5246/swagger" -ForegroundColor Cyan
} else {
    Write-Host "   ❌ Parado" -ForegroundColor Red
}

Write-Host ""

# Verifica configuração do banco
Write-Host "🗄️  Banco de Dados:" -ForegroundColor Yellow
$config = Get-Content "appsettings.json" | ConvertFrom-Json
$useSqlite = $config.UseSqliteForDemo

if ($useSqlite) {
    Write-Host "   Tipo: SQLite (Demo)" -ForegroundColor Cyan
    Write-Host "   Arquivo: sistemachamados_demo.db" -ForegroundColor Gray
    
    if (Test-Path "sistemachamados_demo.db") {
        $size = (Get-Item "sistemachamados_demo.db").Length / 1KB
        Write-Host "   Tamanho: $([math]::Round($size, 2)) KB" -ForegroundColor Gray
    } else {
        Write-Host "   ⚠️  Arquivo não encontrado" -ForegroundColor Yellow
    }
} else {
    Write-Host "   Tipo: SQL Server (Produção)" -ForegroundColor Cyan
    Write-Host "   Server: localhost" -ForegroundColor Gray
    Write-Host "   Database: SistemaChamados" -ForegroundColor Gray
}

Write-Host ""

# Verifica migrations
Write-Host "📦 Migrations:" -ForegroundColor Yellow
$migrations = Get-ChildItem -Path "Migrations" -Filter "*.cs" -ErrorAction SilentlyContinue | Where-Object { $_.Name -notlike "*Designer.cs" -and $_.Name -notlike "*Snapshot.cs" }

if ($migrations) {
    $migrationCount = $migrations.Count
    Write-Host "   ✅ $migrationCount migration(s) encontrada(s)" -ForegroundColor Green
    $lastMigration = $migrations | Sort-Object Name -Descending | Select-Object -First 1
    Write-Host "   Última: $($lastMigration.BaseName)" -ForegroundColor Gray
} else {
    Write-Host "   ⚠️  Nenhuma migration encontrada" -ForegroundColor Yellow
}

Write-Host ""

# Credenciais
Write-Host "🔐 Credenciais NeuroHelp:" -ForegroundColor Magenta
Write-Host "   👨‍💼 Admin:" -ForegroundColor Cyan
Write-Host "      admin@neurohelp.com.br / Admin@123" -ForegroundColor Gray
Write-Host ""
Write-Host "   🔧 Técnicos:" -ForegroundColor Cyan
Write-Host "      rafael.costa@neurohelp.com.br / Tecnico@123 (Hardware)" -ForegroundColor Gray
Write-Host "      ana.silva@neurohelp.com.br / Tecnico@123 (Software)" -ForegroundColor Gray
Write-Host "      bruno.ferreira@neurohelp.com.br / Tecnico@123 (Redes)" -ForegroundColor Gray
Write-Host ""
Write-Host "   👥 Usuários:" -ForegroundColor Cyan
Write-Host "      juliana.martins@neurohelp.com.br / User@123 (Financeiro)" -ForegroundColor Gray
Write-Host "      marcelo.santos@neurohelp.com.br / User@123 (RH)" -ForegroundColor Gray
Write-Host ""

# Comandos disponíveis
Write-Host "📋 Comandos Disponíveis:" -ForegroundColor Yellow
Write-Host "   .\start-all.ps1      - Inicia o backend" -ForegroundColor Gray
Write-Host "   .\stop-all.ps1       - Para o backend" -ForegroundColor Gray
Write-Host "   .\reset-database.ps1 - Reseta o banco de dados" -ForegroundColor Gray
Write-Host "   .\status.ps1         - Mostra este status" -ForegroundColor Gray
Write-Host ""
