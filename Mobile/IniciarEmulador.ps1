# Script para inicializar emulador Android via Visual Studio

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INICIALIZAR EMULADOR ANDROID" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "OPÇÃO 1: VIA VISUAL STUDIO (RECOMENDADO)" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Abra o Visual Studio 2022" -ForegroundColor White
Write-Host "2. Abra a solução: sistema-chamados-faculdade.sln" -ForegroundColor Gray
Write-Host "3. Defina 'SistemaChamados.Mobile' como projeto de inicialização" -ForegroundColor Gray
Write-Host "   (Clique direito no projeto > Definir como Projeto de Inicialização)" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Na barra de ferramentas superior, procure o dropdown de dispositivos" -ForegroundColor Gray
Write-Host "   (ao lado do botão verde de Play)" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Clique no dropdown e selecione:" -ForegroundColor Gray
Write-Host "   - Um emulador Android existente, OU" -ForegroundColor Gray
Write-Host "   - 'Android Emulator' > 'Create New Emulator...'" -ForegroundColor Gray
Write-Host ""
Write-Host "6. Se criar novo emulador:" -ForegroundColor Gray
Write-Host "   - Escolha um dispositivo (ex: Pixel 5)" -ForegroundColor Gray
Write-Host "   - Escolha API Level 33 ou superior (Android 13+)" -ForegroundColor Gray
Write-Host "   - Clique em 'Create'" -ForegroundColor Gray
Write-Host ""
Write-Host "7. Com o emulador selecionado, pressione F5 ou clique no botão Play" -ForegroundColor Gray
Write-Host ""
Write-Host "O Visual Studio irá:" -ForegroundColor Cyan
Write-Host "  ✅ Iniciar o emulador automaticamente" -ForegroundColor Green
Write-Host "  ✅ Compilar o projeto" -ForegroundColor Green
Write-Host "  ✅ Instalar o APK" -ForegroundColor Green
Write-Host "  ✅ Executar o aplicativo" -ForegroundColor Green
Write-Host "  ✅ Anexar o debugger" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "OPÇÃO 2: VIA ANDROID STUDIO" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Se você tem Android Studio instalado:" -ForegroundColor White
Write-Host ""
Write-Host "1. Abra o Android Studio" -ForegroundColor Gray
Write-Host "2. Menu: Tools > AVD Manager" -ForegroundColor Gray
Write-Host "3. Clique no botão Play (▶️) do emulador desejado" -ForegroundColor Gray
Write-Host "4. Aguarde o emulador inicializar (pode levar 1-2 minutos)" -ForegroundColor Gray
Write-Host ""
Write-Host "Depois que o emulador estiver rodando:" -ForegroundColor Cyan
Write-Host "  - Volte para este terminal" -ForegroundColor Gray
Write-Host "  - Execute: .\Executar.ps1" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "OPÇÃO 3: DISPOSITIVO FÍSICO (MAIS RÁPIDO)" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Se você tem um smartphone Android:" -ForegroundColor White
Write-Host ""
Write-Host "1. Ative as Opções do Desenvolvedor:" -ForegroundColor Gray
Write-Host "   Configurações > Sobre o telefone > Toque 7x em 'Número da compilação'" -ForegroundColor DarkGray
Write-Host ""
Write-Host "2. Ative a Depuração USB:" -ForegroundColor Gray
Write-Host "   Configurações > Sistema > Opções do desenvolvedor > Depuração USB" -ForegroundColor DarkGray
Write-Host ""
Write-Host "3. Conecte o cabo USB ao computador" -ForegroundColor Gray
Write-Host ""
Write-Host "4. No telefone, aceite a permissão 'Permitir depuração USB'" -ForegroundColor Gray
Write-Host ""
Write-Host "5. No Visual Studio, o dispositivo aparecerá no dropdown" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "VERIFICAR EMULADORES DISPONÍVEIS:" -ForegroundColor Yellow
Write-Host ""

# Tentar encontrar adb
$adbPaths = @(
    "C:\Program Files (x86)\Android\android-sdk\platform-tools\adb.exe",
    "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk\platform-tools\adb.exe",
    "C:\Android\sdk\platform-tools\adb.exe"
)

$adbFound = $null
foreach($path in $adbPaths) {
    if(Test-Path $path) {
        $adbFound = $path
        break
    }
}

if($adbFound) {
    Write-Host "Executando: adb devices" -ForegroundColor Gray
    Write-Host ""
    & $adbFound devices
    Write-Host ""
    Write-Host "Se aparecer 'List of devices attached' vazio:" -ForegroundColor Cyan
    Write-Host "  ➜ Nenhum dispositivo/emulador conectado" -ForegroundColor Gray
    Write-Host "  ➜ Inicie um emulador usando uma das opções acima" -ForegroundColor Gray
} else {
    Write-Host "⚠️  ADB não encontrado - use Visual Studio para iniciar emulador" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RECOMENDAÇÃO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ MELHOR OPÇÃO: Visual Studio 2022" -ForegroundColor Green
Write-Host ""
Write-Host "   1. Abra Visual Studio 2022" -ForegroundColor White
Write-Host "   2. Abra sistema-chamados-faculdade.sln" -ForegroundColor White
Write-Host "   3. Pressione F5" -ForegroundColor White
Write-Host ""
Write-Host "   Tudo será feito automaticamente! 🚀" -ForegroundColor Cyan
Write-Host ""
