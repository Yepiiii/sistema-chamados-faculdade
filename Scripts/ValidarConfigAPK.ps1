# ========================================
# Validar Configuração para APK Mobile
# ========================================
# Este script verifica se tudo está pronto
# para usar o APK no dispositivo Android

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Validação de Configuração - APK Mobile" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$errorsFound = 0
$warningsFound = 0

# 1. Verificar se APK existe
Write-Host "[1/8] Verificando APK..." -ForegroundColor Yellow
$apkPath = "c:\Users\opera\sistema-chamados-faculdade\APK\SistemaChamados-v1.0.apk"

if (Test-Path $apkPath) {
    $apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
    Write-Host "[OK] APK encontrado ($apkSize MB)" -ForegroundColor Green
} else {
    Write-Host "[ERRO] APK não encontrado!" -ForegroundColor Red
    Write-Host "[INFO] Execute: .\GerarAPK.ps1" -ForegroundColor Yellow
    $errorsFound++
}
Write-Host ""

# 2. Verificar IP da rede
Write-Host "[2/8] Detectando IP da rede..." -ForegroundColor Yellow
$localIP = Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object { 
        $_.IPAddress -notlike "127.*" -and 
        $_.IPAddress -notlike "169.*" -and
        ($_.IPAddress -like "192.168.*" -or $_.IPAddress -like "10.*")
    } | 
    Select-Object -First 1 -ExpandProperty IPAddress

if ($localIP) {
    Write-Host "[OK] IP da rede: $localIP" -ForegroundColor Green
} else {
    Write-Host "[ERRO] Não foi possível detectar IP da rede!" -ForegroundColor Red
    Write-Host "[INFO] Conecte-se a uma rede Wi-Fi" -ForegroundColor Yellow
    $errorsFound++
}
Write-Host ""

# 3. Verificar Constants.cs
Write-Host "[3/8] Verificando Constants.cs..." -ForegroundColor Yellow
$constantsPath = "c:\Users\opera\sistema-chamados-faculdade\SistemaChamados.Mobile\Helpers\Constants.cs"

if (Test-Path $constantsPath) {
    $constantsContent = Get-Content $constantsPath -Raw
    
    if ($localIP -and $constantsContent -match $localIP.Replace(".", "\.")) {
        Write-Host "[OK] IP correto em Constants.cs" -ForegroundColor Green
    } elseif ($localIP) {
        Write-Host "[AVISO] IP em Constants.cs pode estar desatualizado!" -ForegroundColor Yellow
        Write-Host "[INFO] IP atual: $localIP" -ForegroundColor Cyan
        Write-Host "[INFO] Atualize Constants.cs e regere o APK" -ForegroundColor Yellow
        $warningsFound++
    }
} else {
    Write-Host "[ERRO] Constants.cs não encontrado!" -ForegroundColor Red
    $errorsFound++
}
Write-Host ""

# 4. Verificar Firewall
Write-Host "[4/8] Verificando Firewall..." -ForegroundColor Yellow
$firewallRule = Get-NetFirewallRule -DisplayName "Sistema Chamados API" -ErrorAction SilentlyContinue

if ($firewallRule) {
    Write-Host "[OK] Regra de firewall configurada" -ForegroundColor Green
} else {
    Write-Host "[AVISO] Regra de firewall não encontrada" -ForegroundColor Yellow
    Write-Host "[INFO] Execute IniciarAPIMobile.ps1 como Admin" -ForegroundColor Yellow
    $warningsFound++
}
Write-Host ""

# 5. Verificar se API está compilando
Write-Host "[5/8] Verificando compilação da API..." -ForegroundColor Yellow
$projectPath = "c:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade"

if (Test-Path "$projectPath\SistemaChamados.csproj") {
    Set-Location $projectPath
    $buildResult = dotnet build --no-restore -v quiet 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] API compila sem erros" -ForegroundColor Green
    } else {
        Write-Host "[ERRO] API com erros de compilação!" -ForegroundColor Red
        $errorsFound++
    }
} else {
    Write-Host "[ERRO] Projeto da API não encontrado!" -ForegroundColor Red
    $errorsFound++
}
Write-Host ""

