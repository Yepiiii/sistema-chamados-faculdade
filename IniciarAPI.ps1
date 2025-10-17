# Script simplificado para iniciar e manter API rodando
Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Iniciando API" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Matar processos anteriores
Get-Process | Where-Object {$_.ProcessName -like "*SistemaChamados*"} | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# Iniciar API
Set-Location "c:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade"
Write-Host "`nIniciando API em http://localhost:5246..." -ForegroundColor Green
Write-Host "Pressione Ctrl+C para parar`n" -ForegroundColor Yellow

dotnet run --project SistemaChamados.csproj --urls http://localhost:5246
