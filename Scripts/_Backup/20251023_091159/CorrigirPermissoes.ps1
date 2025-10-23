# Script para promover usuario admin para Administrador

Write-Host "=== CORRECAO DE PERMISSOES ===" -ForegroundColor Cyan

$apiJob = Get-Job | Where-Object { $_.Name -like "*API*" -or $_.Name -like "*Backend*" }

if (-not $apiJob) {
    Write-Host "API nao esta rodando!" -ForegroundColor Red
    Write-Host "Execute primeiro: .\IniciarSistema.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "API rodando (Job ID: $($apiJob.Id))" -ForegroundColor Green
Write-Host ""
Write-Host "PROBLEMA IDENTIFICADO:" -ForegroundColor Yellow
Write-Host "- O endpoint /chamados/{id}/fechar requer TipoUsuario = 3 (Administrador)" -ForegroundColor White
Write-Host "- Seu usuario pode nao ter essa permissao" -ForegroundColor White
Write-Host ""
Write-Host "SOLUCAO:" -ForegroundColor Cyan
Write-Host "Execute esta query no SQL Server Management Studio (SSMS):" -ForegroundColor White
Write-Host ""
Write-Host "Server: (localdb)\mssqllocaldb" -ForegroundColor Gray
Write-Host "Database: SistemaChamadosDB" -ForegroundColor Gray
Write-Host ""
Write-Host "UPDATE Usuarios SET TipoUsuario = 3 WHERE Email = 'admin@teste.com';" -ForegroundColor Yellow
Write-Host ""
Write-Host "Tipos de usuario:" -ForegroundColor White
Write-Host "  1 = Solicitante" -ForegroundColor Gray
Write-Host "  2 = Tecnico" -ForegroundColor Gray
Write-Host "  3 = Administrador (necessario para encerrar)" -ForegroundColor Gray
Write-Host ""
Write-Host "Apos executar a query, teste novamente no app." -ForegroundColor Green
