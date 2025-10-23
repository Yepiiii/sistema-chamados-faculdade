# ==============================================================================
# Script: GerarAPK.ps1
# Descricao: Gera o APK do aplicativo mobile Sistema de Chamados
# Autor: Sistema
# Data: 23/10/2025
# ==============================================================================

$ErrorActionPreference = "Stop"

# ==============================================================================
# CONFIGURACOES
# ==============================================================================
$ProjetoMobile = "Mobile\SistemaChamados.Mobile.csproj"
$Configuracao = "Release"
$Framework = "net8.0-android"
$PastaOutput = "Mobile\bin\Release\net8.0-android"

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "           GERADOR DE APK - Sistema de Chamados" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# ==============================================================================
# VERIFICACOES INICIAIS
# ==============================================================================
Write-Host "[*] Verificando ambiente..." -ForegroundColor Yellow

# Verificar se o projeto existe
if (-not (Test-Path $ProjetoMobile)) {
    Write-Host "[X] ERRO: Projeto Mobile nao encontrado em '$ProjetoMobile'" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Projeto encontrado" -ForegroundColor Green

# Verificar dotnet
try {
    $dotnetVersion = dotnet --version
    Write-Host "[OK] .NET SDK: $dotnetVersion" -ForegroundColor Green
} catch {
    Write-Host "[X] ERRO: .NET SDK nao encontrado. Instale o .NET 8 SDK" -ForegroundColor Red
    exit 1
}

# Verificar workload MAUI
Write-Host ""
Write-Host "[*] Verificando workload MAUI..." -ForegroundColor Yellow
$workloads = dotnet workload list 2>&1
if ($workloads -match "maui") {
    Write-Host "[OK] MAUI workload instalado" -ForegroundColor Green
} else {
    Write-Host "[!] MAUI workload nao encontrado" -ForegroundColor Red
    Write-Host "   Instalando MAUI workload..." -ForegroundColor Yellow
    dotnet workload install maui
    Write-Host "[OK] MAUI workload instalado" -ForegroundColor Green
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "           LIMPANDO BUILD ANTERIOR" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan

# Limpar builds anteriores
Write-Host ""
Write-Host "[*] Limpando projeto..." -ForegroundColor Yellow
dotnet clean $ProjetoMobile -c $Configuracao -f $Framework
Write-Host "[OK] Projeto limpo" -ForegroundColor Green

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "           RESTAURANDO DEPENDENCIAS" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "[*] Restaurando pacotes NuGet..." -ForegroundColor Yellow
dotnet restore $ProjetoMobile
Write-Host "[OK] Pacotes restaurados" -ForegroundColor Green

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "           COMPILANDO APLICATIVO (RELEASE)" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "[*] Compilando para Android (Release)..." -ForegroundColor Yellow
Write-Host "   Framework: $Framework" -ForegroundColor Gray
Write-Host "   Configuracao: $Configuracao" -ForegroundColor Gray
Write-Host ""

# Compilar o projeto
dotnet build $ProjetoMobile `
    -c $Configuracao `
    -f $Framework `
    /p:AndroidPackageFormat=apk `
    /p:AndroidEnableProfiledAot=false `
    /p:AndroidUseAapt2=true

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[X] ERRO: Falha na compilacao" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[OK] Compilacao concluida com sucesso!" -ForegroundColor Green

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "           PUBLICANDO APK" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "[*] Gerando APK final..." -ForegroundColor Yellow

# Publicar o APK
dotnet publish $ProjetoMobile `
    -c $Configuracao `
    -f $Framework `
    /p:AndroidPackageFormat=apk `
    /p:AndroidEnableProfiledAot=false `
    /p:AndroidUseAapt2=true

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[X] ERRO: Falha ao publicar APK" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[OK] APK publicado com sucesso!" -ForegroundColor Green

# ==============================================================================
# LOCALIZAR APK GERADO
# ==============================================================================
Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "           LOCALIZANDO APK" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# Procurar APK nas pastas de output
$pastasBusca = @(
    "Mobile\bin\Release\net8.0-android",
    "Mobile\bin\Release\net8.0-android\publish"
)

$apksEncontrados = @()

foreach ($pasta in $pastasBusca) {
    if (Test-Path $pasta) {
        $apks = Get-ChildItem -Path $pasta -Filter "*.apk" -Recurse -File
        foreach ($apk in $apks) {
            $apksEncontrados += $apk
        }
    }
}

if ($apksEncontrados.Count -eq 0) {
    Write-Host "[X] Nenhum APK encontrado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "[*] Procurei em:" -ForegroundColor Yellow
    foreach ($pasta in $pastasBusca) {
        Write-Host "   - $pasta" -ForegroundColor Gray
    }
    exit 1
}

# ==============================================================================
# EXIBIR RESULTADOS
# ==============================================================================
Write-Host ""
Write-Host "==================================================================" -ForegroundColor Green
Write-Host "           APK GERADO COM SUCESSO!" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green
Write-Host ""

foreach ($apk in $apksEncontrados) {
    $tamanhoMB = [math]::Round($apk.Length / 1MB, 2)
    
    Write-Host "APK: $($apk.Name)" -ForegroundColor Cyan
    Write-Host "   Local: $($apk.Directory)" -ForegroundColor White
    Write-Host "   Tamanho: $tamanhoMB MB" -ForegroundColor White
    Write-Host "   Data: $($apk.LastWriteTime)" -ForegroundColor White
    Write-Host ""
}

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "           PROXIMOS PASSOS" -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[*] Para instalar no dispositivo Android:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   1. Conecte o dispositivo via USB" -ForegroundColor White
Write-Host "   2. Ative 'Depuracao USB' nas Opcoes do Desenvolvedor" -ForegroundColor White
Write-Host "   3. Execute o comando:" -ForegroundColor White
Write-Host ""

$primeiroAPK = $apksEncontrados[0]
Write-Host "      adb install `"$($primeiroAPK.FullName)`"" -ForegroundColor Cyan
Write-Host ""

Write-Host "   OU" -ForegroundColor Yellow
Write-Host ""
Write-Host "   1. Copie o APK para o dispositivo (email, WhatsApp, etc.)" -ForegroundColor White
Write-Host "   2. Abra o APK no dispositivo" -ForegroundColor White
Write-Host "   3. Permita instalacao de fontes desconhecidas" -ForegroundColor White
Write-Host ""

Write-Host "==================================================================" -ForegroundColor Green
Write-Host "           PROCESSO CONCLUIDO!" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green
Write-Host ""

# Abrir pasta do APK no Explorer
Write-Host "[*] Abrindo pasta do APK..." -ForegroundColor Yellow
Start-Process explorer.exe -ArgumentList "/select,`"$($primeiroAPK.FullName)`""
