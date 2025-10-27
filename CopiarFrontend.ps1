# Script para copiar Frontend para wwwroot do Backend
# Isso permite que o backend sirva os arquivos estáticos

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Copiando Frontend para Backend/wwwroot" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$FrontendPath = ".\Frontend"
$WwwrootPath = ".\Backend\wwwroot"

# Verifica se a pasta Frontend existe
if (-not (Test-Path $FrontendPath)) {
    Write-Host "[ERRO] Pasta Frontend não encontrada!" -ForegroundColor Red
    exit 1
}

# Cria wwwroot se não existir
if (-not (Test-Path $WwwrootPath)) {
    New-Item -ItemType Directory -Path $WwwrootPath -Force | Out-Null
    Write-Host "[OK] Pasta wwwroot criada" -ForegroundColor Green
}

# Remove conteúdo antigo do wwwroot
Write-Host "[INFO] Limpando wwwroot..." -ForegroundColor Yellow
Remove-Item "$WwwrootPath\*" -Recurse -Force -ErrorAction SilentlyContinue

# Copia todos os arquivos do Frontend
Write-Host "[INFO] Copiando arquivos..." -ForegroundColor Yellow
Copy-Item "$FrontendPath\*" -Destination $WwwrootPath -Recurse -Force

Write-Host ""
Write-Host "[OK] Frontend copiado com sucesso!" -ForegroundColor Green
Write-Host ""
Write-Host "Estrutura copiada:" -ForegroundColor Cyan
Write-Host "  - $WwwrootPath\index.html" -ForegroundColor White
Write-Host "  - $WwwrootPath\assets\" -ForegroundColor White
Write-Host "  - $WwwrootPath\pages\" -ForegroundColor White
Write-Host ""
Write-Host "Acesse: http://localhost:5246/" -ForegroundColor Green
Write-Host "        http://localhost:5246/swagger (API docs)" -ForegroundColor Green
Write-Host ""
