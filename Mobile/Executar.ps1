Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  EXECUTAR APP ANDROID" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Verificando dispositivos..." -ForegroundColor Yellow
adb devices

Write-Host ""
Write-Host "2. Compilando projeto..." -ForegroundColor Yellow
dotnet build -f net8.0-android

Write-Host ""
Write-Host "3. Instalando APK..." -ForegroundColor Yellow
dotnet build -f net8.0-android -t:Install

Write-Host ""
Write-Host "4. Iniciando app..." -ForegroundColor Yellow
adb shell am start -n "com.companyname.sistemachamados.mobile/crc644e47c3ee01e1e9e6.MainActivity"

Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "  APP INICIADO!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "TESTE O BOTAO DE NOTIFICACAO:" -ForegroundColor Yellow
Write-Host "- Na lista de chamados" -ForegroundColor Gray
Write-Host "- Toque no botao laranja com sino (ao lado do +)" -ForegroundColor Gray
Write-Host "- Puxe a barra de notificacoes" -ForegroundColor Gray
Write-Host ""
