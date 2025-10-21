# ========================================
# Script para Configurar IP Automaticamente
# ========================================
# Detecta o IP da rede Wi-Fi (filtra redes virtuais)
# e atualiza Constants.cs para uso com Android fisico

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Configurador de IP - Mobile APK" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Detectar caminhos relativos
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$mobilePath = Join-Path $repoRoot "Mobile"
$constantsPath = Join-Path $mobilePath "Helpers\Constants.cs"

# Verificar se Constants.cs existe
if (-not (Test-Path $constantsPath)) {
    Write-Host "[ERRO] Constants.cs nao encontrado!" -ForegroundColor Red
    Write-Host "[INFO] Caminho esperado: $constantsPath" -ForegroundColor Yellow
    exit 1
}

# Detectar IP da rede Wi-Fi (filtrando adapta dores virtuais)
Write-Host "[1/3] Detectando IP da rede Wi-Fi..." -ForegroundColor Yellow
Write-Host "[INFO] Procurando adaptador de rede fisica (nao virtual)..." -ForegroundColor Cyan
Write-Host ""

# Listar todos os adaptadores
$adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }

Write-Host "Adaptadores de rede ativos:" -ForegroundColor Cyan
$adapters | ForEach-Object {
    $ip = (Get-NetIPAddress -InterfaceIndex $_.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).IPAddress
    if ($ip) {
        $isVirtual = $_.InterfaceDescription -match "Virtual|VMware|VirtualBox|Hyper-V|vEthernet"
        $status = if ($isVirtual) { "[VIRTUAL]" } else { "[FISICA]" }
        Write-Host "  $status $($_.Name): $ip - $($_.InterfaceDescription)" -ForegroundColor $(if ($isVirtual) { "Gray" } else { "Green" })
    }
}
Write-Host ""

# Filtrar apenas adapta dores fisicos (não virtuais)
$localIP = Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object { 
        $_.IPAddress -notlike "127.*" -and 
        $_.IPAddress -notlike "169.*" -and
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
    Write-Host "[AVISO] Nao foi possivel detectar IP de rede fisica automaticamente!" -ForegroundColor Yellow
    Write-Host "[INFO] Adaptadores virtuais detectados (VirtualBox, VMware, Hyper-V)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Por favor, insira o IP manualmente:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Como descobrir o IP correto:" -ForegroundColor Cyan
    Write-Host "1. Execute: ipconfig" -ForegroundColor White
    Write-Host "2. Procure por 'Adaptador de Rede sem Fio Wi-Fi'" -ForegroundColor White
    Write-Host "3. Copie o endereco IPv4 (ex: 192.168.0.105)" -ForegroundColor White
    Write-Host ""
    $manualIP = Read-Host "Digite o IP da sua rede Wi-Fi (ou Enter para cancelar)"
    
    if ([string]::IsNullOrWhiteSpace($manualIP)) {
        Write-Host "[AVISO] Operacao cancelada" -ForegroundColor Yellow
        exit 1
    }
    
    # Validar formato IP
    if ($manualIP -notmatch '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') {
        Write-Host "[ERRO] Formato de IP invalido!" -ForegroundColor Red
        exit 1
    }
    
    $localIP = $manualIP
}

Write-Host "[OK] IP detectado: $localIP" -ForegroundColor Green

# Verificar se é IP virtual
if ($localIP -like "192.168.56.*" -or $localIP -like "192.168.137.*") {
    Write-Host ""
    Write-Host "[AVISO] O IP detectado parece ser de rede virtual!" -ForegroundColor Red
    Write-Host "[INFO] IP: $localIP" -ForegroundColor Yellow
    Write-Host "[INFO] IPs virtuais NAO funcionam com celular fisico!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Deseja continuar mesmo assim? (s/N): " -ForegroundColor Yellow -NoNewline
    $resposta = Read-Host
    
    if ($resposta -ne "s" -and $resposta -ne "S") {
        Write-Host "[AVISO] Operacao cancelada" -ForegroundColor Yellow
        Write-Host "[INFO] Execute 'ipconfig' e encontre o IP da sua placa Wi-Fi" -ForegroundColor Cyan
        exit 1
    }
}

Write-Host ""

# Ler arquivo atual
Write-Host "[2/3] Atualizando Constants.cs..." -ForegroundColor Yellow
$constantsContent = Get-Content $constantsPath -Raw

# Backup do arquivo original
$backupPath = "$constantsPath.backup"
if (-not (Test-Path $backupPath)) {
    Copy-Item $constantsPath $backupPath
    Write-Host "[INFO] Backup criado: $backupPath" -ForegroundColor Cyan
}

# Atualizar IP - procura por linha com BaseUrlPhysicalDevice e substitui o IP
$pattern = '(public static string BaseUrlPhysicalDevice => "http://)([^:]+)(:\d+/api/";)'
$replacement = "`${1}${localIP}`$3"

if ($constantsContent -match $pattern) {
    $constantsContent = $constantsContent -replace $pattern, $replacement
    Set-Content -Path $constantsPath -Value $constantsContent -NoNewline
    Write-Host "[OK] Constants.cs atualizado com IP: $localIP" -ForegroundColor Green
} else {
    Write-Host "[ERRO] Padrao nao encontrado em Constants.cs!" -ForegroundColor Red
    Write-Host "[INFO] Verifique o formato do arquivo" -ForegroundColor Yellow
    Write-Host "[DEBUG] Conteudo atual da linha BaseUrlPhysicalDevice:" -ForegroundColor Cyan
    $constantsContent -split "`n" | Where-Object { $_ -like "*BaseUrlPhysicalDevice*" } | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    exit 1
}
Write-Host ""

# Exibir informacoes
Write-Host "[3/3] Configuracao concluida!" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  INFORMACOES DE CONEXAO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "IP configurado: $localIP" -ForegroundColor Cyan
Write-Host "URL da API: http://${localIP}:5246/api/" -ForegroundColor Cyan
Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  PROXIMOS PASSOS" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Certifique-se que celular esta na mesma rede Wi-Fi" -ForegroundColor White
Write-Host "2. Execute: .\GerarAPK.ps1 (para gerar APK com novo IP)" -ForegroundColor White
Write-Host "3. Execute: .\IniciarAPIMobile.ps1 (para iniciar API)" -ForegroundColor White
Write-Host "4. Instale o APK no celular" -ForegroundColor White
Write-Host "5. Teste a conexao acessando: http://${localIP}:5246/swagger" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TESTE RAPIDO NO NAVEGADOR DO CELULAR" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Abra o navegador do celular e acesse:" -ForegroundColor White
Write-Host "  http://${localIP}:5246/swagger" -ForegroundColor Yellow
Write-Host ""
Write-Host "Se abrir o Swagger = Conexao OK!" -ForegroundColor Green
Write-Host "Se nao abrir = Problema de firewall ou rede" -ForegroundColor Red
Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "  IMPORTANTE" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "Se o IP configurado for:" -ForegroundColor White
Write-Host "  - 192.168.56.x (VirtualBox) = NAO funcionara com celular!" -ForegroundColor Red
Write-Host "  - 192.168.137.x (VMware) = NAO funcionara com celular!" -ForegroundColor Red
Write-Host "  - 192.168.0.x ou 192.168.1.x (Wi-Fi) = Deve funcionar!" -ForegroundColor Green
Write-Host ""
Write-Host "Veja: docs\SOLUCAO_IP_REDE.md para mais informacoes" -ForegroundColor Cyan
Write-Host ""

Write-Host "Pressione qualquer tecla para continuar..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
