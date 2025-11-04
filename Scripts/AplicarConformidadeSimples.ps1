# Script simplificado de conformidade
$ErrorActionPreference = "Continue"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "CONFORMIDADE 100% COM REPOSITORIO REMOTO" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Ler appsettings
$appsettings = Get-Content "appsettings.json" | ConvertFrom-Json
$connectionString = $appsettings.ConnectionStrings.DefaultConnection

# Extrair server e database usando regex simples
$server = "localhost"
$database = "SistemaChamados"

Write-Host "Servidor: $server" -ForegroundColor Green
Write-Host "Banco: $database" -ForegroundColor Green
Write-Host ""

Write-Host "Este script ira:" -ForegroundColor Yellow
Write-Host "  1. Adicionar Status Violado" -ForegroundColor Gray
Write-Host "  2. Remover Status extras" -ForegroundColor Gray
Write-Host "  3. Ajustar Prioridades" -ForegroundColor Gray
Write-Host "  4. Ajustar Categorias" -ForegroundColor Gray
Write-Host "  5. Adicionar usuario admin do remoto" -ForegroundColor Gray
Write-Host ""

$confirmation = Read-Host "Continuar? (S/N)"
if ($confirmation -ne 'S' -and $confirmation -ne 's') {
    Write-Host "Cancelado." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Executando..." -ForegroundColor Yellow

sqlcmd -S $server -d $database -i "Scripts\AjustarConformidade100.sql" -E

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "CONCLUIDO!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
