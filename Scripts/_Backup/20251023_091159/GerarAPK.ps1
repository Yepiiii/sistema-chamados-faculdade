# ========================================
# Script para Gerar APK do Sistema de Chamados
# ========================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Gerador de APK - Sistema de Chamados" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Detectar caminhos relativos
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir

# Caminho do projeto mobile
$projectPath = Join-Path $repoRoot "Mobile"
$outputPath = Join-Path $repoRoot "APK"

# Verificar se projeto existe
if (!(Test-Path $projectPath)) {
    Write-Host "[ERRO] Projeto mobile nao encontrado!" -ForegroundColor Red
    exit 1
}

# Criar pasta de output
if (!(Test-Path $outputPath)) {
    Write-Host "[INFO] Criando pasta de output..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $outputPath | Out-Null
}

Write-Host "[1/4] Limpando build anterior..." -ForegroundColor Yellow
Set-Location $projectPath
dotnet clean -c Release -f net8.0-android | Out-Null

Write-Host "[2/4] Restaurando pacotes..." -ForegroundColor Yellow
dotnet restore | Out-Null

Write-Host "[3/4] Compilando APK (isso pode demorar alguns minutos)..." -ForegroundColor Yellow
Write-Host ""

# Build do APK
dotnet build -c Release -f net8.0-android

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[ERRO] Falha na compilacao do APK!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[4/4] Localizando APK gerado..." -ForegroundColor Yellow

# Procurar pelo APK
$apkPath = Get-ChildItem -Path "$projectPath\bin\Release\net8.0-android" -Filter "*.apk" -Recurse | Select-Object -First 1

if ($null -eq $apkPath) {
    Write-Host "[ERRO] APK nao encontrado!" -ForegroundColor Red
    Write-Host "[INFO] Procurando em: $projectPath\bin\Release\net8.0-android" -ForegroundColor Yellow
    exit 1
}

# Copiar APK para pasta de output
$apkFileName = "SistemaChamados-v1.0.apk"
$destPath = Join-Path $outputPath $apkFileName

Write-Host "[INFO] Copiando APK para: $destPath" -ForegroundColor Yellow
Copy-Item $apkPath.FullName -Destination $destPath -Force

# Informações do APK
$apkSize = [math]::Round((Get-Item $destPath).Length / 1MB, 2)

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  APK GERADO COM SUCESSO!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Localizacao: $destPath" -ForegroundColor Cyan
Write-Host "Tamanho: $apkSize MB" -ForegroundColor Cyan
Write-Host "Versao: 1.0" -ForegroundColor Cyan
Write-Host "Package: com.sistemachamados.mobile" -ForegroundColor Cyan
Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  COMO INSTALAR NO ANDROID" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Copie o APK para seu dispositivo Android" -ForegroundColor White
Write-Host "2. Ative 'Fontes desconhecidas' nas configuracoes" -ForegroundColor White
Write-Host "3. Abra o APK no dispositivo e clique em 'Instalar'" -ForegroundColor White
Write-Host ""
Write-Host "IMPORTANTE: Configure o IP da API em appsettings.json" -ForegroundColor Red
Write-Host "antes de compilar, usando o IP da rede local." -ForegroundColor Red
Write-Host ""
Write-Host "Pressione qualquer tecla para abrir a pasta do APK..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Abrir pasta do APK
explorer.exe $outputPath
