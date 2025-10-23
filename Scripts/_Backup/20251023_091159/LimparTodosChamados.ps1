# Script para limpar todos os chamados via API
Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Limpar Todos os Chamados" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Solicitar credenciais
Write-Host "Digite as credenciais de administrador:" -ForegroundColor Yellow
$email = Read-Host "Email"
$senha = Read-Host "Senha" -AsSecureString
$senhaTexto = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($senha))

Write-Host ""
$confirmar = Read-Host "ATENÇÃO: Isso irá excluir TODOS os chamados do sistema. Deseja continuar? (S/N)"

if ($confirmar -ne "S" -and $confirmar -ne "s") {
    Write-Host "Operação cancelada." -ForegroundColor Yellow
    exit
}

Write-Host ""

try {
    # Fazer login
    Write-Host "Fazendo login..." -ForegroundColor Yellow
    $loginBody = @{
        Email = $email
        Senha = $senhaTexto
    } | ConvertTo-Json

    Write-Host "Tentando conectar em http://localhost:5246/api/usuarios/login" -ForegroundColor Gray

    $loginResponse = Invoke-RestMethod -Uri "http://localhost:5246/api/usuarios/login" -Method POST -Body $loginBody -ContentType "application/json" -ErrorAction Stop
    
    if ($null -eq $loginResponse) {
        Write-Host "[ERRO] Resposta de login vazia" -ForegroundColor Red
        exit 1
    }
    
    if ($null -eq $loginResponse.token) {
        Write-Host "[ERRO] Token não recebido. Resposta:" -ForegroundColor Red
        $loginResponse | ConvertTo-Json
        exit 1
    }
    
    $token = $loginResponse.token
    Write-Host "[OK] Autenticado como $($loginResponse.usuario.nomeCompleto)" -ForegroundColor Green
    Write-Host "Tipo de usuário: $($loginResponse.usuario.tipoUsuario)" -ForegroundColor Gray
    
    if ($loginResponse.usuario.tipoUsuario -ne 3) {
        Write-Host ""
        Write-Host "[ERRO] Apenas administradores (TipoUsuario=3) podem executar esta operação." -ForegroundColor Red
        Write-Host "Seu TipoUsuario: $($loginResponse.usuario.tipoUsuario)" -ForegroundColor Yellow
        exit 1
    }

    # Chamar endpoint de limpeza
    Write-Host "`nExcluindo todos os chamados..." -ForegroundColor Yellow
    Write-Host "Endpoint: DELETE http://localhost:5246/api/chamados/limpar-todos" -ForegroundColor Gray
    
    $headers = @{
        Authorization = "Bearer $token"
    }
    
    $resultado = Invoke-RestMethod -Uri "http://localhost:5246/api/chamados/limpar-todos" -Method DELETE -Headers $headers -ErrorAction Stop
    
    Write-Host ""
    Write-Host "[OK] $($resultado.message)" -ForegroundColor Green
    Write-Host "Total excluído: $($resultado.totalExcluido) chamados" -ForegroundColor Cyan
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
