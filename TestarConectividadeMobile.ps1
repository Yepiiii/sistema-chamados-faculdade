## ===============================================
## Script de Teste de Conectividade Mobile
## ===============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Teste de Conectividade para Mobile" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Detectar IP da máquina
Write-Host "[1/6] Detectando IPs da máquina..." -ForegroundColor Yellow
$ips = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
    $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*"
} | Select-Object IPAddress, InterfaceAlias

if ($ips.Count -eq 0) {
    Write-Host "[ERRO] Nenhum IP de rede local encontrado!" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] IPs encontrados:" -ForegroundColor Green
$ips | ForEach-Object {
    Write-Host "  - $($_.IPAddress) ($($_.InterfaceAlias))" -ForegroundColor White
}
Write-Host ""

# Usar o primeiro IP não-localhost
$selectedIp = $ips[0].IPAddress
Write-Host "[INFO] IP selecionado: $selectedIp" -ForegroundColor Cyan
Write-Host ""

# 2. Verificar se a API está rodando
Write-Host "[2/6] Verificando se a API está rodando na porta 5246..." -ForegroundColor Yellow
$apiProcess = Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object {
    $_.MainWindowTitle -like "*SistemaChamados*" -or 
    (Get-NetTCPConnection -LocalPort 5246 -ErrorAction SilentlyContinue)
}

$portInUse = Get-NetTCPConnection -LocalPort 5246 -State Listen -ErrorAction SilentlyContinue

if ($portInUse) {
    Write-Host "[OK] Porta 5246 está em uso (API provavelmente rodando)" -ForegroundColor Green
} else {
    Write-Host "[AVISO] Porta 5246 não está em uso. Inicie a API primeiro!" -ForegroundColor Red
    Write-Host "       Execute: dotnet run --project SistemaChamados.csproj --urls=`"http://0.0.0.0:5246`"" -ForegroundColor Yellow
}
Write-Host ""

# 3. Testar localhost
Write-Host "[3/6] Testando acesso local (localhost:5246)..." -ForegroundColor Yellow
try {
    $localResponse = Invoke-WebRequest -Uri "http://localhost:5246/swagger/index.html" -TimeoutSec 5 -ErrorAction Stop
    Write-Host "[OK] API acessível localmente (Status: $($localResponse.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "[ERRO] API não acessível localmente: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# 4. Testar via IP da rede
Write-Host "[4/6] Testando acesso via IP de rede ($selectedIp:5246)..." -ForegroundColor Yellow
try {
    $networkResponse = Invoke-WebRequest -Uri "http://${selectedIp}:5246/swagger/index.html" -TimeoutSec 5 -ErrorAction Stop
    Write-Host "[OK] API acessível via IP de rede (Status: $($networkResponse.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "[ERRO] API não acessível via IP de rede: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "[DICA] Pode ser bloqueio de firewall!" -ForegroundColor Yellow
}
Write-Host ""

# 5. Verificar regras de firewall
Write-Host "[5/6] Verificando regras de firewall para porta 5246..." -ForegroundColor Yellow
$firewallRule = Get-NetFirewallRule -DisplayName "*Sistema Chamados*" -ErrorAction SilentlyContinue | 
    Where-Object { $_.Enabled -eq $true }

if ($firewallRule) {
    Write-Host "[OK] Regra de firewall encontrada e ativa" -ForegroundColor Green
    $firewallRule | ForEach-Object {
        Write-Host "  - $($_.DisplayName) (Ação: $($_.Action))" -ForegroundColor White
    }
} else {
    Write-Host "[AVISO] Nenhuma regra de firewall encontrada!" -ForegroundColor Red
    Write-Host "        Para criar, execute como Administrador:" -ForegroundColor Yellow
    Write-Host "        New-NetFirewallRule -DisplayName 'Sistema Chamados API Mobile' -Direction Inbound -LocalPort 5246 -Protocol TCP -Action Allow" -ForegroundColor Cyan
}
Write-Host ""

# 6. Verificar Constants.cs
Write-Host "[6/6] Verificando configuração do Constants.cs..." -ForegroundColor Yellow
$constantsPath = "..\SistemaChamados.Mobile\Helpers\Constants.cs"
if (Test-Path $constantsPath) {
    $constantsContent = Get-Content $constantsPath -Raw
    
    if ($constantsContent -match 'return BaseUrlPhysicalDevice') {
        Write-Host "[OK] Constants.cs configurado para dispositivo físico" -ForegroundColor Green
    } else {
        Write-Host "[AVISO] Constants.cs pode estar configurado para emulador!" -ForegroundColor Red
        Write-Host "        Verifique se está usando BaseUrlPhysicalDevice" -ForegroundColor Yellow
    }
    
    if ($constantsContent -match "http://(\d+\.\d+\.\d+\.\d+):5246") {
        $configuredIp = $matches[1]
        Write-Host "[INFO] IP configurado no app: $configuredIp" -ForegroundColor White
        
        if ($configuredIp -eq $selectedIp) {
            Write-Host "[OK] IP do app coincide com IP atual da máquina" -ForegroundColor Green
        } else {
            Write-Host "[AVISO] IP do app ($configuredIp) diferente do IP atual ($selectedIp)" -ForegroundColor Red
            Write-Host "        Atualize Constants.cs e gere novo APK!" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "[ERRO] Arquivo Constants.cs não encontrado!" -ForegroundColor Red
}
Write-Host ""

# Resumo
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESUMO E PRÓXIMOS PASSOS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para testar do celular:" -ForegroundColor White
Write-Host "1. Conecte o celular na mesma rede Wi-Fi" -ForegroundColor White
Write-Host "2. No navegador do celular, acesse: http://${selectedIp}:5246/swagger" -ForegroundColor Cyan
Write-Host "3. Se funcionar, o app também funcionará" -ForegroundColor White
Write-Host "4. Se NÃO funcionar, configure o firewall (como Administrador)" -ForegroundColor White
Write-Host ""
Write-Host "URL para o app mobile: http://${selectedIp}:5246/api/" -ForegroundColor Green
Write-Host ""
