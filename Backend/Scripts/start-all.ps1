# Script para iniciar o Backend do Sistema de Chamados NeuroHelp
# Autor: Sistema de Chamados
# Data: 2025-11-10

Write-Host "🚀 Iniciando Backend NeuroHelp..." -ForegroundColor Cyan
Write-Host ""

# Navega para a pasta do Backend
$backendPath = Split-Path -Parent $PSScriptRoot
Set-Location $backendPath

Write-Host "📁 Diretório: $backendPath" -ForegroundColor Gray
Write-Host ""

# Verifica se já existe algum processo rodando na porta 5246
Write-Host "🔍 Verificando processos em execução..." -ForegroundColor Yellow
$process = Get-Process -Name "SistemaChamados" -ErrorAction SilentlyContinue

if ($process) {
    Write-Host "⚠️  Backend já está rodando (PID: $($process.Id))" -ForegroundColor Yellow
    $response = Read-Host "Deseja reiniciar? (S/N)"
    
    if ($response -eq "S" -or $response -eq "s") {
        Write-Host "🛑 Parando processo anterior..." -ForegroundColor Red
        Stop-Process -Name "SistemaChamados" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    } else {
        Write-Host "✅ Mantendo processo atual em execução" -ForegroundColor Green
        exit 0
    }
}

# Compila o projeto
Write-Host "🔨 Compilando projeto..." -ForegroundColor Cyan
dotnet build --configuration Release --no-incremental

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro na compilação!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Compilação concluída!" -ForegroundColor Green
Write-Host ""

# Exibe informações do banco
Write-Host "📊 Configuração do Banco de Dados:" -ForegroundColor Cyan
$config = Get-Content "appsettings.json" | ConvertFrom-Json
$useSqlite = $config.UseSqliteForDemo

if ($useSqlite) {
    Write-Host "   Tipo: SQLite (Demo)" -ForegroundColor Yellow
    Write-Host "   Arquivo: sistemachamados_demo.db" -ForegroundColor Gray
} else {
    Write-Host "   Tipo: SQL Server (Produção)" -ForegroundColor Green
    Write-Host "   Server: localhost" -ForegroundColor Gray
    Write-Host "   Database: SistemaChamados" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🌐 Servidor: http://0.0.0.0:5246" -ForegroundColor Green
Write-Host "📖 Swagger: http://localhost:5246/swagger" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔐 Credenciais NeuroHelp:" -ForegroundColor Magenta
Write-Host "   Admin: admin@neurohelp.com.br / Admin@123" -ForegroundColor Gray
Write-Host "   Técnico: rafael.costa@neurohelp.com.br / Tecnico@123" -ForegroundColor Gray
Write-Host "   Usuário: juliana.martins@neurohelp.com.br / User@123" -ForegroundColor Gray
Write-Host ""
Write-Host "Iniciando servidor... (Pressione Ctrl+C para parar)" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor DarkGray
Write-Host ""

# Inicia o servidor
dotnet run
