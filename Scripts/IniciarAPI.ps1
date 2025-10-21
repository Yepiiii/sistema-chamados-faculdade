# Script simplificado para iniciar e manter API rodando
Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Iniciando API" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Detectar caminhos relativos
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$backendPath = Join-Path $repoRoot "Backend"

# Matar processos anteriores
Get-Process | Where-Object {$_.ProcessName -like "*SistemaChamados*"} | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# Iniciar API
Set-Location $backendPath
Write-Host "`nIniciando API em http://localhost:5246..." -ForegroundColor Green
Write-Host "Pressione Ctrl+C para parar`n" -ForegroundColor Yellow

dotnet run --project SistemaChamados.csproj --urls http://localhost:5246
