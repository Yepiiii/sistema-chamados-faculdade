# ========================================
# Iniciar API com ngrok (Acesso Remoto)
# ========================================
# Este script inicia a API local e cria um túnel
# ngrok para acesso de qualquer lugar (internet, 4G, etc.)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  API com ngrok - Acesso Remoto" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se ngrok está instalado
$ngrokInstalled = Get-Command ngrok -ErrorAction SilentlyContinue

if (-not $ngrokInstalled) {
    Write-Host "[ERRO] ngrok não está instalado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Instale o ngrok:" -ForegroundColor Yellow
    Write-Host "  1. Acesse: https://ngrok.com/download" -ForegroundColor Cyan
    Write-Host "  2. Baixe e extraia o ngrok.exe" -ForegroundColor Cyan
    Write-Host "  3. Adicione ao PATH ou copie para Scripts/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Ou instale via Chocolatey:" -ForegroundColor Yellow
    Write-Host "  choco install ngrok" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

Write-Host "[OK] ngrok instalado" -ForegroundColor Green
Write-Host ""

# Detectar caminhos
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$backendPath = Join-Path $repoRoot "Backend"

if (-not (Test-Path $backendPath)) {
    Write-Host "[ERRO] Backend não encontrado em: $backendPath" -ForegroundColor Red
    exit 1
}

# Verificar se já existe API rodando
Write-Host "[1/4] Verificando processos..." -ForegroundColor Yellow
$existingDotnet = Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | 
    Where-Object { $_.Path -like "*Backend*" }

if ($existingDotnet) {
    Write-Host "[INFO] Parando API anterior..." -ForegroundColor Yellow
    Stop-Process -Name "dotnet" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

$existingNgrok = Get-Process -Name "ngrok" -ErrorAction SilentlyContinue
if ($existingNgrok) {
    Write-Host "[INFO] Parando ngrok anterior..." -ForegroundColor Yellow
    Stop-Process -Name "ngrok" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

Write-Host "[OK] Processos limpos" -ForegroundColor Green
Write-Host ""

# Compilar projeto
Write-Host "[2/4] Compilando Backend..." -ForegroundColor Yellow
Set-Location $backendPath

$compileOutput = dotnet build -c Release --nologo 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERRO] Falha na compilação!" -ForegroundColor Red
    Write-Host $compileOutput -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Backend compilado" -ForegroundColor Green
Write-Host ""

# Iniciar API em background
Write-Host "[3/4] Iniciando API..." -ForegroundColor Yellow

$apiJob = Start-Job -ScriptBlock {
    param($backendPath)
    Set-Location $backendPath
    dotnet run --no-build --urls="http://localhost:5246"
} -ArgumentList $backendPath

Write-Host "[INFO] Aguardando API inicializar (5s)..." -ForegroundColor Cyan
Start-Sleep -Seconds 5

# Verificar se API está respondendo
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5246/swagger/index.html" -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
    Write-Host "[OK] API iniciada com sucesso" -ForegroundColor Green
} catch {
    Write-Host "[ERRO] API não está respondendo!" -ForegroundColor Red
    Write-Host "[INFO] Verifique os logs:" -ForegroundColor Yellow
    Receive-Job -Job $apiJob
    Stop-Job -Job $apiJob
    Remove-Job -Job $apiJob
    exit 1
}
Write-Host ""

# Iniciar ngrok
Write-Host "[4/4] Criando túnel ngrok..." -ForegroundColor Yellow

$ngrokJob = Start-Job -ScriptBlock {
    ngrok http 5246 --log=stdout
}

Write-Host "[INFO] Aguardando túnel inicializar (3s)..." -ForegroundColor Cyan
Start-Sleep -Seconds 3

# Obter URL pública do ngrok
try {
    $ngrokApi = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" -ErrorAction Stop
    $publicUrl = $ngrokApi.tunnels[0].public_url
    
    if (-not $publicUrl) {
        throw "URL não encontrada"
    }
    
    Write-Host "[OK] Túnel ngrok criado!" -ForegroundColor Green
    Write-Host ""
    
    # Exibir informações
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✅ API ACESSÍVEL DE QUALQUER LUGAR!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "URL Pública (internet, 4G, qualquer rede):" -ForegroundColor Cyan
    Write-Host "  $publicUrl" -ForegroundColor White -BackgroundColor DarkGreen
    Write-Host ""
    Write-Host "Swagger:" -ForegroundColor Cyan
    Write-Host "  $publicUrl/swagger" -ForegroundColor White
    Write-Host ""
    Write-Host "API:" -ForegroundColor Cyan
    Write-Host "  $publicUrl/api/" -ForegroundColor White
    Write-Host ""
    Write-Host "Dashboard ngrok:" -ForegroundColor Cyan
    Write-Host "  http://localhost:4040" -ForegroundColor White
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  📱 CONFIGURAR APP MOBILE" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Execute:" -ForegroundColor White
    Write-Host "  .\ConfigurarIPRemoto.ps1 -Url '$publicUrl'" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host "  🔐 CREDENCIAIS DE TESTE" -ForegroundColor Magenta
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "Administrador:" -ForegroundColor White
    Write-Host "  Email: admin@sistema.com" -ForegroundColor Cyan
    Write-Host "  Senha: Admin@123" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Aluno:" -ForegroundColor White
    Write-Host "  Email: aluno@sistema.com" -ForegroundColor Cyan
    Write-Host "  Senha: Aluno@123" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "⚠️  IMPORTANTE:" -ForegroundColor Yellow
    Write-Host "  - Esta URL é temporária (muda ao reiniciar)" -ForegroundColor Yellow
    Write-Host "  - Não compartilhe publicamente (sem autenticação robusta)" -ForegroundColor Yellow
    Write-Host "  - Ideal para testes e desenvolvimento" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Pressione Ctrl+C para parar API e ngrok" -ForegroundColor White
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Abrir dashboard do ngrok
    Start-Process "http://localhost:4040"
    
    # Manter script rodando
    Write-Host "[INFO] API e ngrok em execução..." -ForegroundColor Cyan
    Write-Host "[INFO] Monitore requisições em: http://localhost:4040" -ForegroundColor Cyan
    Write-Host ""
    
    # Aguardar Ctrl+C
    try {
        while ($true) {
            Start-Sleep -Seconds 5
            
            # Verificar se jobs ainda estão rodando
            if ((Get-Job -Id $apiJob.Id).State -ne "Running") {
                Write-Host "[AVISO] API parou de funcionar!" -ForegroundColor Red
                break
            }
            
            if ((Get-Job -Id $ngrokJob.Id).State -ne "Running") {
                Write-Host "[AVISO] ngrok parou de funcionar!" -ForegroundColor Red
                break
            }
        }
    } finally {
        Write-Host ""
        Write-Host "Parando serviços..." -ForegroundColor Yellow
        Stop-Job -Job $apiJob -ErrorAction SilentlyContinue
        Stop-Job -Job $ngrokJob -ErrorAction SilentlyContinue
        Remove-Job -Job $apiJob -ErrorAction SilentlyContinue
        Remove-Job -Job $ngrokJob -ErrorAction SilentlyContinue
        Write-Host "[OK] Serviços parados" -ForegroundColor Green
    }
    
} catch {
    Write-Host "[ERRO] Falha ao obter URL do ngrok!" -ForegroundColor Red
    Write-Host "[INFO] Verifique se o ngrok está autenticado:" -ForegroundColor Yellow
    Write-Host "  1. Crie conta em: https://dashboard.ngrok.com/signup" -ForegroundColor Cyan
    Write-Host "  2. Copie seu authtoken" -ForegroundColor Cyan
    Write-Host "  3. Execute: ngrok config add-authtoken SEU_TOKEN" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Erro: $_" -ForegroundColor Red
    
    Stop-Job -Job $apiJob -ErrorAction SilentlyContinue
    Stop-Job -Job $ngrokJob -ErrorAction SilentlyContinue
    Remove-Job -Job $apiJob -ErrorAction SilentlyContinue
    Remove-Job -Job $ngrokJob -ErrorAction SilentlyContinue
    exit 1
}
