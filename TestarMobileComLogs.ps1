#!/usr/bin/env pwsh
# Script para testar o app Mobile com logs de debug

Write-Host "`n=== TESTE MOBILE COM LOGS ===" -ForegroundColor Cyan
Write-Host "Este script irá:" -ForegroundColor Yellow
Write-Host "1. Verificar se há emuladores Android disponíveis" -ForegroundColor White
Write-Host "2. Iniciar o emulador (se disponível)" -ForegroundColor White
Write-Host "3. Compilar e rodar o app" -ForegroundColor White
Write-Host "4. Mostrar os logs de debug`n" -ForegroundColor White

# Verificar adb
$adbPath = "C:\Program Files (x86)\Android\android-sdk\platform-tools\adb.exe"
if (-not (Test-Path $adbPath)) {
    $adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
}

if (Test-Path $adbPath) {
    Write-Host "✓ ADB encontrado: $adbPath" -ForegroundColor Green
    
    # Listar emuladores disponíveis
    $emulatorPath = $adbPath -replace "platform-tools\\adb.exe", "emulator\emulator.exe"
    if (Test-Path $emulatorPath) {
        Write-Host "`nEmuladores disponíveis:" -ForegroundColor Cyan
        & $emulatorPath -list-avds
        
        # Perguntar qual usar
        Write-Host "`nVocê tem emulador configurado acima?" -ForegroundColor Yellow
        Write-Host "Se SIM, copie o nome e execute:" -ForegroundColor White
        Write-Host "  & '$emulatorPath' -avd NOME_DO_EMULADOR`n" -ForegroundColor Gray
    } else {
        Write-Host "⚠ Emulator não encontrado em: $emulatorPath" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ ADB não encontrado. Android SDK não está instalado." -ForegroundColor Red
}

Write-Host "`n=== INSTRUÇÕES PARA VER LOGS ===" -ForegroundColor Cyan
Write-Host "Depois que o app estiver rodando no emulador:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Execute este comando em outro terminal:" -ForegroundColor White
Write-Host "   & '$adbPath' logcat -s 'Mono:D' 'DEBUG:D'" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Ou use o Visual Studio:" -ForegroundColor White
Write-Host "   - View → Output" -ForegroundColor Gray
Write-Host "   - Selecione 'Debug' no dropdown" -ForegroundColor Gray
Write-Host ""

# Compilar o projeto
Write-Host "`n=== COMPILANDO PROJETO ===" -ForegroundColor Cyan
Set-Location "c:\Users\opera\sistema-chamados-faculdade\sistema-chamados-faculdade\Mobile"
dotnet build -c Debug

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✓ Build concluído com sucesso!" -ForegroundColor Green
    Write-Host "`nPara executar, use:" -ForegroundColor Yellow
    Write-Host "  dotnet build -f net8.0-android -t:Run" -ForegroundColor White
    Write-Host "`nOu abra no Visual Studio e pressione F5" -ForegroundColor White
} else {
    Write-Host "`n❌ Build falhou" -ForegroundColor Red
}
