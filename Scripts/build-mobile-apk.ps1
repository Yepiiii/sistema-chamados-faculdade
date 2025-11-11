# Build Mobile APK
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  GERANDO APK DO MOBILE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = $PSScriptRoot
$projectRoot = Split-Path $scriptDir -Parent
$mobilePath = Join-Path $projectRoot "Mobile"

if (-not (Test-Path $mobilePath)) {
    Write-Host "ERRO: Pasta Mobile nao encontrada!" -ForegroundColor Red
    Read-Host "Pressione ENTER"
    exit
}

Set-Location $mobilePath
Write-Host "Pasta Mobile: $mobilePath" -ForegroundColor Green
Write-Host ""

Write-Host "Limpando builds anteriores..." -ForegroundColor Yellow
dotnet clean -c Release

Write-Host ""
Write-Host "Compilando APK em modo Release..." -ForegroundColor Green
Write-Host "Isso pode levar alguns minutos. Aguarde..." -ForegroundColor Yellow
Write-Host ""

dotnet publish -f net8.0-android -c Release

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  COMPILACAO BEM-SUCEDIDA!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    Set-Location $projectRoot
    
    $apkPath = Get-ChildItem -Path "Mobile\bin\Release\net8.0-android" -Filter "*.apk" -Recurse | Select-Object -First 1
    
    if ($apkPath) {
        $apkFolder = Join-Path $projectRoot "APK\builds"
        $dest = Join-Path $apkFolder $apkPath.Name
        
        Copy-Item $apkPath.FullName -Destination $dest -Force
        
        Write-Host "APK copiado para:" -ForegroundColor Cyan
        Write-Host $dest -ForegroundColor White
        Write-Host ""
        Write-Host "Tamanho: $([math]::Round($apkPath.Length / 1MB, 2)) MB" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "  PROXIMOS PASSOS:" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "1. Transfira o APK para seu celular Android" -ForegroundColor Yellow
        Write-Host "2. Instale o APK no dispositivo" -ForegroundColor Yellow
        Write-Host "3. Certifique-se que o Backend esta em:" -ForegroundColor Yellow
        Write-Host "   http://192.168.1.6:5246/api/" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host "ERRO: APK nao encontrado!" -ForegroundColor Red
    }
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  ERRO NA COMPILACAO!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
}

Write-Host ""
Read-Host "Pressione ENTER para sair"
