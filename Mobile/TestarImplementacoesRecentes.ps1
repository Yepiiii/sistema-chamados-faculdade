#!/usr/bin/env pwsh
# Script para testar todas as implementações recentes do sistema mobile
# Timeline, Comentários, Upload de Arquivos, Polling e Notificações

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TESTE DE IMPLEMENTAÇÕES RECENTES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se estamos no diretório correto
$currentDir = Get-Location
if (-not (Test-Path "SistemaChamados.Mobile.csproj")) {
    Write-Host "❌ ERRO: Execute este script no diretório SistemaChamados.Mobile" -ForegroundColor Red
    exit 1
}

Write-Host "📋 CHECKLIST DE IMPLEMENTAÇÕES:" -ForegroundColor Yellow
Write-Host ""
Write-Host "✅ 1. Timeline de Histórico (HistoricoItemDto)" -ForegroundColor Green
Write-Host "✅ 2. Thread de Comentários (ComentarioDto + ComentarioService)" -ForegroundColor Green
Write-Host "✅ 3. Upload de Imagens/Arquivos (AnexoDto + AnexoService)" -ForegroundColor Green
Write-Host "✅ 4. Polling Service (Timer 5 min)" -ForegroundColor Green
Write-Host "✅ 5. Notificações Locais Android (NotificationService)" -ForegroundColor Green
Write-Host ""

# Verificar arquivos críticos
Write-Host "🔍 VERIFICANDO ARQUIVOS CRÍTICOS..." -ForegroundColor Cyan
Write-Host ""

$criticalFiles = @(
    @{ Path = "Models\DTOs\HistoricoItemDto.cs"; Feature = "Timeline de Histórico" },
    @{ Path = "Models\DTOs\ComentarioDto.cs"; Feature = "Thread de Comentários" },
    @{ Path = "Services\Comentarios\ComentarioService.cs"; Feature = "Thread de Comentários" },
    @{ Path = "Models\DTOs\AnexoDto.cs"; Feature = "Upload de Arquivos" },
    @{ Path = "Services\Anexos\AnexoService.cs"; Feature = "Upload de Arquivos" },
    @{ Path = "Models\DTOs\AtualizacaoDto.cs"; Feature = "Polling" },
    @{ Path = "Services\Polling\PollingService.cs"; Feature = "Polling" },
    @{ Path = "Services\Notifications\INotificationService.cs"; Feature = "Notificações" },
    @{ Path = "Platforms\Android\NotificationService.cs"; Feature = "Notificações Android" },
    @{ Path = "Platforms\Android\Resources\drawable\notification_icon.xml"; Feature = "Ícone de Notificação" },
    @{ Path = "POLLING_NOTIFICATIONS_GUIDE.md"; Feature = "Documentação" }
)

$allFilesExist = $true
foreach ($file in $criticalFiles) {
    if (Test-Path $file.Path) {
        Write-Host "  ✅ $($file.Feature): $($file.Path)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $($file.Feature): $($file.Path) NÃO ENCONTRADO" -ForegroundColor Red
        $allFilesExist = $false
    }
}

