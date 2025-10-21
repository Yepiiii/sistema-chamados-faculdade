# Script para testar API
Clear-Host
Write-Host "Testando API..." -ForegroundColor Cyan

# Detectar caminhos relativos
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$backendPath = Join-Path $repoRoot "Backend"

# Iniciar API em background
Write-Host "Iniciando API..." -ForegroundColor Green
$apiJob = Start-Job -ScriptBlock {
    param($path)
    Set-Location $path
    dotnet run --urls http://localhost:5246
} -ArgumentList $backendPath

Write-Host "Aguardando API inicializar..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Testar endpoints
Write-Host "`nTestando GET /api/categorias..." -ForegroundColor Cyan
try {
    $categorias = Invoke-RestMethod -Uri "http://localhost:5246/api/categorias" -Method GET
    Write-Host "[OK] Categorias recebidas:" -ForegroundColor Green
    $categorias | ConvertTo-Json -Depth 3
}
catch {
    Write-Host "[ERRO] $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTestando GET /api/prioridades..." -ForegroundColor Cyan
try {
    $prioridades = Invoke-RestMethod -Uri "http://localhost:5246/api/prioridades" -Method GET
    Write-Host "[OK] Prioridades recebidas:" -ForegroundColor Green
    $prioridades | ConvertTo-Json -Depth 3
}
catch {
    Write-Host "[ERRO] $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "API rodando em background (Job ID: $($apiJob.Id))" -ForegroundColor Yellow
Write-Host "Para parar: Stop-Job -Id $($apiJob.Id); Remove-Job -Id $($apiJob.Id)" -ForegroundColor Yellow
Write-Host "Para ver logs: Receive-Job -Id $($apiJob.Id)" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan

$parar = Read-Host "`nDeseja parar a API agora? (S/N)"
if ($parar -eq "S" -or $parar -eq "s") {
    Write-Host "Parando API..." -ForegroundColor Yellow
    Stop-Job -Job $apiJob
    Remove-Job -Job $apiJob
    Write-Host "[OK] API parada" -ForegroundColor Green
}
