# Script para iniciar a aplicação Web ASP.NET Core
# Serve os arquivos estáticos do wwwroot em http://localhost:8080

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Sistema de Chamados - Web Frontend" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$webPath = Join-Path (Join-Path $PSScriptRoot "..") "Frontend\Web"

if (-Not (Test-Path $webPath)) {
    Write-Host "Erro: Pasta Web não encontrada em $webPath" -ForegroundColor Red
    exit 1
}

Write-Host "Iniciando aplicação Web..." -ForegroundColor Yellow
Write-Host "URL: http://localhost:8080" -ForegroundColor Green
Write-Host ""
Write-Host "Pressione Ctrl+C para parar o servidor." -ForegroundColor Gray
Write-Host ""

# Inicia a aplicação ASP.NET Core
Set-Location $webPath
dotnet run
