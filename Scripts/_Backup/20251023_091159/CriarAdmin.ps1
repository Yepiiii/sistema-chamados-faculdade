# Script para criar usuário administrador
Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Criar Usuário Administrador" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Preencha os dados do administrador:" -ForegroundColor Yellow
$nomeCompleto = Read-Host "Nome Completo"
$email = Read-Host "Email"
$senha = Read-Host "Senha" -AsSecureString
$senhaTexto = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($senha))

Write-Host ""
Write-Host "Criando usuário administrador..." -ForegroundColor Yellow

try {
    $adminBody = @{
        NomeCompleto = $nomeCompleto
        Email = $email
        Senha = $senhaTexto
    } | ConvertTo-Json

    Write-Host "Endpoint: POST http://localhost:5246/api/usuarios/registrar-admin" -ForegroundColor Gray

    $response = Invoke-RestMethod -Uri "http://localhost:5246/api/usuarios/registrar-admin" -Method POST -Body $adminBody -ContentType "application/json" -ErrorAction Stop
    
    Write-Host ""
    Write-Host "[OK] Administrador criado com sucesso!" -ForegroundColor Green
    Write-Host "ID: $($response.id)" -ForegroundColor Cyan
    Write-Host "Nome: $($response.nomeCompleto)" -ForegroundColor Cyan
    Write-Host "Email: $($response.email)" -ForegroundColor Cyan
    Write-Host "Tipo: Administrador (3)" -ForegroundColor Cyan
}
catch {
    Write-Host ""
    Write-Host "[ERRO] $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host "Detalhes: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
