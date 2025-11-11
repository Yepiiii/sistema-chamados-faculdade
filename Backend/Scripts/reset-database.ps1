# Script para resetar completamente o banco de dados
# Autor: Sistema de Chamados
# Data: 2025-11-10

Write-Host "🔄 Reset do Banco de Dados NeuroHelp" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

# Navega para a pasta do Backend
$backendPath = Split-Path -Parent $PSScriptRoot
Set-Location $backendPath

# Verifica a configuração
$config = Get-Content "appsettings.json" | ConvertFrom-Json
$useSqlite = $config.UseSqliteForDemo

Write-Host "⚠️  ATENÇÃO: Esta ação irá DELETAR todos os dados!" -ForegroundColor Red
Write-Host ""

if ($useSqlite) {
    Write-Host "📊 Tipo de Banco: SQLite" -ForegroundColor Yellow
    Write-Host "📁 Arquivo: sistemachamados_demo.db" -ForegroundColor Gray
} else {
    Write-Host "📊 Tipo de Banco: SQL Server" -ForegroundColor Yellow
    Write-Host "🗄️  Database: SistemaChamados" -ForegroundColor Gray
}

Write-Host ""
$response = Read-Host "Deseja continuar? (S/N)"

if ($response -ne "S" -and $response -ne "s") {
    Write-Host "❌ Operação cancelada" -ForegroundColor Red
    exit 0
}

Write-Host ""
Write-Host "🛑 Parando Backend se estiver rodando..." -ForegroundColor Yellow
Stop-Process -Name "SistemaChamados" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

Write-Host "🗑️  Deletando banco de dados..." -ForegroundColor Red
dotnet ef database drop --force

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro ao deletar banco!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Banco deletado!" -ForegroundColor Green
Write-Host ""

Write-Host "🔨 Aplicando migrations..." -ForegroundColor Cyan
dotnet ef database update

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro ao aplicar migrations!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Migrations aplicadas!" -ForegroundColor Green
Write-Host ""

Write-Host "🌱 Populando banco com dados da NeuroHelp..." -ForegroundColor Cyan
Write-Host "   (Isso acontecerá automaticamente ao iniciar o backend)" -ForegroundColor Gray
Write-Host ""

Write-Host "✅ Reset completo!" -ForegroundColor Green
Write-Host ""
Write-Host "▶️  Execute '.\start-all.ps1' para iniciar o backend" -ForegroundColor Cyan
Write-Host ""
