# Script para sincronizar arquivos do Frontend/Desktop para Frontend/wwwroot
# Executar sempre que modificar arquivos em Frontend/Desktop

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SINCRONIZANDO FRONTEND" -ForegroundColor Cyan
Write-Host "  Desktop -> wwwroot" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = $PSScriptRoot
$projectRoot = Split-Path $scriptDir -Parent
$sourcePath = Join-Path $projectRoot "Frontend\Desktop"
$destPath = Join-Path $projectRoot "Frontend\wwwroot"

if (-not (Test-Path $sourcePath)) {
    Write-Host "ERRO: Pasta Frontend/Desktop não encontrada!" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $destPath)) {
    Write-Host "ERRO: Pasta Frontend/wwwroot não encontrada!" -ForegroundColor Red
    exit 1
}

Write-Host "Origem: $sourcePath" -ForegroundColor Yellow
Write-Host "Destino: $destPath" -ForegroundColor Yellow
Write-Host ""

try {
    # Copiar todos os arquivos
    Copy-Item -Path "$sourcePath\*" -Destination $destPath -Recurse -Force -ErrorAction Stop
    
    Write-Host "✅ Arquivos sincronizados com sucesso!" -ForegroundColor Green
    Write-Host ""
    
    # Mostrar arquivos modificados
    Write-Host "Arquivos principais atualizados:" -ForegroundColor Cyan
    Get-ChildItem -Path $destPath -File | Where-Object { $_.Extension -in @('.html', '.js', '.css') } | 
        Select-Object Name, LastWriteTime | 
        Format-Table -AutoSize
    
} catch {
    Write-Host "❌ ERRO ao sincronizar arquivos:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "IMPORTANTE: Execute 'start-frontend.ps1' para ver as mudanças no navegador!" -ForegroundColor Yellow
Write-Host ""
