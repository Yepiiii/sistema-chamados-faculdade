# Script para iniciar a API em background
Write-Host "Iniciando API em nova janela..." -ForegroundColor Cyan

$scriptBlock = {
    Set-Location "C:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade\Backend"
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host "    SERVIDOR API BACKEND" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Iniciando servidor..." -ForegroundColor Yellow
    dotnet run
}

Start-Process powershell -ArgumentList "-NoExit", "-Command", $scriptBlock

Write-Host "API sendo iniciada em nova janela!" -ForegroundColor Green
Write-Host "Aguarde aparecer: 'Now listening on: http://localhost:5246'" -ForegroundColor Yellow
Write-Host ""
Write-Host "Depois execute:" -ForegroundColor Cyan
Write-Host ".\TestarIAComHandoff2.ps1" -ForegroundColor White
