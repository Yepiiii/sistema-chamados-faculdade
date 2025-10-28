# ========================================
# Script: Copiar Mobile Completo
# ========================================
# Copia o projeto mobile completo do Desktop para guinrb-develop

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " COPIANDO MOBILE COMPLETO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "" -ForegroundColor White

$mobileSource = "C:\Users\opera\OneDrive\Área de Trabalho\BACKUP_PROJETO_COMPLETO_20251022_113512\Mobile"
$mobileTarget = "SistemaChamados.Mobile"

# 1. Verificar se mobile completo existe
Write-Host "1. Verificando projeto mobile completo..." -ForegroundColor Yellow
if (Test-Path $mobileSource) {
    Write-Host "   OK Mobile encontrado!" -ForegroundColor Green
    
    # Verificar se tem .csproj
    if (Test-Path "$mobileSource\SistemaChamados.Mobile.csproj") {
        Write-Host "   OK Projeto COMPLETO (.csproj encontrado)" -ForegroundColor Green
    } else {
        Write-Host "   ERRO: .csproj nao encontrado!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "   ERRO: Mobile nao encontrado em: $mobileSource" -ForegroundColor Red
    exit 1
}

# 2. Remover mobile incompleto se existir
Write-Host "`n2. Limpando mobile anterior..." -ForegroundColor Yellow
if (Test-Path $mobileTarget) {
    Write-Host "   Removendo versao anterior..." -ForegroundColor Gray
    Remove-Item $mobileTarget -Recurse -Force
}
Write-Host "   OK!" -ForegroundColor Green

# 3. Copiar projeto completo
Write-Host "`n3. Copiando projeto mobile completo..." -ForegroundColor Yellow
Copy-Item $mobileSource $mobileTarget -Recurse
Write-Host "   OK Copiado!" -ForegroundColor Green

# 4. Verificar estrutura copiada
Write-Host "`n4. Verificando estrutura..." -ForegroundColor Yellow
$estrutura = @{
    "Services" = "Services/"
    "Models" = "Models/"
    "Helpers" = "Helpers/"
    "ViewModels" = "ViewModels/"
    "Views" = "Views/"
    "App.xaml" = ""
    "MauiProgram.cs" = ""
    "SistemaChamados.Mobile.csproj" = ""
}

$todosOk = $true
foreach ($item in $estrutura.Keys) {
    $caminho = Join-Path $mobileTarget ($estrutura[$item] + $item)
    if (Test-Path $caminho) {
        Write-Host "   OK $item" -ForegroundColor Green
    } else {
        Write-Host "   ERRO: $item nao encontrado" -ForegroundColor Red
        $todosOk = $false
    }
}

if (-not $todosOk) {
    Write-Host "`n   AVISO: Alguns arquivos nao foram encontrados" -ForegroundColor Yellow
}

# 5. Verificar configuracao da API
Write-Host "`n5. Verificando configuracao da API..." -ForegroundColor Yellow
$constantsFile = Join-Path $mobileTarget "Helpers\Constants.cs"

if (Test-Path $constantsFile) {
    $constants = Get-Content $constantsFile -Raw
    
    if ($constants -match 'BaseUrlAndroidEmulator.*5246') {
        Write-Host "   OK Porta 5246 configurada (backend GuiNRB)" -ForegroundColor Green
    } else {
        Write-Host "   AVISO: Porta pode precisar ser ajustada" -ForegroundColor Yellow
    }
} else {
    Write-Host "   AVISO: Constants.cs nao encontrado" -ForegroundColor Yellow
}

# 6. Adicionar ao solution
Write-Host "`n6. Adicionando ao solution..." -ForegroundColor Yellow
$slnFile = "sistema-chamados-faculdade.sln"

if (Test-Path $slnFile) {
    $slnContent = Get-Content $slnFile -Raw
    
    if ($slnContent -notmatch "SistemaChamados\.Mobile") {
        Write-Host "   Adicionando ao solution..." -ForegroundColor Gray
        dotnet sln add "$mobileTarget\SistemaChamados.Mobile.csproj" 2>$null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   OK Adicionado!" -ForegroundColor Green
        } else {
            Write-Host "   AVISO: Adicione manualmente:" -ForegroundColor Yellow
            Write-Host "   dotnet sln add SistemaChamados.Mobile\SistemaChamados.Mobile.csproj" -ForegroundColor Cyan
        }
    } else {
        Write-Host "   Mobile ja esta no solution" -ForegroundColor Gray
    }
}

# 7. Verificar pacotes NuGet
Write-Host "`n7. Verificando pacotes NuGet..." -ForegroundColor Yellow
$csprojFile = Join-Path $mobileTarget "SistemaChamados.Mobile.csproj"

if (Test-Path $csprojFile) {
    $csproj = Get-Content $csprojFile -Raw
    
    $pacotesEssenciais = @(
        "Microsoft.Maui.Controls",
        "CommunityToolkit.Mvvm",
        "Newtonsoft.Json"
    )
    
    foreach ($pacote in $pacotesEssenciais) {
        if ($csproj -match $pacote) {
            Write-Host "   OK $pacote" -ForegroundColor Green
        } else {
            Write-Host "   AVISO: $pacote nao encontrado" -ForegroundColor Yellow
        }
    }
}

# 8. Resumo final
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " MOBILE COMPLETO COPIADO!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "" -ForegroundColor White

Write-Host "LOCALIZACAO:" -ForegroundColor Yellow
Write-Host "  .\$mobileTarget" -ForegroundColor White
Write-Host "" -ForegroundColor White

Write-Host "CONFIGURACAO:" -ForegroundColor Yellow
Write-Host "  Backend URL: http://localhost:5246 (Windows)" -ForegroundColor White
Write-Host "  Backend URL: http://10.0.2.2:5246 (Android Emulador)" -ForegroundColor White
Write-Host "" -ForegroundColor White

Write-Host "ESTRUTURA:" -ForegroundColor Yellow
Write-Host "  OK Services/ (Api, Auth, Categorias, Chamados, etc)" -ForegroundColor Green
Write-Host "  OK Models/ (DTOs)" -ForegroundColor Green
Write-Host "  OK Helpers/ (Constants, Settings)" -ForegroundColor Green
Write-Host "  OK ViewModels/" -ForegroundColor Green
Write-Host "  OK Views/" -ForegroundColor Green
Write-Host "" -ForegroundColor White

Write-Host "PROXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "  1. Iniciar backend: dotnet run" -ForegroundColor White
Write-Host "  2. Aguardar ~10 segundos" -ForegroundColor White
Write-Host "  3. Testar mobile:" -ForegroundColor White
Write-Host "     cd SistemaChamados.Mobile" -ForegroundColor Cyan
Write-Host "     dotnet build -t:Run -f net8.0-android" -ForegroundColor Cyan
Write-Host "" -ForegroundColor White

Write-Host "OU use o script completo:" -ForegroundColor Yellow
Write-Host "  .\IniciarAmbienteMobile.ps1" -ForegroundColor Cyan
Write-Host "" -ForegroundColor White

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "" -ForegroundColor White
