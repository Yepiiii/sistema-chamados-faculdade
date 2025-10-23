# Script para testar endpoint de chamados
Clear-Host
Write-Host "Testando GET /api/chamados..." -ForegroundColor Cyan

try {
    # Primeiro precisamos fazer login para obter o token
    Write-Host "Fazendo login..." -ForegroundColor Yellow
    $loginBody = @{
        Email = "admin@admin.com"
        Senha = "admin123"
    } | ConvertTo-Json

    $loginResponse = Invoke-RestMethod -Uri "http://localhost:5246/api/usuarios/login" -Method POST -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.token
    Write-Host "[OK] Token obtido" -ForegroundColor Green

    # Agora buscar chamados
    Write-Host "`nBuscando chamados..." -ForegroundColor Yellow
    $headers = @{
        Authorization = "Bearer $token"
    }
    
    $chamados = Invoke-RestMethod -Uri "http://localhost:5246/api/chamados" -Method GET -Headers $headers
    
    Write-Host "[OK] Chamados recebidos:" -ForegroundColor Green
    $chamados | ConvertTo-Json -Depth 5
}
catch {
    Write-Host "[ERRO] $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host "Detalhes: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}
