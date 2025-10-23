# ==============================================================================
# Script: ConfigurarIPDispositivo.ps1
# Descricao: Detecta o IP local e configura para dispositivo fisico Android
# Autor: Sistema
# Data: 23/10/2025
# ==============================================================================

$ErrorActionPreference = "Stop"

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    CONFIGURADOR DE IP - Dispositivo Fisico Android" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# ==============================================================================
# DETECTAR IP LOCAL
# ==============================================================================
Write-Host "[*] Detectando IP da maquina na rede local..." -ForegroundColor Yellow
Write-Host ""

# Pegar todos os adaptadores de rede ativos
$adapters = Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object { 
        $_.IPAddress -notlike "127.*" -and 
        $_.IPAddress -notlike "169.254.*" -and
        $_.PrefixOrigin -eq "Dhcp" -or $_.PrefixOrigin -eq "Manual"
    } |
    Sort-Object -Property InterfaceIndex

if ($adapters.Count -eq 0) {
    Write-Host "[X] ERRO: Nenhum IP de rede local encontrado!" -ForegroundColor Red
    Write-Host "   Verifique se esta conectado a uma rede (WiFi ou Ethernet)" -ForegroundColor Yellow
    exit 1
}

# Exibir IPs encontrados
Write-Host "[OK] IPs encontrados:" -ForegroundColor Green
$index = 1
$ipList = @()
foreach ($adapter in $adapters) {
    $interface = Get-NetAdapter -InterfaceIndex $adapter.InterfaceIndex
    $ipList += @{
        Index = $index
        IP = $adapter.IPAddress
        Interface = $interface.Name
        Status = $interface.Status
    }
    
    Write-Host "   [$index] $($adapter.IPAddress) - $($interface.Name) ($($interface.Status))" -ForegroundColor Cyan
    $index++
}

Write-Host ""

# Selecionar IP
$ipSelecionado = $null
if ($ipList.Count -eq 1) {
    $ipSelecionado = $ipList[0].IP
    Write-Host "[*] Usando IP: $ipSelecionado" -ForegroundColor Green
} else {
    # Tentar escolher automaticamente o mais provavel (WiFi ou Ethernet conectado)
    $ipPreferido = $ipList | Where-Object { $_.Status -eq "Up" -and ($_.Interface -like "*Wi-Fi*" -or $_.Interface -like "*Ethernet*") } | Select-Object -First 1
    
    if ($ipPreferido) {
        $ipSelecionado = $ipPreferido.IP
        Write-Host "[*] Selecionado automaticamente: $ipSelecionado ($($ipPreferido.Interface))" -ForegroundColor Green
    } else {
        $ipSelecionado = $ipList[0].IP
        Write-Host "[*] Usando primeiro IP disponivel: $ipSelecionado" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    ATUALIZANDO CONFIGURACAO" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://${ipSelecionado}:5246/api/"

# ==============================================================================
# ATUALIZAR Constants.cs
# ==============================================================================
$constantsFile = "Mobile\Helpers\Constants.cs"
Write-Host "[*] Atualizando $constantsFile..." -ForegroundColor Yellow

if (-not (Test-Path $constantsFile)) {
    Write-Host "[X] ERRO: Arquivo $constantsFile nao encontrado!" -ForegroundColor Red
    exit 1
}

$constantsContent = @"
namespace SistemaChamados.Mobile.Helpers;

public static class Constants
{
    // Para Windows Desktop/Emulador iOS
    public static string BaseUrlWindows => "http://localhost:5246/api/";
    
    // Para Emulador Android (10.0.2.2 = localhost do host)
    public static string BaseUrlAndroidEmulator => "http://10.0.2.2:5246/api/";
    
    // Para Dispositivo Fisico - IP da maquina na rede local
    // IP Detectado: $ipSelecionado
    // Ultima atualizacao: $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")
    public static string BaseUrlPhysicalDevice => "$baseUrl";
    
    // BaseUrl dinamica baseada na plataforma
    public static string BaseUrl
    {
        get
        {
#if ANDROID
            // DISPOSITIVO FISICO - Usando IP da rede local
            return BaseUrlPhysicalDevice;
#elif WINDOWS
            return BaseUrlWindows;
#elif IOS || MACCATALYST
            return BaseUrlWindows;
#else
            return BaseUrlWindows;
#endif
        }
    }
}
"@

Set-Content -Path $constantsFile -Value $constantsContent -Encoding UTF8
Write-Host "[OK] Constants.cs atualizado!" -ForegroundColor Green

# ==============================================================================
# ATUALIZAR appsettings.json
# ==============================================================================
$appsettingsFile = "Mobile\appsettings.json"
Write-Host "[*] Atualizando $appsettingsFile..." -ForegroundColor Yellow

if (Test-Path $appsettingsFile) {
    $appsettingsContent = @"
{
  "BaseUrl": "$baseUrl",
  "BaseUrlWindows": "http://localhost:5246/api/",
  "BaseUrlPhysicalDevice": "$baseUrl"
}
"@
    Set-Content -Path $appsettingsFile -Value $appsettingsContent -Encoding UTF8
    Write-Host "[OK] appsettings.json atualizado!" -ForegroundColor Green
} else {
    Write-Host "[!] Aviso: appsettings.json nao encontrado" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Green
Write-Host "    CONFIGURACAO CONCLUIDA!" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "IP configurado: $ipSelecionado" -ForegroundColor Cyan
Write-Host "URL da API: $baseUrl" -ForegroundColor Cyan
Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    PROXIMOS PASSOS" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Certifique-se que a API esta rodando:" -ForegroundColor White
Write-Host "   http://localhost:5246" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Configure o Firewall do Windows:" -ForegroundColor White
Write-Host "   - Permita conexoes na porta 5246" -ForegroundColor Gray
Write-Host "   - Execute o comando abaixo como Administrador:" -ForegroundColor Gray
Write-Host ""
Write-Host "   netsh advfirewall firewall add rule name=`"Sistema Chamados API`" dir=in action=allow protocol=TCP localport=5246" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Certifique-se que PC e celular estao na MESMA rede WiFi" -ForegroundColor White
Write-Host ""
Write-Host "4. Gere um NOVO APK com a configuracao atualizada:" -ForegroundColor White
Write-Host "   .\GerarAPK.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "5. Instale o novo APK no dispositivo" -ForegroundColor White
Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    TESTE DE CONECTIVIDADE" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para testar se o celular consegue acessar a API:" -ForegroundColor White
Write-Host ""
Write-Host "1. Abra o navegador do celular" -ForegroundColor Gray
Write-Host "2. Acesse: http://${ipSelecionado}:5246/api/categorias" -ForegroundColor Cyan
Write-Host "3. Deve retornar um JSON com as categorias" -ForegroundColor Gray
Write-Host ""
