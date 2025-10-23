# Script para obter token JWT do sistema
Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Obter Token JWT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se API está rodando
try {
    $healthCheck = Invoke-WebRequest -Uri "http://localhost:5246/api/categorias" -Method Get -TimeoutSec 2 -ErrorAction Stop
    Write-Host "[OK] API está rodando" -ForegroundColor Green
    Write-Host ""
}
catch {
    Write-Host "[ERRO] API não está rodando!" -ForegroundColor Red
    Write-Host "Execute primeiro: .\IniciarAPI.ps1" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Solicitar credenciais
Write-Host "Digite as credenciais para login:" -ForegroundColor Yellow
Write-Host ""

$email = Read-Host "Email (ou Enter para usar admin@sistema.com)"
if ([string]::IsNullOrWhiteSpace($email)) {
    $email = "admin@sistema.com"
}

$senha = Read-Host "Senha (ou Enter para usar Admin@123)" -AsSecureString
if ($senha.Length -eq 0) {
    $senhaPlainText = "Admin@123"
}
else {
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($senha)
    $senhaPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
}

Write-Host ""
Write-Host "Autenticando..." -ForegroundColor Yellow

try {
    # Fazer login
    $body = @{
        Email = $email
        Senha = $senhaPlainText
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "http://localhost:5246/api/usuarios/login" -Method Post -Body $body -ContentType "application/json" -ErrorAction Stop

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  Login Realizado com Sucesso!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "TOKEN JWT:" -ForegroundColor Cyan
    Write-Host $response.token -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "DADOS DO USUÁRIO:" -ForegroundColor Cyan
    Write-Host "ID: $($response.usuario.id)" -ForegroundColor White
    Write-Host "Nome: $($response.usuario.nomeCompleto)" -ForegroundColor White
    Write-Host "Email: $($response.usuario.email)" -ForegroundColor White
    Write-Host "Tipo: $($response.usuario.tipoUsuario)" -ForegroundColor White
    Write-Host ""
    
    # Copiar token para clipboard (se disponível)
    try {
        Set-Clipboard -Value $response.token
        Write-Host "[OK] Token copiado para a área de transferência!" -ForegroundColor Green
    }
    catch {
        Write-Host "[INFO] Para copiar o token, selecione e use Ctrl+C" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "COMO USAR O TOKEN:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Adicione o header nas requisições:" -ForegroundColor White
    Write-Host "   Authorization: Bearer SEU_TOKEN_AQUI" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Exemplo com PowerShell:" -ForegroundColor White
    Write-Host '   $headers = @{ Authorization = "Bearer ' + $response.token.Substring(0, 20) + '..." }' -ForegroundColor Gray
    Write-Host '   Invoke-RestMethod -Uri "http://localhost:5246/api/chamados" -Headers $headers' -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Exemplo com curl:" -ForegroundColor White
    Write-Host '   curl -H "Authorization: Bearer SEU_TOKEN" http://localhost:5246/api/chamados' -ForegroundColor Gray
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
}
catch {
    Write-Host ""
    Write-Host "[ERRO] Falha ao fazer login!" -ForegroundColor Red
    Write-Host "Mensagem: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.ErrorDetails) {
        Write-Host "Detalhes: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Verifique:" -ForegroundColor Yellow
    Write-Host "1. Se o email e senha estão corretos" -ForegroundColor White
    Write-Host "2. Se o usuário existe no banco de dados" -ForegroundColor White
    Write-Host "3. Execute SetupUsuariosTeste.ps1 para criar usuários de teste" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host ""
