# Script de Instalação do APK - Sistema Chamados GuiNRB
# Data: 10/11/2025

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Instalador APK - Sistema Chamados" -ForegroundColor Cyan
Write-Host "  Integração GuiNRB Backend" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Caminho do APK
$apkPath = "$PSScriptRoot\SistemaChamados-GuiNRB-v1.0.apk"

# Verificar se APK existe
if (-not (Test-Path $apkPath)) {
    Write-Host "❌ ERRO: APK não encontrado em:" -ForegroundColor Red
    Write-Host "   $apkPath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Por favor, certifique-se de que o APK está na pasta APK." -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "✅ APK encontrado:" -ForegroundColor Green
Write-Host "   $apkPath" -ForegroundColor Gray
$apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
Write-Host "   Tamanho: $apkSize MB" -ForegroundColor Gray
Write-Host ""

# Verificar se ADB está instalado
Write-Host "🔍 Verificando ADB..." -ForegroundColor Yellow
try {
    $adbVersion = adb version 2>&1 | Select-String "Android Debug Bridge version"
    Write-Host "✅ ADB encontrado: $adbVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ ERRO: ADB não encontrado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Para instalar o ADB:" -ForegroundColor Yellow
    Write-Host "1. Baixar Android Platform Tools:" -ForegroundColor Gray
    Write-Host "   https://developer.android.com/studio/releases/platform-tools" -ForegroundColor Gray
    Write-Host "2. Extrair e adicionar ao PATH do Windows" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Ou usar método alternativo (copiar APK manualmente)" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host ""
Write-Host "🔍 Verificando dispositivos conectados..." -ForegroundColor Yellow

# Listar dispositivos
$devices = adb devices | Select-String -Pattern "device$" | Measure-Object
$deviceCount = $devices.Count

if ($deviceCount -eq 0) {
    Write-Host "❌ Nenhum dispositivo Android conectado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Para conectar seu dispositivo:" -ForegroundColor Yellow
    Write-Host "1. Conectar via USB" -ForegroundColor Gray
    Write-Host "2. Ativar 'Depuração USB' nas Opções do desenvolvedor" -ForegroundColor Gray
    Write-Host "3. Autorizar o computador no dispositivo" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Ou use método alternativo:" -ForegroundColor Yellow
    Write-Host "- Enviar APK por email/Drive e instalar manualmente" -ForegroundColor Gray
    pause
    exit 1
}

Write-Host "✅ Dispositivo(s) encontrado(s):" -ForegroundColor Green
adb devices | Select-String -Pattern "device$" | ForEach-Object { 
    Write-Host "   $_" -ForegroundColor Gray 
}
Write-Host ""

# Menu de opções
Write-Host "Escolha uma opção:" -ForegroundColor Cyan
Write-Host "1. Instalar APK no dispositivo" -ForegroundColor White
Write-Host "2. Copiar APK para /sdcard/Download/" -ForegroundColor White
Write-Host "3. Desinstalar app antigo e instalar novo" -ForegroundColor White
Write-Host "4. Sair" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Digite o número da opção"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "📱 Instalando APK..." -ForegroundColor Yellow
        adb install -r $apkPath
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✅ APK instalado com sucesso!" -ForegroundColor Green
            Write-Host ""
            Write-Host "📋 Próximos passos:" -ForegroundColor Cyan
            Write-Host "1. Iniciar backend GuiNRB (porta 5246)" -ForegroundColor Gray
            Write-Host "2. Abrir app no dispositivo" -ForegroundColor Gray
            Write-Host "3. Fazer login com: usuario@teste.com / senha123" -ForegroundColor Gray
        } else {
            Write-Host ""
            Write-Host "❌ Erro na instalação!" -ForegroundColor Red
            Write-Host "Tente desinstalar o app antigo primeiro (opção 3)" -ForegroundColor Yellow
        }
    }
    
    "2" {
        Write-Host ""
        Write-Host "📁 Copiando APK para dispositivo..." -ForegroundColor Yellow
        adb push $apkPath /sdcard/Download/SistemaChamados.apk
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✅ APK copiado para /sdcard/Download/" -ForegroundColor Green
            Write-Host ""
            Write-Host "📋 Próximos passos:" -ForegroundColor Cyan
            Write-Host "1. Abrir gerenciador de arquivos no dispositivo" -ForegroundColor Gray
            Write-Host "2. Navegar até Download" -ForegroundColor Gray
            Write-Host "3. Tocar em SistemaChamados.apk" -ForegroundColor Gray
            Write-Host "4. Permitir instalação de fontes desconhecidas" -ForegroundColor Gray
            Write-Host "5. Instalar o app" -ForegroundColor Gray
        } else {
            Write-Host ""
            Write-Host "❌ Erro ao copiar APK!" -ForegroundColor Red
        }
    }
    
    "3" {
        Write-Host ""
        Write-Host "🗑️ Desinstalando app antigo..." -ForegroundColor Yellow
        adb uninstall com.sistemachamados.mobile
        
        Start-Sleep -Seconds 2
        
        Write-Host ""
        Write-Host "📱 Instalando APK..." -ForegroundColor Yellow
        adb install $apkPath
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✅ App reinstalado com sucesso!" -ForegroundColor Green
            Write-Host ""
            Write-Host "📋 Próximos passos:" -ForegroundColor Cyan
            Write-Host "1. Iniciar backend GuiNRB (porta 5246)" -ForegroundColor Gray
            Write-Host "2. Abrir app no dispositivo" -ForegroundColor Gray
            Write-Host "3. Fazer login com: usuario@teste.com / senha123" -ForegroundColor Gray
        } else {
            Write-Host ""
            Write-Host "❌ Erro na instalação!" -ForegroundColor Red
        }
    }
    
    "4" {
        Write-Host ""
        Write-Host "👋 Saindo..." -ForegroundColor Yellow
        exit 0
    }
    
    default {
        Write-Host ""
        Write-Host "❌ Opção inválida!" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
pause
