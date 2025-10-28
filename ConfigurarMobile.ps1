# ========================================
# Script: Copiar e Configurar Mobile
# ========================================
# Copia o projeto mobile e configura para o backend do GuiNRB

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " CONFIGURANDO MOBILE PARA GUINRB-DEVELOP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "" -ForegroundColor White

$mobileSource = "..\SistemaChamados.Mobile"
$mobileTarget = "SistemaChamados.Mobile"

# 1. Verificar se mobile existe
Write-Host "1. Verificando projeto mobile..." -ForegroundColor Yellow
if (Test-Path $mobileSource) {
    Write-Host "   OK Mobile encontrado em: $mobileSource" -ForegroundColor Green
} else {
    Write-Host "   ERRO: Mobile nao encontrado!" -ForegroundColor Red
    Write-Host "   Esperado em: $mobileSource" -ForegroundColor Yellow
    exit 1
}

# 2. Copiar projeto mobile
Write-Host "`n2. Copiando projeto mobile..." -ForegroundColor Yellow
if (Test-Path $mobileTarget) {
    Write-Host "   Mobile ja existe, removendo versao antiga..." -ForegroundColor Gray
    Remove-Item $mobileTarget -Recurse -Force
}

Copy-Item $mobileSource $mobileTarget -Recurse
Write-Host "   OK Copiado!" -ForegroundColor Green

# 3. Verificar porta do backend
Write-Host "`n3. Verificando porta do backend..." -ForegroundColor Yellow
$backendPort = "5246"  # Porta padrão do GuiNRB
Write-Host "   Porta do backend: http://localhost:$backendPort" -ForegroundColor Cyan

# 4. Configurar appsettings.json do mobile
Write-Host "`n4. Configurando appsettings.json do mobile..." -ForegroundColor Yellow
$mobileAppSettings = Join-Path $mobileTarget "appsettings.json"

if (Test-Path $mobileAppSettings) {
    $config = Get-Content $mobileAppSettings -Raw | ConvertFrom-Json
    
    # Atualizar BaseUrl
    if ($config.ApiSettings) {
        $config.ApiSettings.BaseUrl = "http://localhost:$backendPort"
    } else {
        $config | Add-Member -NotePropertyName "ApiSettings" -NotePropertyValue @{
            BaseUrl = "http://localhost:$backendPort"
            Timeout = 30
        }
    }
    
    $config | ConvertTo-Json -Depth 10 | Set-Content $mobileAppSettings
    Write-Host "   OK Configurado!" -ForegroundColor Green
    Write-Host "   BaseUrl: http://localhost:$backendPort" -ForegroundColor Cyan
} else {
    Write-Host "   AVISO: appsettings.json nao encontrado no mobile" -ForegroundColor Yellow
    Write-Host "   Criar manualmente com BaseUrl: http://localhost:$backendPort" -ForegroundColor Yellow
}

# 5. Atualizar helpers/Constants.cs (se existir)
Write-Host "`n5. Verificando Constants.cs..." -ForegroundColor Yellow
$constantsFile = Join-Path $mobileTarget "Helpers\Constants.cs"

if (Test-Path $constantsFile) {
    $constants = Get-Content $constantsFile -Raw
    
    # Atualizar API_BASE_URL
    if ($constants -match 'API_BASE_URL\s*=\s*"[^"]*"') {
        $constants = $constants -replace 'API_BASE_URL\s*=\s*"[^"]*"', "API_BASE_URL = `"http://localhost:$backendPort`""
        $constants | Set-Content $constantsFile
        Write-Host "   OK Constants.cs atualizado!" -ForegroundColor Green
    } else {
        Write-Host "   AVISO: API_BASE_URL nao encontrado em Constants.cs" -ForegroundColor Yellow
    }
} else {
    Write-Host "   Constants.cs nao encontrado (OK se nao for necessario)" -ForegroundColor Gray
}

# 6. Adicionar ao workspace
Write-Host "`n6. Verificando solution..." -ForegroundColor Yellow
$slnFile = "sistema-chamados-faculdade.sln"

if (Test-Path $slnFile) {
    $slnContent = Get-Content $slnFile -Raw
    
    if ($slnContent -notmatch "SistemaChamados\.Mobile") {
        Write-Host "   Adicionando Mobile ao solution..." -ForegroundColor Yellow
        dotnet sln add "$mobileTarget\SistemaChamados.Mobile.csproj" 2>$null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   OK Mobile adicionado ao solution!" -ForegroundColor Green
        } else {
            Write-Host "   AVISO: Nao foi possivel adicionar ao solution automaticamente" -ForegroundColor Yellow
            Write-Host "   Execute manualmente: dotnet sln add SistemaChamados.Mobile\SistemaChamados.Mobile.csproj" -ForegroundColor Cyan
        }
    } else {
        Write-Host "   Mobile ja esta no solution" -ForegroundColor Gray
    }
}

# 7. Resumo
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " CONFIGURACAO CONCLUIDA!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "" -ForegroundColor White

Write-Host "PROJETO MOBILE:" -ForegroundColor Yellow
Write-Host "  Localizacao: .\$mobileTarget" -ForegroundColor White
Write-Host "  Backend URL: http://localhost:$backendPort" -ForegroundColor White
Write-Host "" -ForegroundColor White

Write-Host "PROXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "  1. Iniciar backend: dotnet run" -ForegroundColor White
Write-Host "  2. Aguardar ~10 segundos" -ForegroundColor White
Write-Host "  3. Em outro terminal:" -ForegroundColor White
Write-Host "     cd SistemaChamados.Mobile" -ForegroundColor Cyan
Write-Host "     dotnet build -t:Run -f net8.0-android" -ForegroundColor Cyan
Write-Host "" -ForegroundColor White

Write-Host "OU use o script de inicializacao completo:" -ForegroundColor Yellow
Write-Host "  .\IniciarAmbienteMobile.ps1" -ForegroundColor Cyan
Write-Host "" -ForegroundColor White

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "" -ForegroundColor White
