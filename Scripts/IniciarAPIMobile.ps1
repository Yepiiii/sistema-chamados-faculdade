# ========================================
# Iniciar API para APK Mobile Android
# ========================================
# Este script inicia a API configurada para aceitar
# conexões de dispositivos móveis na rede local

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  API para Mobile APK - Sistema de Chamados" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se já existe API rodando
$existingProcess = Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*sistema-chamados*" }
if ($existingProcess) {
    Write-Host "[INFO] Parando API anterior..." -ForegroundColor Yellow
    Stop-Process -Name "dotnet" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

# Obter IP da máquina na rede local (FILTRANDO ADAPTERS VIRTUAIS)
Write-Host "[1/5] Detectando IP da máquina na rede..." -ForegroundColor Yellow

# Lista todos adapters para diagnóstico
$allAdapters = Get-NetAdapter | Where-Object Status -eq 'Up'
Write-Host "[DEBUG] Adapters ativos detectados:" -ForegroundColor DarkGray
foreach ($adapter in $allAdapters) {
    $isVirtual = $adapter.Name -match "Virtual|VMware|VirtualBox|Hyper-V|vEthernet"
    $tag = if ($isVirtual) { "[VIRTUAL]" } else { "[FISICA]" }
    Write-Host "  $tag $($adapter.Name)" -ForegroundColor DarkGray
}
Write-Host ""

# Detecta IP filtrando adapters virtuais
$localIP = Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object { 
        $_.IPAddress -notlike "127.*" -and 
        $_.IPAddress -notlike "169.*" -and
        $_.IPAddress -notlike "192.168.56.*" -and  # VirtualBox Host-Only
        $_.IPAddress -notlike "192.168.137.*" -and # Mobile Hotspot
        ($_.IPAddress -like "192.168.0.*" -or 
         $_.IPAddress -like "192.168.1.*" -or 
         $_.IPAddress -like "10.0.0.*" -or 
         $_.IPAddress -like "10.0.1.*" -or 
         $_.IPAddress -like "172.16.*" -or 
         $_.IPAddress -like "172.17.*") -and
        $_.InterfaceAlias -notmatch "Virtual|VMware|VirtualBox|Hyper-V|vEthernet"
    } | 
    Select-Object -First 1 -ExpandProperty IPAddress

if (-not $localIP) {
    Write-Host "[ERRO] Não foi possível detectar IP da rede física!" -ForegroundColor Red
    Write-Host "[INFO] Certifique-se de estar conectado a uma rede Wi-Fi ou Ethernet" -ForegroundColor Yellow
    Write-Host "[INFO] IPs virtuais (VirtualBox, VMware) foram ignorados" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] IP detectado: $localIP" -ForegroundColor Green
Write-Host ""

# Configurar regra de firewall
Write-Host "[2/5] Configurando Firewall..." -ForegroundColor Yellow
$firewallRule = Get-NetFirewallRule -DisplayName "Sistema Chamados API" -ErrorAction SilentlyContinue

if (-not $firewallRule) {
    Write-Host "[INFO] Criando regra de firewall..." -ForegroundColor Yellow
    try {
        New-NetFirewallRule -DisplayName "Sistema Chamados API" `
            -Direction Inbound `
            -LocalPort 5246 `
            -Protocol TCP `
            -Action Allow `
            -ErrorAction Stop | Out-Null
        Write-Host "[OK] Regra de firewall criada" -ForegroundColor Green
    } catch {
        Write-Host "[AVISO] Não foi possível criar regra de firewall automaticamente" -ForegroundColor Yellow
        Write-Host "[INFO] Execute como Administrador para criar a regra" -ForegroundColor Yellow
    }
} else {
    Write-Host "[OK] Regra de firewall já existe" -ForegroundColor Green
}
Write-Host ""

# Detectar caminhos relativos
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$backendPath = Join-Path $repoRoot "Backend"
$mobilePath = Join-Path $repoRoot "Mobile"

# Caminho do projeto
$projectPath = $backendPath

if (-not (Test-Path $projectPath)) {
    Write-Host "[ERRO] Projeto não encontrado em: $projectPath" -ForegroundColor Red
    exit 1
}

# Verificar se o banco de dados existe
Write-Host "[3/5] Verificando banco de dados..." -ForegroundColor Yellow
Set-Location $projectPath

# Tentar aplicar migrations (caso necessário)
try {
    dotnet ef database update --no-build 2>&1 | Out-Null
    Write-Host "[OK] Banco de dados atualizado" -ForegroundColor Green
} catch {
    Write-Host "[INFO] Banco já está atualizado" -ForegroundColor Cyan
}
Write-Host ""

# Exibir informações importantes
Write-Host "========================================" -ForegroundColor Green
Write-Host "  INFORMAÇÕES PARA CONEXÃO DO MOBILE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "URL da API:" -ForegroundColor Cyan
Write-Host "  http://$localIP:5246/api/" -ForegroundColor White
Write-Host ""
Write-Host "Swagger (Documentação):" -ForegroundColor Cyan
Write-Host "  http://$localIP:5246/swagger" -ForegroundColor White
Write-Host ""
Write-Host "Testar no navegador do celular:" -ForegroundColor Cyan
Write-Host "  http://$localIP:5246/swagger" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  CREDENCIAIS DE TESTE" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Administrador:" -ForegroundColor White
Write-Host "  Email: admin@sistema.com" -ForegroundColor Cyan
Write-Host "  Senha: Admin@123" -ForegroundColor Cyan
Write-Host ""
Write-Host "Aluno:" -ForegroundColor White
Write-Host "  Email: aluno@sistema.com" -ForegroundColor Cyan
Write-Host "  Senha: Aluno@123" -ForegroundColor Cyan
Write-Host ""
Write-Host "Professor:" -ForegroundColor White
Write-Host "  Email: professor@sistema.com" -ForegroundColor Cyan
Write-Host "  Senha: Prof@123" -ForegroundColor Cyan
Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "  CHECKLIST PARA USAR O APK" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "[1] Celular conectado na mesma rede Wi-Fi que este PC" -ForegroundColor White
Write-Host "[2] APK instalado no celular" -ForegroundColor White
Write-Host "[3] Firewall liberado (porta 5246)" -ForegroundColor White
Write-Host "[4] API configurada em Constants.cs com IP: $localIP" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

# Verificar se o IP no Constants.cs está correto
$constantsPath = Join-Path $mobilePath "Helpers\Constants.cs"
if (Test-Path $constantsPath) {
    $constantsContent = Get-Content $constantsPath -Raw
    if ($constantsContent -notmatch $localIP.Replace(".", "\.")) {
        Write-Host "[AVISO] O IP no Constants.cs pode estar diferente!" -ForegroundColor Red
        Write-Host "[INFO] IP atual do PC: $localIP" -ForegroundColor Yellow
        Write-Host "[INFO] Verifique: $constantsPath" -ForegroundColor Yellow
        Write-Host "[INFO] E regere o APK se necessário!" -ForegroundColor Yellow
        Write-Host ""
    }
}

Write-Host "[4/5] Compilando projeto..." -ForegroundColor Yellow
dotnet build --no-restore -c Release -v minimal

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[ERRO] Falha na compilação!" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Projeto compilado" -ForegroundColor Green
Write-Host ""

Write-Host "[5/5] Iniciando API..." -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  API INICIANDO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "A API está escutando em:" -ForegroundColor White
Write-Host "  - http://localhost:5246 (local)" -ForegroundColor Cyan
Write-Host "  - http://$localIP:5246 (rede)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pressione Ctrl+C para parar a API" -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Executar API com URLs configuradas para aceitar conexões externas
dotnet run --urls="http://0.0.0.0:5246;http://localhost:5246"