if (-not $allFilesExist) {
    Write-Host ""
    Write-Host "❌ Alguns arquivos críticos estão faltando!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🔧 VERIFICANDO PERMISSÕES NO ANDROIDMANIFEST..." -ForegroundColor Cyan

$manifestPath = "Platforms\Android\AndroidManifest.xml"
if (Test-Path $manifestPath) {
    $manifestContent = Get-Content $manifestPath -Raw
    
    $permissions = @(
        "POST_NOTIFICATIONS",
        "VIBRATE",
        "INTERNET",
        "ACCESS_NETWORK_STATE"
    )
    
    $allPermissionsPresent = $true
    foreach ($perm in $permissions) {
        if ($manifestContent -match $perm) {
            Write-Host "  ✅ Permissão $perm encontrada" -ForegroundColor Green
        } else {
            Write-Host "  ❌ Permissão $perm FALTANDO" -ForegroundColor Red
            $allPermissionsPresent = $false
        }
    }
    
    if (-not $allPermissionsPresent) {
        Write-Host ""
        Write-Host "⚠️  Algumas permissões estão faltando no AndroidManifest.xml" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ❌ AndroidManifest.xml não encontrado!" -ForegroundColor Red
}

Write-Host ""
Write-Host "🏗️  LIMPANDO E COMPILANDO PROJETO..." -ForegroundColor Cyan
Write-Host ""

# Limpar build anterior
Write-Host "  🧹 Limpando builds anteriores..." -ForegroundColor Yellow
dotnet clean -v quiet

# Build do projeto
Write-Host "  🔨 Compilando projeto Android..." -ForegroundColor Yellow
$buildResult = dotnet build -f net8.0-android -v minimal 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ ERRO NA COMPILAÇÃO!" -ForegroundColor Red
    Write-Host ""
    Write-Host $buildResult
    exit 1
}

Write-Host "  ✅ Compilação bem-sucedida!" -ForegroundColor Green
Write-Host ""

# Verificar dispositivos Android conectados
Write-Host "📱 VERIFICANDO DISPOSITIVOS ANDROID..." -ForegroundColor Cyan
Write-Host ""

$adbPath = "adb"
try {
    $devices = & $adbPath devices 2>&1 | Select-String -Pattern "device$" -NotMatch "List"
    
    if ($devices) {
        Write-Host "  ✅ Dispositivos encontrados:" -ForegroundColor Green
        & $adbPath devices
    } else {
        Write-Host "  ⚠️  Nenhum dispositivo Android conectado" -ForegroundColor Yellow
        Write-Host "     - Conecte um dispositivo via USB ou" -ForegroundColor Yellow
        Write-Host "     - Inicie um emulador Android" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ⚠️  ADB não encontrado no PATH" -ForegroundColor Yellow
    Write-Host "     Certifique-se de ter Android SDK instalado" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INSTRUÇÕES DE TESTE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "🎯 PARA INICIAR OS TESTES:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. INICIAR API BACKEND:" -ForegroundColor White
Write-Host "   cd ..\sistema-chamados-faculdade" -ForegroundColor Gray
Write-Host "   .\IniciarAPIMobile.ps1" -ForegroundColor Gray
Write-Host ""

Write-Host "2. EXECUTAR APP MOBILE:" -ForegroundColor White
Write-Host "   dotnet build -f net8.0-android && dotnet run -f net8.0-android" -ForegroundColor Gray
Write-Host ""

Write-Host "3. TESTAR FUNCIONALIDADES:" -ForegroundColor White
Write-Host ""
Write-Host "   📝 TIMELINE DE HISTÓRICO:" -ForegroundColor Cyan
Write-Host "      - Abra um chamado existente" -ForegroundColor Gray
Write-Host "      - Role até a seção 'Histórico'" -ForegroundColor Gray
Write-Host "      - Verifique eventos cronológicos" -ForegroundColor Gray
Write-Host ""

Write-Host "   💬 THREAD DE COMENTÁRIOS:" -ForegroundColor Cyan
Write-Host "      - Na tela de detalhes do chamado" -ForegroundColor Gray
Write-Host "      - Role até 'Comentários'" -ForegroundColor Gray
Write-Host "      - Digite um comentário e envie" -ForegroundColor Gray
Write-Host "      - Verifique se aparece na lista" -ForegroundColor Gray
Write-Host ""

Write-Host "   📷 UPLOAD DE ARQUIVOS:" -ForegroundColor Cyan
Write-Host "      - Em 'Novo Chamado' ou 'Detalhes'" -ForegroundColor Gray
Write-Host "      - Toque no botão 'Câmera' ou 'Galeria'" -ForegroundColor Gray
Write-Host "      - Selecione uma imagem" -ForegroundColor Gray
Write-Host "      - Verifique thumbnail na galeria" -ForegroundColor Gray
Write-Host ""

Write-Host "   🔔 POLLING E NOTIFICAÇÕES:" -ForegroundColor Cyan
Write-Host "      - Conceda permissão de notificações (Android 13+)" -ForegroundColor Gray
Write-Host "      - Aguarde 5 minutos OU force atualização" -ForegroundColor Gray
Write-Host "      - Verifique notificação na barra de status" -ForegroundColor Gray
Write-Host "      - Toque na notificação para abrir chamado" -ForegroundColor Gray
Write-Host ""

Write-Host "4. FORÇAR TESTE DE NOTIFICAÇÃO (MOCK):" -ForegroundColor White
Write-Host "   - Adicione botão temporário no ChamadosListPage.xaml:" -ForegroundColor Gray
Write-Host '   <Button Text="🔔 Simular Notificação"' -ForegroundColor DarkGray
Write-Host '           Command="{Binding TestarNotificacaoCommand}"/>' -ForegroundColor DarkGray
Write-Host ""
Write-Host "   - No ChamadosListViewModel.cs, adicione:" -ForegroundColor Gray
Write-Host '   public ICommand TestarNotificacaoCommand { get; }' -ForegroundColor DarkGray
Write-Host ""
Write-Host "   - No construtor:" -ForegroundColor Gray
Write-Host '   TestarNotificacaoCommand = new Command(() => {' -ForegroundColor DarkGray
Write-Host '       _pollingService.SimularAtualizacao();' -ForegroundColor DarkGray
Write-Host '   });' -ForegroundColor DarkGray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DEBUG E LOGS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📊 MONITORE OS LOGS NO VISUAL STUDIO:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   [ChamadosListViewModel] - Operações da lista" -ForegroundColor Gray
Write-Host "   [ChamadoDetailViewModel] - Timeline, comentários, anexos" -ForegroundColor Gray
Write-Host "   [ComentarioService] - Envio/recebimento de comentários" -ForegroundColor Gray
Write-Host "   [AnexoService] - Upload de arquivos" -ForegroundColor Gray
Write-Host "   [PollingService] - Verificações periódicas" -ForegroundColor Gray
Write-Host "   [NotificationService] - Criação de notificações" -ForegroundColor Gray
Write-Host "   [MainActivity] - Navegação via notificações" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TROUBLESHOOTING" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "❓ SE COMENTÁRIOS NÃO APARECEM:" -ForegroundColor Yellow
Write-Host "   - Verifique log: [ComentarioService] Enviando comentário..." -ForegroundColor Gray
Write-Host "   - Confirme que API está rodando na porta 5246" -ForegroundColor Gray
Write-Host "   - Verifique IP no appsettings.json (192.168.x.x)" -ForegroundColor Gray
Write-Host ""

Write-Host "❓ SE UPLOAD FALHA:" -ForegroundColor Yellow
Write-Host "   - Verifique permissões de câmera/storage" -ForegroundColor Gray
Write-Host "   - Confirme MediaPicker.CapturePhotoAsync() no log" -ForegroundColor Gray
Write-Host "   - Tamanho máximo: 5MB por arquivo" -ForegroundColor Gray
Write-Host ""

Write-Host "❓ SE NOTIFICAÇÕES NÃO APARECEM:" -ForegroundColor Yellow
Write-Host "   - Android 13+: Verifique permissão POST_NOTIFICATIONS" -ForegroundColor Gray
Write-Host "   - Configurações > Apps > Sistema de Chamados > Notificações" -ForegroundColor Gray
Write-Host "   - Veja log: [NotificationService] Exibindo notificação..." -ForegroundColor Gray
Write-Host ""

Write-Host "❓ SE POLLING NÃO DISPARA:" -ForegroundColor Yellow
Write-Host "   - Verifique log: [PollingService] Timer iniciado..." -ForegroundColor Gray
Write-Host "   - Use SimularAtualizacao() para forçar" -ForegroundColor Gray
Write-Host "   - Timer padrão: 5 minutos (300000ms)" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DOCUMENTAÇÃO COMPLETA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📖 Consulte os guias detalhados:" -ForegroundColor Yellow
Write-Host "   - POLLING_NOTIFICATIONS_GUIDE.md (Este diretório)" -ForegroundColor Gray
Write-Host "   - README_MOBILE.md (Overview geral)" -ForegroundColor Gray
Write-Host "   - COMO_TESTAR_MOBILE.md (Testes gerais)" -ForegroundColor Gray
Write-Host ""

Write-Host "✅ SISTEMA PRONTO PARA TESTES!" -ForegroundColor Green
Write-Host ""
Write-Host "Pressione ENTER para iniciar o app mobile..." -ForegroundColor Yellow
Read-Host

# Executar app
Write-Host ""
Write-Host "🚀 Iniciando aplicativo Android..." -ForegroundColor Cyan
Write-Host ""

dotnet run -f net8.0-android
