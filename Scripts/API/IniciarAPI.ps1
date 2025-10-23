# ==============================================================================
# Script: IniciarAPIRede.ps1
# Descricao: Inicia a API permitindo acesso da rede local
# Autor: Sistema
# Data: 23/10/2025
# ==============================================================================

$ErrorActionPreference = "Stop"

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    INICIANDO API - Acesso de Rede Local Habilitado" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# Detectar IP local
Write-Host "[*] Detectando IP da rede local..." -ForegroundColor Yellow
$ip = (Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object { 
        $_.IPAddress -notlike "127.*" -and 
        $_.IPAddress -notlike "169.254.*" -and
        ($_.PrefixOrigin -eq "Dhcp" -or $_.PrefixOrigin -eq "Manual")
    } |
    Sort-Object -Property InterfaceIndex |
    Select-Object -First 1).IPAddress

if (-not $ip) {
    Write-Host "[X] ERRO: Nao foi possivel detectar o IP da rede" -ForegroundColor Red
    $ip = "0.0.0.0"
    Write-Host "[!] Usando 0.0.0.0 (todas as interfaces)" -ForegroundColor Yellow
} else {
    Write-Host "[OK] IP detectado: $ip" -ForegroundColor Green
}

Write-Host ""

# Verificar se o projeto existe
$projetoPath = "Backend\SistemaChamados.csproj"
if (-not (Test-Path $projetoPath)) {
    Write-Host "[X] ERRO: Projeto nao encontrado em $projetoPath" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Projeto encontrado: $projetoPath" -ForegroundColor Green
Write-Host ""

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    CONFIGURACAO DA API" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Endpoints disponiveis:" -ForegroundColor Cyan
Write-Host "  - http://localhost:5246        (Acesso local)" -ForegroundColor White
Write-Host "  - http://${ip}:5246            (Acesso da rede)" -ForegroundColor White
Write-Host "  - http://0.0.0.0:5246          (Todas as interfaces)" -ForegroundColor White
Write-Host ""

Write-Host "[!] IMPORTANTE:" -ForegroundColor Yellow
Write-Host "  - Certifique-se que o Firewall esta configurado" -ForegroundColor White
Write-Host "  - Execute: .\ConfigurarFirewall.ps1 (como Admin)" -ForegroundColor Cyan
Write-Host ""

# Parar processos dotnet antigos da API
Write-Host "[*] Parando processos antigos da API..." -ForegroundColor Yellow
$backendProcesses = Get-Process | Where-Object { 
    $_.ProcessName -eq "dotnet" -and 
    $_.Path -like "*Backend*" 
}

if ($backendProcesses) {
    $backendProcesses | Stop-Process -Force
    Write-Host "[OK] Processos antigos encerrados" -ForegroundColor Green
    Start-Sleep -Seconds 2
} else {
    Write-Host "[*] Nenhum processo antigo encontrado" -ForegroundColor Gray
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    INICIANDO API..." -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# Iniciar API em nova janela
$command = @"
Set-Location '$PWD\Backend';
Write-Host '==================================================================' -ForegroundColor Cyan;
Write-Host '    BACKEND API - Sistema de Chamados' -ForegroundColor Green;
Write-Host '    Acesso de Rede Local HABILITADO' -ForegroundColor Yellow;
Write-Host '==================================================================' -ForegroundColor Cyan;
Write-Host '';
Write-Host 'Endpoints:' -ForegroundColor Cyan;
Write-Host '  - http://localhost:5246' -ForegroundColor White;
Write-Host '  - http://${ip}:5246' -ForegroundColor White;
Write-Host '';
Write-Host 'Iniciando servidor...' -ForegroundColor Yellow;
Write-Host '';
dotnet run --project SistemaChamados.csproj --urls 'http://0.0.0.0:5246';
Write-Host '';
Write-Host 'API encerrada. Pressione qualquer tecla para fechar...' -ForegroundColor Yellow;
`$null = `$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
"@

Start-Process powershell -ArgumentList "-NoExit", "-Command", $command

Write-Host "[OK] API iniciada em nova janela!" -ForegroundColor Green
Write-Host ""

# Aguardar inicialização
Write-Host "[*] Aguardando inicializacao da API (15 segundos)..." -ForegroundColor Yellow
for ($i = 15; $i -gt 0; $i--) {
    Write-Host "   $i..." -NoNewline -ForegroundColor Gray
    Start-Sleep -Seconds 1
    if ($i % 5 -eq 0) { Write-Host "" }
}
Write-Host ""
Write-Host ""

# Testar conectividade
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    TESTANDO CONECTIVIDADE" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# Teste 1 - Localhost
Write-Host "[*] Teste 1: Acesso local (localhost)" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5246/api/categorias" -TimeoutSec 5 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "[OK] Localhost funcionando! (Status: $($response.StatusCode))" -ForegroundColor Green
    }
} catch {
    Write-Host "[X] Falha no acesso local" -ForegroundColor Red
    Write-Host "   Erro: $($_.Exception.Message)" -ForegroundColor Gray
}

Write-Host ""

# Teste 2 - IP da rede
Write-Host "[*] Teste 2: Acesso pela rede ($ip)" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://${ip}:5246/api/categorias" -TimeoutSec 5 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "[OK] Acesso pela rede funcionando! (Status: $($response.StatusCode))" -ForegroundColor Green
    }
} catch {
    Write-Host "[X] Falha no acesso pela rede" -ForegroundColor Red
    Write-Host "   Erro: $($_.Exception.Message)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "[!] SOLUCAO:" -ForegroundColor Yellow
    Write-Host "   1. Execute como Administrador: .\ConfigurarFirewall.ps1" -ForegroundColor Cyan
    Write-Host "   2. Reinicie este script" -ForegroundColor White
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Green
Write-Host "    API RODANDO!" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "URLs para teste:" -ForegroundColor Cyan
Write-Host "  - Do PC: http://localhost:5246/api/categorias" -ForegroundColor White
Write-Host "  - Do Celular: http://${ip}:5246/api/categorias" -ForegroundColor White
Write-Host ""
Write-Host "A janela da API permanecera aberta em segundo plano." -ForegroundColor Gray
Write-Host "Para encerrar, feche a janela do PowerShell da API." -ForegroundColor Gray
Write-Host ""