# 6. Verificar banco de dados
Write-Host "[6/8] Verificando banco de dados..." -ForegroundColor Yellow
try {
    $dbCheck = dotnet ef database update --no-build --dry-run 2>&1
    Write-Host "[OK] Banco de dados configurado" -ForegroundColor Green
} catch {
    Write-Host "[AVISO] Não foi possível verificar banco" -ForegroundColor Yellow
    $warningsFound++
}
Write-Host ""

# 7. Verificar porta 5246 em uso
Write-Host "[7/8] Verificando porta 5246..." -ForegroundColor Yellow
$portInUse = Get-NetTCPConnection -LocalPort 5246 -ErrorAction SilentlyContinue

if ($portInUse) {
    Write-Host "[INFO] Porta 5246 está em uso (API pode estar rodando)" -ForegroundColor Cyan
} else {
    Write-Host "[OK] Porta 5246 disponível" -ForegroundColor Green
}
Write-Host ""

# 8. Verificar usuários de teste
Write-Host "[8/8] Verificando script de setup de usuários..." -ForegroundColor Yellow
$setupScript = "$projectPath\SetupUsuariosTeste.ps1"

if (Test-Path $setupScript) {
    Write-Host "[OK] Script de setup encontrado" -ForegroundColor Green
} else {
    Write-Host "[AVISO] Script de setup não encontrado" -ForegroundColor Yellow
    Write-Host "[INFO] Pode ser necessário criar usuários manualmente" -ForegroundColor Yellow
    $warningsFound++
}
Write-Host ""

# Resumo
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESUMO DA VALIDAÇÃO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($errorsFound -eq 0 -and $warningsFound -eq 0) {
    Write-Host "[SUCESSO] Tudo configurado corretamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Próximos passos:" -ForegroundColor Cyan
    Write-Host "1. Executar: .\IniciarAPIMobile.ps1" -ForegroundColor White
    Write-Host "2. Instalar APK no celular" -ForegroundColor White
    Write-Host "3. Conectar celular na mesma rede Wi-Fi" -ForegroundColor White
    Write-Host "4. Abrir app e fazer login" -ForegroundColor White
} elseif ($errorsFound -eq 0) {
    Write-Host "[OK] Configuração válida com $warningsFound aviso(s)" -ForegroundColor Yellow
    Write-Host "[INFO] Revise os avisos acima" -ForegroundColor Yellow
} else {
    Write-Host "[ERRO] Encontrados $errorsFound erro(s) e $warningsFound aviso(s)" -ForegroundColor Red
    Write-Host "[INFO] Corrija os erros antes de prosseguir" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Informações adicionais
if ($localIP) {
    Write-Host "Configurações de Rede:" -ForegroundColor Cyan
    Write-Host "  IP Local: $localIP" -ForegroundColor White
    Write-Host "  URL API: http://$localIP:5246/api/" -ForegroundColor White
    Write-Host "  Swagger: http://$localIP:5246/swagger" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Teste no celular:" -ForegroundColor Cyan
    Write-Host "  1. Conectar na mesma Wi-Fi" -ForegroundColor White
    Write-Host "  2. Abrir navegador no celular" -ForegroundColor White
    Write-Host "  3. Acessar: http://$localIP:5246/swagger" -ForegroundColor White
    Write-Host "  4. Se abrir = Conexão OK!" -ForegroundColor White
    Write-Host ""
}

Write-Host "Credenciais de Teste:" -ForegroundColor Cyan
Write-Host "  admin@sistema.com / Admin@123" -ForegroundColor White
Write-Host "  aluno@sistema.com / Aluno@123" -ForegroundColor White
Write-Host ""

if ($errorsFound -eq 0) {
    Write-Host "Pressione qualquer tecla para continuar..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Retornar código de saída
if ($errorsFound -gt 0) {
    exit 1
} else {
    exit 0
}
