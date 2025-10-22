# Script Rapido - Promover Usuario para Administrador
# Para usar quando a API ja esta rodando

Write-Host "`n=== PROMOVER USUARIO PARA ADMINISTRADOR ===" -ForegroundColor Cyan

# Verifica se API esta rodando
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5246/swagger" -Method Get -TimeoutSec 3 -ErrorAction Stop
    Write-Host "API esta rodando (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "ERRO: API nao esta rodando!" -ForegroundColor Red
    Write-Host "Execute primeiro: .\IniciarSistema.ps1`n" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "INSTRUCOES:" -ForegroundColor Yellow
Write-Host "1. Abra SQL Server Management Studio (SSMS)" -ForegroundColor White
Write-Host "2. Conecte em: (localdb)\mssqllocaldb" -ForegroundColor Gray
Write-Host "3. Execute esta query:" -ForegroundColor White
Write-Host ""
Write-Host "USE SistemaChamadosDB;" -ForegroundColor Yellow
Write-Host "GO" -ForegroundColor Yellow
Write-Host ""
Write-Host "-- Promover usuario para Administrador" -ForegroundColor Green
Write-Host "UPDATE Usuarios" -ForegroundColor Yellow
Write-Host "SET TipoUsuario = 3" -ForegroundColor Yellow
Write-Host "WHERE Email = 'admin@teste.com';" -ForegroundColor Yellow
Write-Host ""
Write-Host "-- Verificar" -ForegroundColor Green
Write-Host "SELECT Id, Nome, Email, TipoUsuario, Ativo" -ForegroundColor Yellow
Write-Host "FROM Usuarios" -ForegroundColor Yellow
Write-Host "WHERE Email = 'admin@teste.com';" -ForegroundColor Yellow
Write-Host ""
Write-Host "Tipos de usuario:" -ForegroundColor Cyan
Write-Host "  1 = Solicitante" -ForegroundColor Gray
Write-Host "  2 = Tecnico" -ForegroundColor Gray
Write-Host "  3 = Administrador (pode encerrar chamados)" -ForegroundColor Green
Write-Host ""
Write-Host "Apos promover, teste no app mobile!" -ForegroundColor Cyan
Write-Host ""
